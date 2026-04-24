package com.card.learn.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.card.learn.entity.BizSubject;
import com.card.learn.entity.BizTag;
import com.card.learn.mapper.BizSubjectMapper;
import com.card.learn.mapper.BizTagMapper;
import com.card.learn.service.IBizTagService;
import com.card.learn.vo.TagVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.stream.Collectors;

/**
 * 标签Service实现
 */
@Service
public class BizTagServiceImpl extends ServiceImpl<BizTagMapper, BizTag> implements IBizTagService {

    @Autowired
    private BizSubjectMapper subjectMapper;

    @Override
    public Page<TagVO> pageTags(String tagName, Long subjectId, Integer pageNum, Integer pageSize) {
        // 构建查询条件
        LambdaQueryWrapper<BizTag> wrapper = new LambdaQueryWrapper<>();

        // 标签名称模糊查询
        if (tagName != null && !tagName.trim().isEmpty()) {
            wrapper.like(BizTag::getTagName, tagName.trim());
        }

        // 科目筛选
        if (subjectId != null) {
            wrapper.eq(BizTag::getSubjectId, subjectId);
        }

        // 按ID排序
        wrapper.orderByAsc(BizTag::getTagId);

        // 分页查询
        Page<BizTag> page = new Page<>(pageNum, pageSize);
        this.page(page, wrapper);

        // 查询所有科目，构建ID到名称的映射
        Map<Long, String> subjectNameMap = subjectMapper.selectList(null)
                .stream()
                .collect(Collectors.toMap(BizSubject::getSubjectId, BizSubject::getSubjectName));

        // 转换为TagVO
        Page<TagVO> voPage = new Page<>(pageNum, pageSize, page.getTotal());
        voPage.setRecords(page.getRecords().stream().map(tag -> {
            TagVO vo = new TagVO();
            vo.setTagId(tag.getTagId());
            vo.setTagName(tag.getTagName());
            vo.setSubjectId(tag.getSubjectId());
            vo.setSubjectName(tag.getSubjectId() != null ?
                    subjectNameMap.getOrDefault(tag.getSubjectId(), "") : "通用标签");
            return vo;
        }).collect(Collectors.toList()));

        return voPage;
    }

}