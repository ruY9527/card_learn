package com.card.learn.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.card.learn.entity.BizStudyHistory;
import com.card.learn.vo.DailyLearnTrendVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 学习历史记录Mapper
 */
@Mapper
public interface BizStudyHistoryMapper extends BaseMapper<BizStudyHistory> {

    /**
     * 查询每日学习趋势（基于学习历史事件表，数据最准确）
     */
    List<DailyLearnTrendVO> selectDailyTrend(@Param("startDate") String startDate, @Param("userId") Long userId);

    /**
     * 查询用户日期范围内的学习历史
     */
    List<BizStudyHistory> selectByUserAndDateRange(@Param("userId") Long userId,
                                                    @Param("startTime") LocalDateTime startTime,
                                                    @Param("endTime") LocalDateTime endTime);

}
