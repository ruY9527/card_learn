package com.card.learn.vo;

import lombok.Data;

import java.io.Serializable;

/**
 * 科目学习统计VO
 */
@Data
public class SubjectStatsVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long total;
    private Long learned;
    private Long mastered;
    private Long review;
}
