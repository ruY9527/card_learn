package com.card.learn.vo;

import lombok.Data;

/**
 * 学习习惯分析VO
 */
@Data
public class LearningHabitsVO {

    /** 上午学习占比 */
    private Integer morning;

    /** 下午学习占比 */
    private Integer afternoon;

    /** 晚上学习占比 */
    private Integer evening;

    /** 学习高峰时段 */
    private String peakHour;

    /** 最活跃学习日 */
    private String mostActiveDay;

    /** 平均每日学习时长(分钟) */
    private Integer avgDailyDuration;

    /** 学习频率(每周天数) */
    private Integer studyFrequency;
}
