package com.card.learn.vo;

import lombok.Data;

import java.io.Serializable;
import java.util.List;

/**
 * 用户成就列表视图对象
 */
@Data
public class AchievementListVO implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 已解锁数量 */
    private Integer unlockedCount;

    /** 总数量 */
    private Integer totalCount;

    /** 成就列表 */
    private List<AchievementVO> achievements;
}
