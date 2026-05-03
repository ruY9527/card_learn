package com.card.learn.vo;

import lombok.Data;

import java.io.Serializable;

/**
 * 科目卡片总数投影
 */
@Data
public class SubjectTotalVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long subjectId;
    private String subjectName;
    private Long majorId;
    private String majorName;
    private Integer totalCards;
}
