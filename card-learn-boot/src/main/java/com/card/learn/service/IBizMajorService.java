package com.card.learn.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.card.learn.entity.BizMajor;

/**
 * 专业Service
 */
public interface IBizMajorService extends IService<BizMajor> {

    /**
     * 分页查询专业列表
     * @param majorName 专业名称（模糊查询）
     * @param status 状态
     * @param pageNum 页码
     * @param pageSize 每页数量
     */
    Page<BizMajor> pageMajors(String majorName, String status, Integer pageNum, Integer pageSize);

}