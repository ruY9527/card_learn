package com.card.learn.dto;

import lombok.Data;

import javax.validation.constraints.NotNull;
import java.io.Serializable;

/**
 * 简化复习提交DTO（小程序/iOS使用，status自动映射SM-2 quality）
 */
@Data
public class SimpleReviewDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    @NotNull(message = "卡片ID不能为空")
    private Long cardId;

    @NotNull(message = "用户ID不能为空")
    private Long userId;

    /** 掌握状态(0未学 1模糊 2掌握) */
    @NotNull(message = "学习状态不能为空")
    private Integer status;

    /** 学习来源: web/ios/mini */
    private String source;
}
