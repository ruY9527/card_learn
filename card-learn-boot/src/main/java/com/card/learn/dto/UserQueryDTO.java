package com.card.learn.dto;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 用户分页查询DTO
 */
@Data
@EqualsAndHashCode(callSuper = true)
@ApiModel("用户查询参数")
public class UserQueryDTO extends PageQueryDTO {

    @ApiModelProperty("用户名")
    private String username;

    @ApiModelProperty("状态")
    private String status;
}
