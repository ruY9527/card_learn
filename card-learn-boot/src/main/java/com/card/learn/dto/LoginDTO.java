package com.card.learn.dto;

import lombok.Data;

/**
 * 登录请求DTO
 */
@Data
public class LoginDTO {

    private String username;

    private String password;

    /**
     * 验证码
     */
    private String captcha;

    /**
     * 验证码key
     */
    private String captchaKey;

}