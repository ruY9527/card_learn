package com.card.learn.dto;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 卡片学习历史查询DTO
 */
@Data
@EqualsAndHashCode(callSuper = true)
@ApiModel("卡片学习历史查询参数")
public class CardStudyHistoryQueryDTO extends PageQueryDTO {

    @ApiModelProperty("用户ID")
    private String userId;
}
