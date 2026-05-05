package com.card.learn.vo;

import lombok.Data;

import java.time.LocalDate;

/**
 * 报告列表项VO
 */
@Data
public class ReportListVO {

    /** 报告ID */
    private Long reportId;

    /** 报告类型 */
    private String reportType;

    /** 周期开始日期 */
    private LocalDate periodStart;

    /** 周期结束日期 */
    private LocalDate periodEnd;

    /** 简要概览 */
    private ReportOverviewVO overview;
}
