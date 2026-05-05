package com.card.learn.vo;

import lombok.Data;

import java.time.LocalDate;
import java.util.List;

/**
 * 学习报告详情VO
 */
@Data
public class ReportDetailVO {

    /** 报告ID */
    private Long reportId;

    /** 报告类型 */
    private String reportType;

    /** 周期开始日期 */
    private LocalDate periodStart;

    /** 周期结束日期 */
    private LocalDate periodEnd;

    /** 概览 */
    private ReportOverviewVO overview;

    /** 掌握率趋势 */
    private MasteryTrendVO masteryTrend;

    /** 科目分析 */
    private List<SubjectAnalysisVO> subjectAnalysis;

    /** 学习习惯 */
    private LearningHabitsVO learningHabits;

    /** 薄弱点列表 */
    private List<WeakPointVO> weakPoints;

    /** 改进建议 */
    private List<SuggestionVO> suggestions;
}
