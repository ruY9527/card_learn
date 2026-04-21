package com.card.learn.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.card.learn.entity.BizCardTag;
import com.card.learn.entity.BizTag;
import com.card.learn.mapper.BizCardTagMapper;
import com.card.learn.service.IBizCardTagService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 卡片标签关联Service实现
 */
@Service
public class BizCardTagServiceImpl extends ServiceImpl<BizCardTagMapper, BizCardTag> implements IBizCardTagService {

    @Autowired
    private BizCardTagMapper cardTagMapper;

    @Override
    public List<BizTag> getTagsByCardId(Long cardId) {
        return cardTagMapper.selectTagsByCardId(cardId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void setCardTags(Long cardId, List<Long> tagIds) {
        // 先删除原有关联
        cardTagMapper.deleteByCardId(cardId);
        // 再插入新关联
        if (tagIds != null && !tagIds.isEmpty()) {
            cardTagMapper.batchInsert(cardId, tagIds);
        }
    }

}