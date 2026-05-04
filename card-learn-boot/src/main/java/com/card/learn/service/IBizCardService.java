package com.card.learn.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.card.learn.dto.CardAuditDTO;
import com.card.learn.dto.CardCreateDTO;
import com.card.learn.dto.CardQueryDTO;
import com.card.learn.entity.BizCard;
import com.card.learn.vo.CardAuditVO;
import com.card.learn.vo.CardVO;
import com.card.learn.vo.MyCardVO;

/**
 * 知识点卡片Service
 */
public interface IBizCardService extends IService<BizCard> {

    /**
     * 分页查询卡片列表
     */
    Page<BizCard> pageCards(CardQueryDTO queryDTO);

    /**
     * 分页查询卡片列表（包含科目名称）
     */
    Page<CardVO> pageCardsWithSubjectName(CardQueryDTO queryDTO);

    /**
     * 用户录入卡片（待审批状态）
     */
    Long createCardByUser(CardCreateDTO dto);

    /**
     * 分页查询待审批卡片列表
     */
    Page<CardAuditVO> pagePendingCards(String auditStatus, Integer pageNum, Integer pageSize);

    /**
     * 审批卡片
     */
    void auditCard(CardAuditDTO dto);

    /**
     * 获取用户录入的卡片列表（我的卡片）
     */
    Page<MyCardVO> pageMyCards(Long createBy, Integer pageNum, Integer pageSize);

    /**
     * 获取待审批卡片数量
     */
    long getPendingCount();

    /**
     * 用户修改自己的卡片（仅限待审批状态）
     */
    void updateMyCard(Long cardId, CardCreateDTO dto, Long createBy);

    /**
     * 用户删除自己的卡片（仅限待审批状态）
     */
    void deleteMyCard(Long cardId, Long createBy);

}