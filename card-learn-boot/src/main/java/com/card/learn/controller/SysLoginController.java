package com.card.learn.controller;

import com.card.learn.common.Result;
import com.card.learn.dto.LoginDTO;
import com.card.learn.entity.SysUser;
import com.card.learn.service.ISysUserService;
import com.card.learn.util.JwtUtil;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * 登录控制器
 */
@RestController
@RequestMapping("/auth")
@Api(tags = "认证管理")
public class SysLoginController {

    private static final String CAPTCHA_PREFIX = "captcha:";

    @Autowired
    private ISysUserService userService;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private RedisTemplate<String, Object> redisTemplate;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @PostMapping("/login")
    @ApiOperation("用户登录")
    public Result<Map<String, Object>> login(@RequestBody LoginDTO loginDTO) {
        // 验证码校验
        if (loginDTO.getCaptchaKey() == null || loginDTO.getCaptcha() == null) {
            return Result.error("请输入验证码");
        }
        String cachedCaptcha = (String) redisTemplate.opsForValue().get(CAPTCHA_PREFIX + loginDTO.getCaptchaKey());
        if (cachedCaptcha == null) {
            return Result.error("验证码已过期，请重新获取");
        }
        if (!cachedCaptcha.equalsIgnoreCase(loginDTO.getCaptcha())) {
            return Result.error("验证码错误");
        }
        // 删除验证码，防止重复使用
        redisTemplate.delete(CAPTCHA_PREFIX + loginDTO.getCaptchaKey());

        // 用户验证
        SysUser user = userService.getByUsername(loginDTO.getUsername());
        if (user == null) {
            return Result.error("用户不存在");
        }
        // 使用BCrypt密码校验
        if (!passwordEncoder.matches(loginDTO.getPassword(), user.getPassword())) {
            return Result.error("密码错误");
        }
        if ("1".equals(user.getStatus())) {
            return Result.error("账号已停用");
        }
        String token = jwtUtil.generateToken(user.getUsername());
        
        // 构建用户信息（不返回敏感字段）
        Map<String, Object> userMap = new HashMap<>();
        userMap.put("userId", user.getUserId());
        userMap.put("username", user.getUsername());
        userMap.put("nickname", user.getNickname());
        userMap.put("avatar", user.getAvatar());
        
        Map<String, Object> data = new HashMap<>();
        data.put("token", token);
        data.put("user", userMap);
        return Result.success(data);
    }

    @PostMapping("/logout")
    @ApiOperation("用户登出")
    public Result<Void> logout() {
        return Result.success();
    }

}