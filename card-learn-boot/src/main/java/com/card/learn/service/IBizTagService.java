package com.card.learn.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.card.learn.entity.BizTag;
import com.card.learn.vo.TagVO;

/**
 * 标签Service
 */
public interface IBizTagService extends IService<BizTag> {

    /**
     * 分页查询标签（包含科目名称）
     * @param tagName 标签名称（模糊查询）
     * @param subjectId 科目ID
     * @param pageNum 页码
     * @param pageSize 每页数量
     * @return 分页结果
     */
    Page<TagVO> pageTags(String tagName, Long subjectId, Integer pageNum, Integer pageSize);

}