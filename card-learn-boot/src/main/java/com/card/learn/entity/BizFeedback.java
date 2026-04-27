package com.card.learn.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 用户反馈表
 */
@Data
@TableName("biz_feedback")
public class BizFeedback implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /** 用户ID */
    private Long userId;

    /** 关联的卡片ID（若是对具体卡片的纠错） */
    private Long cardId;

    /** 所属专业ID */
    private Long majorId;

    /** 所属科目ID */
    private Long subjectId;

    /** 反馈类型: SUGGESTION(建议), ERROR(纠错), FUNCTION(功能问题), OTHER(其他) */
    private String type;

    /** 评分（1-5星） */
    private Integer rating;

    /** 反馈详细内容 */
    private String content;

    /** 用户留下的联系方式 */
    private String contact;

    /** 图片附件（存储URL列表，JSON格式） */
    private String images;

    /** 处理状态（0待处理 1已采纳 2已忽略） */
    private String status;

    /** 管理员回复内容 */
    private String adminReply;

    /** 提交时间 */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    /** 处理时间 */
    private LocalDateTime updateTime;

    /** 更新人ID */
    private Long updateUserId;

}