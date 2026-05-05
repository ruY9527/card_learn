package com.card.learn.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.card.learn.entity.BizUserLevel;
import com.card.learn.vo.RankVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 用户等级Mapper接口
 */
@Mapper
public interface BizUserLevelMapper extends BaseMapper<BizUserLevel> {

    /**
     * 查询总排行榜
     */
    List<RankVO> selectTotalRank(@Param("offset") int offset, @Param("limit") int limit);

    /**
     * 查询周排行榜（本周学习数量）
     */
    List<RankVO> selectWeekRank(@Param("offset") int offset, @Param("limit") int limit);

    /**
     * 查询连击排行榜
     */
    List<RankVO> selectStreakRank(@Param("offset") int offset, @Param("limit") int limit);

    /**
     * 查询总排行榜总数
     */
    int countTotalRank();

    /**
     * 查询周排行榜总数
     */
    int countWeekRank();

    /**
     * 查询连击排行榜总数
     */
    int countStreakRank();

    /**
     * 查询用户排名信息
     */
    RankVO selectUserRank(@Param("userId") Long userId);
}
