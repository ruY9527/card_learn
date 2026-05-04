package com.card.learn.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.entity.BizCardReply;
import com.card.learn.vo.ReplyVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * 评论回复Mapper接口
 */
@Mapper
public interface BizCardReplyMapper extends BaseMapper<BizCardReply> {

    /**
     * 分页查询评论的回复列表（含用户点赞状态）
     */
    Page<ReplyVO> selectRepliesByCommentId(
            Page<ReplyVO> page,
            @Param("commentId") Long commentId,
            @Param("userId") Long userId
    );
}
