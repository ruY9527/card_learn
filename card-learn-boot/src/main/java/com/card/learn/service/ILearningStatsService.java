package com.card.learn.service;

import com.card.learn.vo.DailyLearnTrendVO;
import com.card.learn.vo.LearningStatsVO;
import com.card.learn.vo.SubjectLearnStatsVO;
import com.card.learn.vo.UserLearnRankVO;

import java.util.List;

/**
 * 学习数据统计Service
 */
public interface ILearningStatsService {

    /**
     * 总体学习统计
     * @param userId 用户ID，null表示全局统计
     */
    LearningStatsVO getOverallStats(Long userId);

    /**
     * 每日学习趋势
     * @param userId 用户ID，null表示全局统计
     */
    List<DailyLearnTrendVO> getDailyTrend(Integer days, Long userId);

    /**
     * 用户学习排行榜
     */
    List<UserLearnRankVO> getUserRanking(Integer limit);

    /**
     * 科目维度学习统计
     * @param userId 用户ID，null表示全局统计
     */
    List<SubjectLearnStatsVO> getSubjectStats(Long userId);
}
