package com.card.learn.dto;

import lombok.Data;

/**
 * AI转换请求DTO
 */
@Data
public class AiConvertDTO {

    /**
     * 输入文本内容
     */
    private String content;

    /**
     * 目标科目ID
     */
    private Long subjectId;

    /**
     * AI转换模式：text(纯文本)、note(笔记)、markdown(Markdown)
     */
    private String mode;

}