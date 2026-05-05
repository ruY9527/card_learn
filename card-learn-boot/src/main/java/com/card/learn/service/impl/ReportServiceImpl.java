package com.card.learn.service.impl;

import com.card.learn.entity.BizLearningReport;
import com.card.learn.entity.BizStudyHistory;
import com.card.learn.entity.BizUserProgress;
import com.card.learn.mapper.*;
import com.card.learn.service.IReportService;
import com.card.learn.vo.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.TemporalAdjusters;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 学习报告Service实现
 */
@Slf4j
@Service
public class ReportServiceImpl implements IReportService {

    @Autowired
    private BizLearningReportMapper reportMapper;

    @Autowired
    private BizStudyHistoryMapper studyHistoryMapper;

    @Autowired
    private BizUserProgressMapper progressMapper;

    @Autowired
    private BizWeakPointMapper weakPointMapper;

    @Autowired
    private BizDailyStatsSnapshotMapper dailyStatsMapper;

    @Autowired
    private BizSubjectMapper subjectMapper;

    @Autowired
    private BizCardMapper cardMapper;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public ReportDetailVO getCurrentReport(Long userId, String reportType) {
        LocalDate[] period = getCurrentPeriod(reportType);

        // 查找是否已有报告
        BizLearningReport existing = findExistingReport(userId, reportType, period[0], period[1]);
        if (existing != null) {
            return parseReport(existing);
        }

        // 没有则实时生成
        return buildReport(userId, reportType, period[0], period[1]);
    }

    @Override
    public List<ReportListVO> getHistoryReports(Long userId, String reportType, Integer page, Integer size) {
        int offset = (page - 1) * size;
        List<ReportListVO> reports = reportMapper.selectReportList(userId, reportType, offset, size);

        // 填充每份报告的概览数据
        for (ReportListVO report : reports) {
            BizLearningReport entity = reportMapper.selectById(report.getReportId());
            if (entity != null && entity.getReportData() != null) {
                try {
                    Map<String, Object> data = objectMapper.readValue(entity.getReportData(), new TypeReference<Map<String, Object>>() {});
                    @SuppressWarnings("unchecked")
                    Map<String, Object> overview = (Map<String, Object>) data.get("overview");
                    if (overview != null) {
                        ReportOverviewVO ov = new ReportOverviewVO();
                        ov.setTotalCards((Integer) overview.get("totalCards"));
                        ov.setNewMastered((Integer) overview.get("newMastered"));
                        ov.setForgotten((Integer) overview.get("forgotten"));
                        ov.setStreakDays((Integer) overview.get("streakDays"));
                        report.setOverview(ov);
                    }
                } catch (Exception e) {
                    log.warn("Failed to parse report data for id={}", report.getReportId(), e);
                }
            }
        }
        return reports;
    }

    @Override
    public int getHistoryReportCount(Long userId, String reportType) {
        return reportMapper.selectReportCount(userId, reportType);
    }

    @Override
    public ReportDetailVO getReportById(Long reportId, Long userId) {
        BizLearningReport report = reportMapper.selectById(reportId);
        if (report == null || !report.getUserId().equals(userId)) {
            return null;
        }
        return parseReport(report);
    }

    @Override
    public void generateReport(Long userId, String reportType) {
        LocalDate[] period = getPreviousPeriod(reportType);

        // 检查是否已生成
        BizLearningReport existing = findExistingReport(userId, reportType, period[0], period[1]);
        if (existing != null) {
            log.info("Report already exists for user={}, type={}, period={}~{}", userId, reportType, period[0], period[1]);
            return;
        }

        ReportDetailVO detail = buildReport(userId, reportType, period[0], period[1]);

        // 保存报告
        try {
            BizLearningReport entity = new BizLearningReport();
            entity.setUserId(userId);
            entity.setReportType(reportType);
            entity.setPeriodStart(period[0]);
            entity.setPeriodEnd(period[1]);
            entity.setReportData(objectMapper.writeValueAsString(detail));
            entity.setCreatedAt(LocalDateTime.now());
            reportMapper.insert(entity);
            log.info("Generated {} report for user={}, period={}~{}", reportType, userId, period[0], period[1]);
        } catch (Exception e) {
            log.error("Failed to save report for user={}", userId, e);
        }
    }

    // ============ 内部方法 ============

