package com.card.learn.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 回复视图对象
 */
@Data
public class ReplyVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long replyId;

    /** 所属评论ID */
    private Long commentId;

    /** 回复用户ID */
    private Long userId;

    /** 回复用户昵称 */
    private String userNickname;

    /** 回复内容 */
    private String content;

    /** 点赞数 */
    private Integer likeCount;

    /** 不喜欢数 */
    private Integer dislikeCount;

    /** 当前用户点赞状态：0=无, 1=喜欢, 2=不喜欢 */
    private Integer likeStatus;

    /** 父回复ID（null=第1层） */
    private Long parentReplyId;

    /** 子回复列表（懒加载） */
    private List<ReplyVO> children;

    /** 是否还有更多子回复 */
    private Boolean hasMoreChildren;

    /** 创建时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;
}
