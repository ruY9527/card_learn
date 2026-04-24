package com.card.learn.vo;

import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 卡片视图对象（包含科目名称）
 */
@Data
public class CardVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long cardId;

    /** 所属科目ID */
    private Long subjectId;

    /** 科目名称 */
    private String subjectName;

    /** 卡片正面(支持Markdown/LaTeX) */
    private String frontContent;

    /** 卡片反面(答案/解析) */
    private String backContent;

    /** 难度系数(1-5) */
    private Integer difficultyLevel;

    /** 审批状态（0待审批 1已通过 2已拒绝） */
    private String auditStatus;

    /** 审批状态文本 */
    private String auditStatusText;

    /** 创建用户ID */
    private Long createUserId;

    /** 创建用户昵称 */
    private String createUserNickname;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;

}