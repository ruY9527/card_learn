package com.card.learn.vo;

import lombok.Data;

import java.util.List;

/**
 * 掌握率趋势VO
 */
@Data
public class MasteryTrendVO {

    /** 周期开始掌握率 */
    private Integer startRate;

    /** 周期结束掌握率 */
    private Integer endRate;

    /** 掌握率变化 */
    private Integer changeRate;

    /** 趋势数据 */
    private List<TrendPointVO> trendData;
}
