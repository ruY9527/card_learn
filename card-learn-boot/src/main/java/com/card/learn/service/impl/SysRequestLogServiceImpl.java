package com.card.learn.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.card.learn.entity.SysRequestLog;
import com.card.learn.mapper.SysRequestLogMapper;
import com.card.learn.service.ISysRequestLogService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * 系统请求日志Service实现
 */
@Slf4j
@Service
public class SysRequestLogServiceImpl extends ServiceImpl<SysRequestLogMapper, SysRequestLog> implements ISysRequestLogService {

    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    /**
     * 异步保存请求日志（不影响主业务流程）
     * 使用指定的线程池执行，避免无限制创建线程
     */
    @Async("logAsyncExecutor")
    @Override
    public void saveLogAsync(SysRequestLog requestLog) {
        log.info("【异步日志】开始保存日志: {} {}", requestLog.getRequestMethod(), requestLog.getRequestUrl());
        try {
            // 设置创建时间
            requestLog.setCreateTime(LocalDateTime.now());
            // 保存到数据库
            boolean saved = this.save(requestLog);
            if (saved) {
                log.info("【异步日志】日志保存成功, ID={}", requestLog.getId());
            } else {
                log.warn("【异步日志】日志保存失败（save返回false）");
            }
        } catch (Exception e) {
            // 日志保存失败不影响主业务，打印完整错误堆栈
            log.error("【异步日志】保存请求日志失败: {}", e.getMessage(), e);
        }
    }

    /**
     * 分页查询日志
     */
    @Override
    public Page<SysRequestLog> pageLogs(Integer pageNum, Integer pageSize, String requestMethod,
                                          String requestUrl, String status, String startTime, String endTime) {
        Page<SysRequestLog> page = new Page<>(pageNum, pageSize);
        
        LambdaQueryWrapper<SysRequestLog> wrapper = new LambdaQueryWrapper<>();
        
        // 请求方法筛选
        if (requestMethod != null && !requestMethod.isEmpty()) {
            wrapper.eq(SysRequestLog::getRequestMethod, requestMethod);
        }
        
        // 请求URL筛选（模糊匹配）
        if (requestUrl != null && !requestUrl.isEmpty()) {
            wrapper.like(SysRequestLog::getRequestUrl, requestUrl);
        }
        
        // 执行状态筛选
        if (status != null && !status.isEmpty()) {
            wrapper.eq(SysRequestLog::getStatus, status);
        }
        
        // 时间范围筛选
        if (startTime != null && !startTime.isEmpty()) {
            LocalDateTime start = LocalDateTime.parse(startTime, DATE_FORMATTER);
            wrapper.ge(SysRequestLog::getCreateTime, start);
        }
        
        if (endTime != null && !endTime.isEmpty()) {
            LocalDateTime end = LocalDateTime.parse(endTime, DATE_FORMATTER);
            wrapper.le(SysRequestLog::getCreateTime, end);
        }
        
        // 按创建时间倒序排列
        wrapper.orderByDesc(SysRequestLog::getCreateTime);
        
        return this.page(page, wrapper);
    }

    /**
     * 清理指定天数之前的日志
     */
    @Override
    public int cleanLogs(int days) {
        LocalDateTime threshold = LocalDateTime.now().minusDays(days);
        
        LambdaQueryWrapper<SysRequestLog> wrapper = new LambdaQueryWrapper<>();
        wrapper.lt(SysRequestLog::getCreateTime, threshold);
        
        return this.baseMapper.delete(wrapper);
    }

}