package com.card.learn.controller;

import com.card.learn.common.Result;
import com.card.learn.service.IBizMajorService;
import com.card.learn.service.IBizSubjectService;
import com.card.learn.service.IBizCardService;
import com.card.learn.service.IBizTagService;
import com.card.learn.service.ILearningStatsService;
import com.card.learn.vo.DailyLearnTrendVO;
import com.card.learn.vo.DayLearnDetailVO;
import com.card.learn.vo.LearningStatsVO;
import com.card.learn.vo.SubjectLearnStatsVO;
import com.card.learn.vo.UserLearnRankVO;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import com.card.learn.vo.DashboardStatsVO;

import java.util.List;

/**
 * Dashboard数据统计控制器
 */
@RestController
@RequestMapping("/api/dashboard")
@Api(tags = "数据看板")
public class DashboardController {

    @Autowired
    private IBizMajorService majorService;

    @Autowired
    private IBizSubjectService subjectService;

    @Autowired
    private IBizCardService cardService;

    @Autowired
    private IBizTagService tagService;

    @Autowired
    private ILearningStatsService learningStatsService;

    @GetMapping("/stats")
    @ApiOperation("获取统计数据")
    public Result<DashboardStatsVO> getStats() {
        DashboardStatsVO stats = new DashboardStatsVO();
        stats.setMajorCount(majorService.count());
        stats.setSubjectCount(subjectService.count());
        stats.setCardCount(cardService.count());
        stats.setTagCount(tagService.count());
        return Result.success(stats);
    }

    @GetMapping("/learning-stats")
    @ApiOperation("总体学习统计")
    public Result<LearningStatsVO> getLearningStats(
            @RequestParam(required = false) Long userId) {
        return Result.success(learningStatsService.getOverallStats(userId));
    }

    @GetMapping("/learn-trend")
    @ApiOperation("每日学习趋势")
    public Result<List<DailyLearnTrendVO>> getLearnTrend(
            @RequestParam(defaultValue = "30") Integer days,
            @RequestParam(required = false) Long userId) {
        return Result.success(learningStatsService.getDailyTrend(days, userId));
    }

    @GetMapping("/user-ranking")
    @ApiOperation("用户学习排行榜")
    public Result<List<UserLearnRankVO>> getUserRanking(
            @RequestParam(defaultValue = "10") Integer limit) {
        return Result.success(learningStatsService.getUserRanking(limit));
    }

    @GetMapping("/subject-stats")
    @ApiOperation("科目学习统计")
    public Result<List<SubjectLearnStatsVO>> getSubjectStats(
            @RequestParam(required = false) Long userId) {
        return Result.success(learningStatsService.getSubjectStats(userId));
    }

    @GetMapping("/day-detail")
    @ApiOperation("某日学习详情")
    public Result<DayLearnDetailVO> getDayDetail(
            @RequestParam Long userId,
            @RequestParam String date) {
        return Result.success(learningStatsService.getDayDetail(userId, date));
    }

}