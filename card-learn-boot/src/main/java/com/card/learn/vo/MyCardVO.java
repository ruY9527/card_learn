package com.card.learn.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 我的卡片视图对象（用户录入的卡片）
 */
@Data
public class MyCardVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long draftId;

    /** 所属科目ID */
    private Long subjectId;

    /** 科目名称 */
    private String subjectName;

    /** 卡片正面(支持Markdown/LaTeX) */
    private String frontContent;

    /** 卡片反面(答案/解析) */
    private String backContent;

    /** 难度系数(1-5) */
    private Integer difficultyLevel;

    /** 审批状态（0待审批 1已通过 2已拒绝） */
    private String auditStatus;

    /** 审批状态文本 */
    private String auditStatusText;

    /** 标签列表 */
    private List<String> tags;

    /** 审批备注（拒绝原因） */
    private String auditRemark;

    /** 创建时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;

    /** 审批时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime auditTime;

}