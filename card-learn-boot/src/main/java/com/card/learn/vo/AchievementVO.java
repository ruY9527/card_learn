package com.card.learn.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 成就视图对象
 */
@Data
public class AchievementVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long achievementId;

    /** 成就代码 */
    private String code;

    /** 成就名称 */
    private String name;

    /** 成就描述 */
    private String description;

    /** 成就图标 */
    private String icon;

    /** 等级(1铜牌2银牌3金牌4钻石) */
    private Integer tier;

    /** 分类 */
    private String category;

    /** 条件值 */
    private Integer conditionValue;

    /** 奖励经验值 */
    private Integer expReward;

    /** 当前用户是否已解锁 */
    private Boolean unlocked;

    /** 获得时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime achievedAt;
}
