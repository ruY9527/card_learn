package com.card.learn.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDate;
import com.fasterxml.jackson.annotation.JsonFormat;
import java.time.LocalDateTime;

/**
 * 学习连续记录表
 */
@Data
@TableName("biz_learning_streak")
public class BizLearningStreak implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /** 用户ID */
    private Long userId;

    /** 当前连续天数 */
    private Integer currentStreak;

    /** 最长连续天数 */
    private Integer longestStreak;

    /** 最后学习日期 */
    private LocalDate lastStudyDate;

    /** 累计学习天数 */
    private Integer totalDays;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;
}
