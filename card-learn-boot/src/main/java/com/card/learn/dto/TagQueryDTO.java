package com.card.learn.dto;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 标签分页查询DTO
 */
@Data
@EqualsAndHashCode(callSuper = true)
@ApiModel("标签查询参数")
public class TagQueryDTO extends PageQueryDTO {

    @ApiModelProperty("标签名称")
    private String tagName;

    @ApiModelProperty("科目ID")
    private Long subjectId;
}
