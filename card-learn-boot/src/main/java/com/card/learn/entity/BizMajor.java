package com.card.learn.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;

/**
 * 专业信息表
 */
@Data
@TableName("biz_major")
public class BizMajor implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "major_id", type = IdType.AUTO)
    private Long majorId;

    private String majorName;

    private String description;

    /** 状态 */
    private String status;

}