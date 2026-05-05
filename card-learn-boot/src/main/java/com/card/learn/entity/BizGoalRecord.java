package com.card.learn.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;
import com.fasterxml.jackson.annotation.JsonFormat;

/**
 * 每日目标完成记录表
 */
@Data
@TableName("biz_goal_record")
public class BizGoalRecord implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /** 用户ID */
    private Long userId;

    /** 目标日期 */
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate goalDate;

    /** 目标类型 */
    private String goalType;

    /** 目标数量 */
    private Integer targetCount;

    /** 实际完成 */
    private Integer actualCount;

    /** 是否完成(0未完成1完成) */
    private Integer completed;

    @TableField(fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;
}
