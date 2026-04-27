package com.card.learn.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
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

    /** 建议下次复习时间 */
    private LocalDateTime nextReviewTime;

    private LocalDateTime updateTime;

}