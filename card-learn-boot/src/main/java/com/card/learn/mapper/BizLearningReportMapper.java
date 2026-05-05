package com.card.learn.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.card.learn.entity.BizLearningReport;
import com.card.learn.vo.ReportListVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 学习报告Mapper
 */
@Mapper
public interface BizLearningReportMapper extends BaseMapper<BizLearningReport> {

    /**
     * 查询用户报告列表
     */
    List<ReportListVO> selectReportList(@Param("userId") Long userId,
                                         @Param("reportType") String reportType,
                                         @Param("offset") Integer offset,
                                         @Param("size") Integer size);

    /**
     * 查询用户报告总数
     */
    int selectReportCount(@Param("userId") Long userId,
                          @Param("reportType") String reportType);
}
