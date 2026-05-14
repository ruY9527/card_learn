package com.card.learn.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.common.AppConstants;
import com.card.learn.common.AppMessages;
import com.card.learn.dto.AchievementCheckDTO;
import com.card.learn.dto.GoalSetDTO;
import com.card.learn.entity.*;
import com.card.learn.mapper.*;
import com.card.learn.service.IIncentiveService;
import com.card.learn.vo.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * 激励系统服务实现
 */
@Slf4j
@Service
public class IncentiveServiceImpl implements IIncentiveService {

    /** 等级经验值配置：索引=等级，值=该等级所需累计经验 */
    private static final int[] LEVEL_EXP = {0, 100, 300, 600, 1000, 1500, 2100, 2800, 3600, 4500};

    /** 等级名称 */
    private static final String[] LEVEL_NAMES = AppMessages.LEVEL_NAMES;

    @Autowired
    private BizUserLevelMapper userLevelMapper;

    @Autowired
    private BizExpLogMapper expLogMapper;

    @Autowired
    private BizAchievementMapper achievementMapper;

    @Autowired
    private BizUserAchievementMapper userAchievementMapper;

    @Autowired
    private BizLearningGoalMapper learningGoalMapper;

    @Autowired
    private BizGoalRecordMapper goalRecordMapper;

    @Autowired
    private BizUserDailyCountMapper dailyCountMapper;

    @Autowired
    private BizLearningStreakMapper streakMapper;

    // ==================== 经验值 ====================

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void awardExp(Long userId, int exp, String sourceType, String sourceId, String description) {
        if (userId == null || exp <= 0) {
            return;
        }

        // 1. 更新用户等级
        BizUserLevel userLevel = getOrCreateUserLevel(userId);
        int oldLevel = userLevel.getLevel();
        userLevel.setCurrentExp(userLevel.getCurrentExp() + exp);
        userLevel.setTotalExp(userLevel.getTotalExp() + exp);

        // 检查是否升级
        int newLevel = calculateLevel(userLevel.getTotalExp());
        if (newLevel > oldLevel) {
            userLevel.setLevel(newLevel);
            log.info("用户 {} 升级: {} -> {}", userId, oldLevel, newLevel);
        }
        userLevelMapper.updateById(userLevel);

        // 2. 记录经验值日志
        BizExpLog expLog = new BizExpLog();
        expLog.setUserId(userId);
        expLog.setExpChange(exp);
        expLog.setSourceType(sourceType);
        expLog.setSourceId(sourceId);
        expLog.setDescription(description);
        expLogMapper.insert(expLog);

        // 3. 更新每日计数
        updateDailyCount(userId, sourceType);

        // 4. 更新每日目标进度
        updateGoalProgress(userId, sourceType);
    }

    // ==================== 成就 ====================

    @Override
    public List<AchievementVO> getAchievementList(Long userId, String category) {
        return achievementMapper.selectAchievementList(userId, category);
    }

