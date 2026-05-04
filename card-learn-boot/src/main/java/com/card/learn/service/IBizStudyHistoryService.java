package com.card.learn.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.card.learn.entity.BizStudyHistory;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 学习历史记录Service
 */
public interface IBizStudyHistoryService extends IService<BizStudyHistory> {

    /**
     * 记录学习历史
     */
    void recordHistory(Long userId, Long cardId, Integer status);

    /**
     * 查询某用户某卡片某状态的最近学习时间
     */
    LocalDateTime getLastStudyTime(Long userId, Long cardId, Integer status);

    /**
     * 批量查询卡片的最近学习时间，返回 key=cardId, value=最近学习时间
     */
    Map<Long, LocalDateTime> batchGetLastStudyTime(Long userId, List<Long> cardIds);

    /**
     * 批量查询卡片的学习次数，返回 key=cardId, value=学习次数
     */
    Map<Long, Integer> batchGetStudyCount(Long userId, List<Long> cardIds);
}
