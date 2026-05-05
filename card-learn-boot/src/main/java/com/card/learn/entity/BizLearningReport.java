package com.card.learn.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;
import com.fasterxml.jackson.annotation.JsonFormat;

/**
 * 学习报告表
 */
@Data
@TableName("biz_learning_report")
public class BizLearningReport implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /** 用户ID */
    private Long userId;

    /** 报告类型: weekly/monthly */
    private String reportType;

    /** 统计周期开始日期 */
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate periodStart;

    /** 统计周期结束日期 */
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate periodEnd;

    /** 报告数据JSON */
    private String reportData;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;
}
