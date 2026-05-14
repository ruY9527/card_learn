package com.card.learn.dto;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import java.io.Serializable;

/**
 * 学习目标设置参数
 */
@Data
@ApiModel("学习目标设置参数")
public class GoalSetDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    @ApiModelProperty(value = "每日学习目标数量")
    private Integer dailyLearnTarget;

    @ApiModelProperty(value = "每日掌握目标数量")
    private Integer dailyMasterTarget;

    @ApiModelProperty(value = "是否启用")
    private Boolean enabled;

    @ApiModelProperty(value = "提醒小时(0-23)")
    private Integer reminderHour;

    @ApiModelProperty(value = "提醒分钟(0-59)")
    private Integer reminderMinute;
}
