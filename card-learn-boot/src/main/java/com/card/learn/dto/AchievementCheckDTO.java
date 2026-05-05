package com.card.learn.dto;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import java.io.Serializable;

/**
 * 成就检查参数
 */
@Data
@ApiModel("成就检查参数")
public class AchievementCheckDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    @ApiModelProperty(value = "用户ID", required = true)
    private Long userId;

    @ApiModelProperty(value = "操作类型(learn/master/review/comment/contribute)", required = true)
    private String actionType;

    @ApiModelProperty(value = "来源ID(如卡片ID)")
    private String sourceId;
}
