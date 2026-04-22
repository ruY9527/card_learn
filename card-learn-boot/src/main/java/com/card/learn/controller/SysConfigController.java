package com.card.learn.controller;

import com.card.learn.common.Result;
import com.card.learn.dto.SprintConfigDTO;
import com.card.learn.entity.SysConfig;
import com.card.learn.service.ISysConfigService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

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
            return Result.error("配置不存在");
        }
        return Result.success(config);
    }

    /**
     * 更新配置值
     */
    @PutMapping("/{key}")
    @ApiOperation("更新配置值")
    public Result<Void> updateConfig(@PathVariable String key, @RequestBody Map<String, String> body) {
        String value = body.get("value");
        if (value == null) {
            return Result.error("配置值不能为空");
        }
        boolean success = configService.updateConfigValue(key, value);
        if (success) {
            return Result.success();
        } else {
            return Result.error("配置不存在或更新失败");
        }
    }

    /**
     * 更新整个配置对象
     */
    @PutMapping
    @ApiOperation("更新配置对象")
    public Result<Void> updateConfigEntity(@RequestBody SysConfig config) {
        if (config.getConfigKey() == null) {
            return Result.error("配置键不能为空");
        }
        boolean success = configService.updateById(config);
        if (success) {
            return Result.success();
        } else {
            return Result.error("更新失败");
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
            return Result.error("配置键和配置值不能为空");
        }
        // 检查是否已存在
        SysConfig existing = configService.getConfigByKey(config.getConfigKey());
        if (existing != null) {
            return Result.error("配置键已存在");
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
            return Result.error("配置不存在");
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
    public Result<Void> updateSprintConfig(@RequestBody Map<String, String> body) {
        String examDate = body.get("examDate");
        String examName = body.get("examName");
        String enabled = body.get("enabled");

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