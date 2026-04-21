package com.card.learn.dto;

import lombok.Data;

import java.util.List;

/**
 * AI生成的卡片结果DTO
 */
@Data
public class AiCardDTO {

    /**
     * 卡片正面内容（问题）
     */
    private String frontContent;

    /**
     * 卡片反面内容（答案）
     */
    private String backContent;

    /**
     * 难度等级
     */
    private Integer difficultyLevel;

    /**
     * 标签列表
     */
    private List<String> tags;

}