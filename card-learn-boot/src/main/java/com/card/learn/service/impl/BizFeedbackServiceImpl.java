package com.card.learn.service.impl;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.card.learn.dto.FeedbackQueryDTO;
import com.card.learn.dto.UserFeedbackQueryDTO;
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
    public Page<FeedbackVO> pageFeedback(FeedbackQueryDTO queryDTO) {
        Page<FeedbackVO> page = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize());
        return feedbackMapper.selectFeedbackWithDetails(page, queryDTO.getType(), queryDTO.getStatus());
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
    public Page<BizFeedback> pageUserFeedback(UserFeedbackQueryDTO queryDTO) {
        Page<BizFeedback> page = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize());
        return feedbackMapper.selectPageByUserId(page, queryDTO.getUserId());
    }

}