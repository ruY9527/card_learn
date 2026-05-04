package com.card.learn.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.entity.BizCard;
import com.card.learn.vo.CardAuditVO;
import com.card.learn.vo.CardVO;
import com.card.learn.vo.MyCardVO;
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
    Page<CardVO> selectCardsWithSubjectName(Page<CardVO> page, @Param("subjectId") Long subjectId, @Param("frontContent") String frontContent);

    /**
     * 分页查询待审批卡片（关联科目名称、创建用户昵称）
     */
    Page<CardAuditVO> selectPendingCards(Page<CardAuditVO> page, @Param("auditStatus") String auditStatus);

    /**
     * 分页查询用户录入的卡片（我的卡片）
     */
    Page<MyCardVO> selectMyCards(Page<MyCardVO> page, @Param("createBy") Long createBy);

    Page<BizCard> selectPageCardList(Page<BizCard> page, @Param("subjectId") Long subjectId, @Param("frontContent") String frontContent);

}