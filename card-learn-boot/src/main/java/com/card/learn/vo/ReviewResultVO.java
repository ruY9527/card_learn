package com.card.learn.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 复习结果视图对象（返回SM-2计算结果）
 */
@Data
public class ReviewResultVO implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 卡片ID */
    private Long cardId;

    /** 掌握状态(0未学 1模糊 2掌握) */
    private Integer status;

    /** SM-2容易系数 */
    private Double easeFactor;

    /** SM-2连续正确次数 */
    private Integer repetitions;

    /** SM-2复习间隔天数 */
    private Integer intervalDays;

    /** 下次复习时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime nextReviewTime;
}
