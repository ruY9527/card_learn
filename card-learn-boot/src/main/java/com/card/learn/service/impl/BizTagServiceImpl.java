package com.card.learn.service.impl;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.card.learn.common.AppMessages;
import com.card.learn.dto.TagQueryDTO;
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

    @Autowired
    private BizTagMapper tagMapper;

    @Override
    public Page<TagVO> pageTags(TagQueryDTO queryDTO) {
        Page<BizTag> page = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize());
        tagMapper.selectPageByCondition(page, queryDTO.getTagName(), queryDTO.getSubjectId());

        Map<Long, String> subjectNameMap = subjectMapper.selectList(null)
                .stream()
                .collect(Collectors.toMap(BizSubject::getSubjectId, BizSubject::getSubjectName));

        Page<TagVO> voPage = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize(), page.getTotal());
        voPage.setRecords(page.getRecords().stream().map(tag -> {
            TagVO vo = new TagVO();
            vo.setTagId(tag.getTagId());
            vo.setTagName(tag.getTagName());
            vo.setSubjectId(tag.getSubjectId());
            vo.setSubjectName(tag.getSubjectId() != null ?
                    subjectNameMap.getOrDefault(tag.getSubjectId(), "") : AppMessages.GENERIC_TAG);
            return vo;
        }).collect(Collectors.toList()));

        return voPage;
    }

}