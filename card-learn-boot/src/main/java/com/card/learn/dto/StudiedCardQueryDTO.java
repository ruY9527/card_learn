package com.card.learn.dto;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 已学卡片查询DTO
 */
@Data
@EqualsAndHashCode(callSuper = true)
@ApiModel("已学卡片查询参数")
public class StudiedCardQueryDTO extends PageQueryDTO {

    @ApiModelProperty("用户ID")
    private String userId;
}
