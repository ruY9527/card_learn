package com.card.learn.vo;

import lombok.Data;

import java.io.Serializable;

/**
 * 目标进度视图对象
 */
@Data
public class GoalProgressVO implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 日期 */
    private String date;

    /** 学习进度 */
    private Integer learnProgress;

    /** 学习目标 */
    private Integer learnTarget;

    /** 学习是否完成 */
    private Boolean learnCompleted;

    /** 学习完成百分比 */
    private Double learnPercent;

    /** 掌握进度 */
    private Integer masterProgress;

    /** 掌握目标 */
    private Integer masterTarget;

    /** 掌握是否完成 */
    private Boolean masterCompleted;

    /** 掌握完成百分比 */
    private Double masterPercent;
}
