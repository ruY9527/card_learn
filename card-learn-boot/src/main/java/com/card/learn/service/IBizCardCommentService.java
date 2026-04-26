package com.card.learn.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.card.learn.entity.BizCardComment;
import com.card.learn.mapper.CommentStats;
import com.card.learn.vo.CommentVO;

/**
 * 闪卡评论Service接口
 */
public interface IBizCardCommentService extends IService<BizCardComment> {

    /**
     * 分页查询评论列表（包含卡片信息）
     */
    Page<CommentVO> pageComments(Long cardId, String commentType, String status, Integer pageNum, Integer pageSize);

    /**
     * 提交评论（劣质评论自动生成反馈）
     */
    BizCardComment submitComment(BizCardComment comment);

    /**
     * 管理员回复评论
     */
    void adminReply(Long commentId, String reply);

    /**
     * 处理评论（标记为已处理）
     */
    void handleComment(Long commentId, String status);

    /**
     * 获取卡片评论统计
     */
    CommentStats getCommentStats(Long cardId);
}