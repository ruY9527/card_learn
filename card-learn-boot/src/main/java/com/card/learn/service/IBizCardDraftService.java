package com.card.learn.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.card.learn.dto.AuditCardQueryDTO;
import com.card.learn.dto.CardAuditDTO;
import com.card.learn.dto.CardCreateDTO;
import com.card.learn.dto.MyCardQueryDTO;
import com.card.learn.entity.BizCardDraft;
import com.card.learn.vo.CardAuditVO;
import com.card.learn.vo.MyCardVO;

/**
 * 用户录入卡片临时表Service
 */
public interface IBizCardDraftService extends IService<BizCardDraft> {

    /**
     * 用户录入卡片（存入临时表，待审批）
     */
    Long createDraftCard(CardCreateDTO dto);

    /**
     * 分页查询待审批卡片列表
     */
    Page<CardAuditVO> pagePendingDrafts(AuditCardQueryDTO queryDTO);

    /**
     * 审批卡片（通过时迁移到正式表，拒绝时更新状态）
     */
    Long auditDraftCard(CardAuditDTO dto);

    /**
     * 获取用户录入的卡片列表（我的卡片）
     */
    Page<MyCardVO> pageMyDrafts(Long createUserId, MyCardQueryDTO queryDTO);

    /**
     * 获取待审批卡片数量
     */
    long getPendingCount();

    /**
     * 用户修改自己的卡片（仅限待审批状态）
     */
    void updateMyDraftCard(Long draftId, CardCreateDTO dto, Long createUserId);

    /**
     * 用户删除自己的卡片（仅限待审批状态）
     */
    void deleteMyDraftCard(Long draftId, Long createUserId);

}
