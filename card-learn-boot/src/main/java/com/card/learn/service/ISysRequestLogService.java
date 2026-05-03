package com.card.learn.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.card.learn.dto.RequestLogQueryDTO;
import com.card.learn.entity.SysRequestLog;

/**
 * 系统请求日志Service
 */
public interface ISysRequestLogService extends IService<SysRequestLog> {

    /**
     * 异步保存请求日志（不影响主业务流程）
     */
    void saveLogAsync(SysRequestLog log);

    /**
     * 分页查询日志
     */
    Page<SysRequestLog> pageLogs(RequestLogQueryDTO queryDTO);

    /**
     * 清理指定天数之前的日志
     */
    int cleanLogs(int days);

}