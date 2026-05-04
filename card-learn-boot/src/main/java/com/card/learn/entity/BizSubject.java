package com.card.learn.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import com.fasterxml.jackson.annotation.JsonFormat;
import java.time.LocalDateTime;

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

    @TableField(fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;

    /** 创建人 */
    private Long createBy;

    /** 修改人 */
    private Long updateBy;

}