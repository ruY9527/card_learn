package com.card.learn.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;
import com.fasterxml.jackson.annotation.JsonFormat;

/**
 * 经验值变动日志表
 */
@Data
@TableName("biz_exp_log")
public class BizExpLog implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /** 用户ID */
    private Long userId;

    /** 经验变化(正数增加) */
    private Integer expChange;

    /** 来源类型(STUDY/MASTER/REVIEW/GOAL/ACHIEVEMENT/COMMENT/CONTRIBUTE) */
    private String sourceType;

    /** 来源ID(如卡片ID) */
    private String sourceId;

    /** 变动描述 */
    private String description;

    @TableField(fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;
}
