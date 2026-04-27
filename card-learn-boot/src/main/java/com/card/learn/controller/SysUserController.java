package com.card.learn.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.common.Result;
import com.card.learn.entity.SysUser;
import com.card.learn.entity.SysRole;
import com.card.learn.service.ISysUserService;
import com.card.learn.service.ISysRoleService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.HashMap;

/**
 * 用户管理控制器
 */
@RestController
@RequestMapping("/system/user")
@Api(tags = "用户管理")
public class SysUserController {

    @Autowired
    private ISysUserService userService;

    @Autowired
    private ISysRoleService roleService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @GetMapping("/page")
    @ApiOperation("分页查询用户")
    public Result<Page<SysUser>> page(
            @RequestParam(required = false) String username,
            @RequestParam(required = false) String status,
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        return Result.success(userService.pageUsers(username, status, pageNum, pageSize));
    }

    @GetMapping("/list")
    @ApiOperation("获取全部用户列表")
    public Result<List<SysUser>> list() {
        return Result.success(userService.list());
    }

    @GetMapping("/detail/{id}")
    @ApiOperation("获取用户详情")
    public Result<Map<String, Object>> getById(@PathVariable Long id) {
        SysUser user = userService.getById(id);
        List<SysRole> roles = roleService.selectRolesByUserId(id);
        Map<String, Object> data = new HashMap<>();
        data.put("user", user);
        data.put("roles", roles);
        return Result.success(data);
    }

    @PostMapping
    @ApiOperation("新增用户")
    public Result<Void> save(@RequestBody SysUser user) {
        // 检查用户名是否存在
        if (userService.getByUsername(user.getUsername()) != null) {
            return Result.error("用户名已存在");
        }
        // 对密码进行BCrypt加密
        if (user.getPassword() == null || user.getPassword().isEmpty()) {
            user.setPassword(passwordEncoder.encode("123456")); // 默认密码
        } else {
            user.setPassword(passwordEncoder.encode(user.getPassword()));
        }
        // 默认状态为正常
        if (user.getStatus() == null || user.getStatus().isEmpty()) {
            user.setStatus("0");
        }
        userService.save(user);
        return Result.success();
    }

    @PutMapping
    @ApiOperation("更新用户")
    public Result<Void> update(@RequestBody SysUser user) {
        // 如果传递了密码，需要进行加密处理
        if (user.getPassword() != null && !user.getPassword().isEmpty()) {
            user.setPassword(passwordEncoder.encode(user.getPassword()));
        } else {
            // 密码为空时不更新密码字段，保留原密码
            SysUser existingUser = userService.getById(user.getUserId());
            user.setPassword(existingUser.getPassword());
        }
        userService.updateById(user);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    @ApiOperation("删除用户")
    public Result<Void> delete(@PathVariable Long id) {
        userService.removeById(id);
        return Result.success();
    }

    @PutMapping("/resetPassword")
    @ApiOperation("重置密码")
    public Result<Void> resetPassword(@RequestParam Long userId, @RequestParam String password) {
        userService.resetPassword(userId, password);
        return Result.success();
    }

    @PutMapping("/assignRoles")
    @ApiOperation("分配角色")
    public Result<Void> assignRoles(@RequestParam Long userId, @RequestBody List<Long> roleIds) {
        userService.assignRoles(userId, roleIds);
        return Result.success();
    }

    @PutMapping("/changeStatus")
    @ApiOperation("修改用户状态")
    public Result<Void> changeStatus(@RequestParam Long userId, @RequestParam String status) {
        SysUser user = userService.getById(userId);
        user.setStatus(status);
        userService.updateById(user);
        return Result.success();
    }

}