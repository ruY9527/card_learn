package com.card.learn.service.impl;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.card.learn.common.AppMessages;
import com.card.learn.dto.CardAuditDTO;
import com.card.learn.dto.CardCreateDTO;
import com.card.learn.dto.CardQueryDTO;
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
    public Page<BizCard> pageCards(CardQueryDTO queryDTO) {
        Page<BizCard> page = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize());
        return cardMapper.selectPageCardList(page, queryDTO.getSubjectId(), queryDTO.getFrontContent());
    }

    @Override
    public Page<CardVO> pageCardsWithSubjectName(CardQueryDTO queryDTO) {
        Page<CardVO> page = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize());
        return cardMapper.selectCardsWithSubjectName(page, queryDTO.getSubjectId(), queryDTO.getFrontContent());
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
        card.setCreateBy(dto.getCreateBy());
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
            throw new RuntimeException(AppMessages.CARD_NOT_FOUND);
        }
        
        // 只有待审批状态的卡片才能审批
        if (!"0".equals(card.getAuditStatus())) {
            throw new RuntimeException(AppMessages.CARD_ALREADY_AUDITED);
        }
        
        card.setAuditStatus(dto.getAuditStatus());
        card.setAuditUserId(dto.getAuditUserId());
        card.setAuditTime(LocalDateTime.now());
        card.setAuditRemark(dto.getAuditRemark());
        card.setUpdateTime(LocalDateTime.now());
        
        updateById(card);
    }

    @Override
    public Page<MyCardVO> pageMyCards(Long createBy, Integer pageNum, Integer pageSize) {
        Page<MyCardVO> page = new Page<>(pageNum, pageSize);
        Page<MyCardVO> result = cardMapper.selectMyCards(page, createBy);

        // 获取标签信息
        if (!CollectionUtils.isEmpty(result.getRecords())) {
            List<Long> cardIds = result.getRecords().stream()
                    .map(MyCardVO::getDraftId)
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
                    vo.setTags(cardTagsMap.get(vo.getDraftId()));
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
    public void updateMyCard(Long cardId, CardCreateDTO dto, Long createBy) {
        BizCard card = getById(cardId);
        if (card == null) {
            throw new RuntimeException(AppMessages.CARD_NOT_FOUND);
        }
        
        // 校验是否是用户自己的卡片
        if (!card.getCreateBy().equals(createBy)) {
            throw new RuntimeException(AppMessages.CARD_NO_PERMISSION_EDIT);
        }
        
        // 只有待审批状态的卡片才能修改
        if (!"0".equals(card.getAuditStatus())) {
            throw new RuntimeException(AppMessages.CARD_ONLY_PENDING_EDIT);
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
    public void deleteMyCard(Long cardId, Long createBy) {
        BizCard card = getById(cardId);
        if (card == null) {
            throw new RuntimeException(AppMessages.CARD_NOT_FOUND);
        }
        
        // 校验是否是用户自己的卡片
        if (!card.getCreateBy().equals(createBy)) {
            throw new RuntimeException(AppMessages.CARD_NO_PERMISSION_DELETE);
        }
        
        // 只有待审批状态的卡片才能删除
        if (!"0".equals(card.getAuditStatus())) {
            throw new RuntimeException(AppMessages.CARD_ONLY_PENDING_DELETE);
        }
        
        removeById(cardId);
        
        // 删除标签关联
        cardTagService.lambdaUpdate()
                .eq(BizCardTag::getCardId, cardId)
                .remove();
    }

}