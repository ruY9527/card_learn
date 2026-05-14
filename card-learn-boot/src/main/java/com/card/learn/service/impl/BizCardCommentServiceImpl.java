package com.card.learn.service.impl;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.card.learn.common.AppConstants;
import com.card.learn.common.AppMessages;
import com.card.learn.dto.CommentQueryDTO;
import com.card.learn.dto.NoteQueryDTO;
import com.card.learn.entity.BizCardComment;
import com.card.learn.entity.BizFeedback;
import com.card.learn.entity.SysUser;
import com.card.learn.mapper.BizCardCommentMapper;
import com.card.learn.mapper.CommentStats;
import com.card.learn.service.IBizCardCommentService;
import com.card.learn.service.IBizFeedbackService;
import com.card.learn.service.ISysUserService;
import com.card.learn.vo.CommentVO;
import com.card.learn.vo.NoteVO;
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

    @Autowired
    private ISysUserService sysUserService;

    @Override
    public Page<CommentVO> pageComments(CommentQueryDTO queryDTO, Long userId) {
        Page<CommentVO> page = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize());
        return commentMapper.selectCommentsWithCardInfo(page, queryDTO.getCardId(), queryDTO.getCommentType(), queryDTO.getStatus(), userId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public BizCardComment submitComment(BizCardComment comment) {
        // 查询用户昵称
        if (comment.getUserId() != null) {
            SysUser user = sysUserService.getById(comment.getUserId());
            if (user != null) {
                comment.setUserNickname(user.getNickname() != null ? user.getNickname() : user.getUsername());
            }
        }

        // 保存评论
        comment.setStatus("0");
        comment.setCreateTime(LocalDateTime.now());
        if (comment.getIsNote() == null) {
            comment.setIsNote(0);
        }
        if (comment.getLikeCount() == null) {
            comment.setLikeCount(0);
        }
        if (comment.getReplyCount() == null) {
            comment.setReplyCount(0);
        }
        save(comment);

        // 如果是劣质评论，自动创建反馈记录
        if (AppConstants.COMMENT_TYPE_POOR.equals(comment.getCommentType())) {
            BizFeedback feedback = new BizFeedback();
            feedback.setUserId(comment.getUserId());
            feedback.setCardId(comment.getCardId());
            feedback.setType(AppConstants.FEEDBACK_TYPE_ERROR);
            feedback.setRating(comment.getRating());
            feedback.setContent(AppMessages.POOR_CONTENT_PREFIX + comment.getContent());
            feedback.setStatus("0");
            feedback.setCreateTime(LocalDateTime.now());
            feedbackService.save(feedback);

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

            if (comment.getFeedbackId() != null) {
                BizFeedback feedback = feedbackService.getById(comment.getFeedbackId());
                if (feedback != null) {
                    feedback.setStatus("1");
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

    @Override
    public Page<NoteVO> pageMyNotes(NoteQueryDTO queryDTO) {
        Page<NoteVO> page = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize());
        return commentMapper.selectMyNotes(page, queryDTO.getUserId(), queryDTO.getUsername(),
                queryDTO.getSubjectId(), queryDTO.getStartDate(), queryDTO.getEndDate(),
                queryDTO.getCardId(), queryDTO.getKeyword());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void editNote(Long commentId, Long userId, String content) {
        BizCardComment comment = getById(commentId);
        if (comment != null && comment.getUserId().equals(userId) && Integer.valueOf(1).equals(comment.getIsNote())) {
            comment.setContent(content);
            comment.setUpdateTime(LocalDateTime.now());
            updateById(comment);
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteNote(Long commentId, Long userId) {
        BizCardComment comment = getById(commentId);
        if (comment != null && comment.getUserId().equals(userId) && Integer.valueOf(1).equals(comment.getIsNote())) {
            comment.setStatus("2");
            comment.setUpdateTime(LocalDateTime.now());
            updateById(comment);
        }
    }
}
