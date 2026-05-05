package com.card.learn.vo;

import lombok.Data;

/**
 * 改进建议VO
 */
@Data
public class SuggestionVO {

    /** 建议类型: subject/card/habit */
    private String type;

    /** 优先级: high/medium/low */
    private String priority;

    /** 建议内容 */
    private String content;

    public SuggestionVO() {}

    public SuggestionVO(String type, String priority, String content) {
        this.type = type;
        this.priority = priority;
        this.content = content;
    }
}
