package com.card.learn.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.entity.BizCardDraft;
import com.card.learn.vo.CardAuditVO;
import com.card.learn.vo.MyCardVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * 用户录入卡片临时表Mapper
 */
@Mapper
public interface BizCardDraftMapper extends BaseMapper<BizCardDraft> {

    /**
     * 分页查询待审批卡片（关联科目名称、创建用户昵称）
     */
    Page<CardAuditVO> selectPendingDrafts(Page<CardAuditVO> page, @Param("auditStatus") String auditStatus);

    /**
     * 分页查询用户录入的卡片（我的卡片）
     */
    Page<MyCardVO> selectMyDrafts(Page<MyCardVO> page, @Param("createUserId") Long createUserId, @Param("auditStatus") String auditStatus);

}
