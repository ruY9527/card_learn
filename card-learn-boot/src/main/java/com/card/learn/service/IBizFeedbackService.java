package com.card.learn.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.card.learn.dto.FeedbackQueryDTO;
import com.card.learn.dto.UserFeedbackQueryDTO;
import com.card.learn.entity.BizFeedback;
import com.card.learn.vo.FeedbackVO;

/**
 * 用户反馈Service
 */
public interface IBizFeedbackService extends IService<BizFeedback> {

    /**
     * 分页查询反馈（关联用户和卡片信息）
     */
    Page<FeedbackVO> pageFeedback(FeedbackQueryDTO queryDTO);

    /**
     * 处理反馈（更新状态和回复）
     */
    void processFeedback(Long id, String status, String adminReply);

    /**
     * 获取用户提交的反馈列表
     */
    Page<BizFeedback> pageUserFeedback(UserFeedbackQueryDTO queryDTO);

}