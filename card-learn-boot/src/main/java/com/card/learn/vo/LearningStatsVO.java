package com.card.learn.vo;

import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * 总体学习统计视图对象
 */
@Data
public class LearningStatsVO implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 总卡片数 */
    private Long totalCards;

    /** 学习天数 */
    private Long learnDays;

    /** 总学习记录数 */
    private Long totalLearnRecords;

    /** 未学卡片数 */
    private Long unlearnedCount;

    /** 模糊卡片数 */
    private Long fuzzyCount;

    /** 掌握卡片数 */
    private Long masteredCount;

    /** 已学习占比(%) */
    private BigDecimal learnedRate;
}