    /**
     * 构建报告详情
     */
    private ReportDetailVO buildReport(Long userId, String reportType, LocalDate startDate, LocalDate endDate) {
        ReportDetailVO detail = new ReportDetailVO();
        detail.setReportType(reportType);
        detail.setPeriodStart(startDate);
        detail.setPeriodEnd(endDate);

        // 1. 概览
        detail.setOverview(buildOverview(userId, startDate, endDate));

        // 2. 掌握率趋势
        detail.setMasteryTrend(buildMasteryTrend(userId, startDate, endDate));

        // 3. 科目分析
        detail.setSubjectAnalysis(buildSubjectAnalysis(userId, startDate, endDate));

        // 4. 学习习惯
        detail.setLearningHabits(buildLearningHabits(userId, startDate, endDate));

        // 5. 薄弱点
        detail.setWeakPoints(buildWeakPoints(userId));

        // 6. 改进建议
        detail.setSuggestions(buildSuggestions(detail));

        return detail;
    }

    /**
     * 构建概览数据
     */
    private ReportOverviewVO buildOverview(Long userId, LocalDate startDate, LocalDate endDate) {
        ReportOverviewVO overview = new ReportOverviewVO();

        // 查询周期内的学习历史
        String start = startDate.atStartOfDay().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        String end = endDate.atTime(LocalTime.MAX).format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

        // 学习卡片数（去重）
        Long totalCards = progressMapper.countByCondition(userId, null, null, startDate.atStartOfDay(), endDate.atTime(LocalTime.MAX));
        overview.setTotalCards(totalCards != null ? totalCards.intValue() : 0);

        // 新掌握卡片数
        Long newMastered = progressMapper.countByCondition(userId, 2, 2, startDate.atStartOfDay(), endDate.atTime(LocalTime.MAX));
        overview.setNewMastered(newMastered != null ? newMastered.intValue() : 0);

        // 遗忘卡片数（status=0且在周期内更新过）
        Long forgotten = progressMapper.countByCondition(userId, 0, 0, startDate.atStartOfDay(), endDate.atTime(LocalTime.MAX));
        overview.setForgotten(forgotten != null ? forgotten.intValue() : 0);

        // 连续学习天数
        overview.setStreakDays(calculateStreakDays(userId));

        // 学习时长（暂用学习次数*2分钟估算）
        overview.setStudyDuration(overview.getTotalCards() * 2);

        return overview;
    }

    /**
     * 构建掌握率趋势
     */
    private MasteryTrendVO buildMasteryTrend(Long userId, LocalDate startDate, LocalDate endDate) {
        MasteryTrendVO trend = new MasteryTrendVO();

        // 计算周期开始和结束的掌握率
        int startRate = calculateMasteryRate(userId, startDate);
        int endRate = calculateMasteryRate(userId, endDate);

        trend.setStartRate(startRate);
        trend.setEndRate(endRate);
        trend.setChangeRate(endRate - startRate);

        // 构建每日趋势数据
        List<TrendPointVO> trendData = new ArrayList<>();
        LocalDate current = startDate;
        while (!current.isAfter(endDate)) {
            int rate = calculateMasteryRate(userId, current);
            trendData.add(new TrendPointVO(current.toString(), rate));
            current = current.plusDays(1);
        }
        trend.setTrendData(trendData);

        return trend;
    }

    /**
     * 构建科目分析
     */
    private List<SubjectAnalysisVO> buildSubjectAnalysis(Long userId, LocalDate startDate, LocalDate endDate) {
        // 复用现有的科目统计查询
        List<SubjectLearnStatsVO> stats = progressMapper.selectSubjectStats(userId);
        List<SubjectAnalysisVO> result = new ArrayList<>();

        for (SubjectLearnStatsVO stat : stats) {
            SubjectAnalysisVO analysis = new SubjectAnalysisVO();
            analysis.setSubjectId(stat.getSubjectId().longValue());
            analysis.setSubjectName(stat.getSubjectName());
            analysis.setTotalCards(stat.getTotalCards() != null ? stat.getTotalCards().intValue() : 0);
            analysis.setMastered(stat.getMasteredCount() != null ? stat.getMasteredCount().intValue() : 0);
            analysis.setWeakPoints(0); // TODO: 按科目统计薄弱点

            int total = analysis.getTotalCards();
            analysis.setMasteryRate(total > 0 ? analysis.getMastered() * 100 / total : 0);

            result.add(analysis);
        }

        return result;
    }

