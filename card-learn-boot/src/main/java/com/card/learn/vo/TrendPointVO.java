package com.card.learn.vo;

import lombok.Data;

/**
 * 趋势数据点VO
 */
@Data
public class TrendPointVO {

    /** 日期 */
    private String date;

    /** 掌握率 */
    private Integer rate;

    public TrendPointVO() {}

    public TrendPointVO(String date, Integer rate) {
        this.date = date;
        this.rate = rate;
    }
}
