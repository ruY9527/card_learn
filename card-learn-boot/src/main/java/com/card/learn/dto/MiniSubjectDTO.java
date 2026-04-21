package com.card.learn.dto;

import lombok.Data;

import java.io.Serializable;

/**
 * 小程序科目DTO
 */
@Data
public class MiniSubjectDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long subjectId;
    private Long majorId;
    private String subjectName;
    private String icon;
    private Integer orderNum;

}