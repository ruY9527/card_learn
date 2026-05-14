package com.card.learn.controller;

import com.card.learn.common.AppMessages;
import com.card.learn.common.Result;
import com.card.learn.dto.EmailRegisterDTO;
import com.card.learn.dto.LoginDTO;
import com.card.learn.dto.ResetPasswordDTO;
import com.card.learn.dto.SendEmailCodeDTO;
import com.card.learn.entity.SysMenu;
import com.card.learn.entity.SysRole;
import com.card.learn.entity.SysUser;
import com.card.learn.service.IEmailAuthService;
import com.card.learn.service.ISysMenuService;
import com.card.learn.service.ISysRoleService;
import com.card.learn.service.ISysUserService;
import com.card.learn.util.JwtUtil;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import com.card.learn.vo.LoginUserInfoVO;
import com.card.learn.vo.LoginVO;

import javax.validation.Valid;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 登录控制器
 */
@RestController
@RequestMapping("/auth")
@Api(tags = "认证管理")
public class SysLoginController {

    private static final String CAPTCHA_PREFIX = "captcha:";
    private static final String EMAIL_REGEX = "^[\\w.-]+@[\\w.-]+\\.\\w+$";

    @Autowired
    private ISysUserService userService;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private RedisTemplate<String, Object> redisTemplate;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private IEmailAuthService emailAuthService;

    @Autowired
    private ISysRoleService roleService;

    @Autowired
    private ISysMenuService menuService;

    @PostMapping("/login")
    @ApiOperation("用户登录（支持用户名或邮箱）")
    public Result<LoginVO> login(@RequestBody LoginDTO loginDTO) {
        // 验证码校验
        if (loginDTO.getCaptchaKey() == null || loginDTO.getCaptcha() == null) {
            return Result.error(AppMessages.CAPTCHA_REQUIRED);
        }
        String cachedCaptcha = (String) redisTemplate.opsForValue().get(CAPTCHA_PREFIX + loginDTO.getCaptchaKey());
        if (cachedCaptcha == null) {
            return Result.error(AppMessages.CAPTCHA_EXPIRED);
        }
        if (!cachedCaptcha.equalsIgnoreCase(loginDTO.getCaptcha())) {
            return Result.error(AppMessages.CAPTCHA_WRONG);
        }
        // 删除验证码，防止重复使用
        redisTemplate.delete(CAPTCHA_PREFIX + loginDTO.getCaptchaKey());

        // 用户验证 - 支持用户名或邮箱登录
        SysUser user = findUserByLoginId(loginDTO.getUsername(), loginDTO.getEmail());
        if (user == null) {
            return Result.error(AppMessages.USER_NOT_FOUND);
        }
        // 使用BCrypt密码校验
        if (!passwordEncoder.matches(loginDTO.getPassword(), user.getPassword())) {
            return Result.error(AppMessages.PASSWORD_WRONG);
        }
        if ("1".equals(user.getStatus())) {
            return Result.error(AppMessages.ACCOUNT_INACTIVE);
        }
        String token = jwtUtil.generateToken(user.getUsername());

        // 构建用户信息（不返回敏感字段）
        LoginUserInfoVO userInfo = buildUserInfo(user);

        LoginVO loginVO = new LoginVO();
        loginVO.setToken(token);
        loginVO.setUser(userInfo);
        return Result.success(loginVO);
    }

    @PostMapping("/email-code/send")
    @ApiOperation("发送邮箱验证码")
    public Result<Map<String, String>> sendEmailCode(@Valid @RequestBody SendEmailCodeDTO dto) {
        try {
            String codeKey = emailAuthService.sendEmailCode(dto.getEmail(), dto.getType());
            Map<String, String> data = new HashMap<>();
            data.put("codeKey", codeKey);
            return Result.success(AppMessages.CAPTCHA_SENT, data);
        } catch (RuntimeException e) {
            return Result.error(e.getMessage());
        }
    }

