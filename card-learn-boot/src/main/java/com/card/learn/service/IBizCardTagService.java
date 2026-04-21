package com.card.learn.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.card.learn.entity.BizCardTag;
import com.card.learn.entity.BizTag;

import java.util.List;

/**
 * 卡片标签关联Service
 */
public interface IBizCardTagService extends IService<BizCardTag> {

    /**
     * 获取卡片的标签列表
     */
    List<BizTag> getTagsByCardId(Long cardId);

    /**
     * 设置卡片的标签（先删后插）
     */
    void setCardTags(Long cardId, List<Long> tagIds);

}