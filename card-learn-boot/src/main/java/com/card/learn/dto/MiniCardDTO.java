package com.card.learn.dto;

import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;
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
    private Integer status; // 学习状态：0未学/1模糊/2掌握
    private LocalDateTime updateTime; // 学习/更新时间

}