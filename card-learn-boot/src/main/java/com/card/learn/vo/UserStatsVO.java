package com.card.learn.vo;

import lombok.Data;

import java.io.Serializable;

/**
 * 用户学习统计VO
 */
@Data
public class UserStatsVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long learned;
    private Long mastered;
    private Long review;
}
