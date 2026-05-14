package com.card.learn.controller;

import com.card.learn.common.AppMessages;
import com.card.learn.common.Result;
import com.card.learn.dto.SprintConfigDTO;
import com.card.learn.entity.SysConfig;
import com.card.learn.service.ISysConfigService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import com.card.learn.dto.ConfigUpdateDTO;
import com.card.learn.dto.SprintConfigUpdateDTO;

import java.util.List;

/**
 * 系统配置管理Controller（管理端）
 */
@RestController
@RequestMapping("/system/config")
@Api(tags = "系统配置管理")
public class SysConfigController {

    @Autowired
    private ISysConfigService configService;

    /**
     * 获取所有配置列表
     */
    @GetMapping("/list")
    @ApiOperation("获取所有配置列表")
    public Result<List<SysConfig>> getAllConfigs() {
        return Result.success(configService.getAllConfigs());
    }

    /**
     * 根据配置键获取配置
     */
    @GetMapping("/{key}")
    @ApiOperation("根据配置键获取配置")
    public Result<SysConfig> getConfigByKey(@PathVariable String key) {
        SysConfig config = configService.getConfigByKey(key);
        if (config == null) {
            return Result.error(AppMessages.CONFIG_NOT_FOUND);
        }
        return Result.success(config);
    }

    /**
     * 更新配置值
     */
    @PutMapping("/{key}")
    @ApiOperation("更新配置值")
    public Result<Void> updateConfig(@PathVariable String key, @RequestBody ConfigUpdateDTO body) {
        String value = body.getValue();
        if (value == null) {
            return Result.error(AppMessages.CONFIG_VALUE_REQUIRED);
        }
        boolean success = configService.updateConfigValue(key, value);
        if (success) {
            return Result.success();
        } else {
            return Result.error(AppMessages.CONFIG_NOT_FOUND_OR_UPDATE_FAILED);
        }
    }

    /**
     * 更新整个配置对象
     */
    @PutMapping
    @ApiOperation("更新配置对象")
    public Result<Void> updateConfigEntity(@RequestBody SysConfig config) {
        if (config.getConfigKey() == null) {
            return Result.error(AppMessages.CONFIG_KEY_REQUIRED);
        }
        boolean success = configService.updateById(config);
        if (success) {
            return Result.success();
        } else {
            return Result.error(AppMessages.CONFIG_UPDATE_FAILED);
        }
    }

    /**
     * 批量更新配置
     */
    @PutMapping("/batch")
    @ApiOperation("批量更新配置")
    public Result<Void> batchUpdateConfigs(@RequestBody List<SysConfig> configs) {
        for (SysConfig config : configs) {
            if (config.getConfigKey() != null && config.getConfigValue() != null) {
                configService.updateConfigValue(config.getConfigKey(), config.getConfigValue());
            }
        }
        return Result.success();
    }

    /**
     * 新增配置
     */
    @PostMapping
    @ApiOperation("新增配置")
    public Result<Void> addConfig(@RequestBody SysConfig config) {
        if (config.getConfigKey() == null || config.getConfigValue() == null) {
            return Result.error(AppMessages.CONFIG_KEY_VALUE_REQUIRED);
        }
        // 检查是否已存在
        SysConfig existing = configService.getConfigByKey(config.getConfigKey());
        if (existing != null) {
            return Result.error(AppMessages.CONFIG_KEY_ALREADY_EXISTS);
        }
        configService.save(config);
        return Result.success();
    }

    /**
     * 删除配置
     */
    @DeleteMapping("/{key}")
    @ApiOperation("删除配置")
    public Result<Void> deleteConfig(@PathVariable String key) {
        SysConfig config = configService.getConfigByKey(key);
        if (config == null) {
            return Result.error(AppMessages.CONFIG_NOT_FOUND);
        }
        configService.removeById(config.getId());
        return Result.success();
    }

    /**
     * 获取冲刺配置（管理端查看）
     */
    @GetMapping("/sprint")
    @ApiOperation("获取冲刺配置")
    public Result<SprintConfigDTO> getSprintConfig() {
        return Result.success(configService.getSprintConfig());
    }

    /**
     * 更新冲刺配置
     */
    @PutMapping("/sprint")
    @ApiOperation("更新冲刺配置")
    public Result<Void> updateSprintConfig(@RequestBody SprintConfigUpdateDTO body) {
        String examDate = body.getExamDate();
        String examName = body.getExamName();
        String enabled = body.getEnabled();

        if (examDate != null) {
            configService.updateConfigValue("sprint_exam_date", examDate);
        }
        if (examName != null) {
            configService.updateConfigValue("sprint_exam_name", examName);
        }
        if (enabled != null) {
            configService.updateConfigValue("sprint_enabled", enabled);
        }

        return Result.success();
    }

}