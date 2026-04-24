package com.card.learn.dto;

import lombok.Data;

import javax.validation.constraints.NotNull;
import java.io.Serializable;

/**
 * 卡片审批DTO
 */
@Data
public class CardAuditDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 卡片ID */
    @NotNull(message = "卡片ID不能为空")
    private Long cardId;

    /** 审批状态：1通过 2拒绝 */
    @NotNull(message = "审批状态不能为空")
    private String auditStatus;

    /** 审批备注（拒绝原因等） */
    private String auditRemark;

    /** 审批人ID（后台管理员） */
    private Long auditUserId;

}