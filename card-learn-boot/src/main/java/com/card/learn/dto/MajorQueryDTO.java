package com.card.learn.dto;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 专业分页查询DTO
 */
@Data
@EqualsAndHashCode(callSuper = true)
@ApiModel("专业查询参数")
public class MajorQueryDTO extends PageQueryDTO {

    @ApiModelProperty("专业名称")
    private String majorName;

    @ApiModelProperty("状态")
    private String status;
}
