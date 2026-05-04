package com.card.learn.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.card.learn.entity.BizCommentLike;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * 点赞Mapper接口
 */
@Mapper
public interface BizCommentLikeMapper extends BaseMapper<BizCommentLike> {

    /**
     * 查询用户是否点赞了某条评论
     */
    int countByCommentAndUser(@Param("commentId") Long commentId, @Param("userId") Long userId);

    /**
     * 查询用户是否点赞了某条回复
     */
    int countByReplyAndUser(@Param("replyId") Long replyId, @Param("userId") Long userId);
}
