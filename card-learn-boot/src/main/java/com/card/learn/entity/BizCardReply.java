package com.card.learn.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import com.fasterxml.jackson.annotation.JsonFormat;
import java.time.LocalDateTime;

/**
 * 评论回复表
 */
@Data
@TableName("biz_card_reply")
public class BizCardReply implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "reply_id", type = IdType.AUTO)
    private Long replyId;

    /** 所属评论ID */
    private Long commentId;

    /** 卡片ID（冗余） */
    private Long cardId;

    /** 回复用户ID */
    private Long userId;

    /** 回复用户昵称（冗余） */
    private String userNickname;

    /** 回复内容 */
    private String content;

    /** 点赞数（冗余） */
    private Integer likeCount;

    /** 不喜欢数（冗余） */
    private Integer dislikeCount;

    /** 父回复ID（null=第1层） */
    private Long parentReplyId;

    /** 状态：0正常 1已删除 */
    private String status;

    /** 创建人 */
    private Long createBy;

    /** 创建时间 */
    @TableField(fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;

    /** 更新时间 */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;

    /** 修改人 */
    private Long updateBy;
}
