package com.card.learn.vo;

import lombok.Data;

import java.io.Serializable;

/**
 * 每日学习趋势视图对象
 */
@Data
public class DailyLearnTrendVO implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 日期 (yyyy-MM-dd) */
    private String date;

    /** 学习记录数 */
    private Long count;
}
