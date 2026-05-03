package com.card.learn.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.io.Serializable;

/**
 * 设备注册DTO
 */
@Data
public class DeviceRegisterDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    @NotNull(message = "用户ID不能为空")
    private Long userId;

    @NotBlank(message = "设备Token不能为空")
    private String deviceToken;

    @NotBlank(message = "设备类型不能为空")
    private String deviceType;
}
