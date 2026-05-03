package com.card.learn.dto;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 反馈分页查询DTO
 */
@Data
@EqualsAndHashCode(callSuper = true)
@ApiModel("反馈查询参数")
public class FeedbackQueryDTO extends PageQueryDTO {

    @ApiModelProperty("反馈类型")
    private String type;

    @ApiModelProperty("状态")
    private String status;
}
