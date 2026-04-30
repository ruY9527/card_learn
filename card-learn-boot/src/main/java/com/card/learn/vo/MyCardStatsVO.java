package com.card.learn.vo;

import lombok.Data;

import java.io.Serializable;

/**
 * 我的卡片统计VO
 */
@Data
public class MyCardStatsVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long pending;
    private Long passed;
    private Long rejected;
    private Long total;
}
