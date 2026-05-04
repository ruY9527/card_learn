package com.card.learn.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import com.fasterxml.jackson.annotation.JsonFormat;
import java.time.LocalDateTime;

/**
 * 用户录入卡片临时表（待审批）
 */
@Data
@TableName("biz_card_draft")
public class BizCardDraft implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "draft_id", type = IdType.AUTO)
    private Long draftId;

    /** 所属科目ID */
    private Long subjectId;

    /** 卡片正面(支持Markdown/LaTeX) */
    private String frontContent;

    /** 卡片反面(答案/解析) */
    private String backContent;

    /** 难度系数(1-5) */
    private Integer difficultyLevel;

    /** 创建用户ID（小程序用户） */
    private Long createUserId;

    /** 标签ID列表（JSON格式存储） */
    private String tagIds;

    /** 审批状态（0待审批 1已通过 2已拒绝） */
    private String auditStatus;

    /** 审批人ID */
    private Long auditUserId;

    /** 审批时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime auditTime;

    /** 审批备注（拒绝原因等） */
    private String auditRemark;

    @TableField(fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;

    /** 更新人ID */
    private Long updateUserId;

}