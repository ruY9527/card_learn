package com.card.learn.vo;

import lombok.Data;

import java.io.Serializable;

/**
 * 排行榜视图对象
 */
@Data
public class RankVO implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 排名 */
    private Integer rank;

    /** 用户ID */
    private Long userId;

    /** 用户昵称 */
    private String nickname;

    /** 头像 */
    private String avatar;

    /** 等级 */
    private Integer level;

    /** 等级名称 */
    private String levelName;

    /** 总经验 */
    private Integer totalExp;

    /** 本周学习数 */
    private Integer weekLearnCount;

    /** 当前连续天数 */
    private Integer currentStreak;
}
