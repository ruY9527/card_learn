package com.card.learn.dto;

import lombok.Data;

/**
 * 冲刺配置更新请求DTO
 */
@Data
public class SprintConfigUpdateDTO {

    private String examDate;
    private String examName;
    private String enabled;
}
