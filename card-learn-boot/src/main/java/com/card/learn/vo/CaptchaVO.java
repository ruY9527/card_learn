package com.card.learn.vo;

import lombok.Data;

import java.io.Serializable;

/**
 * 验证码VO
 */
@Data
public class CaptchaVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private String key;
    private String image;
}
