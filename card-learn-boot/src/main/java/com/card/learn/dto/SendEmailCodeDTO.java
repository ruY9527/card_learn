package com.card.learn.dto;

import com.card.learn.common.AppMessages;
import lombok.Data;

import javax.validation.constraints.Email;
import javax.validation.constraints.NotBlank;

/**
 * 发送邮箱验证码请求DTO
 */
@Data
public class SendEmailCodeDTO {

    @NotBlank(message = AppMessages.EMAIL_REQUIRED)
    @Email(message = "邮箱格式不正确")
    private String email;

    /**
     * 验证码用途: register | reset
     */
    @NotBlank(message = "验证码类型不能为空")
    private String type;

}
