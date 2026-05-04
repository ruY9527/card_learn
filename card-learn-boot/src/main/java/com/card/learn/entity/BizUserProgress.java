package com.card.learn.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import com.fasterxml.jackson.annotation.JsonFormat;
import java.time.LocalDateTime;

/**
 * 用户学习进度表
 */
@Data
@TableName("biz_user_progress")
public class BizUserProgress implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /** 用户ID */
    private Long userId;

    /** 卡片ID */
    private Long cardId;

    /** 掌握状态(0未学 1模糊 2掌握) */
    private Integer status;

    /** SM-2容易系数 */
    private Double easeFactor;

    /** SM-2连续正确次数 */
    private Integer repetitions;

    /** SM-2复习间隔天数 */
    private Integer intervalDays;

    /** 建议下次复习时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime nextReviewTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;


    /** 创建人 */
    private Long createBy;

    /** 修改人 */
    private Long updateBy;
}
