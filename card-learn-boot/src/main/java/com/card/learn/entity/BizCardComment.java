package com.card.learn.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 闪卡评论表
 * 用于用户对闪卡知识点进行评价，劣质内容与反馈管理联动
 */
@Data
@TableName("biz_card_comment")
public class BizCardComment implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "comment_id", type = IdType.AUTO)
    private Long commentId;

    /** 卡片ID */
    private Long cardId;

    /** 用户ID */
    private Long userId;

    /** 用户昵称（冗余字段） */
    private String userNickname;

    /** 评论内容 */
    private String content;

    /** 评分（1-5星） */
    private Integer rating;

    /** 评论类型：QUALITY(优质内容)/POOR(劣质内容)/NEUTRAL(中性) */
    private String commentType;

    /** 状态：0正常 1已处理 2已隐藏 */
    private String status;

    /** 管理员回复 */
    private String adminReply;

    /** 关联的反馈ID（劣质评论自动生成反馈时） */
    private Long feedbackId;

    /** 创建时间 */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    /** 更新时间 */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}