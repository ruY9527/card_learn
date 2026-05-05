package com.card.learn.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;
import com.fasterxml.jackson.annotation.JsonFormat;

/**
 * 成就定义表
 */
@Data
@TableName("biz_achievement")
public class BizAchievement implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "achievement_id", type = IdType.AUTO)
    private Long achievementId;

    /** 成就代码(唯一标识) */
    private String achievementCode;

    /** 成就名称 */
    private String name;

    /** 成就描述 */
    private String description;

    /** 成就图标 */
    private String icon;

    /** 等级(1铜牌2银牌3金牌4钻石) */
    private Integer tier;

    /** 分类(streak/count/subject/social) */
    private String category;

    /** 条件类型 */
    private String conditionType;

    /** 条件值 */
    private Integer conditionValue;

    /** 奖励经验值 */
    private Integer expReward;

    /** 排序 */
    private Integer sortOrder;

    /** 是否启用(0禁用1启用) */
    private Integer enabled;

    @TableField(fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;
}
