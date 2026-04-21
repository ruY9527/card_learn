package com.card.learn.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 知识点卡片表
 */
@Data
@TableName("biz_card")
public class BizCard implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "card_id", type = IdType.AUTO)
    private Long cardId;

    /** 所属科目ID */
    private Long subjectId;

    /** 卡片正面(支持Markdown/LaTeX) */
    private String frontContent;

    /** 卡片反面(答案/解析) */
    private String backContent;

    /** 难度系数(1-5) */
    private Integer difficultyLevel;

    /** 删除标志 */
    @TableLogic
    private String delFlag;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;

}