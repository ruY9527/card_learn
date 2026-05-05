package com.card.learn.vo;

import lombok.Data;

import java.io.Serializable;

/**
 * 学习目标视图对象
 */
@Data
public class LearningGoalVO implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 每日学习目标 */
    private Integer dailyLearnTarget;

    /** 每日掌握目标 */
    private Integer dailyMasterTarget;

    /** 是否启用 */
    private Boolean enabled;
}
