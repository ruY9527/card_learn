package com.card.learn.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.card.learn.entity.BizWeakPoint;
import com.card.learn.vo.WeakPointVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 薄弱点Mapper
 */
@Mapper
public interface BizWeakPointMapper extends BaseMapper<BizWeakPoint> {

    /**
     * 查询用户薄弱点列表
     */
    List<WeakPointVO> selectWeakPointList(@Param("userId") Long userId,
                                           @Param("offset") Integer offset,
                                           @Param("size") Integer size);

    /**
     * 查询用户薄弱点总数
     */
    int selectWeakPointCount(@Param("userId") Long userId);

    /**
     * 按用户和卡片查找薄弱点
     */
    BizWeakPoint selectByUserAndCard(@Param("userId") Long userId,
                                      @Param("cardId") Long cardId);

    /**
     * 删除用户卡片的薄弱点
     */
    int deleteByUserAndCard(@Param("userId") Long userId,
                            @Param("cardId") Long cardId);
}
