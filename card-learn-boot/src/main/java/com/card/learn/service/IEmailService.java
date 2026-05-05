package com.card.learn.service;

/**
 * 邮件发送服务
 */
public interface IEmailService {

    /**
     * 发送注册验证码邮件
     */
    void sendVerifyCode(String to, String code);

    /**
     * 发送激活邮件
     */
    void sendActivateEmail(String to, String username, String activateUrl);

    /**
     * 发送重置密码验证码邮件
     */
    void sendResetCode(String to, String code);

}
