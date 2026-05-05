package com.card.learn.service.impl;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.dto.AdminReviewPlanQueryDTO;
import com.card.learn.dto.DeviceRegisterDTO;
import com.card.learn.dto.SimpleReviewDTO;
import com.card.learn.dto.SM2ReviewDTO;
import com.card.learn.util.SM2Algorithm;
import com.card.learn.entity.*;
import com.card.learn.mapper.*;
import com.card.learn.dto.AchievementCheckDTO;
import com.card.learn.service.IBizStudyHistoryService;
import com.card.learn.service.IIncentiveService;
import com.card.learn.service.ILearningService;
import com.card.learn.service.IWeakPointService;
import com.card.learn.vo.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 学习服务实现
 */
@Service
public class LearningServiceImpl implements ILearningService {

    @Autowired
    private BizUserProgressMapper progressMapper;

    @Autowired
    private BizReviewPlanMapper reviewPlanMapper;

    @Autowired
    private BizLearningStreakMapper streakMapper;

    @Autowired
    private BizUserDeviceMapper deviceMapper;

    @Autowired
    private BizStudyHistoryMapper studyHistoryMapper;

    @Autowired
    private IBizStudyHistoryService studyHistoryService;

    @Autowired
    private IIncentiveService incentiveService;

    @Autowired
    private IWeakPointService weakPointService;

