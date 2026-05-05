package com.card.learn.controller;

import com.card.learn.common.Result;
import com.card.learn.dto.ReportQueryDTO;
import com.card.learn.service.IReportService;
import com.card.learn.service.IWeakPointService;
import com.card.learn.vo.ReportDetailVO;
import com.card.learn.vo.ReportListVO;
import com.card.learn.vo.WeakPointVO;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 学习报告控制器
 */
@RestController
@RequestMapping("/api/learning")
@Api(tags = "学习报告")
public class LearningReportController {

    @Autowired
    private IReportService reportService;

    @Autowired
    private IWeakPointService weakPointService;

    @GetMapping("/report/current")
    @ApiOperation("获取当前周期报告")
    public Result<ReportDetailVO> getCurrentReport(
            @RequestParam(defaultValue = "weekly") String type,
            @RequestParam(required = false) Long userId) {
        ReportDetailVO report = reportService.getCurrentReport(userId, type);
        return Result.success(report);
    }

    @GetMapping("/report/history")
    @ApiOperation("获取历史报告列表")
    public Result<Map<String, Object>> getHistoryReports(
            @RequestParam(defaultValue = "weekly") String type,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "4") Integer size,
            @RequestParam(required = false) Long userId) {
        List<ReportListVO> records = reportService.getHistoryReports(userId, type, page, size);
        int total = reportService.getHistoryReportCount(userId, type);

        Map<String, Object> result = new HashMap<>();
        result.put("records", records);
        result.put("total", total);
        result.put("pages", (total + size - 1) / size);
        return Result.success(result);
    }

    @GetMapping("/report/{id}")
    @ApiOperation("获取指定报告详情")
    public Result<ReportDetailVO> getReportById(
            @PathVariable Long id,
            @RequestParam(required = false) Long userId) {
        ReportDetailVO report = reportService.getReportById(id, userId);
        if (report == null) {
            return Result.error("报告不存在");
        }
        return Result.success(report);
    }

    @GetMapping("/weak-points")
    @ApiOperation("获取薄弱点列表")
    public Result<Map<String, Object>> getWeakPoints(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "20") Integer size,
            @RequestParam(required = false) Long userId) {
        List<WeakPointVO> records = weakPointService.getWeakPoints(userId, page, size);
        int total = weakPointService.getWeakPointCount(userId);

        Map<String, Object> result = new HashMap<>();
        result.put("records", records);
        result.put("total", total);
        return Result.success(result);
    }

    @PostMapping("/weak-points/{cardId}/review")
    @ApiOperation("标记薄弱点已复习")
    public Result<Void> markWeakPointReviewed(
            @PathVariable Long cardId,
            @RequestParam(required = false) Long userId) {
        weakPointService.markReviewed(userId, cardId);
        return Result.success(null);
    }
}
