package com.card.learn.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.card.learn.dto.UserQueryDTO;
import com.card.learn.entity.SysUser;

import java.util.List;

/**
 * 后台用户Service
 */
public interface ISysUserService extends IService<SysUser> {

    /**
     * 根据用户名查询用户
     */
    SysUser getByUsername(String username);

    /**
     * 分页查询用户
     */
    Page<SysUser> pageUsers(UserQueryDTO queryDTO);

    /**
     * 分配角色
     */
    void assignRoles(Long userId, List<Long> roleIds);

    /**
     * 重置密码
     */
    void resetPassword(Long userId, String password);

    /**
     * 验证密码
     */
    boolean checkPassword(Long userId, String rawPassword);

}