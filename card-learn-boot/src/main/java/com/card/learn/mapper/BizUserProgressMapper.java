package com.card.learn.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.card.learn.entity.BizUserProgress;
import com.card.learn.vo.DailyLearnTrendVO;
import com.card.learn.vo.LearningStatsVO;
import com.card.learn.vo.SubjectLearnStatsVO;
import com.card.learn.vo.UserLearnRankVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 用户学习进度Mapper
 */
@Mapper
public interface BizUserProgressMapper extends BaseMapper<BizUserProgress> {

    /**
     * 总体学习统计
     */
    LearningStatsVO selectOverallStats(@Param("userId") Long userId);

    /**
     * 每日学习趋势
     */
    List<DailyLearnTrendVO> selectDailyTrend(@Param("startDate") String startDate, @Param("userId") Long userId);

    /**
     * 用户学习排行榜
     */
    List<UserLearnRankVO> selectUserRanking(@Param("limit") Integer limit);

    /**
     * 科目维度学习统计
     */
    List<SubjectLearnStatsVO> selectSubjectStats(@Param("userId") Long userId);

    BizUserProgress selectByUserIdAndCardId(@Param("userId") Long userId, @Param("cardId") Long cardId);

    Long countByCondition(@Param("userId") Long userId, @Param("minStatus") Integer minStatus, @Param("maxStatus") Integer maxStatus, @Param("startTime") LocalDateTime startTime, @Param("endTime") LocalDateTime endTime);
}