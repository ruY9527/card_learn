package com.card.learn.service.impl;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.dto.AdminReviewPlanQueryDTO;
import com.card.learn.dto.DeviceRegisterDTO;
import com.card.learn.dto.SM2ReviewDTO;
import com.card.learn.entity.*;
import com.card.learn.mapper.*;
import com.card.learn.service.ILearningService;
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

    @Override
    public SM2ProgressVO getSM2Progress(Long userId, Long cardId) {
        BizUserProgress progress = progressMapper.selectByUserIdAndCardId(userId, cardId);

        SM2ProgressVO vo = new SM2ProgressVO();
        vo.setCardId(cardId);

        if (progress != null && progress.getNextReviewTime() != null) {
            // 从复习计划中获取SM-2参数
            BizReviewPlan plan = reviewPlanMapper.selectLatestPendingByUserAndCard(userId, cardId);
            if (plan != null) {
                vo.setNextReviewTime(progress.getNextReviewTime());
            }
        }

        // 默认值
        if (vo.getEaseFactor() == null) vo.setEaseFactor(2.5);
        if (vo.getRepetitions() == null) vo.setRepetitions(0);
        if (vo.getInterval() == null) vo.setInterval(1);

        return vo;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void submitReview(SM2ReviewDTO dto) {
        // 1. 更新用户进度
        BizUserProgress progress = progressMapper.selectByUserIdAndCardId(dto.getUserId(), dto.getCardId());

        // 根据quality映射status: >=3为掌握(2), 1-2为模糊(1), 0为未学(0)
        int status = dto.getQuality() >= 3 ? 2 : (dto.getQuality() >= 1 ? 1 : 0);

        LocalDateTime nextReviewTime = ZonedDateTime.parse(dto.getNextReviewTime(),
            DateTimeFormatter.ISO_ZONED_DATE_TIME).toLocalDateTime();

        if (progress == null) {
            progress = new BizUserProgress();
            progress.setUserId(dto.getUserId());
            progress.setCardId(dto.getCardId());
            progress.setStatus(status);
            progress.setNextReviewTime(nextReviewTime);
            progressMapper.insert(progress);
        } else {
            progress.setStatus(status);
            progress.setNextReviewTime(nextReviewTime);
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
    public List<ReviewPlanVO> getReviewPlan(Long userId) {
        return reviewPlanMapper.selectReviewPlan(userId, LocalDate.now());
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
        return reviewPlanMapper.selectAdminReviewPlan(page, queryDTO.getUserId(), queryDTO.getStatus(), queryDTO.getScheduledDate());
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
