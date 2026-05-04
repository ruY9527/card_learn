package com.card.learn.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.card.learn.entity.BizCardReply;
import com.card.learn.vo.ReplyVO;

/**
 * 评论回复Service接口
 */
public interface IBizCardReplyService extends IService<BizCardReply> {

    /**
     * 分页查询评论的回复列表
     */
    Page<ReplyVO> pageReplies(Long commentId, Long userId, Integer pageNum, Integer pageSize);

    /**
     * 提交回复
     */
    BizCardReply submitReply(BizCardReply reply);

    /**
     * 删除回复（软删除）
     */
    void deleteReply(Long replyId, Long userId);

    /**
     * 获取回复的子回复列表
     */
    java.util.List<ReplyVO> getChildrenReplies(Long parentReplyId, Long userId);
}
