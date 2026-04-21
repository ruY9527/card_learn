package com.card.learn.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.card.learn.entity.BizSubject;
import com.card.learn.vo.SubjectVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 科目Mapper
 */
@Mapper
public interface BizSubjectMapper extends BaseMapper<BizSubject> {

    /**
     * 查询科目列表（关联专业名称）
     */
    List<SubjectVO> selectSubjectsWithMajorName(@Param("majorId") Long majorId);

}