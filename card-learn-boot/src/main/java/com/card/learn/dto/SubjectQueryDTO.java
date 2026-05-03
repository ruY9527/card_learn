package com.card.learn.dto;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 科目分页查询DTO
 */
@Data
@EqualsAndHashCode(callSuper = true)
@ApiModel("科目查询参数")
public class SubjectQueryDTO extends PageQueryDTO {

    @ApiModelProperty("专业ID")
    private Long majorId;

    @ApiModelProperty("科目名称")
    private String subjectName;
}
