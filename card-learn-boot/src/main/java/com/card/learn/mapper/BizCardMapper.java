package com.card.learn.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.entity.BizCard;
import com.card.learn.vo.CardVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * 知识点卡片Mapper
 */
@Mapper
public interface BizCardMapper extends BaseMapper<BizCard> {

    /**
     * 分页查询卡片（关联科目名称）
     */
    Page<CardVO> selectCardsWithSubjectName(Page<CardVO> page, @Param("subjectId") Long subjectId);

}