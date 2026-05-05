package com.card.learn.service;

import com.card.learn.dto.EmailRegisterDTO;
import com.card.learn.dto.ResetPasswordDTO;
import com.card.learn.vo.LoginVO;

/**
 * 邮箱认证服务
 */
public interface IEmailAuthService {

    /**
     * 发送邮箱验证码
     *
     * @param email 邮箱
     * @param type  用途: register | reset
     * @return codeKey
     */
    String sendEmailCode(String email, String type);

    /**
     * 邮箱注册
     *
     * @param dto 注册请求
     * @return 需要激活时返回用户名(String)，不需要激活时返回LoginVO
     */
    Object register(EmailRegisterDTO dto);

    /**
     * 激活账号
     *
     * @param code 激活码
     * @param key  激活key
     * @return 登录信息（含token）
     */
    LoginVO activate(String code, String key);

    /**
     * 发送重置密码验证码
     *
     * @param email 邮箱
     */
    void sendResetCode(String email);

    /**
     * 重置密码
     *
     * @param dto 重置请求
     */
    void resetPassword(ResetPasswordDTO dto);

}
