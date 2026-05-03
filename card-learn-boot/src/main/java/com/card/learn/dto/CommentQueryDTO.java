package com.card.learn.dto;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 评论分页查询DTO
 */
@Data
@EqualsAndHashCode(callSuper = true)
@ApiModel("评论查询参数")
public class CommentQueryDTO extends PageQueryDTO {

    @ApiModelProperty("卡片ID")
    private Long cardId;

    @ApiModelProperty("评论类型")
    private String commentType;

    @ApiModelProperty("状态")
    private String status;
}
