package com.card.learn.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.entity.BizTag;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * 标签Mapper
 */
@Mapper
public interface BizTagMapper extends BaseMapper<BizTag> {

    Page<BizTag> selectPageByCondition(Page<BizTag> page, @Param("tagName") String tagName, @Param("subjectId") Long subjectId);

}