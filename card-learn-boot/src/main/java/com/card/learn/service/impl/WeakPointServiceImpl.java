package com.card.learn.service.impl;

import com.card.learn.common.AppConstants;
import com.card.learn.entity.BizWeakPoint;
import com.card.learn.mapper.BizWeakPointMapper;
import com.card.learn.service.IWeakPointService;
import com.card.learn.vo.WeakPointVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 薄弱点Service实现
 */
@Slf4j
@Service
public class WeakPointServiceImpl implements IWeakPointService {

    @Autowired
    private BizWeakPointMapper weakPointMapper;

    @Override
    public void recordWeakPoint(Long userId, Long cardId, Integer status) {
        if (status == 0 || status == 1) {
            // 遗忘或模糊 -> 记录/更新薄弱点
            BizWeakPoint existing = weakPointMapper.selectByUserAndCard(userId, cardId);
            if (existing == null) {
                BizWeakPoint wp = new BizWeakPoint();
                wp.setUserId(userId);
                wp.setCardId(cardId);
                wp.setErrorCount(1);
                wp.setLastErrorTime(LocalDateTime.now());
                wp.setStatus(AppConstants.WEAK_POINT_ACTIVE);
                weakPointMapper.insert(wp);
            } else {
                existing.setErrorCount(existing.getErrorCount() + 1);
                existing.setLastErrorTime(LocalDateTime.now());
                weakPointMapper.updateById(existing);
            }
        } else if (status == 2) {
            // 掌握 -> 清除薄弱点标记
            weakPointMapper.deleteByUserAndCard(userId, cardId);
        }
    }

    @Override
    public List<WeakPointVO> getWeakPoints(Long userId, Integer page, Integer size) {
        int offset = (page - 1) * size;
        return weakPointMapper.selectWeakPointList(userId, offset, size);
    }

    @Override
    public int getWeakPointCount(Long userId) {
        return weakPointMapper.selectWeakPointCount(userId);
    }

    @Override
    public void markReviewed(Long userId, Long cardId) {
        BizWeakPoint existing = weakPointMapper.selectByUserAndCard(userId, cardId);
        if (existing != null) {
            existing.setStatus(AppConstants.WEAK_POINT_REVIEWED);
            weakPointMapper.updateById(existing);
        }
    }
}
