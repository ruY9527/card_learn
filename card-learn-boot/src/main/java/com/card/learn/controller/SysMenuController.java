package com.card.learn.controller;

import com.card.learn.common.Result;
import com.card.learn.entity.SysMenu;
import com.card.learn.entity.SysUser;
import com.card.learn.service.ISysMenuService;
import com.card.learn.service.ISysUserService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 菜单管理控制器
 */
@RestController
@RequestMapping("/system/menu")
@Api(tags = "菜单管理")
public class SysMenuController {

    @Autowired
    private ISysMenuService menuService;

    @Autowired
    private ISysUserService userService;

    @GetMapping("/list")
    @ApiOperation("获取菜单列表")
    public Result<List<SysMenu>> list() {
        List<SysMenu> menus = menuService.list();
        return Result.success(menuService.buildMenuTree(menus));
    }

    @GetMapping("/userMenus")
    @ApiOperation("获取指定用户菜单")
    public Result<List<SysMenu>> getUserMenus(@RequestParam Long userId) {
        List<SysMenu> menus = menuService.selectMenusByUserId(userId);
        return Result.success(menuService.buildMenuTree(menus));
    }

    @GetMapping("/{id:\\d+}")
    @ApiOperation("获取菜单详情")
    public Result<SysMenu> getById(@PathVariable Long id) {
        return Result.success(menuService.getById(id));
    }

    @GetMapping("/current")
    @ApiOperation("获取当前登录用户菜单")
    public Result<List<SysMenu>> getCurrentUserMenus() {
        String username = SecurityContextHolder.getContext().getAuthentication().getName();
        SysUser user = userService.getByUsername(username);
        if (user == null) {
            return Result.error("用户不存在");
        }
        List<SysMenu> menus = menuService.selectMenusByUserId(user.getUserId());
        return Result.success(menuService.buildMenuTree(menus));
    }

    @GetMapping("/roleMenus/{roleId}")
    @ApiOperation("获取角色的菜单ID列表")
    public Result<List<Long>> getRoleMenus(@PathVariable Long roleId) {
        return Result.success(menuService.selectMenuIdsByRoleId(roleId));
    }

    @PostMapping
    @ApiOperation("新增菜单")
    public Result<Void> save(@RequestBody SysMenu menu) {
        menuService.save(menu);
        return Result.success();
    }

    @PutMapping
    @ApiOperation("更新菜单")
    public Result<Void> update(@RequestBody SysMenu menu) {
        menuService.updateById(menu);
        return Result.success();
    }

    @DeleteMapping("/{id:\\d+}")
    @ApiOperation("删除菜单")
    public Result<Void> delete(@PathVariable Long id) {
        menuService.removeById(id);
        return Result.success();
    }

}