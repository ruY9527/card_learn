package com.card.learn.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;

/**
 * 标签表
 */
@Data
@TableName("biz_tag")
public class BizTag implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "tag_id", type = IdType.AUTO)
    private Long tagId;

    private String tagName;

    /** 所属科目ID（null表示通用标签） */
    private Long subjectId;


    /** 创建人 */
    private Long createBy;

    /** 修改人 */
    private Long updateBy;
}
