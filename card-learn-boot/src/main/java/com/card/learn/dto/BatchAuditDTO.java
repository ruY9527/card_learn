package com.card.learn.dto;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import java.util.List;

/**
 * 批量审批DTO
 */
@Data
@ApiModel("批量审批参数")
public class BatchAuditDTO {

    @ApiModelProperty("审批用户ID")
    private Long auditUserId;

    @ApiModelProperty("审批备注")
    private String auditRemark;
}
