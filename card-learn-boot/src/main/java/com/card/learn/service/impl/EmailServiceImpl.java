package com.card.learn.service.impl;

import com.card.learn.common.AppMessages;
import com.card.learn.service.IEmailService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
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

    @Value("${email.from:noreply@example.com}")
    private String fromAddress;

    @Override
    public void sendVerifyCode(String to, String code) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(fromAddress);
        message.setTo(to);
        message.setSubject(AppMessages.EMAIL_SUBJECT_REGISTER);
        message.setText(String.format(AppMessages.EMAIL_BODY_REGISTER_TEMPLATE, code));
        mailSender.send(message);
        log.info("注册验证码邮件已发送至: {}", to);
    }

    @Override
    public void sendActivateEmail(String to, String username, String activateUrl) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(fromAddress);
        message.setTo(to);
        message.setSubject(AppMessages.EMAIL_SUBJECT_ACTIVATE);
        message.setText(String.format(AppMessages.EMAIL_BODY_ACTIVATE_TEMPLATE, username, to, activateUrl));
        mailSender.send(message);
        log.info("激活邮件已发送至: {}", to);
    }

    @Override
    public void sendResetCode(String to, String code) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(fromAddress);
        message.setTo(to);
        message.setSubject(AppMessages.EMAIL_SUBJECT_RESET);
        message.setText(String.format(AppMessages.EMAIL_BODY_RESET_TEMPLATE, code));
        mailSender.send(message);
        log.info("重置密码验证码邮件已发送至: {}", to);
    }

}
