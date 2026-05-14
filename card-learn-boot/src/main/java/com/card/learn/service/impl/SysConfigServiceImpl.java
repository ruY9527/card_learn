package com.card.learn.service.impl;

import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.card.learn.common.AppMessages;
import com.card.learn.dto.SprintConfigDTO;
import com.card.learn.entity.SysConfig;
import com.card.learn.mapper.SysConfigMapper;
import com.card.learn.service.ISysConfigService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.List;

/**
 * 系统配置Service实现
 */
@Slf4j
@Service
public class SysConfigServiceImpl extends ServiceImpl<SysConfigMapper, SysConfig> implements ISysConfigService {

    @Autowired
    private SysConfigMapper configMapper;

    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    @Override
    public String getConfigValue(String configKey) {
        SysConfig config = getConfigByKey(configKey);
        return config != null ? config.getConfigValue() : null;
    }

    @Override
    public SysConfig getConfigByKey(String configKey) {
        return configMapper.selectByKey(configKey);
    }

    @Override
    public boolean updateConfigValue(String configKey, String configValue) {
        LambdaUpdateWrapper<SysConfig> wrapper = new LambdaUpdateWrapper<>();
        wrapper.eq(SysConfig::getConfigKey, configKey)
                .set(SysConfig::getConfigValue, configValue);
        return this.update(wrapper);
    }

    @Override
    public List<SysConfig> getAllConfigs() {
        return configMapper.selectAll();
    }

    @Override
    public SprintConfigDTO getSprintConfig() {
        SprintConfigDTO dto = new SprintConfigDTO();

        // 获取考试日期
        String examDateStr = getConfigValue("sprint_exam_date");
        String examName = getConfigValue("sprint_exam_name");
        String enabled = getConfigValue("sprint_enabled");

        dto.setExamName(examName != null ? examName : AppMessages.DEFAULT_EXAM_NAME);
        dto.setEnabled("true".equals(enabled));

        if (examDateStr != null) {
            try {
                LocalDate examDate = LocalDate.parse(examDateStr, DATE_FORMATTER);
                LocalDate today = LocalDate.now();

                // 计算剩余天数
                long daysRemaining = ChronoUnit.DAYS.between(today, examDate);
                dto.setExamDate(examDateStr);
                dto.setDaysRemaining(Math.max(daysRemaining, 0L));
                dto.setIsExpired(daysRemaining < 0);
            } catch (Exception e) {
                log.error("解析考试日期失败: {}", examDateStr);
                dto.setExamDate(examDateStr);
                dto.setDaysRemaining(0L);
                dto.setIsExpired(true);
            }
        } else {
            dto.setExamDate(null);
            dto.setDaysRemaining(0L);
            dto.setIsExpired(true);
        }

        return dto;
    }

}