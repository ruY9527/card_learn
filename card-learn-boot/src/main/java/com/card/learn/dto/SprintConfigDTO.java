package com.card.learn.dto;

import lombok.Data;

/**
 * 冲刺配置DTO（小程序和前端使用）
 */
@Data
public class SprintConfigDTO {

    /** 考试名称 */
    private String examName;

    /** 考试日期 */
    private String examDate;

    /** 剩余天数 */
    private Long daysRemaining;

    /** 是否已过期 */
    private Boolean isExpired;

    /** 是否启用 */
    private Boolean enabled;

}