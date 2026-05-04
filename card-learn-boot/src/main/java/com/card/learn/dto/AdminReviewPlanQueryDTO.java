package com.card.learn.dto;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

/**
 * 管理端-复习计划查询DTO
 */
@Data
@ApiModel("管理端复习计划查询参数")
public class AdminReviewPlanQueryDTO {

    @ApiModelProperty("用户ID")
    private Long userId;

    @ApiModelProperty("状态：0待复习 1已完成")
    private String status;

    @ApiModelProperty("计划日期-开始，格式：yyyy-MM-dd HH:mm:ss")
    private String scheduledDateStart;

    @ApiModelProperty("计划日期-结束，格式：yyyy-MM-dd HH:mm:ss")
    private String scheduledDateEnd;

    @ApiModelProperty(value = "页码", example = "1")
    private Integer pageNum = 1;

    @ApiModelProperty(value = "每页条数", example = "20")
    private Integer pageSize = 20;
}
