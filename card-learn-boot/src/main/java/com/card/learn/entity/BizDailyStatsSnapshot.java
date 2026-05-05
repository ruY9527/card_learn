package com.card.learn.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import com.fasterxml.jackson.annotation.JsonFormat;

/**
 * 每日学习统计快照
 */
@Data
@TableName("biz_daily_stats_snapshot")
public class BizDailyStatsSnapshot implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /** 用户ID */
    private Long userId;

    /** 统计日期 */
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate statsDate;

    /** 当日学习卡片数 */
    private Integer totalCards;

    /** 当日新掌握卡片数 */
    private Integer newMastered;

    /** 当日遗忘卡片数 */
    private Integer forgotten;

    /** 当日学习时长(分钟) */
    private Integer studyDuration;

    /** 当日掌握率 */
    private BigDecimal masteryRate;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;
}
