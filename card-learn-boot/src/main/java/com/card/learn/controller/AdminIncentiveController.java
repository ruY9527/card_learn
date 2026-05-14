package com.card.learn.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.common.Result;
import com.card.learn.entity.BizAchievement;
import com.card.learn.mapper.BizAchievementMapper;
import com.card.learn.mapper.BizUserLevelMapper;
import com.card.learn.service.IIncentiveService;
import com.card.learn.vo.AchievementVO;
import com.card.learn.vo.LearningGoalVO;
import com.card.learn.vo.RankVO;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 管理端-激励系统Controller
 */
@RestController
@RequestMapping("/admin/incentive")
@Api(tags = "管理端-激励系统")
public class AdminIncentiveController {

    @Autowired
    private IIncentiveService incentiveService;

    @Autowired
    private BizAchievementMapper achievementMapper;

    @Autowired
    private BizUserLevelMapper userLevelMapper;

    // ==================== 成就管理 ====================

    @GetMapping("/achievement/list")
    @ApiOperation("获取所有成就列表")
    public Result<List<AchievementVO>> getAllAchievements(
            @RequestParam(required = false) String category) {
        return Result.success(incentiveService.getAchievementList(null, category));
    }

    @GetMapping("/achievement/stats")
    @ApiOperation("成就统计概览")
    public Result<Map<String, Object>> getAchievementStats() {
        Map<String, Object> stats = new HashMap<>();
        long total = achievementMapper.selectCount(null);
        stats.put("totalAchievements", total);
        return Result.success(stats);
    }

    // ==================== 目标管理 ====================

    @GetMapping("/goal/user")
    @ApiOperation("获取用户学习目标及提醒设置")
    public Result<LearningGoalVO> getUserGoal(@RequestParam Long userId) {
        return Result.success(incentiveService.getCurrentGoal(userId));
    }

    // ==================== 排行榜 ====================

    @GetMapping("/rank/total")
    @ApiOperation("管理端-总排行榜")
    public Result<Page<RankVO>> getTotalRank(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "20") int pageSize) {
        return Result.success(incentiveService.getTotalRank(pageNum, pageSize));
    }

    @GetMapping("/rank/week")
    @ApiOperation("管理端-周排行榜")
    public Result<Page<RankVO>> getWeekRank(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "20") int pageSize) {
        return Result.success(incentiveService.getWeekRank(pageNum, pageSize));
    }

    @GetMapping("/rank/streak")
    @ApiOperation("管理端-连击排行榜")
    public Result<Page<RankVO>> getStreakRank(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "20") int pageSize) {
        return Result.success(incentiveService.getStreakRank(pageNum, pageSize));
    }
}
