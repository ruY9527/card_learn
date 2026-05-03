package com.card.learn.vo;

import lombok.Data;

import java.io.Serializable;

/**
 * 用户学习连续记录视图对象
 */
@Data
public class UserStreakVO implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 当前连续天数 */
    private Integer currentStreak;

    /** 最长连续天数 */
    private Integer longestStreak;

    /** 累计学习天数 */
    private Integer totalStudyDays;

    /** 今日已学卡片数 */
    private Integer masteredToday;

    /** 今日已学卡片数(含模糊) */
    private Integer learnedToday;
}
