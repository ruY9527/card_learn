package com.card.learn.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.entity.BizMajor;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * 专业Mapper
 */
@Mapper
public interface BizMajorMapper extends BaseMapper<BizMajor> {

    Page<BizMajor> selectPageByCondition(Page<BizMajor> page, @Param("majorName") String majorName, @Param("status") String status);

}