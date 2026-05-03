package com.card.learn.dto;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 操作日志分页查询DTO
 */
@Data
@EqualsAndHashCode(callSuper = true)
@ApiModel("操作日志查询参数")
public class OperLogQueryDTO extends PageQueryDTO {

    @ApiModelProperty("操作标题")
    private String title;
}
