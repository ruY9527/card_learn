package com.card.learn.vo;

import lombok.Data;

import java.io.Serializable;

/**
 * 科目状态统计投影
 */
@Data
public class SubjectStatusCountVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long subjectId;
    private Integer status;
    private Integer count;
}
