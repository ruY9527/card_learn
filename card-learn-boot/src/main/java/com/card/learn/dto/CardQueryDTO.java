package com.card.learn.dto;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 卡片分页查询DTO
 */
@Data
@EqualsAndHashCode(callSuper = true)
@ApiModel("卡片查询参数")
public class CardQueryDTO extends PageQueryDTO {

    @ApiModelProperty("科目ID")
    private Long subjectId;

    @ApiModelProperty("卡片正面内容")
    private String frontContent;
}
