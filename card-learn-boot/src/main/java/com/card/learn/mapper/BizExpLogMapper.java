package com.card.learn.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.entity.BizExpLog;
import com.card.learn.vo.ExpLogVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * 经验值变动日志Mapper接口
 */
@Mapper
public interface BizExpLogMapper extends BaseMapper<BizExpLog> {

    /**
     * 分页查询用户经验值日志
     */
    Page<ExpLogVO> selectExpLogPage(Page<ExpLogVO> page,
                                    @Param("userId") Long userId,
                                    @Param("sourceType") String sourceType);
}
