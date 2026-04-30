package com.card.learn.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.card.learn.dto.CardAuditDTO;
import com.card.learn.dto.CardCreateDTO;
import com.card.learn.entity.BizCard;
import com.card.learn.entity.BizCardTag;
import com.card.learn.entity.BizTag;
import com.card.learn.mapper.BizCardMapper;
import com.card.learn.service.IBizCardService;
import com.card.learn.service.IBizCardTagService;
import com.card.learn.service.IBizTagService;
import com.card.learn.vo.CardAuditVO;
import com.card.learn.vo.CardVO;
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
 * 知识点卡片Service实现
 */
@Service
public class BizCardServiceImpl extends ServiceImpl<BizCardMapper, BizCard> implements IBizCardService {

    @Autowired
    private BizCardMapper cardMapper;

    @Autowired
    private IBizCardTagService cardTagService;

    @Autowired
    private IBizTagService tagService;

    @Override
    public Page<BizCard> pageCards(Long subjectId, String frontContent, Integer pageNum, Integer pageSize) {
        LambdaQueryWrapper<BizCard> wrapper = new LambdaQueryWrapper<>();
        if (subjectId != null) {
            wrapper.eq(BizCard::getSubjectId, subjectId);
        }
        if (frontContent != null && !frontContent.trim().isEmpty()) {
            wrapper.like(BizCard::getFrontContent, frontContent.trim());
        }
        // 只查询已通过的卡片（供学习使用），兼容 audit_status 为 NULL 的系统内置卡片
        wrapper.and(w -> w.eq(BizCard::getAuditStatus, "1").or().isNull(BizCard::getAuditStatus));
        // 按card_id升序排列，让旧卡片（有标签的）排在前面
        wrapper.orderByAsc(BizCard::getCardId);
        return page(new Page<>(pageNum, pageSize), wrapper);
    }

