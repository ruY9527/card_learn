package com.card.learn.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.card.learn.dto.CommentQueryDTO;
import com.card.learn.dto.NoteQueryDTO;
import com.card.learn.entity.BizCardComment;
import com.card.learn.mapper.CommentStats;
import com.card.learn.vo.CommentVO;
import com.card.learn.vo.NoteVO;

/**
 * 闪卡评论Service接口
 */
public interface IBizCardCommentService extends IService<BizCardComment> {

    /**
     * 分页查询评论列表（包含卡片信息）
     */
    Page<CommentVO> pageComments(CommentQueryDTO queryDTO, Long userId);

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

    /**
     * 分页查询用户的笔记列表
     */
    Page<NoteVO> pageMyNotes(NoteQueryDTO queryDTO);

    /**
     * 编辑笔记
     */
    void editNote(Long commentId, Long userId, String content);

    /**
     * 删除笔记
     */
    void deleteNote(Long commentId, Long userId);
}