package com.card.learn.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.card.learn.entity.SysOperLog;

/**
 * 操作日志Service
 */
public interface ISysOperLogService extends IService<SysOperLog> {

    /**
     * 分页查询操作日志
     */
    Page<SysOperLog> pageLogs(String title, Integer pageNum, Integer pageSize);

}