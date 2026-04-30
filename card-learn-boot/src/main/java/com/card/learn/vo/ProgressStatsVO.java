package com.card.learn.vo;

import lombok.Data;

import java.io.Serializable;

/**
 * 学习进度统计VO
 */
@Data
public class ProgressStatsVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long learnedCount;
    private Long masteredCount;
    private Long reviewCount;
}
