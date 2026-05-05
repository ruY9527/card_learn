package com.card.learn.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.dto.AchievementCheckDTO;
import com.card.learn.dto.GoalSetDTO;
import com.card.learn.dto.RankQueryDTO;
import com.card.learn.vo.*;

import java.util.List;

/**
 * 激励系统服务接口（成就、等级、经验值、目标、排行榜）
 */
public interface IIncentiveService {

    // ==================== 经验值 ====================

    /**
     * 发放经验值
     * @param userId 用户ID
     * @param exp 经验值
     * @param sourceType 来源类型
     * @param sourceId 来源ID
     * @param description 描述
     */
    void awardExp(Long userId, int exp, String sourceType, String sourceId, String description);

    // ==================== 成就 ====================

    /**
     * 获取成就列表（含用户解锁状态）
     */
    List<AchievementVO> getAchievementList(Long userId, String category);

    /**
     * 获取用户已解锁成就统计
     */
    AchievementListVO getUserAchievements(Long userId);

    /**
     * 检查并解锁成就
     */
    AchievementCheckVO checkAndUnlockAchievement(AchievementCheckDTO dto);

    // ==================== 等级 ====================

    /**
     * 获取用户等级信息
     */
    UserLevelVO getLevelInfo(Long userId);

    /**
     * 分页查询经验值日志
     */
    Page<ExpLogVO> getExpLogPage(Long userId, String sourceType, int pageNum, int pageSize);

    // ==================== 目标 ====================

    /**
     * 获取当前目标设置
     */
    LearningGoalVO getCurrentGoal(Long userId);

    /**
     * 设置学习目标
     */
    LearningGoalVO setGoal(Long userId, GoalSetDTO dto);

    /**
     * 获取今日目标进度
     */
    GoalProgressVO getGoalProgress(Long userId);

    /**
     * 获取本周目标完成情况
     */
    List<GoalProgressVO> getWeekGoalProgress(Long userId);

    // ==================== 排行榜 ====================

    /**
     * 获取总排行榜
     */
    Page<RankVO> getTotalRank(int pageNum, int pageSize);

    /**
     * 获取周排行榜
     */
    Page<RankVO> getWeekRank(int pageNum, int pageSize);

    /**
     * 获取连击排行榜
     */
    Page<RankVO> getStreakRank(int pageNum, int pageSize);

    /**
     * 获取用户排名
     */
    RankVO getUserRank(Long userId);
}
