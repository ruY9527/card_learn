package com.card.learn.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.card.learn.entity.BizFeedback;
import com.card.learn.mapper.BizFeedbackMapper;
import com.card.learn.service.IBizFeedbackService;
import com.card.learn.vo.FeedbackVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

/**
 * 用户反馈Service实现
 */
@Service
public class BizFeedbackServiceImpl extends ServiceImpl<BizFeedbackMapper, BizFeedback> implements IBizFeedbackService {

    @Autowired
    private BizFeedbackMapper feedbackMapper;

    @Override
    public Page<FeedbackVO> pageFeedback(String type, String status, Integer pageNum, Integer pageSize) {
        Page<FeedbackVO> page = new Page<>(pageNum, pageSize);
        return feedbackMapper.selectFeedbackWithDetails(page, type, status);
    }

    @Override
    @Transactional
    public void processFeedback(Long id, String status, String adminReply) {
        BizFeedback feedback = getById(id);
        if (feedback != null) {
            feedback.setStatus(status);
            feedback.setAdminReply(adminReply);
            feedback.setUpdateTime(LocalDateTime.now());
            updateById(feedback);
        }
    }

    @Override
    public Page<BizFeedback> pageUserFeedback(Long userId, Integer pageNum, Integer pageSize) {
        LambdaQueryWrapper<BizFeedback> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(BizFeedback::getUserId, userId);
        wrapper.orderByDesc(BizFeedback::getCreateTime);
        return page(new Page<>(pageNum, pageSize), wrapper);
    }

}