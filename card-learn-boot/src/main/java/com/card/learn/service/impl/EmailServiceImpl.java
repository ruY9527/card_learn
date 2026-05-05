package com.card.learn.service.impl;

import com.card.learn.service.IEmailService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

/**
 * 邮件发送服务实现
 */
@Slf4j
@Service
public class EmailServiceImpl implements IEmailService {

    @Autowired
    private JavaMailSender mailSender;

    private static final String FROM_ADDRESS = "yundee@yundeeiot.com";

    private String getFromAddress() {
        return FROM_ADDRESS;
    }

    @Override
    public void sendVerifyCode(String to, String code) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(getFromAddress());
        message.setTo(to);
        message.setSubject("【考研学习卡片】注册验证码");
        message.setText("您好！\n\n"
                + "您的注册验证码为: " + code + "\n"
                + "验证码5分钟内有效，请勿泄露给他人。\n\n"
                + "如果不是您本人操作，请忽略此邮件。");
        mailSender.send(message);
        log.info("注册验证码邮件已发送至: {}", to);
    }

    @Override
    public void sendActivateEmail(String to, String username, String activateUrl) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(getFromAddress());
        message.setTo(to);
        message.setSubject("【考研学习卡片】邮箱激活 - 请在24小时内完成");
        message.setText("您好，" + username + "！\n\n"
                + "您注册的邮箱是: " + to + "\n"
                + "请点击以下链接激活账号:\n\n"
                + activateUrl + "\n\n"
                + "链接有效期: 24小时\n\n"
                + "如果无法点击，请复制链接到浏览器打开。\n\n"
                + "如果不是您本人操作，请忽略此邮件。");
        mailSender.send(message);
        log.info("激活邮件已发送至: {}", to);
    }

    @Override
    public void sendResetCode(String to, String code) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(getFromAddress());
        message.setTo(to);
        message.setSubject("【考研学习卡片】重置密码验证码");
        message.setText("您好！\n\n"
                + "您申请重置密码，验证码为: " + code + "\n"
                + "验证码5分钟内有效，请勿泄露给他人。\n\n"
                + "如果不是您本人操作，请立即联系管理员。");
        mailSender.send(message);
        log.info("重置密码验证码邮件已发送至: {}", to);
    }

}
