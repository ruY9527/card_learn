package com.card.learn.mapper;

import lombok.Data;

import java.io.Serializable;

/**
 * 评论统计结果
 */
@Data
public class CommentStats implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 总评论数 */
    private Integer totalComments;

    /** 优质内容数 */
    private Integer qualityCount;

    /** 劣质内容数 */
    private Integer poorCount;

    /** 平均评分 */
    private Double avgRating;
}