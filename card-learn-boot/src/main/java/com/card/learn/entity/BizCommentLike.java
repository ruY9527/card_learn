package com.card.learn.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import com.fasterxml.jackson.annotation.JsonFormat;
import java.time.LocalDateTime;

/**
 * 评论/回复点赞表
 */
@Data
@TableName("biz_comment_like")
public class BizCommentLike implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "like_id", type = IdType.AUTO)
    private Long likeId;

    /** 评论ID */
    private Long commentId;

    /** 回复ID */
    private Long replyId;

    /** 点赞用户ID */
    private Long userId;

    /** 点赞类型：1=喜欢 2=不喜欢 */
    private Integer likeType;

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
