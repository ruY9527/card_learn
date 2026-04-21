package com.card.learn.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.card.learn.entity.BizSubject;
import com.card.learn.vo.SubjectVO;

import java.util.List;

/**
 * 科目Service
 */
public interface IBizSubjectService extends IService<BizSubject> {

    /**
     * 查询科目列表（包含专业名称）
     */
    List<SubjectVO> listSubjectsWithMajorName(Long majorId);

}