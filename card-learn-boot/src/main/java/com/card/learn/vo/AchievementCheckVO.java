package com.card.learn.vo;

import lombok.Data;

import java.io.Serializable;
import java.util.List;

/**
 * 成就检查结果视图对象
 */
@Data
public class AchievementCheckVO implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 新解锁的成就 */
    private List<AchievementVO> newAchievements;

    /** 总经验 */
    private Integer totalExp;

    /** 当前等级 */
    private Integer level;

    /** 是否升级 */
    private Boolean leveledUp;
}
