package com.card.learn.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.common.Result;
import com.card.learn.entity.SysOperLog;
import com.card.learn.service.ISysOperLogService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 操作日志控制器
 */
@RestController
@RequestMapping("/system/log")
@Api(tags = "操作日志管理")
public class SysOperLogController {

    @Autowired
    private ISysOperLogService operLogService;

    @GetMapping("/page")
    @ApiOperation("分页查询操作日志")
    public Result<Page<SysOperLog>> page(
            @RequestParam(required = false) String title,
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        return Result.success(operLogService.pageLogs(title, pageNum, pageSize));
    }

    @GetMapping("/{id}")
    @ApiOperation("获取日志详情")
    public Result<SysOperLog> getById(@PathVariable Long id) {
        return Result.success(operLogService.getById(id));
    }

    @DeleteMapping("/{id}")
    @ApiOperation("删除日志")
    public Result<Void> delete(@PathVariable Long id) {
        operLogService.removeById(id);
        return Result.success();
    }

    @DeleteMapping("/clear")
    @ApiOperation("清空日志")
    public Result<Void> clear() {
        operLogService.remove(new LambdaQueryWrapper<>());
        return Result.success();
    }

}