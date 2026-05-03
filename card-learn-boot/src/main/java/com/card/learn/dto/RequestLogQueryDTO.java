package com.card.learn.dto;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 请求日志分页查询DTO
 */
@Data
@EqualsAndHashCode(callSuper = true)
@ApiModel("请求日志查询参数")
public class RequestLogQueryDTO extends PageQueryDTO {

    @ApiModelProperty("请求方法")
    private String requestMethod;

    @ApiModelProperty("请求URL")
    private String requestUrl;

    @ApiModelProperty("状态：1成功 0失败")
    private String status;

    @ApiModelProperty("开始时间，格式：yyyy-MM-dd HH:mm:ss")
    private String startTime;

    @ApiModelProperty("结束时间，格式：yyyy-MM-dd HH:mm:ss")
    private String endTime;
}
