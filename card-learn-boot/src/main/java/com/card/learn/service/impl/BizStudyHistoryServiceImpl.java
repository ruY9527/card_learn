package com.card.learn.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.card.learn.entity.BizStudyHistory;
import com.card.learn.mapper.BizStudyHistoryMapper;
import com.card.learn.service.IBizStudyHistoryService;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 学习历史记录Service实现
 */
@Service
public class BizStudyHistoryServiceImpl extends ServiceImpl<BizStudyHistoryMapper, BizStudyHistory> implements IBizStudyHistoryService {

    @Override
    public void recordHistory(Long userId, Long cardId, Integer status, String source) {
        BizStudyHistory history = new BizStudyHistory();
        history.setUserId(userId);
        history.setCardId(cardId);
        history.setStatus(status);
        history.setSource(source);
        history.setCreateTime(LocalDateTime.now());
        save(history);
    }

    @Override
    public LocalDateTime getLastStudyTime(Long userId, Long cardId, Integer status) {
        BizStudyHistory record = lambdaQuery()
                .eq(BizStudyHistory::getCardId, cardId)
                .eq(BizStudyHistory::getStatus, status)
                .eq(userId != null, BizStudyHistory::getUserId, userId)
                .orderByDesc(BizStudyHistory::getCreateTime)
                .last("LIMIT 1")
                .one();
        return record != null ? record.getCreateTime() : null;
    }

    @Override
    public Map<Long, LocalDateTime> batchGetLastStudyTime(Long userId, List<Long> cardIds) {
        if (cardIds == null || cardIds.isEmpty()) {
            return Collections.emptyMap();
        }
        List<BizStudyHistory> records = lambdaQuery()
                .in(BizStudyHistory::getCardId, cardIds)
                .eq(userId != null, BizStudyHistory::getUserId, userId)
                .orderByDesc(BizStudyHistory::getCreateTime)
                .list();

        // 每个 cardId 只保留最新的一条记录
        Map<Long, LocalDateTime> result = new HashMap<>();
        for (BizStudyHistory record : records) {
            result.putIfAbsent(record.getCardId(), record.getCreateTime());
        }
        return result;
    }

    @Override
    public Map<Long, Integer> batchGetStudyCount(Long userId, List<Long> cardIds) {
        if (cardIds == null || cardIds.isEmpty()) {
            return Collections.emptyMap();
        }
        List<BizStudyHistory> records = lambdaQuery()
                .in(BizStudyHistory::getCardId, cardIds)
                .eq(userId != null, BizStudyHistory::getUserId, userId)
                .select(BizStudyHistory::getCardId)
                .list();

        Map<Long, Integer> result = new HashMap<>();
        for (BizStudyHistory record : records) {
            result.merge(record.getCardId(), 1, Integer::sum);
        }
        return result;
    }
}
