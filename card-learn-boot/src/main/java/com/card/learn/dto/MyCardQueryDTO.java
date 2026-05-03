package com.card.learn.dto;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 我的卡片分页查询DTO
 */
@Data
@EqualsAndHashCode(callSuper = true)
@ApiModel("我的卡片查询参数")
public class MyCardQueryDTO extends PageQueryDTO {

    @ApiModelProperty("审批状态：0待审批 1通过 2拒绝")
    private String auditStatus;
}
