package com.card.learn.vo;

import lombok.Data;

import java.io.Serializable;

/**
 * 用户等级视图对象
 */
@Data
public class UserLevelVO implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 当前等级 */
    private Integer level;

    /** 等级名称 */
    private String levelName;

    /** 当前等级经验 */
    private Integer currentExp;

    /** 累计经验 */
    private Integer totalExp;

    /** 下一级所需经验 */
    private Integer nextLevelExp;

    /** 升级进度百分比 */
    private Double progressPercent;

    /** 距下一级还需经验 */
    private Integer expToNextLevel;
}
