package com.card.learn.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.card.learn.entity.BizCard;
import com.card.learn.mapper.BizCardMapper;
import com.card.learn.service.IBizCardService;
import org.springframework.stereotype.Service;

/**
 * 知识点卡片Service实现
 */
@Service
public class BizCardServiceImpl extends ServiceImpl<BizCardMapper, BizCard> implements IBizCardService {

    @Override
    public Page<BizCard> pageCards(Long subjectId, Integer pageNum, Integer pageSize) {
        LambdaQueryWrapper<BizCard> wrapper = new LambdaQueryWrapper<>();
        if (subjectId != null) {
            wrapper.eq(BizCard::getSubjectId, subjectId);
        }
        wrapper.orderByDesc(BizCard::getCreateTime);
        return page(new Page<>(pageNum, pageSize), wrapper);
    }

}