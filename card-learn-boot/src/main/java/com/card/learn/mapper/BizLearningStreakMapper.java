package com.card.learn.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.card.learn.entity.BizLearningStreak;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * 学习连续记录Mapper
 */
@Mapper
public interface BizLearningStreakMapper extends BaseMapper<BizLearningStreak> {

    BizLearningStreak selectByUserId(@Param("userId") Long userId);

}
