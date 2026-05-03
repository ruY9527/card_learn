package com.card.learn.service.impl;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.card.learn.dto.CommentQueryDTO;
import com.card.learn.entity.BizCardComment;
import com.card.learn.entity.BizFeedback;
import com.card.learn.mapper.BizCardCommentMapper;
import com.card.learn.mapper.CommentStats;
import com.card.learn.service.IBizCardCommentService;
import com.card.learn.service.IBizFeedbackService;
import com.card.learn.vo.CommentVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

/**
 * 闪卡评论Service实现
 */
@Service
public class BizCardCommentServiceImpl extends ServiceImpl<BizCardCommentMapper, BizCardComment> implements IBizCardCommentService {

    @Autowired
    private BizCardCommentMapper commentMapper;

    @Autowired
    private IBizFeedbackService feedbackService;

    @Override
    public Page<CommentVO> pageComments(CommentQueryDTO queryDTO) {
        Page<CommentVO> page = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize());
        return commentMapper.selectCommentsWithCardInfo(page, queryDTO.getCardId(), queryDTO.getCommentType(), queryDTO.getStatus());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public BizCardComment submitComment(BizCardComment comment) {
        // 保存评论
        comment.setStatus("0");
        comment.setCreateTime(LocalDateTime.now());
        save(comment);

        // 如果是劣质评论，自动创建反馈记录
        if ("POOR".equals(comment.getCommentType())) {
            BizFeedback feedback = new BizFeedback();
            feedback.setUserId(comment.getUserId());
            feedback.setCardId(comment.getCardId());
            feedback.setType("ERROR");  // 纠错类型
            feedback.setRating(comment.getRating());
            feedback.setContent("用户标记为劣质内容：" + comment.getContent());
            feedback.setStatus("0");  // 待处理
            feedback.setCreateTime(LocalDateTime.now());
            feedbackService.save(feedback);

            // 更新评论的关联反馈ID
            comment.setFeedbackId(feedback.getId());
            updateById(comment);
        }

        return comment;
    }

    @Override
    public void adminReply(Long commentId, String reply) {
        BizCardComment comment = getById(commentId);
        if (comment != null) {
            comment.setAdminReply(reply);
            comment.setUpdateTime(LocalDateTime.now());
            updateById(comment);
        }
    }

    @Override
    public void handleComment(Long commentId, String status) {
        BizCardComment comment = getById(commentId);
        if (comment != null) {
            comment.setStatus(status);
            comment.setUpdateTime(LocalDateTime.now());
            updateById(comment);

            // 如果有关联的反馈，同步处理
            if (comment.getFeedbackId() != null) {
                BizFeedback feedback = feedbackService.getById(comment.getFeedbackId());
                if (feedback != null) {
                    feedback.setStatus("1");  // 已采纳
                    feedback.setUpdateTime(LocalDateTime.now());
                    feedbackService.updateById(feedback);
                }
            }
        }
    }

    @Override
    public CommentStats getCommentStats(Long cardId) {
        return commentMapper.selectCommentStats(cardId);
    }
}