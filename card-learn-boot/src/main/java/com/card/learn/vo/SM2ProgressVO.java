package com.card.learn.vo;

import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * SM-2学习进度视图对象
 */
@Data
public class SM2ProgressVO implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 卡片ID */
    private Long cardId;

    /** 容易系数 */
    private Double easeFactor;

    /** 连续正确次数 */
    private Integer repetitions;

    /** 下次间隔天数 */
    private Integer interval;

    /** 下次复习时间 */
    private LocalDateTime nextReviewTime;
}
