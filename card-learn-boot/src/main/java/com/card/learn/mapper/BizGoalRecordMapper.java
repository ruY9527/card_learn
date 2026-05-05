package com.card.learn.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.card.learn.entity.BizGoalRecord;
import com.card.learn.vo.GoalProgressVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDate;
import java.util.List;

/**
 * 每日目标完成记录Mapper接口
 */
@Mapper
public interface BizGoalRecordMapper extends BaseMapper<BizGoalRecord> {

    /**
     * 查询某日目标完成情况
     */
    List<BizGoalRecord> selectByUserAndDate(@Param("userId") Long userId, @Param("goalDate") LocalDate goalDate);

    /**
     * 查询本周目标完成情况
     */
    List<GoalProgressVO> selectWeekRecords(@Param("userId") Long userId,
                                            @Param("startDate") LocalDate startDate,
                                            @Param("endDate") LocalDate endDate);
}
