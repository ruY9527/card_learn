package com.card.learn.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 经验值变动日志视图对象
 */
@Data
public class ExpLogVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long id;

    /** 经验变化 */
    private Integer expChange;

    /** 来源类型 */
    private String sourceType;

    /** 来源ID */
    private String sourceId;

    /** 变动描述 */
    private String description;

    /** 创建时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;
}