    @PostMapping("/email/register")
    @ApiOperation("邮箱注册")
    public Result<?> emailRegister(@Valid @RequestBody EmailRegisterDTO dto) {
        try {
            Object result = emailAuthService.register(dto);
            if (result instanceof LoginVO) {
                // 不需要激活，直接返回登录信息
                return Result.success(AppMessages.REGISTER_SUCCESS, result);
            } else {
                // 需要激活，返回用户名
                Map<String, String> data = new HashMap<>();
                data.put("username", result.toString());
                return Result.success(AppMessages.REGISTER_SUCCESS_ACTIVATE, data);
            }
        } catch (RuntimeException e) {
            return Result.error(e.getMessage());
        }
    }

    @GetMapping("/activate")
    @ApiOperation("激活账号")
    public Result<LoginVO> activate(@RequestParam String code, @RequestParam String key) {
        try {
            LoginVO loginVO = emailAuthService.activate(code, key);
            return Result.success(AppMessages.ACTIVATE_SUCCESS, loginVO);
        } catch (RuntimeException e) {
            return Result.error(e.getMessage());
        }
    }

    @PostMapping("/password/reset-code/send")
    @ApiOperation("发送重置密码验证码")
    public Result<Map<String, String>> sendResetCode(@RequestBody Map<String, String> body) {
        String email = body.get("email");
        if (email == null || email.isEmpty()) {
            return Result.error(AppMessages.EMAIL_REQUIRED);
        }
        try {
            emailAuthService.sendResetCode(email);
            Map<String, String> data = new HashMap<>();
            data.put("codeKey", "sent");
            return Result.success(AppMessages.CAPTCHA_SENT, data);
        } catch (RuntimeException e) {
            return Result.error(e.getMessage());
        }
    }

    @PostMapping("/password/reset")
    @ApiOperation("重置密码")
    public Result<Void> resetPassword(@Valid @RequestBody ResetPasswordDTO dto) {
        try {
            emailAuthService.resetPassword(dto);
            return Result.success(AppMessages.PASSWORD_RESET_SUCCESS, null);
        } catch (RuntimeException e) {
            return Result.error(e.getMessage());
        }
    }

    @PostMapping("/logout")
    @ApiOperation("用户登出")
    public Result<Void> logout() {
        return Result.success();
    }

    /**
     * 根据用户名或邮箱查找用户
     */
    private SysUser findUserByLoginId(String username, String email) {
        if (email != null && !email.isEmpty() && email.matches(EMAIL_REGEX)) {
            return userService.getByEmail(email);
        }
        if (username != null && !username.isEmpty()) {
            // 自动识别：如果输入的是邮箱格式，按邮箱查找
            if (username.matches(EMAIL_REGEX)) {
                return userService.getByEmail(username);
            }
            return userService.getByUsername(username);
        }
        return null;
    }

    /**
     * 构建登录用户信息（含角色）
     */
    private LoginUserInfoVO buildUserInfo(SysUser user) {
        LoginUserInfoVO userInfo = new LoginUserInfoVO();
        userInfo.setUserId(user.getUserId());
        userInfo.setUsername(user.getUsername());
        userInfo.setNickname(user.getNickname());
        userInfo.setEmail(user.getEmail());
        userInfo.setAvatar(user.getAvatar());

        // 查询用户角色
        List<SysRole> roles = roleService.selectRolesByUserId(user.getUserId());
        if (roles != null && !roles.isEmpty()) {
            userInfo.setRoles(roles.stream().map(SysRole::getRoleKey).collect(Collectors.toList()));
        } else {
            userInfo.setRoles(new ArrayList<>());
        }

        // 查询用户菜单权限
        List<SysMenu> menus = menuService.selectMenusByUserId(user.getUserId());
        userInfo.setMenus(menuService.buildMenuTree(menus));

        return userInfo;
    }

}
