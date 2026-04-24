package com.card.learn.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.card.learn.entity.BizCardAuditLog;
import org.apache.ibatis.annotations.Mapper;

/**
 * 卡片审批历史日志Mapper
 */
@Mapper
public interface BizCardAuditLogMapper extends BaseMapper<BizCardAuditLog> {

}