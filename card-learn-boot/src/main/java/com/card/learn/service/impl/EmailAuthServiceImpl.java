package com.card.learn.service.impl;

import com.card.learn.common.AppConstants;
import com.card.learn.common.AppMessages;
import com.card.learn.dto.EmailRegisterDTO;
import com.card.learn.dto.ResetPasswordDTO;
import com.card.learn.entity.SysUser;
import com.card.learn.service.IEmailAuthService;
import com.card.learn.service.IEmailService;
import com.card.learn.service.ISysConfigService;
import com.card.learn.service.ISysUserService;
import com.card.learn.util.JwtUtil;
import com.card.learn.vo.LoginUserInfoVO;
import com.card.learn.vo.LoginVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Random;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

/**
 * 邮箱认证服务实现
 */
@Slf4j
@Service
public class EmailAuthServiceImpl implements IEmailAuthService {

    private static final String EMAIL_VERIFY_PREFIX = "email:verify:";
    private static final String EMAIL_RESET_PREFIX = "email:reset:";
    private static final String EMAIL_ACTIVATE_PREFIX = "email:activate:";
    private static final String EMAIL_SEND_LAST_PREFIX = "email:send:last:";
    private static final String EMAIL_SEND_COUNT_PREFIX = "email:send:count:";

    @Autowired
    private ISysUserService userService;

    @Autowired
    private IEmailService emailService;

    @Autowired
    private ISysConfigService configService;

    @Autowired
    private RedisTemplate<String, Object> redisTemplate;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtil jwtUtil;

    @Value("${email.verify-code-ttl:300}")
    private int verifyCodeTtl;

    @Value("${email.activate-code-ttl:86400}")
    private int activateCodeTtl;

    @Value("${email.send-limit-per-day:10}")
    private int sendLimitPerDay;

    @Value("${email.send-interval-seconds:60}")
    private int sendIntervalSeconds;

    @Override
    public String sendEmailCode(String email, String type) {
        // 频率限制：60秒间隔
        String lastSendKey = EMAIL_SEND_LAST_PREFIX + email;
        if (Boolean.TRUE.equals(redisTemplate.hasKey(lastSendKey))) {
            throw new RuntimeException(AppMessages.SEND_TOO_FREQUENT);
        }

        // 频率限制：每日上限
        String countKey = EMAIL_SEND_COUNT_PREFIX + email;
        Object countObj = redisTemplate.opsForValue().get(countKey);
        int count = countObj != null ? Integer.parseInt(countObj.toString()) : 0;
        if (count >= sendLimitPerDay) {
            throw new RuntimeException(AppMessages.DAILY_SEND_LIMIT);
        }

        // 注册类型需检查邮箱未注册
        if (AppConstants.EMAIL_TYPE_REGISTER.equals(type) && userService.existsByEmail(email)) {
            throw new RuntimeException(AppMessages.EMAIL_ALREADY_REGISTERED);
        }
        // 重置类型需检查邮箱已注册
        if (AppConstants.EMAIL_TYPE_RESET.equals(type) && !userService.existsByEmail(email)) {
            throw new RuntimeException(AppMessages.EMAIL_NOT_REGISTERED);
        }

        // 生成验证码
        String code = generateVerifyCode();
        String codeKey = UUID.randomUUID().toString();

        // 存储验证码到Redis
        String redisKey;
        if (AppConstants.EMAIL_TYPE_REGISTER.equals(type)) {
            redisKey = EMAIL_VERIFY_PREFIX + codeKey;
        } else {
            redisKey = EMAIL_RESET_PREFIX + codeKey;
        }
        redisTemplate.opsForValue().set(redisKey, email + ":" + code, verifyCodeTtl, TimeUnit.SECONDS);

        // 更新频率限制
        redisTemplate.opsForValue().set(lastSendKey, "1", sendIntervalSeconds, TimeUnit.SECONDS);
        redisTemplate.opsForValue().set(countKey, String.valueOf(count + 1), 24, TimeUnit.HOURS);

        // 发送邮件
        if (AppConstants.EMAIL_TYPE_REGISTER.equals(type)) {
            emailService.sendVerifyCode(email, code);
        } else {
            emailService.sendResetCode(email, code);
        }

        return codeKey;
    }

