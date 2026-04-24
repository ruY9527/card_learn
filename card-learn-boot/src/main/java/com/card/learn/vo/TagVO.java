package com.card.learn.vo;

import lombok.Data;

import java.io.Serializable;

/**
 * 标签视图对象（包含科目名称）
 */
@Data
public class TagVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long tagId;

    /** 标签名称 */
    private String tagName;

    /** 所属科目ID（null表示通用标签） */
    private Long subjectId;

    /** 科目名称 */
    private String subjectName;

}