    @Override
    public AchievementListVO getUserAchievements(Long userId) {
        AchievementListVO vo = new AchievementListVO();
        List<AchievementVO> all = achievementMapper.selectAchievementList(userId, null);
        vo.setTotalCount(all.size());
        vo.setUnlockedCount((int) all.stream().filter(AchievementVO::getUnlocked).count());
        vo.setAchievements(all);
        return vo;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public AchievementCheckVO checkAndUnlockAchievement(AchievementCheckDTO dto) {
        Long userId = dto.getUserId();
        String actionType = dto.getActionType();

        AchievementCheckVO result = new AchievementCheckVO();
        result.setNewAchievements(new ArrayList<>());
        result.setLeveledUp(false);

        // 获取用户统计数据
        int learnCount = getDailyCountSum(userId, AppConstants.COUNT_TYPE_LEARN);
        int masterCount = getDailyCountSum(userId, AppConstants.COUNT_TYPE_MASTER);
        int reviewCount = getDailyCountSum(userId, AppConstants.COUNT_TYPE_REVIEW);
        int streakDays = getStreakDays(userId);

        // 查询所有已启用的成就
        List<AchievementVO> allAchievements = achievementMapper.selectAchievementList(userId, null);

        for (AchievementVO achievement : allAchievements) {
            if (achievement.getUnlocked()) {
                continue;
            }

            boolean shouldUnlock = false;
            switch (achievement.getCategory()) {
                case AppConstants.ACHIEVEMENT_CATEGORY_COUNT:
                    shouldUnlock = checkCountAchievement(achievement, learnCount, masterCount, reviewCount);
                    break;
                case AppConstants.ACHIEVEMENT_CATEGORY_STREAK:
                    shouldUnlock = checkStreakAchievement(achievement, streakDays);
                    break;
                case AppConstants.ACHIEVEMENT_CATEGORY_SOCIAL:
                    shouldUnlock = checkSocialAchievement(achievement, userId, actionType);
                    break;
                case AppConstants.ACHIEVEMENT_CATEGORY_SUBJECT:
                    // 科目成就需要额外数据，暂跳过
                    break;
            }

            if (shouldUnlock) {
                unlockAchievement(userId, achievement);
                result.getNewAchievements().add(achievement);

                // 发放成就奖励经验
                if (achievement.getExpReward() > 0) {
                    awardExp(userId, achievement.getExpReward(), AppConstants.EXP_SOURCE_ACHIEVEMENT,
                            String.valueOf(achievement.getAchievementId()),
                            "解锁成就: " + achievement.getName());
                }
            }
        }

        // 返回当前状态
        BizUserLevel userLevel = getOrCreateUserLevel(userId);
        result.setTotalExp(userLevel.getTotalExp());
        result.setLevel(userLevel.getLevel());

        return result;
    }

    // ==================== 等级 ====================

    @Override
    public UserLevelVO getLevelInfo(Long userId) {
        BizUserLevel userLevel = getOrCreateUserLevel(userId);
        UserLevelVO vo = new UserLevelVO();
        vo.setLevel(userLevel.getLevel());
        vo.setLevelName(LEVEL_NAMES[userLevel.getLevel()]);
        vo.setCurrentExp(userLevel.getCurrentExp());
        vo.setTotalExp(userLevel.getTotalExp());

        int nextLevel = userLevel.getLevel() + 1;
        if (nextLevel <= LEVEL_EXP.length - 1) {
            vo.setNextLevelExp(LEVEL_EXP[nextLevel]);
            int currentLevelExp = LEVEL_EXP[userLevel.getLevel()];
            int nextLevelExp = LEVEL_EXP[nextLevel];
            int rangeExp = nextLevelExp - currentLevelExp;
            int progressExp = userLevel.getTotalExp() - currentLevelExp;
            vo.setProgressPercent(rangeExp > 0 ? Math.round(progressExp * 100.0 / rangeExp * 10.0) / 10.0 : 100.0);
            vo.setExpToNextLevel(nextLevelExp - userLevel.getTotalExp());
        } else {
            vo.setNextLevelExp(LEVEL_EXP[LEVEL_EXP.length - 1]);
            vo.setProgressPercent(100.0);
            vo.setExpToNextLevel(0);
        }
        return vo;
    }

    @Override
    public Page<ExpLogVO> getExpLogPage(Long userId, String sourceType, int pageNum, int pageSize) {
        Page<ExpLogVO> page = new Page<>(pageNum, pageSize);
        return expLogMapper.selectExpLogPage(page, userId, sourceType);
    }

    // ==================== 目标 ====================

    @Override
    public LearningGoalVO getCurrentGoal(Long userId) {
        LearningGoalVO vo = new LearningGoalVO();
        LambdaQueryWrapper<BizLearningGoal> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(BizLearningGoal::getUserId, userId);
        List<BizLearningGoal> goals = learningGoalMapper.selectList(wrapper);

        vo.setDailyLearnTarget(20);
        vo.setDailyMasterTarget(10);
        vo.setEnabled(true);

        for (BizLearningGoal goal : goals) {
            if (AppConstants.GOAL_TYPE_DAILY_LEARN.equals(goal.getGoalType())) {
                vo.setDailyLearnTarget(goal.getTargetCount());
                vo.setEnabled(goal.getEnabled() == 1);
                vo.setReminderHour(goal.getReminderHour());
                vo.setReminderMinute(goal.getReminderMinute());
            } else if (AppConstants.GOAL_TYPE_DAILY_MASTER.equals(goal.getGoalType())) {
                vo.setDailyMasterTarget(goal.getTargetCount());
            }
        }
        return vo;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public LearningGoalVO setGoal(Long userId, GoalSetDTO dto) {
        LocalDate today = LocalDate.now();

        if (dto.getDailyLearnTarget() != null) {
            saveOrUpdateGoal(userId, AppConstants.GOAL_TYPE_DAILY_LEARN, dto.getDailyLearnTarget(), dto.getEnabled(), dto.getReminderHour(), dto.getReminderMinute());
            // 更新今日目标记录
            saveOrUpdateGoalRecord(userId, today, AppConstants.GOAL_TYPE_DAILY_LEARN, dto.getDailyLearnTarget());
        }
        if (dto.getDailyMasterTarget() != null) {
            saveOrUpdateGoal(userId, AppConstants.GOAL_TYPE_DAILY_MASTER, dto.getDailyMasterTarget(), dto.getEnabled(), dto.getReminderHour(), dto.getReminderMinute());
            saveOrUpdateGoalRecord(userId, today, AppConstants.GOAL_TYPE_DAILY_MASTER, dto.getDailyMasterTarget());
        }

        return getCurrentGoal(userId);
    }

    @Override
    public GoalProgressVO getGoalProgress(Long userId) {
        LocalDate today = LocalDate.now();
        LearningGoalVO goal = getCurrentGoal(userId);
        BizUserDailyCount count = dailyCountMapper.selectByUserAndDate(userId, today);

        GoalProgressVO vo = new GoalProgressVO();
        vo.setDate(today.toString());
        vo.setLearnTarget(goal.getDailyLearnTarget());
        vo.setMasterTarget(goal.getDailyMasterTarget());

        int learnProgress = count != null ? count.getLearnCount() : 0;
        int masterProgress = count != null ? count.getMasterCount() : 0;

        vo.setLearnProgress(learnProgress);
        vo.setMasterProgress(masterProgress);
        vo.setLearnCompleted(learnProgress >= goal.getDailyLearnTarget());
        vo.setMasterCompleted(masterProgress >= goal.getDailyMasterTarget());
        vo.setLearnPercent(goal.getDailyLearnTarget() > 0 ?
                Math.min(100.0, Math.round(learnProgress * 1000.0 / goal.getDailyLearnTarget()) / 10.0) : 0);
        vo.setMasterPercent(goal.getDailyMasterTarget() > 0 ?
                Math.min(100.0, Math.round(masterProgress * 1000.0 / goal.getDailyMasterTarget()) / 10.0) : 0);

        return vo;
    }

    @Override
    public List<GoalProgressVO> getWeekGoalProgress(Long userId) {
        LocalDate today = LocalDate.now();
        LocalDate startOfWeek = today.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
        LocalDate endOfWeek = today;

        List<GoalProgressVO> records = goalRecordMapper.selectWeekRecords(userId, startOfWeek, endOfWeek);
        LearningGoalVO goal = getCurrentGoal(userId);

        // 补充百分比计算
        for (GoalProgressVO record : records) {
            record.setLearnTarget(goal.getDailyLearnTarget());
            record.setMasterTarget(goal.getDailyMasterTarget());
            record.setLearnPercent(goal.getDailyLearnTarget() > 0 ?
                    Math.min(100.0, Math.round(record.getLearnProgress() * 1000.0 / goal.getDailyLearnTarget()) / 10.0) : 0);
            record.setMasterPercent(goal.getDailyMasterTarget() > 0 ?
                    Math.min(100.0, Math.round(record.getMasterProgress() * 1000.0 / goal.getDailyMasterTarget()) / 10.0) : 0);
        }
        return records;
    }

    // ==================== 排行榜 ====================

    @Override
    public Page<RankVO> getTotalRank(int pageNum, int pageSize) {
        int offset = (pageNum - 1) * pageSize;
        int total = userLevelMapper.countTotalRank();
        List<RankVO> records = userLevelMapper.selectTotalRank(offset, pageSize);
        Page<RankVO> page = new Page<>(pageNum, pageSize, total);
        page.setRecords(records);
        return page;
    }

    @Override
    public Page<RankVO> getWeekRank(int pageNum, int pageSize) {
        int offset = (pageNum - 1) * pageSize;
        int total = userLevelMapper.countWeekRank();
        List<RankVO> records = userLevelMapper.selectWeekRank(offset, pageSize);
        Page<RankVO> page = new Page<>(pageNum, pageSize, total);
        page.setRecords(records);
        return page;
    }

    @Override
    public Page<RankVO> getStreakRank(int pageNum, int pageSize) {
        int offset = (pageNum - 1) * pageSize;
        int total = userLevelMapper.countStreakRank();
        List<RankVO> records = userLevelMapper.selectStreakRank(offset, pageSize);
        Page<RankVO> page = new Page<>(pageNum, pageSize, total);
        page.setRecords(records);
        return page;
    }

    @Override
    public RankVO getUserRank(Long userId) {
        return userLevelMapper.selectUserRank(userId);
    }

    // ==================== 内部方法 ====================

    private BizUserLevel getOrCreateUserLevel(Long userId) {
        LambdaQueryWrapper<BizUserLevel> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(BizUserLevel::getUserId, userId);
        BizUserLevel userLevel = userLevelMapper.selectOne(wrapper);
        if (userLevel == null) {
            userLevel = new BizUserLevel();
            userLevel.setUserId(userId);
            userLevel.setLevel(1);
            userLevel.setCurrentExp(0);
            userLevel.setTotalExp(0);
            userLevelMapper.insert(userLevel);
        }
        return userLevel;
    }

    private int calculateLevel(int totalExp) {
        for (int i = LEVEL_EXP.length - 1; i >= 1; i--) {
            if (totalExp >= LEVEL_EXP[i]) {
                return i;
            }
        }
        return 1;
    }

    private void updateDailyCount(Long userId, String sourceType) {
        LocalDate today = LocalDate.now();
        BizUserDailyCount count = dailyCountMapper.selectByUserAndDate(userId, today);
        if (count == null) {
            count = new BizUserDailyCount();
            count.setUserId(userId);
            count.setCountDate(today);
            count.setLearnCount(0);
            count.setMasterCount(0);
            count.setReviewCount(0);
            dailyCountMapper.insert(count);
        }

        switch (sourceType) {
            case AppConstants.EXP_SOURCE_STUDY:
                count.setLearnCount(count.getLearnCount() + 1);
                break;
            case AppConstants.EXP_SOURCE_MASTER:
                count.setMasterCount(count.getMasterCount() + 1);
                break;
            case AppConstants.EXP_SOURCE_REVIEW:
                count.setReviewCount(count.getReviewCount() + 1);
                break;
        }
        dailyCountMapper.updateById(count);
    }

    private void updateGoalProgress(Long userId, String sourceType) {
        LocalDate today = LocalDate.now();
        List<BizGoalRecord> records = goalRecordMapper.selectByUserAndDate(userId, today);

        String goalType = null;
        if (AppConstants.EXP_SOURCE_STUDY.equals(sourceType)) {
            goalType = AppConstants.GOAL_TYPE_DAILY_LEARN;
        } else if (AppConstants.EXP_SOURCE_MASTER.equals(sourceType)) {
            goalType = AppConstants.GOAL_TYPE_DAILY_MASTER;
        }

        if (goalType == null) {
            return;
        }

        for (BizGoalRecord record : records) {
            if (goalType.equals(record.getGoalType())) {
                record.setActualCount(record.getActualCount() + 1);
                if (record.getActualCount() >= record.getTargetCount()) {
                    record.setCompleted(1);
                }
                goalRecordMapper.updateById(record);
                return;
            }
        }

        // 不存在则创建
        LearningGoalVO goal = getCurrentGoal(userId);
        int target = AppConstants.GOAL_TYPE_DAILY_LEARN.equals(goalType) ? goal.getDailyLearnTarget() : goal.getDailyMasterTarget();
        BizGoalRecord newRecord = new BizGoalRecord();
        newRecord.setUserId(userId);
        newRecord.setGoalDate(today);
        newRecord.setGoalType(goalType);
        newRecord.setTargetCount(target);
        newRecord.setActualCount(1);
        newRecord.setCompleted(0);
        goalRecordMapper.insert(newRecord);
    }

    private int getDailyCountSum(Long userId, String type) {
        BizUserDailyCount count = dailyCountMapper.selectByUserAndDate(userId, LocalDate.now());
        if (count == null) {
            return 0;
        }
        switch (type) {
            case AppConstants.COUNT_TYPE_LEARN: return count.getLearnCount();
            case AppConstants.COUNT_TYPE_MASTER: return count.getMasterCount();
            case AppConstants.COUNT_TYPE_REVIEW: return count.getReviewCount();
            default: return 0;
        }
    }

    private int getStreakDays(Long userId) {
        LambdaQueryWrapper<BizLearningStreak> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(BizLearningStreak::getUserId, userId);
        BizLearningStreak streak = streakMapper.selectOne(wrapper);
        return streak != null && streak.getCurrentStreak() != null ? streak.getCurrentStreak() : 0;
    }

    private boolean checkCountAchievement(AchievementVO achievement, int learnCount, int masterCount, int reviewCount) {
        switch (achievement.getCode()) {
            case AppConstants.ACHIEVE_FIRST_LEARN: return learnCount >= 1;
            case AppConstants.ACHIEVE_FIRST_MASTER: return masterCount >= 1;
            case AppConstants.ACHIEVE_FIRST_REVIEW: return reviewCount >= 1;
            case AppConstants.ACHIEVE_LEARN_50: return learnCount >= 50;
            case AppConstants.ACHIEVE_LEARN_100: return learnCount >= 100;
            case AppConstants.ACHIEVE_LEARN_300: return learnCount >= 300;
            case AppConstants.ACHIEVE_LEARN_500: return learnCount >= 500;
            case AppConstants.ACHIEVE_LEARN_1000: return learnCount >= 1000;
            case AppConstants.ACHIEVE_MASTER_10: return masterCount >= 10;
            case AppConstants.ACHIEVE_MASTER_50: return masterCount >= 50;
            case AppConstants.ACHIEVE_MASTER_100: return masterCount >= 100;
            case AppConstants.ACHIEVE_MASTER_300: return masterCount >= 300;
            case AppConstants.ACHIEVE_MASTER_500: return masterCount >= 500;
            default: return false;
        }
    }

    private boolean checkStreakAchievement(AchievementVO achievement, int streakDays) {
        if (streakDays < achievement.getConditionValue()) {
            return false;
        }
        return Arrays.asList(AppConstants.ACHIEVE_STREAK_3, AppConstants.ACHIEVE_STREAK_7, AppConstants.ACHIEVE_STREAK_14,
                        AppConstants.ACHIEVE_STREAK_30, AppConstants.ACHIEVE_STREAK_60, AppConstants.ACHIEVE_STREAK_100)
                .contains(achievement.getCode());
    }

    private boolean checkSocialAchievement(AchievementVO achievement, Long userId, String actionType) {
        // 简化处理：根据 actionType 匹配
        if (AppConstants.ACHIEVE_FIRST_COMMENT.equals(achievement.getCode()) && AppConstants.ACHIEVE_ALIAS_COMMENT.equals(actionType)) {
            return true;
        }
        if (AppConstants.ACHIEVE_FIRST_CONTRIBUTE.equals(achievement.getCode()) && AppConstants.ACHIEVE_ALIAS_CONTRIBUTE.equals(actionType)) {
            return true;
        }
        return false;
    }

    private void unlockAchievement(Long userId, AchievementVO achievement) {
        BizUserAchievement ua = new BizUserAchievement();
        ua.setUserId(userId);
        ua.setAchievementId(achievement.getAchievementId());
        ua.setAchievementCode(achievement.getCode());
        ua.setAchievedAt(LocalDateTime.now());
        userAchievementMapper.insert(ua);
        achievement.setUnlocked(true);
        achievement.setAchievedAt(LocalDateTime.now());
        log.info("用户 {} 解锁成就: {}", userId, achievement.getName());
    }

    private void saveOrUpdateGoal(Long userId, String goalType, Integer targetCount, Boolean enabled, Integer reminderHour, Integer reminderMinute) {
        LambdaQueryWrapper<BizLearningGoal> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(BizLearningGoal::getUserId, userId)
                .eq(BizLearningGoal::getGoalType, goalType);
        BizLearningGoal existing = learningGoalMapper.selectOne(wrapper);

        if (existing != null) {
            if (targetCount != null) {
                existing.setTargetCount(targetCount);
            }
            if (enabled != null) {
                existing.setEnabled(enabled ? 1 : 0);
            }
            if (reminderHour != null) {
                existing.setReminderHour(reminderHour);
            }
            if (reminderMinute != null) {
                existing.setReminderMinute(reminderMinute);
            }
            learningGoalMapper.updateById(existing);
        } else {
            BizLearningGoal goal = new BizLearningGoal();
            goal.setUserId(userId);
            goal.setGoalType(goalType);
            goal.setTargetCount(targetCount != null ? targetCount : 20);
            goal.setEnabled(enabled != null && enabled ? 1 : 0);
            goal.setReminderHour(reminderHour);
            goal.setReminderMinute(reminderMinute);
            learningGoalMapper.insert(goal);
        }
    }

    private void saveOrUpdateGoalRecord(Long userId, LocalDate date, String goalType, int targetCount) {
        LambdaQueryWrapper<BizGoalRecord> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(BizGoalRecord::getUserId, userId)
                .eq(BizGoalRecord::getGoalDate, date)
                .eq(BizGoalRecord::getGoalType, goalType);
        BizGoalRecord existing = goalRecordMapper.selectOne(wrapper);

        if (existing != null) {
            existing.setTargetCount(targetCount);
            existing.setCompleted(existing.getActualCount() >= targetCount ? 1 : 0);
            goalRecordMapper.updateById(existing);
        } else {
            BizGoalRecord record = new BizGoalRecord();
            record.setUserId(userId);
            record.setGoalDate(date);
            record.setGoalType(goalType);
            record.setTargetCount(targetCount);
            record.setActualCount(0);
            record.setCompleted(0);
            goalRecordMapper.insert(record);
        }
    }
}
