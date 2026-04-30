package com.card.learn.vo;

import lombok.Data;

import java.io.Serializable;

/**
 * 登录结果VO
 */
@Data
public class LoginVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private String token;
    private LoginUserInfoVO user;
}
