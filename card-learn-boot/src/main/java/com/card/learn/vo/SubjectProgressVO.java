package com.card.learn.vo;

import lombok.Data;

import java.io.Serializable;

/**
 * 科目进度视图对象
 */
@Data
public class SubjectProgressVO implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 科目ID */
    private Long subjectId;

    /** 科目名称 */
    private String subjectName;

    /** 专业ID */
    private Long majorId;

    /** 专业名称 */
    private String majorName;

    /** 总卡片数 */
    private Integer totalCards;

    /** 已掌握数 */
    private Integer masteredCount;

    /** 已学习数(含掌握) */
    private Integer learnedCount;

    /** 掌握率(%) */
    private Double masteryRate;
}
