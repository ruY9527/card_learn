package com.card.learn.service.impl;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.card.learn.dto.RequestLogQueryDTO;
import com.card.learn.entity.SysRequestLog;
import com.card.learn.mapper.SysRequestLogMapper;
import com.card.learn.service.ISysRequestLogService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

/**
 * 系统请求日志Service实现
 */
@Slf4j
@Service
public class SysRequestLogServiceImpl extends ServiceImpl<SysRequestLogMapper, SysRequestLog> implements ISysRequestLogService {

    @Autowired
    private SysRequestLogMapper requestLogMapper;

    @Async("logAsyncExecutor")
    @Override
    public void saveLogAsync(SysRequestLog requestLog) {
        log.info("【异步日志】开始保存日志: {} {}", requestLog.getRequestMethod(), requestLog.getRequestUrl());
        try {
            requestLog.setCreateTime(LocalDateTime.now());
            boolean saved = this.save(requestLog);
            if (saved) {
                log.info("【异步日志】日志保存成功, ID={}", requestLog.getId());
            } else {
                log.warn("【异步日志】日志保存失败（save返回false）");
            }
        } catch (Exception e) {
            log.error("【异步日志】保存请求日志失败: {}", e.getMessage(), e);
        }
    }

    @Override
    public Page<SysRequestLog> pageLogs(RequestLogQueryDTO queryDTO) {
        Page<SysRequestLog> page = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize());
        return requestLogMapper.selectPageByCondition(page, queryDTO);
    }

    /**
     * 清理指定天数之前的日志
     */
    @Override
    public int cleanLogs(int days) {
        LocalDateTime threshold = LocalDateTime.now().minusDays(days);
        return requestLogMapper.deleteByCreateTimeBefore(threshold);
    }

}