package com.card.learn.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.card.learn.entity.BizUserDailyCount;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDate;

/**
 * 用户每日学习计数Mapper接口
 */
@Mapper
public interface BizUserDailyCountMapper extends BaseMapper<BizUserDailyCount> {

    /**
     * 查询用户某日学习计数
     */
    BizUserDailyCount selectByUserAndDate(@Param("userId") Long userId, @Param("countDate") LocalDate countDate);
}
