package com.card.learn.vo;

import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 用户学习过的卡片VO
 */
@Data
public class StudiedCardVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long userId;
    private String nickname;
    private Long cardId;
    private Long subjectId;
    private String subjectName;
    private String frontContent;
    private Integer difficultyLevel;
    private Long studyCount;
    private LocalDateTime lastStudyTime;
    private Integer lastStatus;
}
