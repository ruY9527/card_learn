package com.card.learn.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.card.learn.entity.BizMajor;
import com.card.learn.mapper.BizMajorMapper;
import com.card.learn.service.IBizMajorService;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

/**
 * 专业Service实现
 */
@Service
public class BizMajorServiceImpl extends ServiceImpl<BizMajorMapper, BizMajor> implements IBizMajorService {

    @Override
    public Page<BizMajor> pageMajors(String majorName, String status, Integer pageNum, Integer pageSize) {
        Page<BizMajor> page = new Page<>(pageNum, pageSize);
        
        LambdaQueryWrapper<BizMajor> wrapper = new LambdaQueryWrapper<>();
        
        // 专业名称模糊查询
        if (StringUtils.hasText(majorName)) {
            wrapper.like(BizMajor::getMajorName, majorName);
        }
        
        // 状态筛选
        if (StringUtils.hasText(status)) {
            wrapper.eq(BizMajor::getStatus, status);
        }
        
        // 按创建时间倒序
        wrapper.orderByDesc(BizMajor::getCreateTime);
        
        return page(page, wrapper);
    }

}