package com.card.learn.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.common.Result;
import com.card.learn.entity.SysRole;
import com.card.learn.service.ISysRoleService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 角色管理控制器
 */
@RestController
@RequestMapping("/system/role")
@Api(tags = "角色管理")
public class SysRoleController {

    @Autowired
    private ISysRoleService roleService;

    @GetMapping("/page")
    @ApiOperation("分页查询角色")
    public Result<Page<SysRole>> page(
            @RequestParam(required = false) String roleName,
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        return Result.success(roleService.pageRoles(roleName, pageNum, pageSize));
    }

    @GetMapping("/list")
    @ApiOperation("获取角色列表")
    public Result<List<SysRole>> list() {
        return Result.success(roleService.list());
    }

    @GetMapping("/{id}")
    @ApiOperation("获取角色详情")
    public Result<SysRole> getById(@PathVariable Long id) {
        return Result.success(roleService.getById(id));
    }

    @PostMapping
    @ApiOperation("新增角色")
    public Result<Void> save(@RequestBody SysRole role) {
        roleService.save(role);
        return Result.success();
    }

    @PutMapping
    @ApiOperation("更新角色")
    public Result<Void> update(@RequestBody SysRole role) {
        roleService.updateById(role);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    @ApiOperation("删除角色")
    public Result<Void> delete(@PathVariable Long id) {
        roleService.removeById(id);
        return Result.success();
    }

    @PutMapping("/assignMenus")
    @ApiOperation("分配菜单权限")
    public Result<Void> assignMenus(@RequestParam Long roleId, @RequestBody List<Long> menuIds) {
        roleService.assignMenus(roleId, menuIds);
        return Result.success();
    }

    @PutMapping("/changeStatus")
    @ApiOperation("修改角色状态")
    public Result<Void> changeStatus(@RequestParam Long roleId, @RequestParam String status) {
        SysRole role = roleService.getById(roleId);
        role.setStatus(status);
        roleService.updateById(role);
        return Result.success();
    }

}