    @Override
    public Page<CardVO> pageCardsWithSubjectName(Long subjectId, String frontContent, Integer pageNum, Integer pageSize) {
        Page<CardVO> page = new Page<>(pageNum, pageSize);
        return cardMapper.selectCardsWithSubjectName(page, subjectId, frontContent);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long createCardByUser(CardCreateDTO dto) {
        // 创建卡片，设置为待审批状态
        BizCard card = new BizCard();
        card.setSubjectId(dto.getSubjectId());
        card.setFrontContent(dto.getFrontContent());
        card.setBackContent(dto.getBackContent());
        card.setDifficultyLevel(dto.getDifficultyLevel() != null ? dto.getDifficultyLevel() : 2);
        card.setAuditStatus("0"); // 待审批
        card.setCreateUserId(dto.getCreateUserId());
        card.setCreateTime(LocalDateTime.now());
        
        save(card);
        
        // 设置标签
        if (!CollectionUtils.isEmpty(dto.getTagIds())) {
            cardTagService.setCardTags(card.getCardId(), dto.getTagIds());
        }
        
        return card.getCardId();
    }

    @Override
    public Page<CardAuditVO> pagePendingCards(String auditStatus, Integer pageNum, Integer pageSize) {
        Page<CardAuditVO> page = new Page<>(pageNum, pageSize);
        Page<CardAuditVO> result = cardMapper.selectPendingCards(page, auditStatus);
        
        // 获取标签信息
        if (!CollectionUtils.isEmpty(result.getRecords())) {
            List<Long> cardIds = result.getRecords().stream()
                    .map(CardAuditVO::getCardId)
                    .collect(Collectors.toList());
            
            // 获取卡片标签关联
            List<BizCardTag> cardTags = cardTagService.lambdaQuery()
                    .in(BizCardTag::getCardId, cardIds)
                    .list();
            
            if (!CollectionUtils.isEmpty(cardTags)) {
                List<Long> tagIds = cardTags.stream()
                        .map(BizCardTag::getTagId)
                        .distinct()
                        .collect(Collectors.toList());
                
                List<BizTag> tags = tagService.listByIds(tagIds);
                Map<Long, String> tagNameMap = tags.stream()
                        .collect(Collectors.toMap(BizTag::getTagId, BizTag::getTagName));
                
                Map<Long, List<String>> cardTagsMap = cardTags.stream()
                        .collect(Collectors.groupingBy(
                                BizCardTag::getCardId,
                                Collectors.mapping(ct -> tagNameMap.get(ct.getTagId()), Collectors.toList())
                        ));
                
                result.getRecords().forEach(vo -> {
                    vo.setTags(cardTagsMap.get(vo.getCardId()));
                });
            }
        }
        
        return result;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void auditCard(CardAuditDTO dto) {
        BizCard card = getById(dto.getCardId());
        if (card == null) {
            throw new RuntimeException("卡片不存在");
        }
        
        // 只有待审批状态的卡片才能审批
        if (!"0".equals(card.getAuditStatus())) {
            throw new RuntimeException("该卡片已审批，不能重复审批");
        }
        
        card.setAuditStatus(dto.getAuditStatus());
        card.setAuditUserId(dto.getAuditUserId());
        card.setAuditTime(LocalDateTime.now());
        card.setAuditRemark(dto.getAuditRemark());
        card.setUpdateTime(LocalDateTime.now());
        
        updateById(card);
    }

    @Override
    public Page<MyCardVO> pageMyCards(Long createUserId, Integer pageNum, Integer pageSize) {
        Page<MyCardVO> page = new Page<>(pageNum, pageSize);
        Page<MyCardVO> result = cardMapper.selectMyCards(page, createUserId);
        
        // 获取标签信息
        if (!CollectionUtils.isEmpty(result.getRecords())) {
            List<Long> cardIds = result.getRecords().stream()
                    .map(MyCardVO::getCardId)
                    .collect(Collectors.toList());
            
            // 获取卡片标签关联
            List<BizCardTag> cardTags = cardTagService.lambdaQuery()
                    .in(BizCardTag::getCardId, cardIds)
                    .list();
            
            if (!CollectionUtils.isEmpty(cardTags)) {
                List<Long> tagIds = cardTags.stream()
                        .map(BizCardTag::getTagId)
                        .distinct()
                        .collect(Collectors.toList());
                
                List<BizTag> tags = tagService.listByIds(tagIds);
                Map<Long, String> tagNameMap = tags.stream()
                        .collect(Collectors.toMap(BizTag::getTagId, BizTag::getTagName));
                
                Map<Long, List<String>> cardTagsMap = cardTags.stream()
                        .collect(Collectors.groupingBy(
                                BizCardTag::getCardId,
                                Collectors.mapping(ct -> tagNameMap.get(ct.getTagId()), Collectors.toList())
                        ));
                
                result.getRecords().forEach(vo -> {
                    vo.setTags(cardTagsMap.get(vo.getCardId()));
                });
            }
        }
        
        return result;
    }

    @Override
    public long getPendingCount() {
        return lambdaQuery()
                .eq(BizCard::getAuditStatus, "0")
                .eq(BizCard::getDelFlag, "0")
                .count();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateMyCard(Long cardId, CardCreateDTO dto, Long createUserId) {
        BizCard card = getById(cardId);
        if (card == null) {
            throw new RuntimeException("卡片不存在");
        }
        
        // 校验是否是用户自己的卡片
        if (!card.getCreateUserId().equals(createUserId)) {
            throw new RuntimeException("无权限修改此卡片");
        }
        
        // 只有待审批状态的卡片才能修改
        if (!"0".equals(card.getAuditStatus())) {
            throw new RuntimeException("只有待审批状态的卡片才能修改");
        }
        
        card.setSubjectId(dto.getSubjectId());
        card.setFrontContent(dto.getFrontContent());
        card.setBackContent(dto.getBackContent());
        card.setDifficultyLevel(dto.getDifficultyLevel());
        card.setUpdateTime(LocalDateTime.now());
        
        updateById(card);
        
        // 更新标签
        if (!CollectionUtils.isEmpty(dto.getTagIds())) {
            cardTagService.setCardTags(cardId, dto.getTagIds());
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteMyCard(Long cardId, Long createUserId) {
        BizCard card = getById(cardId);
        if (card == null) {
            throw new RuntimeException("卡片不存在");
        }
        
        // 校验是否是用户自己的卡片
        if (!card.getCreateUserId().equals(createUserId)) {
            throw new RuntimeException("无权限删除此卡片");
        }
        
        // 只有待审批状态的卡片才能删除
        if (!"0".equals(card.getAuditStatus())) {
            throw new RuntimeException("只有待审批状态的卡片才能删除");
        }
        
        removeById(cardId);
        
        // 删除标签关联
        cardTagService.lambdaUpdate()
                .eq(BizCardTag::getCardId, cardId)
                .remove();
    }

}