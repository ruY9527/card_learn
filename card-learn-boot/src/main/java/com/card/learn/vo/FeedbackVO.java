package com.card.learn.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 反馈视图对象（包含用户和卡片信息）
 */
@Data
public class FeedbackVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long id;

    /** 用户ID */
    private Long userId;

    /** 用户昵称 */
    private String userNickname;

    /** 关联的卡片ID */
    private Long cardId;

    /** 卡片正面内容（简要显示） */
    private String cardFrontContent;

    /** 反馈类型 */
    private String type;

    /** 评分（1-5星） */
    private Integer rating;

    /** 反馈详细内容 */
    private String content;

    /** 用户留下的联系方式 */
    private String contact;

    /** 图片附件 */
    private String images;

    /** 处理状态 */
    private String status;

    /** 管理员回复内容 */
    private String adminReply;

    /** 提交时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;

    /** 处理时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;

}