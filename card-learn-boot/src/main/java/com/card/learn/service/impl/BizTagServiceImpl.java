package com.card.learn.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.card.learn.entity.BizTag;
import com.card.learn.mapper.BizTagMapper;
import com.card.learn.service.IBizTagService;
import org.springframework.stereotype.Service;

/**
 * 标签Service实现
 */
@Service
public class BizTagServiceImpl extends ServiceImpl<BizTagMapper, BizTag> implements IBizTagService {

}