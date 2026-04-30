package com.card.learn.vo;

import lombok.Data;

import java.io.Serializable;

/**
 * 卡片审批结果VO
 */
@Data
public class AuditResultVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long cardId;
    private String message;
}
