package com.card.learn.vo;

import lombok.Data;

import java.io.Serializable;

/**
 * 管理端复习计划视图对象（含用户信息）
 */
@Data
public class AdminReviewPlanVO implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 复习计划ID */
    private Long id;

    /** 用户ID */
    private Long userId;

    /** 用户昵称 */
    private String nickname;

    /** 用户头像 */
    private String avatar;

    /** 卡片ID */
    private Long cardId;

    /** 计划日期 */
    private String scheduledDate;

    /** 卡片正面内容 */
    private String frontContent;

    /** 卡片背面内容 */
    private String backContent;

    /** 科目名称 */
    private String subjectName;

    /** 难度等级 */
    private Integer difficultyLevel;

    /** 状态(0待复习 1已完成) */
    private String status;
}
