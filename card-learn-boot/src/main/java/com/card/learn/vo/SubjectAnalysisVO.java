package com.card.learn.vo;

import lombok.Data;

/**
 * 科目分析VO
 */
@Data
public class SubjectAnalysisVO {

    /** 科目ID */
    private Long subjectId;

    /** 科目名称 */
    private String subjectName;

    /** 总卡片数 */
    private Integer totalCards;

    /** 已掌握数 */
    private Integer mastered;

    /** 薄弱点数 */
    private Integer weakPoints;

    /** 掌握率 */
    private Integer masteryRate;
}
