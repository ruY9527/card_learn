package com.card.learn.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.common.Result;
import com.card.learn.dto.CardAuditDTO;
import com.card.learn.entity.BizCardDraft;
import com.card.learn.service.IBizCardDraftService;
import com.card.learn.vo.CardAuditVO;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 管理端卡片审批控制器（审批临时表中的卡片）
 */
@RestController
@RequestMapping("/card/audit")
@Api(tags = "卡片审批管理")
public class AdminCardController {

    @Autowired
    private IBizCardDraftService draftService;

    /**
     * 分页查询待审批卡片列表（从临时表查询）
     */
    @GetMapping("/page")
    @ApiOperation("分页查询待审批卡片")
    public Result<Page<CardAuditVO>> page(
            @RequestParam(required = false) String auditStatus,
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        Page<CardAuditVO> page = draftService.pagePendingDrafts(auditStatus, pageNum, pageSize);
        return Result.success(page);
    }

    /**
     * 获取卡片详情（用于审批查看）
     */
    @GetMapping("/{id}")
    @ApiOperation("获取卡片详情")
    public Result<BizCardDraft> getById(@PathVariable Long id) {
        BizCardDraft draft = draftService.getById(id);
        if (draft == null) {
            return Result.error("卡片不存在");
        }
        return Result.success(draft);
    }

    /**
     * 审批卡片（通过时迁移到正式表，拒绝时更新状态）
     * 返回：审批通过时返回正式卡片ID，拒绝时返回null
     */
    @PostMapping("/process")
    @ApiOperation("审批卡片")
    public Result<Map<String, Object>> auditCard(@RequestBody @Validated CardAuditDTO dto) {
        try {
            Long cardId = draftService.auditDraftCard(dto);
            String msg = "1".equals(dto.getAuditStatus()) ? "审批通过，已添加到知识库" : "审批拒绝";
            
            Map<String, Object> data = new HashMap<>();
            data.put("cardId", cardId); // 审批通过时返回正式卡片ID
            data.put("message", msg);
            
            return Result.success(data);
        } catch (RuntimeException e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取待审批卡片数量
     */
    @GetMapping("/pending/count")
    @ApiOperation("获取待审批卡片数量")
    public Result<Long> getPendingCount() {
        long count = draftService.getPendingCount();
        return Result.success(count);
    }

    /**
     * 批量审批通过
     */
    @PostMapping("/batch/pass")
    @ApiOperation("批量审批通过")
    public Result<String> batchPass(@RequestBody List<Long> draftIds, @RequestParam Long auditUserId) {
        int passCount = 0;
        for (Long draftId : draftIds) {
            CardAuditDTO dto = new CardAuditDTO();
            dto.setCardId(draftId);
            dto.setAuditStatus("1");
            dto.setAuditUserId(auditUserId);
            try {
                draftService.auditDraftCard(dto);
                passCount++;
            } catch (RuntimeException e) {
                // 跳过已审批的卡片
            }
        }
        return Result.success("批量审批完成，成功通过" + passCount + "张卡片");
    }

    /**
     * 批量审批拒绝
     */
    @PostMapping("/batch/reject")
    @ApiOperation("批量审批拒绝")
    public Result<String> batchReject(
            @RequestBody List<Long> draftIds,
            @RequestParam Long auditUserId,
            @RequestParam(required = false) String auditRemark) {
        int rejectCount = 0;
        for (Long draftId : draftIds) {
            CardAuditDTO dto = new CardAuditDTO();
            dto.setCardId(draftId);
            dto.setAuditStatus("2");
            dto.setAuditUserId(auditUserId);
            dto.setAuditRemark(auditRemark);
            try {
                draftService.auditDraftCard(dto);
                rejectCount++;
            } catch (RuntimeException e) {
                // 跳过已审批的卡片
            }
        }
        return Result.success("批量拒绝完成，成功拒绝" + rejectCount + "张卡片");
    }

}