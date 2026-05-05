package com.card.learn.dto;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 排行榜查询参数
 */
@Data
@EqualsAndHashCode(callSuper = true)
@ApiModel("排行榜查询参数")
public class RankQueryDTO extends PageQueryDTO {

    @ApiModelProperty(value = "排行榜类型(total/week/streak)", example = "total")
    private String rankType = "total";
}
