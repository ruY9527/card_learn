package com.card.learn.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.card.learn.dto.TagQueryDTO;
import com.card.learn.entity.BizTag;
import com.card.learn.vo.TagVO;

/**
 * 标签Service
 */
public interface IBizTagService extends IService<BizTag> {

    /**
     * 分页查询标签（包含科目名称）
     */
    Page<TagVO> pageTags(TagQueryDTO queryDTO);

}