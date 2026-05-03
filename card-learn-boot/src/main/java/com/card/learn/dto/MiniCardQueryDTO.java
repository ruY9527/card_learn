package com.card.learn.dto;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 小程序卡片分页查询DTO
 */
@Data
@EqualsAndHashCode(callSuper = true)
@ApiModel("小程序卡片查询参数")
public class MiniCardQueryDTO extends PageQueryDTO {

    @ApiModelProperty("科目ID")
    private Long subjectId;

    @ApiModelProperty("卡片正面内容")
    private String frontContent;

    @ApiModelProperty("用户ID")
    private String userId;

    @ApiModelProperty("状态筛选：learned/mastered/review/unlearned/all")
    private String status;
}
