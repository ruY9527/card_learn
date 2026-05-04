package com.card.learn.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import com.fasterxml.jackson.annotation.JsonFormat;
import java.time.LocalDateTime;

/**
 * 卡片审批历史日志表
 */
@Data
@TableName("biz_card_audit_log")
public class BizCardAuditLog implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "log_id", type = IdType.AUTO)
    private Long logId;

    /** 临时卡片ID */
    private Long draftId;

    /** 正式卡片ID（审批通过后生成） */
    private Long cardId;

    /** 审批状态（1通过 2拒绝） */
    private String auditStatus;

    /** 审批人ID */
    private Long auditUserId;

    /** 审批备注 */
    private String auditRemark;

    /** 审批时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime auditTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;

    /** 更新人ID */
    private Long updateUserId;

}