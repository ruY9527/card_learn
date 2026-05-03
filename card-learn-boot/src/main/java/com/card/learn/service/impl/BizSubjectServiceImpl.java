package com.card.learn.service.impl;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.card.learn.dto.SubjectQueryDTO;
import com.card.learn.entity.BizSubject;
import com.card.learn.mapper.BizSubjectMapper;
import com.card.learn.service.IBizSubjectService;
import com.card.learn.vo.SubjectVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 科目Service实现
 */
@Service
public class BizSubjectServiceImpl extends ServiceImpl<BizSubjectMapper, BizSubject> implements IBizSubjectService {

    @Autowired
    private BizSubjectMapper subjectMapper;

    @Override
    public List<SubjectVO> listSubjectsWithMajorName(Long majorId) {
        return subjectMapper.selectSubjectsWithMajorName(majorId);
    }

    @Override
    public Page<SubjectVO> pageSubjects(SubjectQueryDTO queryDTO) {
        Page<SubjectVO> page = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize());
        return subjectMapper.selectSubjectsPage(page, queryDTO.getMajorId(), queryDTO.getSubjectName());
    }

}