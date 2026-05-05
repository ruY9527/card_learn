package com.card.learn.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.card.learn.entity.BizUserAchievement;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * 用户成就记录Mapper接口
 */
@Mapper
public interface BizUserAchievementMapper extends BaseMapper<BizUserAchievement> {

    /**
     * 统计用户已解锁成就数
     */
    int countByUserId(@Param("userId") Long userId);

    /**
     * 检查用户是否已解锁某成就
     */
    int countByUserAndCode(@Param("userId") Long userId, @Param("achievementCode") String achievementCode);
}
