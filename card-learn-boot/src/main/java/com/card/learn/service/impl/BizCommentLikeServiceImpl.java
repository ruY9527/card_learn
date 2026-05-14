package com.card.learn.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.card.learn.common.AppMessages;
import com.card.learn.entity.BizCardComment;
import com.card.learn.entity.BizCardReply;
import com.card.learn.entity.BizCommentLike;
import com.card.learn.mapper.BizCommentLikeMapper;
import com.card.learn.service.IBizCardCommentService;
import com.card.learn.service.IBizCardReplyService;
import com.card.learn.service.IBizCommentLikeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 点赞Service实现
 */
@Service
public class BizCommentLikeServiceImpl extends ServiceImpl<BizCommentLikeMapper, BizCommentLike> implements IBizCommentLikeService {

    @Autowired
    private BizCommentLikeMapper likeMapper;

    @Autowired
    private IBizCardCommentService commentService;

    @Autowired
    private IBizCardReplyService replyService;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int toggleCommentLike(Long commentId, Long userId, Integer likeType) {
        LambdaQueryWrapper<BizCommentLike> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(BizCommentLike::getCommentId, commentId)
               .eq(BizCommentLike::getUserId, userId);
        BizCommentLike existing = getOne(wrapper);

        BizCardComment comment = commentService.getById(commentId);
        if (comment == null) {
            throw new RuntimeException(AppMessages.COMMENT_NOT_FOUND);
        }

        if (existing == null) {
            // 无记录 -> 新增
            BizCommentLike like = new BizCommentLike();
            like.setCommentId(commentId);
            like.setUserId(userId);
            like.setLikeType(likeType);
            like.setCreateBy(userId);
            like.setUpdateBy(userId);
            save(like);

            if (likeType == 1) {
                comment.setLikeCount((comment.getLikeCount() == null ? 0 : comment.getLikeCount()) + 1);
            } else {
                comment.setDislikeCount((comment.getDislikeCount() == null ? 0 : comment.getDislikeCount()) + 1);
            }
            commentService.updateById(comment);
            return likeType;
        } else if (existing.getLikeType().equals(likeType)) {
            // 同类型 -> 取消
            removeById(existing.getLikeId());

            if (likeType == 1) {
                if (comment.getLikeCount() != null && comment.getLikeCount() > 0) {
                    comment.setLikeCount(comment.getLikeCount() - 1);
                }
            } else {
                if (comment.getDislikeCount() != null && comment.getDislikeCount() > 0) {
                    comment.setDislikeCount(comment.getDislikeCount() - 1);
                }
            }
            commentService.updateById(comment);
            return 0;
        } else {
            // 不同类型 -> 切换
            Integer oldType = existing.getLikeType();
            existing.setLikeType(likeType);
            existing.setUpdateBy(userId);
            updateById(existing);

            // 减少旧类型计数
            if (oldType == 1) {
                if (comment.getLikeCount() != null && comment.getLikeCount() > 0) {
                    comment.setLikeCount(comment.getLikeCount() - 1);
                }
            } else {
                if (comment.getDislikeCount() != null && comment.getDislikeCount() > 0) {
                    comment.setDislikeCount(comment.getDislikeCount() - 1);
                }
            }
            // 增加新类型计数
            if (likeType == 1) {
                comment.setLikeCount((comment.getLikeCount() == null ? 0 : comment.getLikeCount()) + 1);
            } else {
                comment.setDislikeCount((comment.getDislikeCount() == null ? 0 : comment.getDislikeCount()) + 1);
            }
            commentService.updateById(comment);
            return likeType;
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int toggleReplyLike(Long replyId, Long userId, Integer likeType) {
        LambdaQueryWrapper<BizCommentLike> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(BizCommentLike::getReplyId, replyId)
               .eq(BizCommentLike::getUserId, userId);
        BizCommentLike existing = getOne(wrapper);

        BizCardReply reply = replyService.getById(replyId);
        if (reply == null) {
            throw new RuntimeException(AppMessages.REPLY_NOT_FOUND);
        }

        if (existing == null) {
            // 无记录 -> 新增
            BizCommentLike like = new BizCommentLike();
            like.setReplyId(replyId);
            like.setUserId(userId);
            like.setLikeType(likeType);
            like.setCreateBy(userId);
            like.setUpdateBy(userId);
            save(like);

            if (likeType == 1) {
                reply.setLikeCount((reply.getLikeCount() == null ? 0 : reply.getLikeCount()) + 1);
            } else {
                reply.setDislikeCount((reply.getDislikeCount() == null ? 0 : reply.getDislikeCount()) + 1);
            }
            replyService.updateById(reply);
            return likeType;
        } else if (existing.getLikeType().equals(likeType)) {
            // 同类型 -> 取消
            removeById(existing.getLikeId());

            if (likeType == 1) {
                if (reply.getLikeCount() != null && reply.getLikeCount() > 0) {
                    reply.setLikeCount(reply.getLikeCount() - 1);
                }
            } else {
                if (reply.getDislikeCount() != null && reply.getDislikeCount() > 0) {
                    reply.setDislikeCount(reply.getDislikeCount() - 1);
                }
            }
            replyService.updateById(reply);
            return 0;
        } else {
            // 不同类型 -> 切换
            Integer oldType = existing.getLikeType();
            existing.setLikeType(likeType);
            existing.setUpdateBy(userId);
            updateById(existing);

            if (oldType == 1) {
                if (reply.getLikeCount() != null && reply.getLikeCount() > 0) {
                    reply.setLikeCount(reply.getLikeCount() - 1);
                }
            } else {
                if (reply.getDislikeCount() != null && reply.getDislikeCount() > 0) {
                    reply.setDislikeCount(reply.getDislikeCount() - 1);
                }
            }
            if (likeType == 1) {
                reply.setLikeCount((reply.getLikeCount() == null ? 0 : reply.getLikeCount()) + 1);
            } else {
                reply.setDislikeCount((reply.getDislikeCount() == null ? 0 : reply.getDislikeCount()) + 1);
            }
            replyService.updateById(reply);
            return likeType;
        }
    }
}
