package com.card.learn.vo;

import lombok.Data;

import java.io.Serializable;

/**
 * 首页统计数据VO
 */
@Data
public class DashboardStatsVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long majorCount;
    private Long subjectCount;
    private Long cardCount;
    private Long tagCount;
}
