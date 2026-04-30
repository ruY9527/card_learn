package com.card.learn.vo;

import lombok.Data;

import java.io.Serializable;
import java.util.List;

/**
 * 卡片学习历史详情VO
 */
@Data
public class CardStudyHistoryVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long cardId;
    private String frontContent;
    private List<StudyHistoryRecordVO> records;
    private Long total;
}