    /**
     * 构建学习习惯分析
     */
    private LearningHabitsVO buildLearningHabits(Long userId, LocalDate startDate, LocalDate endDate) {
        LearningHabitsVO habits = new LearningHabitsVO();

        // 查询周期内的学习历史
        List<BizStudyHistory> history = studyHistoryMapper.selectByUserAndDateRange(
                userId, startDate.atStartOfDay(), endDate.atTime(LocalTime.MAX));

        if (history.isEmpty()) {
            habits.setMorning(0);
            habits.setAfternoon(0);
            habits.setEvening(0);
            habits.setPeakHour("无数据");
            habits.setMostActiveDay("无数据");
            habits.setAvgDailyDuration(0);
            habits.setStudyFrequency(0);
            return habits;
        }

        // 时段分布
        int morning = 0, afternoon = 0, evening = 0;
        Map<Integer, Integer> hourCounts = new HashMap<>();
        Map<DayOfWeek, Integer> dayCounts = new HashMap<>();

        for (BizStudyHistory h : history) {
            LocalDateTime time = h.getCreateTime();
            int hour = time.getHour();
            DayOfWeek dow = time.getDayOfWeek();

            if (hour >= 6 && hour < 12) { morning++; }
            else if (hour >= 12 && hour < 18) { afternoon++; }
            else { evening++; }

            hourCounts.merge(hour, 1, Integer::sum);
            dayCounts.merge(dow, 1, Integer::sum);
        }

        int total = history.size();
        habits.setMorning(morning * 100 / total);
        habits.setAfternoon(afternoon * 100 / total);
        habits.setEvening(evening * 100 / total);

        // 高峰时段
        int peakHour = hourCounts.entrySet().stream()
                .max(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .orElse(8);
        habits.setPeakHour(String.format("%02d:00-%02d:00", peakHour, peakHour + 2));

        // 最活跃学习日
        DayOfWeek activeDay = dayCounts.entrySet().stream()
                .max(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .orElse(DayOfWeek.MONDAY);
        habits.setMostActiveDay(formatDayOfWeek(activeDay));

        // 平均每日学习时长
        long daysBetween = java.time.temporal.ChronoUnit.DAYS.between(startDate, endDate) + 1;
        habits.setAvgDailyDuration(daysBetween > 0 ? (int)(total * 2.0 / daysBetween) : 0);

        // 学习频率
        long studyDays = history.stream()
                .map(h -> h.getCreateTime().toLocalDate())
                .distinct()
                .count();
        habits.setStudyFrequency((int)(studyDays * 7 / Math.max(daysBetween, 1)));

        return habits;
    }

    /**
     * 构建薄弱点列表
     */
    private List<WeakPointVO> buildWeakPoints(Long userId) {
        return weakPointMapper.selectWeakPointList(userId, 0, 10);
    }

    /**
     * 构建改进建议
     */
    private List<SuggestionVO> buildSuggestions(ReportDetailVO detail) {
        List<SuggestionVO> suggestions = new ArrayList<>();

        // 基于科目分析生成建议
        if (detail.getSubjectAnalysis() != null) {
            for (SubjectAnalysisVO subject : detail.getSubjectAnalysis()) {
                if (subject.getMasteryRate() < 40) {
                    suggestions.add(new SuggestionVO("subject", "high",
                            subject.getSubjectName() + "掌握率偏低(" + subject.getMasteryRate() + "%)，建议加强复习"));
                } else if (subject.getMasteryRate() < 60) {
                    suggestions.add(new SuggestionVO("subject", "medium",
                            subject.getSubjectName() + "掌握率有待提高(" + subject.getMasteryRate() + "%)，建议增加练习"));
                }
            }
        }

        // 基于薄弱点生成建议
        if (detail.getWeakPoints() != null && !detail.getWeakPoints().isEmpty()) {
            WeakPointVO topWeak = detail.getWeakPoints().get(0);
            suggestions.add(new SuggestionVO("card", "high",
                    "「" + topWeak.getFrontContent() + "」错误" + topWeak.getErrorCount() + "次，建议重新学习后重试"));
        }

        // 基于学习习惯生成建议
        if (detail.getLearningHabits() != null) {
            LearningHabitsVO habits = detail.getLearningHabits();
            if (habits.getStudyFrequency() != null && habits.getStudyFrequency() >= 5) {
                suggestions.add(new SuggestionVO("habit", "medium", "保持当前学习节奏，连续学习有助于记忆巩固"));
            } else if (habits.getStudyFrequency() != null && habits.getStudyFrequency() < 3) {
                suggestions.add(new SuggestionVO("habit", "high", "学习频率较低，建议每天保持一定的学习量"));
            }
        }

        if (suggestions.isEmpty()) {
            suggestions.add(new SuggestionVO("habit", "low", "继续保持良好的学习习惯"));
        }

        return suggestions;
    }

    // ============ 辅助方法 ============

    /**
     * 计算掌握率
     */
    private int calculateMasteryRate(Long userId, LocalDate date) {
        Long total = progressMapper.countByCondition(userId, null, null, null, date.atTime(LocalTime.MAX));
        Long mastered = progressMapper.countByCondition(userId, 2, 2, null, date.atTime(LocalTime.MAX));
        if (total == null || total == 0) return 0;
        return (int)(mastered * 100 / total);
    }

    /**
     * 计算连续学习天数
     */
    private int calculateStreakDays(Long userId) {
        LocalDate today = LocalDate.now();
        int streak = 0;
        LocalDate checkDate = today;

        while (true) {
            Long count = progressMapper.countByCondition(userId, null, null,
                    checkDate.atStartOfDay(), checkDate.atTime(LocalTime.MAX));
            if (count != null && count > 0) {
                streak++;
                checkDate = checkDate.minusDays(1);
            } else {
                break;
            }
        }
        return streak;
    }

    /**
     * 获取当前周期日期范围
     */
    private LocalDate[] getCurrentPeriod(String reportType) {
        LocalDate today = LocalDate.now();
        if ("monthly".equals(reportType)) {
            LocalDate start = today.with(TemporalAdjusters.firstDayOfMonth());
            LocalDate end = today.with(TemporalAdjusters.lastDayOfMonth());
            return new LocalDate[]{start, end};
        } else {
            LocalDate start = today.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
            LocalDate end = start.plusDays(6);
            return new LocalDate[]{start, end};
        }
    }

    /**
     * 获取上一个周期日期范围
     */
    private LocalDate[] getPreviousPeriod(String reportType) {
        LocalDate today = LocalDate.now();
        if ("monthly".equals(reportType)) {
            LocalDate lastMonth = today.minusMonths(1);
            LocalDate start = lastMonth.with(TemporalAdjusters.firstDayOfMonth());
            LocalDate end = lastMonth.with(TemporalAdjusters.lastDayOfMonth());
            return new LocalDate[]{start, end};
        } else {
            LocalDate lastWeek = today.minusWeeks(1);
            LocalDate start = lastWeek.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
            LocalDate end = start.plusDays(6);
            return new LocalDate[]{start, end};
        }
    }

    /**
     * 查找已有报告
     */
    private BizLearningReport findExistingReport(Long userId, String reportType, LocalDate startDate, LocalDate endDate) {
        List<ReportListVO> reports = reportMapper.selectReportList(userId, reportType, 0, 100);
        for (ReportListVO r : reports) {
            if (r.getPeriodStart() != null && r.getPeriodStart().equals(startDate)
                    && r.getPeriodEnd() != null && r.getPeriodEnd().equals(endDate)) {
                return reportMapper.selectById(r.getReportId());
            }
        }
        return null;
    }

    /**
     * 解析已保存的报告
     */
    private ReportDetailVO parseReport(BizLearningReport entity) {
        try {
            ReportDetailVO detail = objectMapper.readValue(entity.getReportData(), ReportDetailVO.class);
            detail.setReportId(entity.getId());
            return detail;
        } catch (Exception e) {
            log.error("Failed to parse report data for id={}", entity.getId(), e);
            return null;
        }
    }

    /**
     * 格式化星期
     */
    private String formatDayOfWeek(DayOfWeek dow) {
        switch (dow) {
            case MONDAY: return "周一";
            case TUESDAY: return "周二";
            case WEDNESDAY: return "周三";
            case THURSDAY: return "周四";
            case FRIDAY: return "周五";
            case SATURDAY: return "周六";
            case SUNDAY: return "周日";
            default: return "";
        }
    }
}
