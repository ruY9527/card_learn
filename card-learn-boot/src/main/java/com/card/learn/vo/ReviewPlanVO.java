package com.card.learn.vo;

import lombok.Data;

import java.io.Serializable;

/**
 * 复习计划视图对象
 */
@Data
public class ReviewPlanVO implements Serializable {

    private static final long serialVersionUID = 1L;

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

    /** 学习次数 */
    private Integer studyCount;
}
