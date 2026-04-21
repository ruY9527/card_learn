package com.card.learn.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.card.learn.entity.BizCardTag;
import com.card.learn.mapper.BizCardTagMapper;
import com.card.learn.service.IBizCardTagService;
import org.springframework.stereotype.Service;

/**
 * 卡片标签关联Service实现
 */
@Service
public class BizCardTagServiceImpl extends ServiceImpl<BizCardTagMapper, BizCardTag> implements IBizCardTagService {

}