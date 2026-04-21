package com.card.learn.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.card.learn.entity.SysRole;

import java.util.List;

/**
 * 角色Service
 */
public interface ISysRoleService extends IService<SysRole> {

    /**
     * 分页查询角色
     */
    Page<SysRole> pageRoles(String roleName, Integer pageNum, Integer pageSize);

    /**
     * 分配菜单权限
     */
    void assignMenus(Long roleId, List<Long> menuIds);

    /**
     * 根据用户ID查询角色列表
     */
    List<SysRole> selectRolesByUserId(Long userId);

}