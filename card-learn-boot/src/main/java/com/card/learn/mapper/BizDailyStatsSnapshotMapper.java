package com.card.learn.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.card.learn.entity.BizDailyStatsSnapshot;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDate;
import java.util.List;

/**
 * 每日统计快照Mapper
 */
@Mapper
public interface BizDailyStatsSnapshotMapper extends BaseMapper<BizDailyStatsSnapshot> {

    /**
     * 查询用户日期范围内的统计快照
     */
    List<BizDailyStatsSnapshot> selectByUserAndDateRange(@Param("userId") Long userId,
                                                          @Param("startDate") LocalDate startDate,
                                                          @Param("endDate") LocalDate endDate);
}
