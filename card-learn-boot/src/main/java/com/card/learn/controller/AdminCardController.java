package com.card.learn.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.common.Result;
import com.card.learn.dto.AuditCardQueryDTO;
import com.card.learn.dto.BatchAuditDTO;
import com.card.learn.dto.CardAuditDTO;
import com.card.learn.entity.BizCardDraft;
import com.card.learn.service.IBizCardDraftService;
import com.card.learn.vo.CardAuditVO;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import com.card.learn.vo.AuditResultVO;

import java.util.List;

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
    public Result<Page<CardAuditVO>> page(AuditCardQueryDTO queryDTO) {
        return Result.success(draftService.pagePendingDrafts(queryDTO));
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
    public Result<AuditResultVO> auditCard(@RequestBody @Validated CardAuditDTO dto) {
        try {
            Long cardId = draftService.auditDraftCard(dto);
            String msg = "1".equals(dto.getAuditStatus()) ? "审批通过，已添加到知识库" : "审批拒绝";

            AuditResultVO result = new AuditResultVO();
            result.setCardId(cardId);
            result.setMessage(msg);

            return Result.success(result);
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
    public Result<String> batchPass(@RequestBody List<Long> draftIds, BatchAuditDTO auditDTO) {
        int passCount = 0;
        for (Long draftId : draftIds) {
            CardAuditDTO dto = new CardAuditDTO();
            dto.setCardId(draftId);
            dto.setAuditStatus("1");
            dto.setAuditUserId(auditDTO.getAuditUserId());
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
    public Result<String> batchReject(@RequestBody List<Long> draftIds, BatchAuditDTO auditDTO) {
        int rejectCount = 0;
        for (Long draftId : draftIds) {
            CardAuditDTO dto = new CardAuditDTO();
            dto.setCardId(draftId);
            dto.setAuditStatus("2");
            dto.setAuditUserId(auditDTO.getAuditUserId());
            dto.setAuditRemark(auditDTO.getAuditRemark());
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