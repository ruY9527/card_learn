package com.card.learn.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.dto.RequestLogQueryDTO;
import com.card.learn.entity.SysRequestLog;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;

/**
 * 系统请求日志Mapper
 */
@Mapper
public interface SysRequestLogMapper extends BaseMapper<SysRequestLog> {

    Page<SysRequestLog> selectPageByCondition(Page<SysRequestLog> page, @Param("dto") RequestLogQueryDTO dto);

    int deleteByCreateTimeBefore(@Param("threshold") LocalDateTime threshold);

}