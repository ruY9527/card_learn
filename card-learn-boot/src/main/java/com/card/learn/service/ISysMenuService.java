package com.card.learn.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.card.learn.entity.SysMenu;

import java.util.List;

/**
 * 菜单Service
 */
public interface ISysMenuService extends IService<SysMenu> {

    /**
     * 根据用户ID查询菜单权限列表
     */
    List<SysMenu> selectMenusByUserId(Long userId);

    /**
     * 构建菜单树形结构
     */
    List<SysMenu> buildMenuTree(List<SysMenu> menus);

    /**
     * 根据角色ID查询菜单ID列表
     */
    List<Long> selectMenuIdsByRoleId(Long roleId);

}