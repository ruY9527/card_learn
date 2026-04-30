package com.card.learn.vo;

import lombok.Data;

import java.io.Serializable;

/**
 * 请求日志统计VO
 */
@Data
public class RequestLogStatsVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long total;
    private Long success;
    private Long fail;
    private Long today;
}
