package com.card.learn.vo;

import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 评论视图对象（包含卡片信息）
 */
@Data
public class CommentVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long commentId;

    /** 卡片ID */
    private Long cardId;

    /** 卡片正面内容（预览） */
    private String cardFrontContent;

    /** 科目名称 */
    private String subjectName;

    /** 用户ID */
    private Long userId;

    /** 用户昵称 */
    private String userNickname;

    /** 评论内容 */
    private String content;

    /** 评分（1-5星） */
    private Integer rating;

    /** 评论类型：QUALITY/POOR/NEUTRAL */
    private String commentType;

    /** 评论类型文本 */
    private String commentTypeText;

    /** 状态：0正常 1已处理 2已隐藏 */
    private String status;

    /** 状态文本 */
    private String statusText;

    /** 管理员回复 */
    private String adminReply;

    /** 关联的反馈ID */
    private Long feedbackId;

    /** 创建时间 */
    private LocalDateTime createTime;

    /** 更新时间 */
    private LocalDateTime updateTime;
}