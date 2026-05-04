package com.card.learn.dto;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 笔记分页查询DTO
 */
@Data
@EqualsAndHashCode(callSuper = true)
@ApiModel("笔记查询参数")
public class NoteQueryDTO extends PageQueryDTO {

    @ApiModelProperty("用户ID")
    private Long userId;

    @ApiModelProperty("用户名（模糊搜索）")
    private String username;

    @ApiModelProperty("按科目筛选")
    private Long subjectId;

    @ApiModelProperty("开始日期（yyyy-MM-dd）")
    private String startDate;

    @ApiModelProperty("结束日期（yyyy-MM-dd）")
    private String endDate;

    @ApiModelProperty("按卡片筛选")
    private Long cardId;

    @ApiModelProperty("关键词搜索")
    private String keyword;
}
