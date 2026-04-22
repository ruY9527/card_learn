package com.card.learn.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.card.learn.entity.SysConfig;
import com.card.learn.dto.SprintConfigDTO;

import java.util.List;

/**
 * 系统配置Service
 */
public interface ISysConfigService extends IService<SysConfig> {

    /**
     * 根据配置键获取配置值
     * @param configKey 配置键
     * @return 配置值
     */
    String getConfigValue(String configKey);

    /**
     * 根据配置键获取配置对象
     * @param configKey 配置键
     * @return 配置对象
     */
    SysConfig getConfigByKey(String configKey);

    /**
     * 更新配置值
     * @param configKey 配置键
     * @param configValue 配置值
     * @return 是否成功
     */
    boolean updateConfigValue(String configKey, String configValue);

    /**
     * 获取所有配置列表
     * @return 配置列表
     */
    List<SysConfig> getAllConfigs();

    /**
     * 获取冲刺配置（小程序和管理端使用）
     * @return 冲刺配置DTO
     */
    SprintConfigDTO getSprintConfig();

}