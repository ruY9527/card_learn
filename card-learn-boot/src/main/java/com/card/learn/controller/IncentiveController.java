package com.card.learn.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.common.Result;
import com.card.learn.dto.AchievementCheckDTO;
import com.card.learn.dto.GoalSetDTO;
import com.card.learn.service.IIncentiveService;
import com.card.learn.vo.*;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 激励系统Controller（成就、等级、经验值、目标、排行榜）
 */
@RestController
@RequestMapping("/api/incentive")
@Api(tags = "激励系统")
public class IncentiveController {

    @Autowired
    private IIncentiveService incentiveService;

    // ==================== 成就 ====================

    @GetMapping("/achievement/list")
    @ApiOperation("获取成就列表（含用户解锁状态）")
    public Result<List<AchievementVO>> getAchievementList(
            @RequestParam Long userId,
            @RequestParam(required = false) String category) {
        return Result.success(incentiveService.getAchievementList(userId, category));
    }

    @GetMapping("/achievement/user")
    @ApiOperation("获取用户已解锁成就统计")
    public Result<AchievementListVO> getUserAchievements(@RequestParam Long userId) {
        return Result.success(incentiveService.getUserAchievements(userId));
    }

    @GetMapping("/achievement/check")
    @ApiOperation("检查并解锁成就")
    public Result<AchievementCheckVO> checkAchievement(
            @RequestParam Long userId,
            @RequestParam String actionType,
            @RequestParam(required = false) String sourceId) {
        AchievementCheckDTO dto = new AchievementCheckDTO();
        dto.setUserId(userId);
        dto.setActionType(actionType);
        dto.setSourceId(sourceId);
        return Result.success(incentiveService.checkAndUnlockAchievement(dto));
    }

    // ==================== 等级 ====================

    @GetMapping("/level/info")
    @ApiOperation("获取用户等级信息")
    public Result<UserLevelVO> getLevelInfo(@RequestParam Long userId) {
        return Result.success(incentiveService.getLevelInfo(userId));
    }

    @GetMapping("/level/exp-log")
    @ApiOperation("获取经验值日志")
    public Result<Page<ExpLogVO>> getExpLog(
            @RequestParam Long userId,
            @RequestParam(required = false) String sourceType,
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "20") int pageSize) {
        return Result.success(incentiveService.getExpLogPage(userId, sourceType, pageNum, pageSize));
    }

    // ==================== 目标 ====================

    @GetMapping("/goal/current")
    @ApiOperation("获取当前目标设置")
    public Result<LearningGoalVO> getCurrentGoal(@RequestParam Long userId) {
        return Result.success(incentiveService.getCurrentGoal(userId));
    }

    @PostMapping("/goal/set")
    @ApiOperation("设置学习目标")
    public Result<LearningGoalVO> setGoal(@RequestParam Long userId, @RequestBody GoalSetDTO dto) {
        return Result.success(incentiveService.setGoal(userId, dto));
    }

    @GetMapping("/goal/progress")
    @ApiOperation("获取今日目标进度")
    public Result<GoalProgressVO> getGoalProgress(@RequestParam Long userId) {
        return Result.success(incentiveService.getGoalProgress(userId));
    }

    @GetMapping("/goal/week")
    @ApiOperation("获取本周目标完成情况")
    public Result<List<GoalProgressVO>> getWeekGoalProgress(@RequestParam Long userId) {
        return Result.success(incentiveService.getWeekGoalProgress(userId));
    }

    // ==================== 排行榜 ====================

    @GetMapping("/rank/total")
    @ApiOperation("总排行榜")
    public Result<Page<RankVO>> getTotalRank(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "20") int pageSize) {
        return Result.success(incentiveService.getTotalRank(pageNum, pageSize));
    }

    @GetMapping("/rank/week")
    @ApiOperation("周排行榜")
    public Result<Page<RankVO>> getWeekRank(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "20") int pageSize) {
        return Result.success(incentiveService.getWeekRank(pageNum, pageSize));
    }

    @GetMapping("/rank/streak")
    @ApiOperation("连击排行榜")
    public Result<Page<RankVO>> getStreakRank(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "20") int pageSize) {
        return Result.success(incentiveService.getStreakRank(pageNum, pageSize));
    }

    @GetMapping("/rank/user/{userId}")
    @ApiOperation("获取用户排名")
    public Result<RankVO> getUserRank(@PathVariable Long userId) {
        return Result.success(incentiveService.getUserRank(userId));
    }
}
