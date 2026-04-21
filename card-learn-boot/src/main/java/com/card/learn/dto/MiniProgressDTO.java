package com.card.learn.dto;

import lombok.Data;

import java.io.Serializable;

/**
 * 小程序进度DTO
 */
@Data
public class MiniProgressDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long cardId;
    private Long appUserId;  // 可为空，游客模式
    private Integer status;  // 0未学, 1模糊, 2掌握

}