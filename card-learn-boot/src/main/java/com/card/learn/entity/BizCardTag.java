package com.card.learn.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import com.fasterxml.jackson.annotation.JsonFormat;
import java.time.LocalDateTime;

/**
 * 卡片标签关联表
 */
@Data
@TableName("biz_card_tag")
public class BizCardTag implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 使用cardId作为虚拟主键（实际为复合主键）
     * 设置为INPUT类型，不自动生成
     */
    @TableId(type = IdType.INPUT)
    private Long cardId;

    private Long tagId;

    @TableField(fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;

    /** 更新人ID */
    private Long updateUserId;

}