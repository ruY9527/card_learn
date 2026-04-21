package com.card.learn.vo;

import lombok.Data;

import java.io.Serializable;

/**
 * 科目视图对象（包含专业名称）
 */
@Data
public class SubjectVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long subjectId;

    /** 所属专业ID */
    private Long majorId;

    /** 专业名称 */
    private String majorName;

    private String subjectName;

    private String icon;

    /** 排序 */
    private Integer orderNum;

}