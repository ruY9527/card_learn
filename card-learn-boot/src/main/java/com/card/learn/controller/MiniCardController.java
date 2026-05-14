package com.card.learn.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.common.AppMessages;
import com.card.learn.common.Result;
import com.card.learn.dto.CardAuditDTO;
import com.card.learn.dto.CardCreateDTO;
import com.card.learn.dto.MyCardQueryDTO;
import com.card.learn.entity.BizCardDraft;
import com.card.learn.entity.SysUser;
import com.card.learn.service.IBizCardDraftService;
import com.card.learn.service.ISysUserService;
import com.card.learn.vo.CardAuditVO;
import com.card.learn.vo.MyCardVO;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import com.card.learn.vo.MyCardStatsVO;

import java.util.List;

/**
 * 小程序用户录入卡片控制器（使用临时表）
 */
@RestController
@RequestMapping("/api/miniprogram/card")
@Api(tags = "小程序用户卡片管理")
public class MiniCardController {

    @Autowired
    private IBizCardDraftService draftService;

    @Autowired
    private ISysUserService userService;

    private Long getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            return null;
        }
        String username = authentication.getName();
        if (username == null || "anonymousUser".equals(username)) {
            return null;
        }
        SysUser user = userService.getByUsername(username);
        return user != null ? user.getUserId() : null;
    }

    /**
     * 用户录入卡片（提交待审批，存入临时表）
     */
    @PostMapping("/create")
    @ApiOperation("用户录入卡片")
    public Result<Long> createCard(@RequestBody @Validated CardCreateDTO dto) {
        Long currentUserId = getCurrentUserId();
        if (currentUserId == null) {
            return Result.error(401, AppMessages.PLEASE_LOGIN_SUBMIT_CARD);
        }
        dto.setCreateBy(currentUserId);
        Long draftId = draftService.createDraftCard(dto);
        return Result.success(AppMessages.CARD_SUBMIT_SUCCESS, draftId);
    }

    /**
     * 获取我的卡片列表（临时表中的记录）
     */
    @GetMapping("/my")
    @ApiOperation("获取我的卡片列表")
    public Result<Page<MyCardVO>> getMyCards(MyCardQueryDTO queryDTO) {
        Long currentUserId = getCurrentUserId();
        if (currentUserId == null) {
            return Result.error(401, AppMessages.PLEASE_LOGIN_VIEW_CARDS);
        }
        return Result.success(draftService.pageMyDrafts(currentUserId, queryDTO));
    }

    /**
     * 修改我的卡片（仅限待审批状态）
     */
    @PutMapping("/my/{id}")
    @ApiOperation("修改我的卡片")
    public Result<Void> updateMyCard(
            @PathVariable Long id,
            @RequestBody @Validated CardCreateDTO dto) {
        Long currentUserId = getCurrentUserId();
        if (currentUserId == null) {
            return Result.error(401, AppMessages.PLEASE_LOGIN_EDIT_CARD);
        }
        dto.setCreateBy(currentUserId);
        draftService.updateMyDraftCard(id, dto, currentUserId);
        return Result.success();
    }

    /**
     * 删除我的卡片（仅限待审批状态）
     */
    @DeleteMapping("/my/{id}")
    @ApiOperation("删除我的卡片")
    public Result<Void> deleteMyCard(
            @PathVariable Long id,
            @RequestParam(required = false) Long userId) {
        Long currentUserId = getCurrentUserId();
        if (currentUserId == null) {
            return Result.error(401, AppMessages.PLEASE_LOGIN_DELETE_CARD);
        }
        draftService.deleteMyDraftCard(id, currentUserId);
        return Result.success();
    }

    /**
     * 获取我的卡片统计
     */
    @GetMapping("/my/stats")
    @ApiOperation("获取我的卡片统计")
    public Result<MyCardStatsVO> getMyCardStats(@RequestParam(required = false) Long userId) {
        Long currentUserId = getCurrentUserId();
        if (currentUserId == null) {
            return Result.error(401, AppMessages.PLEASE_LOGIN_VIEW_STATS);
        }

        // 待审批数量
        long pendingCount = draftService.lambdaQuery()
                .eq(BizCardDraft::getCreateBy, currentUserId)
                .eq(BizCardDraft::getAuditStatus, "0")
                .count();

        // 已通过数量
        long passedCount = draftService.lambdaQuery()
                .eq(BizCardDraft::getCreateBy, currentUserId)
                .eq(BizCardDraft::getAuditStatus, "1")
                .count();

        // 已拒绝数量
        long rejectedCount = draftService.lambdaQuery()
                .eq(BizCardDraft::getCreateBy, currentUserId)
                .eq(BizCardDraft::getAuditStatus, "2")
                .count();

        MyCardStatsVO stats = new MyCardStatsVO();
        stats.setPending(pendingCount);
        stats.setPassed(passedCount);
        stats.setRejected(rejectedCount);
        stats.setTotal(pendingCount + passedCount + rejectedCount);

        return Result.success(stats);
    }

}
