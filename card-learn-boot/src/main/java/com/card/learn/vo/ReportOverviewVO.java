package com.card.learn.vo;

import lombok.Data;

/**
 * 报告概览VO
 */
@Data
public class ReportOverviewVO {

    /** 学习卡片数 */
    private Integer totalCards;

    /** 新掌握卡片数 */
    private Integer newMastered;

    /** 遗忘卡片数 */
    private Integer forgotten;

    /** 连续学习天数 */
    private Integer streakDays;

    /** 学习时长(分钟) */
    private Integer studyDuration;

    /** 与上期对比 */
    private ComparisonVO comparison;
}
