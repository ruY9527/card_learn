package com.card.learn.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.card.learn.entity.BizAchievement;
import com.card.learn.vo.AchievementVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 成就定义Mapper接口
 */
@Mapper
public interface BizAchievementMapper extends BaseMapper<BizAchievement> {

    /**
     * 查询成就列表（含用户解锁状态）
     */
    List<AchievementVO> selectAchievementList(@Param("userId") Long userId, @Param("category") String category);
}
