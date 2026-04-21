package com.card.learn.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;

/**
 * 科目信息表
 */
@Data
@TableName("biz_subject")
public class BizSubject implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "subject_id", type = IdType.AUTO)
    private Long subjectId;

    /** 所属专业ID */
    private Long majorId;

    private String subjectName;

    private String icon;

    /** 排序 */
    private Integer orderNum;

}