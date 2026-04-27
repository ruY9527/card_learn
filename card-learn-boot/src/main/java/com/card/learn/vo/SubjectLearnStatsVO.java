package com.card.learn.vo;

import lombok.Data;

import java.io.Serializable;

/**
 * 科目学习统计视图对象
 */
@Data
public class SubjectLearnStatsVO implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 科目ID */
    private Long subjectId;

    /** 科目名称 */
    private String subjectName;

    /** 专业名称 */
    private String majorName;

    /** 科目下总卡片数 */
    private Long totalCards;

    /** 未学卡片数 */
    private Long unlearnedCount;

    /** 模糊卡片数 */
    private Long fuzzyCount;

    /** 掌握卡片数 */
    private Long masteredCount;
}
