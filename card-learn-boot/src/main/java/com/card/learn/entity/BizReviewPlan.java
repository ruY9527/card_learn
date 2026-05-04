package com.card.learn.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDate;
import com.fasterxml.jackson.annotation.JsonFormat;
import java.time.LocalDateTime;

/**
 * 复习计划表
 */
@Data
@TableName("biz_review_plan")
public class BizReviewPlan implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /** 用户ID */
    private Long userId;

    /** 卡片ID */
    private Long cardId;

    /** 计划复习日期 */
    private LocalDate scheduledDate;

    /** 状态(0待复习 1已完成) */
    private String status;

    /** 实际复习时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime actualReviewDate;

    /** SM-2质量评分(0-5) */
    private Integer sm2Quality;

    @TableField(fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;

    /** 创建人 */
    private Long createBy;

    /** 修改人 */
    private Long updateBy;
}
