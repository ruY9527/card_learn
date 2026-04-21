package com.card.learn.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.card.learn.entity.BizSubject;
import com.card.learn.mapper.BizSubjectMapper;
import com.card.learn.service.IBizSubjectService;
import org.springframework.stereotype.Service;

/**
 * 科目Service实现
 */
@Service
public class BizSubjectServiceImpl extends ServiceImpl<BizSubjectMapper, BizSubject> implements IBizSubjectService {

}