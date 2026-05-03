package com.card.learn.service.impl;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.card.learn.dto.OperLogQueryDTO;
import com.card.learn.entity.SysOperLog;
import com.card.learn.mapper.SysOperLogMapper;
import com.card.learn.service.ISysOperLogService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * 操作日志Service实现
 */
@Service
public class SysOperLogServiceImpl extends ServiceImpl<SysOperLogMapper, SysOperLog> implements ISysOperLogService {

    @Autowired
    private SysOperLogMapper operLogMapper;

    @Override
    public Page<SysOperLog> pageLogs(OperLogQueryDTO queryDTO) {
        Page<SysOperLog> page = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize());
        return operLogMapper.selectPageByCondition(page, queryDTO.getTitle());
    }

    @Override
    public void clearLogs() {
        operLogMapper.deleteAll();
    }

}