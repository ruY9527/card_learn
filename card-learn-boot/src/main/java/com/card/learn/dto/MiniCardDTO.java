package com.card.learn.dto;

import lombok.Data;

import java.io.Serializable;
import java.util.List;

/**
 * 小程序卡片DTO
 */
@Data
public class MiniCardDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long cardId;
    private Long subjectId;
    private String subjectName;
    private String frontContent;
    private String backContent;
    private Integer difficultyLevel;
    private List<String> tags;

}