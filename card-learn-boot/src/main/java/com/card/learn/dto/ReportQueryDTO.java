package com.card.learn.dto;

import lombok.Data;

/**
 * 报告查询DTO
 */
@Data
public class ReportQueryDTO {

    /** 报告类型: weekly/monthly */
    private String type = "weekly";

    /** 页码 */
    private Integer page = 1;

    /** 每页数量 */
    private Integer size = 4;
}
