package com.card.learn.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.card.learn.entity.BizCard;
import com.card.learn.vo.CardVO;

/**
 * 知识点卡片Service
 */
public interface IBizCardService extends IService<BizCard> {

    /**
     * 分页查询卡片列表
     */
    Page<BizCard> pageCards(Long subjectId, Integer pageNum, Integer pageSize);

    /**
     * 分页查询卡片列表（包含科目名称）
     */
    Page<CardVO> pageCardsWithSubjectName(Long subjectId, Integer pageNum, Integer pageSize);

}