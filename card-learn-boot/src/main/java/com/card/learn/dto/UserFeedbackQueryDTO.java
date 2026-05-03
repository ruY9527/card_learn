package com.card.learn.dto;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 用户反馈分页查询DTO
 */
@Data
@EqualsAndHashCode(callSuper = true)
@ApiModel("用户反馈查询参数")
public class UserFeedbackQueryDTO extends PageQueryDTO {

    @ApiModelProperty("用户ID")
    private Long userId;
}
