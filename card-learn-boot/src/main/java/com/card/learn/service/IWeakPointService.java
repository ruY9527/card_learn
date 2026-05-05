package com.card.learn.service;

import com.card.learn.vo.WeakPointVO;

import java.util.List;

/**
 * 薄弱点Service
 */
public interface IWeakPointService {

    /**
     * 记录薄弱点（复习时调用）
     * @param userId 用户ID
     * @param cardId 卡片ID
     * @param status 复习状态: 0=遗忘, 1=模糊, 2=掌握
     */
    void recordWeakPoint(Long userId, Long cardId, Integer status);

    /**
     * 获取用户薄弱点列表
     */
    List<WeakPointVO> getWeakPoints(Long userId, Integer page, Integer size);

    /**
     * 获取用户薄弱点总数
     */
    int getWeakPointCount(Long userId);

    /**
     * 标记薄弱点已复习
     */
    void markReviewed(Long userId, Long cardId);
}