    @Override
    @Transactional
    public Object register(EmailRegisterDTO dto) {
        // 验证密码格式
        if (!isValidPassword(dto.getPassword())) {
            throw new RuntimeException(AppMessages.PASSWORD_FORMAT_INVALID);
        }

        // 检查邮箱未注册
        if (userService.existsByEmail(dto.getEmail())) {
            throw new RuntimeException(AppMessages.EMAIL_ALREADY_REGISTERED);
        }

        // 验证验证码
        String redisKey = EMAIL_VERIFY_PREFIX + dto.getCodeKey();
        String cached = (String) redisTemplate.opsForValue().get(redisKey);
        if (cached == null) {
            throw new RuntimeException(AppMessages.CAPTCHA_EXPIRED);
        }
        String[] parts = cached.split(":");
        if (!parts[0].equals(dto.getEmail()) || !parts[1].equals(dto.getCode())) {
            throw new RuntimeException(AppMessages.CAPTCHA_WRONG);
        }
        // 验证成功后删除验证码
        redisTemplate.delete(redisKey);

        // 生成用户名
        String username = generateUsername(dto.getEmail());

        // 读取配置：是否需要邮箱激活
        String activationRequired = configService.getConfigValue("email_activation_required");
        boolean needActivation = !"false".equals(activationRequired);

        // 创建用户
        SysUser user = new SysUser();
        user.setUsername(username);
        user.setPassword(passwordEncoder.encode(dto.getPassword()));
        user.setNickname(username);
        user.setEmail(dto.getEmail());
        user.setStatus(needActivation ? "1" : "0"); // 需要激活=1，不需要=0
        user.setDelFlag("0");
        userService.save(user);

        if (needActivation) {
            // 生成激活码并发送激活邮件
            String activateCode = UUID.randomUUID().toString();
            String activateKey = UUID.randomUUID().toString();
            String activateRedisKey = EMAIL_ACTIVATE_PREFIX + activateKey;
            redisTemplate.opsForValue().set(activateRedisKey,
                    user.getUserId() + ":" + activateCode, activateCodeTtl, TimeUnit.SECONDS);

            String baseUrl = configService.getConfigValue("email_activate_url");
            if (baseUrl == null || baseUrl.isEmpty()) {
                baseUrl = "http://localhost:5173/auth/activate";
            }
            String activateUrl = baseUrl + "?code=" + activateCode + "&key=" + activateKey;
            emailService.sendActivateEmail(dto.getEmail(), username, activateUrl);

            log.info("用户注册成功（待激活）: username={}, email={}", username, dto.getEmail());
            return username;
        } else {
            // 不需要激活，直接生成token返回
            String token = jwtUtil.generateToken(user.getUsername());

            LoginUserInfoVO userInfo = new LoginUserInfoVO();
            userInfo.setUserId(user.getUserId());
            userInfo.setUsername(user.getUsername());
            userInfo.setNickname(user.getNickname());
            userInfo.setEmail(user.getEmail());
            userInfo.setAvatar(user.getAvatar());
            userInfo.setRoles(new ArrayList<>());

            LoginVO loginVO = new LoginVO();
            loginVO.setToken(token);
            loginVO.setUser(userInfo);

            log.info("用户注册成功（已激活）: username={}, email={}", username, dto.getEmail());
            return loginVO;
        }
    }

