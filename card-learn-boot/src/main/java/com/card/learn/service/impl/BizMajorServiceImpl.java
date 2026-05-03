package com.card.learn.service.impl;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.card.learn.dto.MajorQueryDTO;
import com.card.learn.entity.BizMajor;
import com.card.learn.mapper.BizMajorMapper;
import com.card.learn.service.IBizMajorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * 专业Service实现
 */
@Service
public class BizMajorServiceImpl extends ServiceImpl<BizMajorMapper, BizMajor> implements IBizMajorService {

    @Autowired
    private BizMajorMapper majorMapper;

    @Override
    public Page<BizMajor> pageMajors(MajorQueryDTO queryDTO) {
        Page<BizMajor> page = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize());
        return majorMapper.selectPageByCondition(page, queryDTO.getMajorName(), queryDTO.getStatus());
    }

}