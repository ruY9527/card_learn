package com.card.learn.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;
import com.fasterxml.jackson.annotation.JsonFormat;

/**
 * 用户每日学习计数表
 */
@Data
@TableName("biz_user_daily_count")
public class BizUserDailyCount implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /** 用户ID */
    private Long userId;

    /** 统计日期 */
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate countDate;

    /** 当日学习卡片数 */
    private Integer learnCount;

    /** 当日掌握卡片数 */
    private Integer masterCount;

    /** 当日复习卡片数 */
    private Integer reviewCount;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;

    @TableField(fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;
}
