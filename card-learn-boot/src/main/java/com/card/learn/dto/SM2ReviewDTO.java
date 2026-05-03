package com.card.learn.dto;

import lombok.Data;

import javax.validation.constraints.NotNull;
import java.io.Serializable;

/**
 * SM-2复习提交DTO
 */
@Data
public class SM2ReviewDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    @NotNull(message = "卡片ID不能为空")
    private Long cardId;

    @NotNull(message = "用户ID不能为空")
    private Long userId;

    @NotNull(message = "质量评分不能为空")
    private Integer quality;

    @NotNull(message = "容易系数不能为空")
    private Double easeFactor;

    @NotNull(message = "连续次数不能为空")
    private Integer repetitions;

    @NotNull(message = "间隔天数不能为空")
    private Integer interval;

    /** 下次复习时间(ISO格式) */
    @NotNull(message = "下次复习时间不能为空")
    private String nextReviewTime;
}
