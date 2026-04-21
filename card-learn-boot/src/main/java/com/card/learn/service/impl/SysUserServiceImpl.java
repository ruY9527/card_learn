package com.card.learn.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.card.learn.entity.SysUser;
import com.card.learn.entity.SysUserRole;
import com.card.learn.mapper.SysUserMapper;
import com.card.learn.mapper.SysUserRoleMapper;
import com.card.learn.service.ISysUserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 后台用户Service实现
 */
@Service
public class SysUserServiceImpl extends ServiceImpl<SysUserMapper, SysUser> implements ISysUserService {

    @Autowired
    private SysUserRoleMapper userRoleMapper;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public SysUser getByUsername(String username) {
        return getOne(new LambdaQueryWrapper<SysUser>()
                .eq(SysUser::getUsername, username));
    }

    @Override
    public Page<SysUser> pageUsers(String username, Integer pageNum, Integer pageSize) {
        LambdaQueryWrapper<SysUser> wrapper = new LambdaQueryWrapper<>();
        if (username != null && !username.isEmpty()) {
            wrapper.like(SysUser::getUsername, username);
        }
        wrapper.orderByDesc(SysUser::getCreateTime);
        return page(new Page<>(pageNum, pageSize), wrapper);
    }

    @Override
    @Transactional
    public void assignRoles(Long userId, List<Long> roleIds) {
        // 先删除原有关联
        userRoleMapper.deleteByUserId(userId);
        // 新增关联
        if (roleIds != null && !roleIds.isEmpty()) {
            for (Long roleId : roleIds) {
                SysUserRole userRole = new SysUserRole();
                userRole.setUserId(userId);
                userRole.setRoleId(roleId);
                userRoleMapper.insert(userRole);
            }
        }
    }

    @Override
    public void resetPassword(Long userId, String password) {
        SysUser user = getById(userId);
        if (user != null) {
            user.setPassword(passwordEncoder.encode(password));
            updateById(user);
        }
    }

    @Override
    public boolean checkPassword(Long userId, String rawPassword) {
        SysUser user = getById(userId);
        if (user != null && user.getPassword() != null) {
            return passwordEncoder.matches(rawPassword, user.getPassword());
        }
        return false;
    }

}