    @Override
    public SM2ProgressVO getSM2Progress(Long userId, Long cardId) {
        BizUserProgress progress = progressMapper.selectByUserIdAndCardId(userId, cardId);

        SM2ProgressVO vo = new SM2ProgressVO();
        vo.setCardId(cardId);

        if (progress != null) {
            vo.setEaseFactor(progress.getEaseFactor() != null ? progress.getEaseFactor() : 2.5);
            vo.setRepetitions(progress.getRepetitions() != null ? progress.getRepetitions() : 0);
            vo.setInterval(progress.getIntervalDays() != null ? progress.getIntervalDays() : 1);
            vo.setNextReviewTime(progress.getNextReviewTime());
        } else {
            vo.setEaseFactor(2.5);
            vo.setRepetitions(0);
            vo.setInterval(1);
        }

        return vo;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void submitReview(SM2ReviewDTO dto) {
        // 1. 更新用户进度
        BizUserProgress progress = progressMapper.selectByUserIdAndCardId(dto.getUserId(), dto.getCardId());

        // 根据quality映射status: >=3为掌握(2), 1-2为模糊(1), 0为未学(0)
        int status = dto.getQuality() >= 3 ? 2 : (dto.getQuality() >= 1 ? 1 : 0);

        // 支持多种时间格式：yyyy-MM-dd HH:mm:ss、ISO 8601（带T和时区）
        LocalDateTime nextReviewTime;
        String timeStr = dto.getNextReviewTime();
        try {
            nextReviewTime = LocalDateTime.parse(timeStr, DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        } catch (Exception e) {
            try {
                nextReviewTime = LocalDateTime.parse(timeStr, DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss"));
            } catch (Exception e2) {
                nextReviewTime = ZonedDateTime.parse(timeStr, DateTimeFormatter.ISO_ZONED_DATE_TIME).toLocalDateTime();
            }
        }

        if (progress == null) {
            progress = new BizUserProgress();
            progress.setUserId(dto.getUserId());
            progress.setCardId(dto.getCardId());
            progress.setStatus(status);
            progress.setNextReviewTime(nextReviewTime);
            progress.setEaseFactor(dto.getEaseFactor());
            progress.setRepetitions(dto.getRepetitions());
            progress.setIntervalDays(dto.getInterval());
            progressMapper.insert(progress);
        } else {
            progress.setStatus(status);
            progress.setNextReviewTime(nextReviewTime);
            progress.setEaseFactor(dto.getEaseFactor());
            progress.setRepetitions(dto.getRepetitions());
            progress.setIntervalDays(dto.getInterval());
            progressMapper.updateById(progress);
        }

        // 2. 创建/更新复习计划
        BizReviewPlan plan = reviewPlanMapper.selectPendingByUserAndCard(dto.getUserId(), dto.getCardId());

        if (plan != null) {
            plan.setStatus("1");
            plan.setActualReviewDate(LocalDateTime.now());
            plan.setSm2Quality(dto.getQuality());
            reviewPlanMapper.updateById(plan);
        }

        // 创建新的复习计划
        BizReviewPlan newPlan = new BizReviewPlan();
        newPlan.setUserId(dto.getUserId());
        newPlan.setCardId(dto.getCardId());
        newPlan.setScheduledDate(nextReviewTime.toLocalDate());
        newPlan.setStatus("0");
        reviewPlanMapper.insert(newPlan);

        // 3. 记录学习历史
        BizStudyHistory history = new BizStudyHistory();
        history.setUserId(dto.getUserId());
        history.setCardId(dto.getCardId());
        history.setStatus(status);
        history.setCreateTime(LocalDateTime.now());
        studyHistoryMapper.insert(history);

        // 4. 更新学习连续记录
        updateLearningStreak(dto.getUserId());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ReviewResultVO submitSimpleReview(SimpleReviewDTO dto) {
        // 1. 映射 status -> SM-2 quality: 0->0, 1->3, 2->5
        int quality;
        switch (dto.getStatus()) {
            case 0:
                quality = 0;
                break;
            case 1:
                quality = 3;
                break;
            case 2:
                quality = 5;
                break;
            default:
                quality = 3;
        }

        // 2. 加载当前 SM-2 状态
        BizUserProgress progress = progressMapper.selectByUserIdAndCardId(dto.getUserId(), dto.getCardId());

        double currentEF = 2.5;
        int currentReps = 0;
        int currentInterval = 1;

        if (progress != null) {
            if (progress.getEaseFactor() != null) {
                currentEF = progress.getEaseFactor();
            }
            if (progress.getRepetitions() != null) {
                currentReps = progress.getRepetitions();
            }
            if (progress.getIntervalDays() != null) {
                currentInterval = progress.getIntervalDays();
            }
        }

        // 3. 计算 SM-2
        SM2Algorithm.SM2Result sm2Result = SM2Algorithm.calculate(quality, currentEF, currentReps, currentInterval);

        // 4. 更新用户进度
        LocalDateTime nextReviewTime = LocalDateTime.now().plusDays(sm2Result.getInterval());

        if (progress == null) {
            progress = new BizUserProgress();
            progress.setUserId(dto.getUserId());
            progress.setCardId(dto.getCardId());
            progress.setStatus(dto.getStatus());
            progress.setNextReviewTime(nextReviewTime);
            progress.setEaseFactor(sm2Result.getEaseFactor());
            progress.setRepetitions(sm2Result.getRepetitions());
            progress.setIntervalDays(sm2Result.getInterval());
            progressMapper.insert(progress);
        } else {
            progress.setStatus(dto.getStatus());
            progress.setNextReviewTime(nextReviewTime);
            progress.setEaseFactor(sm2Result.getEaseFactor());
            progress.setRepetitions(sm2Result.getRepetitions());
            progress.setIntervalDays(sm2Result.getInterval());
            progressMapper.updateById(progress);
        }

        // 5. 创建/更新复习计划
        BizReviewPlan plan = reviewPlanMapper.selectPendingByUserAndCard(dto.getUserId(), dto.getCardId());
        if (plan != null) {
            plan.setStatus("1");
            plan.setActualReviewDate(LocalDateTime.now());
            plan.setSm2Quality(quality);
            reviewPlanMapper.updateById(plan);
        }

        BizReviewPlan newPlan = new BizReviewPlan();
        newPlan.setUserId(dto.getUserId());
        newPlan.setCardId(dto.getCardId());
        newPlan.setScheduledDate(nextReviewTime.toLocalDate());
        newPlan.setStatus("0");
        reviewPlanMapper.insert(newPlan);

        // 6. 记录学习历史
        BizStudyHistory history = new BizStudyHistory();
        history.setUserId(dto.getUserId());
        history.setCardId(dto.getCardId());
        history.setStatus(dto.getStatus());
        history.setCreateTime(LocalDateTime.now());
        studyHistoryMapper.insert(history);

        // 7. 更新学习连续记录
        updateLearningStreak(dto.getUserId());

        // 8. 记录薄弱点
        weakPointService.recordWeakPoint(dto.getUserId(), dto.getCardId(), dto.getStatus());

        // 9. 激励系统：发放经验值 + 检查成就
        String cardIdStr = String.valueOf(dto.getCardId());
        incentiveService.awardExp(dto.getUserId(), 1, "STUDY", cardIdStr, "学习卡片");
        if (dto.getStatus() == 2) {
            incentiveService.awardExp(dto.getUserId(), 5, "MASTER", cardIdStr, "掌握卡片");
        }

        AchievementCheckDTO checkDTO = new AchievementCheckDTO();
        checkDTO.setUserId(dto.getUserId());
        checkDTO.setActionType("learn");
        checkDTO.setSourceId(cardIdStr);
        incentiveService.checkAndUnlockAchievement(checkDTO);

        if (dto.getStatus() == 2) {
            AchievementCheckDTO masterCheckDTO = new AchievementCheckDTO();
            masterCheckDTO.setUserId(dto.getUserId());
            masterCheckDTO.setActionType("master");
            masterCheckDTO.setSourceId(cardIdStr);
            incentiveService.checkAndUnlockAchievement(masterCheckDTO);
        }

        // 9. 构建返回结果
        ReviewResultVO result = new ReviewResultVO();
        result.setCardId(dto.getCardId());
        result.setStatus(dto.getStatus());
        result.setEaseFactor(sm2Result.getEaseFactor());
        result.setRepetitions(sm2Result.getRepetitions());
        result.setIntervalDays(sm2Result.getInterval());
        result.setNextReviewTime(nextReviewTime);

        return result;
    }

    @Override
    public List<ReviewPlanVO> getReviewPlan(Long userId) {
        List<ReviewPlanVO> plans = reviewPlanMapper.selectReviewPlan(userId, LocalDate.now());

        // 按 cardId 去重，保留 scheduledDate 最早的
        Map<Long, ReviewPlanVO> dedupMap = new LinkedHashMap<>();
        for (ReviewPlanVO plan : plans) {
            dedupMap.putIfAbsent(plan.getCardId(), plan);
        }
        List<ReviewPlanVO> deduped = new ArrayList<>(dedupMap.values());

        // 批量查询学习次数
        List<Long> cardIds = deduped.stream().map(ReviewPlanVO::getCardId).collect(Collectors.toList());
        Map<Long, Integer> countMap = studyHistoryService.batchGetStudyCount(userId, cardIds);
        for (ReviewPlanVO plan : deduped) {
            plan.setStudyCount(countMap.getOrDefault(plan.getCardId(), 0));
        }

        return deduped;
    }

    @Override
    public List<SubjectProgressVO> getSubjectProgress(Long userId) {
        // 1. 查询各科目卡片总数
        List<SubjectTotalVO> totals = reviewPlanMapper.selectSubjectCardTotals();

        // 2. 查询各科目各状态进度数
        List<SubjectStatusCountVO> statusCounts = reviewPlanMapper.selectSubjectStatusCounts(userId);

        // 3. Java代码计算掌握度
        Map<Long, SubjectTotalVO> totalMap = totals.stream()
            .collect(Collectors.toMap(SubjectTotalVO::getSubjectId, t -> t));

        Map<Long, Map<Integer, Integer>> statusMap = statusCounts.stream()
            .collect(Collectors.groupingBy(
                SubjectStatusCountVO::getSubjectId,
                Collectors.toMap(SubjectStatusCountVO::getStatus, SubjectStatusCountVO::getCount)
            ));

        List<SubjectProgressVO> result = new ArrayList<>();
        for (SubjectTotalVO total : totals) {
            if (total.getTotalCards() == null || total.getTotalCards() == 0) continue;

            SubjectProgressVO vo = new SubjectProgressVO();
            vo.setSubjectId(total.getSubjectId());
            vo.setSubjectName(total.getSubjectName());
            vo.setMajorId(total.getMajorId());
            vo.setMajorName(total.getMajorName());
            vo.setTotalCards(total.getTotalCards());

            Map<Integer, Integer> statusCount = statusMap.getOrDefault(total.getSubjectId(), Map.of());
            int masteredCount = statusCount.getOrDefault(2, 0);
            int learnedCount = statusCount.getOrDefault(1, 0) + masteredCount;

            vo.setMasteredCount(masteredCount);
            vo.setLearnedCount(learnedCount);

            double masteryRate = Math.round(masteredCount * 1000.0 / total.getTotalCards()) / 10.0;
            vo.setMasteryRate(masteryRate);

            result.add(vo);
        }
        return result;
    }

    @Override
    public UserStreakVO getLearningStats(Long userId) {
        UserStreakVO vo = new UserStreakVO();

        // 获取连续记录
        BizLearningStreak streak = streakMapper.selectByUserId(userId);

        if (streak != null) {
            vo.setCurrentStreak(streak.getCurrentStreak());
            vo.setLongestStreak(streak.getLongestStreak());
            vo.setTotalStudyDays(streak.getTotalDays());
        } else {
            vo.setCurrentStreak(0);
            vo.setLongestStreak(0);
            vo.setTotalStudyDays(0);
        }

        // 今日学习统计
        LocalDate today = LocalDate.now();
        LocalDateTime startOfDay = today.atStartOfDay();
        LocalDateTime endOfDay = today.plusDays(1).atStartOfDay();

        Long masteredToday = progressMapper.countByCondition(userId, 2, 2, startOfDay, endOfDay);
        vo.setMasteredToday(masteredToday.intValue());

        Long learnedToday = progressMapper.countByCondition(userId, 1, null, startOfDay, endOfDay);
        vo.setLearnedToday(learnedToday.intValue());

        return vo;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void registerDevice(DeviceRegisterDTO dto) {
        BizUserDevice device = deviceMapper.selectByDeviceToken(dto.getDeviceToken());

        if (device == null) {
            device = new BizUserDevice();
            device.setUserId(dto.getUserId());
            device.setDeviceToken(dto.getDeviceToken());
            device.setDeviceType(dto.getDeviceType());
            device.setPushEnabled("1");
            device.setLastActiveTime(LocalDateTime.now());
            deviceMapper.insert(device);
        } else {
            device.setUserId(dto.getUserId());
            device.setLastActiveTime(LocalDateTime.now());
            deviceMapper.updateById(device);
        }
    }

    @Override
    public Page<AdminReviewPlanVO> getAdminReviewPlan(AdminReviewPlanQueryDTO queryDTO) {
        Page<AdminReviewPlanVO> page = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize());
        Page<AdminReviewPlanVO> result = reviewPlanMapper.selectAdminReviewPlan(page, queryDTO.getUserId(), queryDTO.getStatus(), queryDTO.getScheduledDateStart(), queryDTO.getScheduledDateEnd());

        // 按 userId+cardId 去重，保留 scheduledDate 最新的
        Map<String, AdminReviewPlanVO> dedupMap = new LinkedHashMap<>();
        for (AdminReviewPlanVO vo : result.getRecords()) {
            String key = vo.getUserId() + "_" + vo.getCardId();
            // 因为 SQL 按 scheduledDate DESC 排序，第一个就是最新的
            dedupMap.putIfAbsent(key, vo);
        }
        List<AdminReviewPlanVO> deduped = new ArrayList<>(dedupMap.values());

        // 批量查询学习次数（按用户分组）
        Map<Long, List<Long>> userCardMap = new HashMap<>();
        for (AdminReviewPlanVO vo : deduped) {
            userCardMap.computeIfAbsent(vo.getUserId(), k -> new ArrayList<>()).add(vo.getCardId());
        }
        for (Map.Entry<Long, List<Long>> entry : userCardMap.entrySet()) {
            Map<Long, Integer> countMap = studyHistoryService.batchGetStudyCount(entry.getKey(), entry.getValue());
            for (AdminReviewPlanVO vo : deduped) {
                if (vo.getUserId().equals(entry.getKey())) {
                    vo.setStudyCount(countMap.getOrDefault(vo.getCardId(), 0));
                }
            }
        }

        result.setRecords(deduped);
        result.setTotal(deduped.size());
        return result;
    }

    private void updateLearningStreak(Long userId) {
        LocalDate today = LocalDate.now();

        BizLearningStreak streak = streakMapper.selectByUserId(userId);

        if (streak == null) {
            streak = new BizLearningStreak();
            streak.setUserId(userId);
            streak.setCurrentStreak(1);
            streak.setLongestStreak(1);
            streak.setLastStudyDate(today);
            streak.setTotalDays(1);
            streakMapper.insert(streak);
        } else {
            if (streak.getLastStudyDate() == null) {
                streak.setCurrentStreak(1);
                streak.setTotalDays(streak.getTotalDays() + 1);
            } else if (streak.getLastStudyDate().equals(today)) {
                // 今天已记录，不重复
                return;
            } else if (streak.getLastStudyDate().equals(today.minusDays(1))) {
                // 连续
                streak.setCurrentStreak(streak.getCurrentStreak() + 1);
                streak.setTotalDays(streak.getTotalDays() + 1);
            } else {
                // 断了
                streak.setCurrentStreak(1);
                streak.setTotalDays(streak.getTotalDays() + 1);
            }

            if (streak.getCurrentStreak() > streak.getLongestStreak()) {
                streak.setLongestStreak(streak.getCurrentStreak());
            }
            streak.setLastStudyDate(today);
            streakMapper.updateById(streak);
        }
    }
}
