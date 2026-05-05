package com.card.learn.service;

import com.card.learn.vo.ReportDetailVO;
import com.card.learn.vo.ReportListVO;

import java.util.List;

/**
 * 学习报告Service
 */
public interface IReportService {

    /**
     * 获取当前周期报告
     * @param userId 用户ID
     * @param reportType 报告类型: weekly/monthly
     */
    ReportDetailVO getCurrentReport(Long userId, String reportType);

    /**
     * 获取历史报告列表
     */
    List<ReportListVO> getHistoryReports(Long userId, String reportType, Integer page, Integer size);

    /**
     * 获取历史报告总数
     */
    int getHistoryReportCount(Long userId, String reportType);

    /**
     * 获取指定报告详情
     */
    ReportDetailVO getReportById(Long reportId, Long userId);

    /**
     * 生成报告（定时任务调用）
     */
    void generateReport(Long userId, String reportType);
}
