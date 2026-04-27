package com.card.learn.vo;

import lombok.Data;

import java.io.Serializable;

/**
 * 用户学习排行视图对象
 */
@Data
public class UserLearnRankVO implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 用户ID */
    private Long userId;

    /** 用户昵称 */
    private String nickname;

    /** 用户头像 */
    private String avatar;

    /** 学习卡片总数 */
    private Long totalCards;

    /** 掌握卡片数 */
    private Long masteredCount;

    /** 模糊卡片数 */
    private Long fuzzyCount;
}