    @Override
    @Transactional
    public LoginVO activate(String code, String key) {
        String redisKey = EMAIL_ACTIVATE_PREFIX + key;
        String cached = (String) redisTemplate.opsForValue().get(redisKey);
        if (cached == null) {
            throw new RuntimeException(AppMessages.ACTIVATE_LINK_EXPIRED);
        }

        String[] parts = cached.split(":");
        Long userId = Long.parseLong(parts[0]);
        String storedCode = parts[1];

        if (!storedCode.equals(code)) {
            throw new RuntimeException(AppMessages.ACTIVATE_LINK_INVALID);
        }

        SysUser user = userService.getById(userId);
        if (user == null) {
            throw new RuntimeException(AppMessages.USER_NOT_FOUND);
        }
        if ("0".equals(user.getStatus())) {
            throw new RuntimeException(AppMessages.ACCOUNT_ALREADY_ACTIVATED);
        }

        // 激活用户
        user.setStatus("0");
        userService.updateById(user);

        // 删除激活码
        redisTemplate.delete(redisKey);

        // 生成token自动登录
        String token = jwtUtil.generateToken(user.getUsername());

        LoginUserInfoVO userInfo = new LoginUserInfoVO();
        userInfo.setUserId(user.getUserId());
        userInfo.setUsername(user.getUsername());
        userInfo.setNickname(user.getNickname());
        userInfo.setEmail(user.getEmail());
        userInfo.setAvatar(user.getAvatar());
        userInfo.setRoles(new ArrayList<>());

        LoginVO loginVO = new LoginVO();
        loginVO.setToken(token);
        loginVO.setUser(userInfo);

        log.info("用户激活成功: userId={}, username={}", userId, user.getUsername());
        return loginVO;
    }

    @Override
    public void sendResetCode(String email) {
        sendEmailCode(email, AppConstants.EMAIL_TYPE_RESET);
    }

    @Override
    public void resetPassword(ResetPasswordDTO dto) {
        // 验证密码格式
        if (!isValidPassword(dto.getNewPassword())) {
            throw new RuntimeException(AppMessages.PASSWORD_FORMAT_INVALID);
        }

        // 检查邮箱已注册
        SysUser user = userService.getByEmail(dto.getEmail());
        if (user == null) {
            throw new RuntimeException(AppMessages.EMAIL_NOT_REGISTERED);
        }

        // 验证验证码
        String redisKey = EMAIL_RESET_PREFIX + dto.getCodeKey();
        String cached = (String) redisTemplate.opsForValue().get(redisKey);
        if (cached == null) {
            throw new RuntimeException(AppMessages.CAPTCHA_EXPIRED);
        }
        String[] parts = cached.split(":");
        if (!parts[0].equals(dto.getEmail()) || !parts[1].equals(dto.getCode())) {
            throw new RuntimeException(AppMessages.CAPTCHA_WRONG);
        }
        // 验证成功后删除验证码
        redisTemplate.delete(redisKey);

        // 更新密码
        user.setPassword(passwordEncoder.encode(dto.getNewPassword()));
        userService.updateById(user);

        log.info("密码重置成功: email={}", dto.getEmail());
    }

    /**
     * 生成6位随机验证码
     */
    private String generateVerifyCode() {
        Random random = new Random();
        int code = 100000 + random.nextInt(900000);
        return String.valueOf(code);
    }

    /**
     * 密码校验：6-20位，必须包含字母和数字
     */
    private boolean isValidPassword(String password) {
        if (password == null || password.length() < 6 || password.length() > 20) {
            return false;
        }
        boolean hasLetter = password.matches(".*[a-zA-Z].*");
        boolean hasDigit = password.matches(".*[0-9].*");
        return hasLetter && hasDigit;
    }

    /**
     * 根据邮箱生成唯一用户名
     */
    private String generateUsername(String email) {
        String base = email.split("@")[0];
        // 保留字母和数字，移除特殊字符
        String cleaned = base.replaceAll("[^a-zA-Z0-9]", "");
        // 确保不以数字开头
        if (!cleaned.isEmpty() && Character.isDigit(cleaned.charAt(0))) {
            cleaned = "user" + cleaned;
        }
        // 如果清洗后为空，生成随机用户名
        if (cleaned.isEmpty()) {
            cleaned = "user" + System.currentTimeMillis() % 10000;
        }
        // 检查唯一性，冲突则追加数字
        return ensureUniqueUsername(cleaned);
    }

    private String ensureUniqueUsername(String baseUsername) {
        String username = baseUsername;
        int counter = 1;
        while (userService.existsByUsername(username)) {
            username = baseUsername + counter;
            counter++;
        }
        return username;
    }

}
