package com.card.learn.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.card.learn.dto.MajorQueryDTO;
import com.card.learn.entity.BizMajor;

/**
 * 专业Service
 */
public interface IBizMajorService extends IService<BizMajor> {

    /**
     * 分页查询专业列表
     */
    Page<BizMajor> pageMajors(MajorQueryDTO queryDTO);

}