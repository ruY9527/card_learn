package com.card.learn.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.io.Serializable;
import java.util.List;

/**
 * 用户录入卡片DTO
 */
@Data
public class CardCreateDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 所属科目ID */
    @NotNull(message = "科目ID不能为空")
    private Long subjectId;

    /** 卡片正面(支持Markdown/LaTeX) */
    @NotBlank(message = "卡片正面内容不能为空")
    private String frontContent;

    /** 卡片反面(答案/解析) */
    @NotBlank(message = "卡片反面内容不能为空")
    private String backContent;

    /** 难度系数(1-5) */
    private Integer difficultyLevel;

    /** 标签ID列表 */
    private List<Long> tagIds;

    /** 创建用户ID（小程序用户） */
    private Long createBy;

}