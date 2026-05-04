package com.card.learn.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.entity.BizCardComment;
import com.card.learn.vo.CommentVO;
import com.card.learn.vo.NoteVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * 闪卡评论Mapper接口
 */
@Mapper
public interface BizCardCommentMapper extends BaseMapper<BizCardComment> {

    /**
     * 分页查询评论列表（关联卡片信息）
     */
    Page<CommentVO> selectCommentsWithCardInfo(
            Page<CommentVO> page,
            @Param("cardId") Long cardId,
            @Param("commentType") String commentType,
            @Param("status") String status,
            @Param("userId") Long userId
    );

    /**
     * 获取卡片评论统计
     */
    CommentStats selectCommentStats(@Param("cardId") Long cardId);

    /**
     * 分页查询用户的笔记列表
     */
    Page<NoteVO> selectMyNotes(
            Page<NoteVO> page,
            @Param("userId") Long userId,
            @Param("username") String username,
            @Param("subjectId") Long subjectId,
            @Param("startDate") String startDate,
            @Param("endDate") String endDate,
            @Param("cardId") Long cardId,
            @Param("keyword") String keyword
    );
}
