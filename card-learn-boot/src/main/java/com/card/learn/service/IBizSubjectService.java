package com.card.learn.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
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

    /**
     * 分页查询科目列表（包含专业名称）
     * @param majorId 专业ID
     * @param subjectName 科目名称（模糊查询）
     * @param pageNum 页码
     * @param pageSize 每页数量
     */
    Page<SubjectVO> pageSubjects(Long majorId, String subjectName, Integer pageNum, Integer pageSize);

}