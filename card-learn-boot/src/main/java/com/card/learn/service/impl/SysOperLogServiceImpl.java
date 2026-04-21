package com.card.learn.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.card.learn.entity.SysOperLog;
import com.card.learn.mapper.SysOperLogMapper;
import com.card.learn.service.ISysOperLogService;
import org.springframework.stereotype.Service;

/**
 * 操作日志Service实现
 */
@Service
public class SysOperLogServiceImpl extends ServiceImpl<SysOperLogMapper, SysOperLog> implements ISysOperLogService {

    @Override
    public Page<SysOperLog> pageLogs(String title, Integer pageNum, Integer pageSize) {
        LambdaQueryWrapper<SysOperLog> wrapper = new LambdaQueryWrapper<>();
        if (title != null && !title.isEmpty()) {
            wrapper.like(SysOperLog::getTitle, title);
        }
        wrapper.orderByDesc(SysOperLog::getOperTime);
        return page(new Page<>(pageNum, pageSize), wrapper);
    }

}