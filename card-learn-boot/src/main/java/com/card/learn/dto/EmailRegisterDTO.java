package com.card.learn.dto;

import lombok.Data;

import javax.validation.constraints.Email;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;

/**
 * 邮箱注册请求DTO
 */
@Data
public class EmailRegisterDTO {

    @NotBlank(message = "邮箱不能为空")
    @Email(message = "邮箱格式不正确")
    private String email;

    @NotBlank(message = "验证码不能为空")
    private String code;

    @NotBlank(message = "验证码key不能为空")
    private String codeKey;

    @NotBlank(message = "密码不能为空")
    @Size(min = 6, max = 20, message = "密码长度需6-20位")
    private String password;

}
