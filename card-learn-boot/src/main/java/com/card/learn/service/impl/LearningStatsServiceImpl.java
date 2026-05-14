package com.card.learn.service.impl;

import com.card.learn.common.AppMessages;
import com.card.learn.entity.BizCard;
import com.card.learn.entity.BizStudyHistory;
import com.card.learn.entity.BizSubject;
import com.card.learn.mapper.BizCardMapper;
import com.card.learn.mapper.BizStudyHistoryMapper;
import com.card.learn.mapper.BizSubjectMapper;
import com.card.learn.mapper.BizUserProgressMapper;
import com.card.learn.service.ILearningStatsService;
import com.card.learn.vo.DailyLearnTrendVO;
import com.card.learn.vo.DayLearnDetailVO;
import com.card.learn.vo.LearningStatsVO;
import com.card.learn.vo.SubjectLearnStatsVO;
import com.card.learn.vo.UserLearnRankVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 学习数据统计Service实现
 */
@Service
public class LearningStatsServiceImpl implements ILearningStatsService {

    @Autowired
    private BizUserProgressMapper progressMapper;

    @Autowired
    private BizStudyHistoryMapper studyHistoryMapper;

    @Autowired
    private BizCardMapper cardMapper;

    @Autowired
    private BizSubjectMapper subjectMapper;

    @Override
    public LearningStatsVO getOverallStats(Long userId) {
        LearningStatsVO stats = progressMapper.selectOverallStats(userId);
        if (stats == null) {
            stats = new LearningStatsVO();
            stats.setTotalCards(0L);
            stats.setLearnDays(0L);
            stats.setTotalLearnRecords(0L);
            stats.setUnlearnedCount(0L);
            stats.setFuzzyCount(0L);
            stats.setMasteredCount(0L);
            stats.setLearnedRate(java.math.BigDecimal.ZERO);
        }
        return stats;
    }

    @Override
    public List<DailyLearnTrendVO> getDailyTrend(Integer days, Long userId) {
        if (days == null || days <= 0) {
            days = 30;
        }
        String startDate = LocalDate.now().minusDays(days).format(DateTimeFormatter.ISO_LOCAL_DATE);
        return studyHistoryMapper.selectDailyTrend(startDate, userId);
    }

    @Override
    public List<UserLearnRankVO> getUserRanking(Integer limit) {
        if (limit == null || limit <= 0) {
            limit = 10;
        }
        return progressMapper.selectUserRanking(limit);
    }

    @Override
    public List<SubjectLearnStatsVO> getSubjectStats(Long userId) {
        return progressMapper.selectSubjectStats(userId);
    }

    @Override
    public DayLearnDetailVO getDayDetail(Long userId, String date) {
        LocalDate ld = LocalDate.parse(date);
        LocalDateTime startTime = ld.atStartOfDay();
        LocalDateTime endTime = ld.atTime(LocalTime.MAX);

        List<BizStudyHistory> records = studyHistoryMapper.selectByUserAndDateRange(userId, startTime, endTime);

        DayLearnDetailVO vo = new DayLearnDetailVO();
        vo.setDate(date);
        vo.setTotalCount(records.size());
        vo.setMasteredCount(0);
        vo.setFuzzyCount(0);
        vo.setAgainCount(0);
        vo.setCards(new ArrayList<>());

        if (records.isEmpty()) {
            return vo;
        }

        // 批量查询卡片信息
        Set<Long> cardIds = records.stream().map(BizStudyHistory::getCardId).collect(Collectors.toSet());
        Map<Long, BizCard> cardMap = new HashMap<>();
        for (Long cardId : cardIds) {
            BizCard card = cardMapper.selectById(cardId);
            if (card != null) {
                cardMap.put(cardId, card);
            }
        }

        // 批量查询科目信息
        Set<Long> subjectIds = cardMap.values().stream()
                .map(BizCard::getSubjectId)
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());
        Map<Long, String> subjectNameMap = new HashMap<>();
        for (Long subjectId : subjectIds) {
            BizSubject subject = subjectMapper.selectById(subjectId);
            if (subject != null) {
                subjectNameMap.put(subjectId, subject.getSubjectName());
            }
        }

        // 组装卡片列表
        DateTimeFormatter timeFmt = DateTimeFormatter.ofPattern("HH:mm");
        for (BizStudyHistory record : records) {
            DayLearnDetailVO.DayCardItem item = new DayLearnDetailVO.DayCardItem();
            item.setCardId(record.getCardId());
            item.setStatus(record.getStatus());
            item.setSource(record.getSource());
            if (record.getCreateTime() != null) {
                item.setStudyTime(record.getCreateTime().format(timeFmt));
            }

            BizCard card = cardMap.get(record.getCardId());
            if (card != null) {
                item.setFrontContent(card.getFrontContent());
                item.setSubjectName(subjectNameMap.getOrDefault(card.getSubjectId(), AppMessages.UNKNOWN_SUBJECT));
            } else {
                item.setFrontContent(AppMessages.CARD_DELETED);
                item.setSubjectName(AppMessages.UNKNOWN_SUBJECT);
            }

            vo.getCards().add(item);

            // 统计各状态数量
            if (record.getStatus() != null) {
                if (record.getStatus() == 2) {
                    vo.setMasteredCount(vo.getMasteredCount() + 1);
                } else if (record.getStatus() == 1) {
                    vo.setFuzzyCount(vo.getFuzzyCount() + 1);
                } else {
                    vo.setAgainCount(vo.getAgainCount() + 1);
                }
            }
        }

        return vo;
    }
}
