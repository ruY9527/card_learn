package com.card.learn.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.common.Result;
import com.card.learn.dto.CardAuditDTO;
import com.card.learn.dto.CardCreateDTO;
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

import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
            return Result.error(401, "请先登录后再提交卡片");
        }
        dto.setCreateUserId(currentUserId);
        Long draftId = draftService.createDraftCard(dto);
        return Result.success("卡片提交成功，等待审核", draftId);
    }

    /**
     * 获取我的卡片列表（临时表中的记录）
     */
    @GetMapping("/my")
    @ApiOperation("获取我的卡片列表")
    public Result<Page<MyCardVO>> getMyCards(
            @RequestParam(required = false) Long userId,
            @RequestParam(required = false) String auditStatus,
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        Long currentUserId = getCurrentUserId();
        if (currentUserId == null) {
            return Result.error(401, "请先登录后再查看我的卡片");
        }
        Page<MyCardVO> page = draftService.pageMyDrafts(currentUserId, auditStatus, pageNum, pageSize);
        return Result.success(page);
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
            return Result.error(401, "请先登录后再修改卡片");
        }
        dto.setCreateUserId(currentUserId);
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
            return Result.error(401, "请先登录后再删除卡片");
        }
        draftService.deleteMyDraftCard(id, currentUserId);
        return Result.success();
    }

    /**
     * 获取我的卡片统计
     */
    @GetMapping("/my/stats")
    @ApiOperation("获取我的卡片统计")
    public Result<Map<String, Object>> getMyCardStats(@RequestParam(required = false) Long userId) {
        Long currentUserId = getCurrentUserId();
        if (currentUserId == null) {
            return Result.error(401, "请先登录后再查看统计");
        }
        Map<String, Object> stats = new HashMap<>();
        
        // 待审批数量
        long pendingCount = draftService.lambdaQuery()
                .eq(BizCardDraft::getCreateUserId, currentUserId)
                .eq(BizCardDraft::getAuditStatus, "0")
                .count();
        
        // 已通过数量
        long passedCount = draftService.lambdaQuery()
                .eq(BizCardDraft::getCreateUserId, currentUserId)
                .eq(BizCardDraft::getAuditStatus, "1")
                .count();
        
        // 已拒绝数量
        long rejectedCount = draftService.lambdaQuery()
                .eq(BizCardDraft::getCreateUserId, currentUserId)
                .eq(BizCardDraft::getAuditStatus, "2")
                .count();
        
        stats.put("pending", pendingCount);
        stats.put("passed", passedCount);
        stats.put("rejected", rejectedCount);
        stats.put("total", pendingCount + passedCount + rejectedCount);
        
        return Result.success(stats);
    }

}
