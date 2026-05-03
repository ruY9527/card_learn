package com.card.learn.service.impl;

import com.card.learn.mapper.BizUserProgressMapper;
import com.card.learn.service.ILearningStatsService;
import com.card.learn.vo.DailyLearnTrendVO;
import com.card.learn.vo.LearningStatsVO;
import com.card.learn.vo.SubjectLearnStatsVO;
import com.card.learn.vo.UserLearnRankVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * 学习数据统计Service实现
 */
@Service
public class LearningStatsServiceImpl implements ILearningStatsService {

    @Autowired
    private BizUserProgressMapper progressMapper;

    @Override
    public LearningStatsVO getOverallStats(Long userId) {
        LearningStatsVO stats = progressMapper.selectOverallStats(userId);
        if (stats == null) {
            stats = new LearningStatsVO();
            stats.setTotalCards(0L);
            stats.setLearnDays(0L);
            stats.setTotalLearnRecords(0L);
            stats.setUnlearnedCount(0L);
            stats.setFuzzyCount(0L);
            stats.setMasteredCount(0L);
            stats.setLearnedRate(java.math.BigDecimal.ZERO);
        }
        return stats;
    }

    @Override
    public List<DailyLearnTrendVO> getDailyTrend(Integer days, Long userId) {
        if (days == null || days <= 0) {
            days = 30;
        }
        String startDate = LocalDate.now().minusDays(days).format(DateTimeFormatter.ISO_LOCAL_DATE);
        return progressMapper.selectDailyTrend(startDate, userId);
    }

    @Override
    public List<UserLearnRankVO> getUserRanking(Integer limit) {
        if (limit == null || limit <= 0) {
            limit = 10;
        }
        return progressMapper.selectUserRanking(limit);
    }

    @Override
    public List<SubjectLearnStatsVO> getSubjectStats(Long userId) {
        return progressMapper.selectSubjectStats(userId);
    }
}
