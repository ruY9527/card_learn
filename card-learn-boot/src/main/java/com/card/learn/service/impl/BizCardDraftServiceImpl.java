package com.card.learn.service.impl;

import com.alibaba.fastjson2.JSON;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.card.learn.dto.CardAuditDTO;
import com.card.learn.dto.CardCreateDTO;
import com.card.learn.entity.BizCard;
import com.card.learn.entity.BizCardDraft;
import com.card.learn.entity.BizCardTag;
import com.card.learn.entity.BizCardAuditLog;
import com.card.learn.mapper.BizCardDraftMapper;
import com.card.learn.mapper.BizCardMapper;
import com.card.learn.service.IBizCardDraftService;
import com.card.learn.service.IBizCardService;
import com.card.learn.service.IBizCardTagService;
import com.card.learn.service.IBizCardAuditLogService;
import com.card.learn.vo.CardAuditVO;
import com.card.learn.vo.MyCardVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.CollectionUtils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 用户录入卡片临时表Service实现
 */
@Service
public class BizCardDraftServiceImpl extends ServiceImpl<BizCardDraftMapper, BizCardDraft> implements IBizCardDraftService {

    @Autowired
    private BizCardDraftMapper draftMapper;

    @Autowired
    private IBizCardService cardService;

    @Autowired
    private IBizCardTagService cardTagService;

    @Autowired
    private IBizCardAuditLogService auditLogService;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long createDraftCard(CardCreateDTO dto) {
        // 创建临时卡片
        BizCardDraft draft = new BizCardDraft();
        draft.setSubjectId(dto.getSubjectId());
        draft.setFrontContent(dto.getFrontContent());
        draft.setBackContent(dto.getBackContent());
        draft.setDifficultyLevel(dto.getDifficultyLevel() != null ? dto.getDifficultyLevel() : 2);
        draft.setCreateUserId(dto.getCreateUserId());
        draft.setAuditStatus("0"); // 待审批
        
        // 将标签ID列表存为JSON字符串
        if (!CollectionUtils.isEmpty(dto.getTagIds())) {
            draft.setTagIds(JSON.toJSONString(dto.getTagIds()));
        }
        
        draft.setCreateTime(LocalDateTime.now());
        
        save(draft);
        
        return draft.getDraftId();
    }

