package com.card.learn.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.card.learn.entity.BizCardTag;
import com.card.learn.entity.BizTag;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 卡片标签关联Mapper
 */
@Mapper
public interface BizCardTagMapper extends BaseMapper<BizCardTag> {

    /**
     * 根据卡片ID查询标签列表
     */
    List<BizTag> selectTagsByCardId(@Param("cardId") Long cardId);

    /**
     * 删除卡片的所有标签关联
     */
    int deleteByCardId(@Param("cardId") Long cardId);

    /**
     * 批量插入卡片标签关联
     */
    int batchInsert(@Param("cardId") Long cardId, @Param("tagIds") List<Long> tagIds);

}