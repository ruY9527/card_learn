package com.card.learn.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.card.learn.entity.BizUserProgress;
import com.card.learn.mapper.BizUserProgressMapper;
import com.card.learn.service.IBizUserProgressService;
import org.springframework.stereotype.Service;

/**
 * 用户学习进度Service实现
 */
@Service
public class BizUserProgressServiceImpl extends ServiceImpl<BizUserProgressMapper, BizUserProgress> implements IBizUserProgressService {

}