    @Override
    public Page<CardAuditVO> pagePendingDrafts(String auditStatus, Integer pageNum, Integer pageSize) {
        Page<CardAuditVO> page = new Page<>(pageNum, pageSize);
        Page<CardAuditVO> result = draftMapper.selectPendingDrafts(page, auditStatus);
        
        // 解析标签信息
        if (!CollectionUtils.isEmpty(result.getRecords())) {
            for (CardAuditVO vo : result.getRecords()) {
                // 从draftId对应的记录中获取tagIds
                BizCardDraft draft = getById(vo.getCardId()); // 注意：这里cardId实际是draftId
                if (draft != null && draft.getTagIds() != null) {
                    List<Long> tagIds = JSON.parseArray(draft.getTagIds(), Long.class);
                    if (!CollectionUtils.isEmpty(tagIds)) {
                        List<String> tagNames = cardTagService.lambdaQuery()
                                .in(BizCardTag::getTagId, tagIds)
                                .list()
                                .stream()
                                .map(ct -> {
                                    // 需要获取标签名称，这里简化处理
                                    return "标签" + ct.getTagId();
                                })
                                .collect(Collectors.toList());
                        vo.setTags(tagNames);
                    }
                }
            }
        }
        
        return result;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long auditDraftCard(CardAuditDTO dto) {
        BizCardDraft draft = getById(dto.getCardId());
        if (draft == null) {
            throw new RuntimeException("临时卡片不存在");
        }
        
        // 只有待审批状态的卡片才能审批
        if (!"0".equals(draft.getAuditStatus())) {
            throw new RuntimeException("该卡片已审批，不能重复审批");
        }
        
        Long cardId = null;
        
        if ("1".equals(dto.getAuditStatus())) {
            // 审批通过 - 创建正式卡片
            BizCard card = new BizCard();
            card.setSubjectId(draft.getSubjectId());
            card.setFrontContent(draft.getFrontContent());
            card.setBackContent(draft.getBackContent());
            card.setDifficultyLevel(draft.getDifficultyLevel());
            card.setAuditStatus("1"); // 已通过
            card.setCreateUserId(draft.getCreateUserId());
            card.setCreateTime(LocalDateTime.now());
            
            cardService.save(card);
            cardId = card.getCardId();
            
            // 设置标签关联
            if (draft.getTagIds() != null) {
                List<Long> tagIds = JSON.parseArray(draft.getTagIds(), Long.class);
                if (!CollectionUtils.isEmpty(tagIds)) {
                    cardTagService.setCardTags(cardId, tagIds);
                }
            }
            
            // 更新临时卡片状态
            draft.setAuditStatus("1");
            draft.setAuditUserId(dto.getAuditUserId());
            draft.setAuditTime(LocalDateTime.now());
            draft.setAuditRemark(dto.getAuditRemark());
            draft.setUpdateTime(LocalDateTime.now());
            updateById(draft);
            
            // 记录审批日志
            auditLogService.saveAuditLog(draft.getDraftId(), cardId, "1", dto.getAuditUserId(), dto.getAuditRemark());
            
        } else if ("2".equals(dto.getAuditStatus())) {
            // 审批拒绝 - 更新临时卡片状态（不迁移到正式表）
            draft.setAuditStatus("2");
            draft.setAuditUserId(dto.getAuditUserId());
            draft.setAuditTime(LocalDateTime.now());
            draft.setAuditRemark(dto.getAuditRemark());
            draft.setUpdateTime(LocalDateTime.now());
            updateById(draft);
            
            // 记录审批日志
            auditLogService.saveAuditLog(draft.getDraftId(), null, "2", dto.getAuditUserId(), dto.getAuditRemark());
        }
        
        return cardId;
    }

    @Override
    public Page<MyCardVO> pageMyDrafts(Long createUserId, String auditStatus, Integer pageNum, Integer pageSize) {
        Page<MyCardVO> page = new Page<>(pageNum, pageSize);
        return draftMapper.selectMyDrafts(page, createUserId, auditStatus);
    }

    @Override
    public long getPendingCount() {
        return lambdaQuery()
                .eq(BizCardDraft::getAuditStatus, "0")
                .count();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateMyDraftCard(Long draftId, CardCreateDTO dto, Long createUserId) {
        BizCardDraft draft = getById(draftId);
        if (draft == null) {
            throw new RuntimeException("临时卡片不存在");
        }
        
        // 校验是否是用户自己的卡片
        if (!draft.getCreateUserId().equals(createUserId)) {
            throw new RuntimeException("无权限修改此卡片");
        }
        
        // 只有待审批状态的卡片才能修改
        if (!"0".equals(draft.getAuditStatus())) {
            throw new RuntimeException("只有待审批状态的卡片才能修改");
        }
        
        draft.setSubjectId(dto.getSubjectId());
        draft.setFrontContent(dto.getFrontContent());
        draft.setBackContent(dto.getBackContent());
        draft.setDifficultyLevel(dto.getDifficultyLevel());
        draft.setUpdateTime(LocalDateTime.now());
        
        // 更新标签
        if (!CollectionUtils.isEmpty(dto.getTagIds())) {
            draft.setTagIds(JSON.toJSONString(dto.getTagIds()));
        }
        
        updateById(draft);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteMyDraftCard(Long draftId, Long createUserId) {
        BizCardDraft draft = getById(draftId);
        if (draft == null) {
            throw new RuntimeException("临时卡片不存在");
        }
        
        // 校验是否是用户自己的卡片
        if (!draft.getCreateUserId().equals(createUserId)) {
            throw new RuntimeException("无权限删除此卡片");
        }
        
        // 只有待审批状态的卡片才能删除
        if (!"0".equals(draft.getAuditStatus())) {
            throw new RuntimeException("只有待审批状态的卡片才能删除");
        }
        
        removeById(draftId);
    }

}
