package com.card.learn.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.card.learn.entity.BizCommentLike;

/**
 * 点赞Service接口
 */
public interface IBizCommentLikeService extends IService<BizCommentLike> {

    /**
     * 切换评论点赞/踩状态
     * @param likeType 1=喜欢, 2=不喜欢
     * @return 0=取消, 1=喜欢, 2=不喜欢
     */
    int toggleCommentLike(Long commentId, Long userId, Integer likeType);

    /**
     * 切换回复点赞/踩状态
     * @param likeType 1=喜欢, 2=不喜欢
     * @return 0=取消, 1=喜欢, 2=不喜欢
     */
    int toggleReplyLike(Long replyId, Long userId, Integer likeType);
}
