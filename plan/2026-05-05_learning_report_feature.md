# 个性化学习报告功能设计规划

**创建日期**: 2026-05-05
**功能模块**: 学习增强 - 个性化学习报告
**项目**: card_learn 考研知识点学习卡片系统

---

## 一、需求概述

### 1.1 功能目标

- 为用户提供周期性（周报、月报）的个性化学习报告
- 基于用户学习数据生成详细的统计分析和改进建议
- 帮助用户了解自己的学习进度、薄弱点和发展趋势

### 1.2 报告周期

| 类型 | 生成时间 | 内容侧重点 |
|------|----------|------------|
| 周报 | 每周一 00:05 自动生成 | 本周学习情况、进步/退步分析、薄弱点预警 |
| 月报 | 每月1日 00:05 自动生成 | 本月总结、科目对比、整体成长轨迹、阶段建议 |

### 1.3 报告内容（全面报告）

1. 学习时长统计
2. 掌握率变化趋势
3. 遗忘曲线分析
4. 科目对比分析
5. 成长轨迹展示
6. 个性化改进建议

---

## 二、报告内容设计

### 2.1 周报内容

```
┌─────────────────────────────────────────────────────────────┐
│                     📊 第{期号}期学习周报                    │
│                     {起始日期} - {结束日期}                    │
└─────────────────────────────────────────────────────────────┘

【📈 学习概览】
┌──────────────────────────────────────────────────────────┐
│  本周学习卡片数    │  掌握卡片数    │  遗忘卡片数    │  连续天数   │
│      120          │      35       │      18       │     7      │
│   ↑ 20%          │   ↑ 15%      │   ↓ 10%      │    稳定    │
└──────────────────────────────────────────────────────────┘

【⏰ 学习时段分析】
     上午(6-12点)    ████████████░░░░░░░  45%
     下午(12-18点)   ██████████░░░░░░░░░░  35%
     晚上(18-24点)   ██████░░░░░░░░░░░░░  20%
本周学习高峰时段: 上午 8:00-10:00

【🎯 掌握率趋势】
上周末掌握率: 42%
本周末掌握率: 48%
本周提升: +6% ↑

【📚 科目进度】
┌──────────────────────────────────────────────────────────┐
│  科目         │  卡片数  │  已掌握  │  薄弱点  │  掌握率   │
├──────────────────────────────────────────────────────────┤
│  数据结构     │   150   │    72   │   23    │   48%   │
│  计算机网络   │   120   │    45   │   31    │   37%   │
│  操作系统     │   100   │    52   │   18    │   52%   │
└──────────────────────────────────────────────────────────┘
⚠️ 计算机网络掌握率偏低，建议加强复习

【🔔 薄弱点预警】
以下卡片本周复习效果不佳，建议重点关注:
┌──────────────────────────────────────────────────────────┐
│  1. 「三次握手四次挥手」- 错误3次                         │
│  2. 「TCP滑动窗口」- 错误2次                              │
│  3. 「进程与线程区别」- 错误2次                           │
└──────────────────────────────────────────────────────────┘

【🏆 成就解锁】
🎉 本周解锁成就: 「连续7天学习」「掌握50卡片」

【💡 下周建议】
1. 本周计算机网络学习效果不佳，建议增加该科目复习时间
2. 「三次握手四次挥手」相关卡片建议重新学习理论后重试
3. 保持当前学习节奏，连续学习有助于记忆巩固
```

### 2.2 月报内容

```
┌─────────────────────────────────────────────────────────────┐
│                     📊 {月份}月度学习报告                    │
│                     {起始日期} - {结束日期}                    │
└─────────────────────────────────────────────────────────────┘

【📊 本月总览】
┌─────────────────────────────────────────────────────────────┐
│  学习卡片总数  │  新掌握卡片  │  遗忘卡片  │  总学习时长  │
│     520       │     186     │    67     │   32小时    │
│   ↑ 15%      │   ↑ 22%    │   ↓ 8%   │   ↑ 18%   │
└─────────────────────────────────────────────────────────────┘

【📈 成长轨迹】
                    掌握率变化趋势
    50% │                                    ●
        │                              ●
    40% │                        ●
        │                  ●
    30% │            ●
        │      ●
    20% │●
        └────┬────┬────┬────┬────┬────┬────┬────→ 周
             1    2    3    4

【🎯 掌握率提升】
月初掌握率: 28%
月末掌握率: 48%
本月提升: +20% 超过 85% 的用户

【📚 科目对比分析】
         掌握率对比
    数据结构    ████████████████░░░░  65%
    操作系统    ████████████░░░░░░░░  52%
    计算机网络  ██████████░░░░░░░░░░░  38%
    组成原理    ████████████████████  72%

【⏰ 学习习惯分析】
· 平均每日学习时长: 1.8小时
· 学习高峰时段: 上午 8:00-10:00
· 最活跃学习日: 周六、周日
· 连续学习最长: 14天

【🧠 遗忘曲线分析】
本周遗忘曲线:
         记忆保留率
    100% │        ●─────────────
        │       /
     80% │      /
        │     /
     60% │    /
        │   /
     40% │  /
        │ /
     20% │/
        └───────────────────────── 天数
          1   3   7   14  30

建议: 根据遗忘曲线，建议在第3天、第7天、第14天进行复习

【🏆 本月成就】
🎉 新解锁成就:
   · 「学习新秀」- 首次完成月度学习目标
   · 「持之以恒」- 连续学习30天
   · 「数据结构大师」- 数据结构科目掌握率超过80%

【📋 下月学习计划建议】
1. 计算机网络是薄弱科目，建议下月重点突破
2. 建议设定每日学习目标: 10张新卡片 + 20张复习
3. 继续保持上午学习习惯，学习效率最高
```

---

## 三、数据统计指标

### 3.1 核心指标

| 指标 | 计算方式 | 说明 |
|------|----------|------|
| 学习卡片数 | 本周期内学习过的卡片去重数 | 包含新学和复习 |
| 新掌握卡片数 | status从0/1变为2的卡片数 | 只增不减 |
| 遗忘卡片数 | status从2变为1的卡片数 | 可能恢复 |
| 掌握率 | 掌握卡片数 / 总卡片数 | 百分比 |
| 学习时长 | 每次学习行为记录时长累加 | 需要记录时长 |
| 连续学习天数 | 每日有学习记录的天数 | 中断则重置 |

### 3.2 进阶指标

| 指标 | 计算方式 | 说明 |
|------|----------|------|
| 遗忘曲线 | 根据SM-2参数计算 | 预测下次遗忘时间 |
| 掌握率提升 | 月末掌握率 - 月初掌握率 | 正数表示进步 |
| 学习效率 | 掌握卡片数 / 学习总时长 | 卡片/小时 |
| 薄弱点 | 错误次数 >= 2的卡片 | 需重点复习 |

### 3.3 习惯分析指标

| 指标 | 说明 |
|------|------|
| 学习时段分布 | 上午/下午/晚上各时段学习占比 |
| 高峰时段 | 学习最活跃的时间段 |
| 学习频率 | 每周学习天数 |
| 最活跃学习日 | 一周中哪天学习最多 |

---

## 四、数据库设计

### 4.1 新增表

```sql
-- 学习报告表
CREATE TABLE `biz_learning_report` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `report_type` varchar(10) NOT NULL COMMENT '报告类型: weekly/monthly',
  `period_start` date NOT NULL COMMENT '统计周期开始日期',
  `period_end` date NOT NULL COMMENT '统计周期结束日期',
  `report_data` longtext COMMENT '报告数据JSON',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_type` (`user_id`, `report_type`),
  KEY `idx_period` (`period_start`, `period_end`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学习报告表';

-- 薄弱点记录表
CREATE TABLE `biz_weak_point` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `card_id` bigint(20) NOT NULL COMMENT '卡片ID',
  `error_count` int(11) DEFAULT 1 COMMENT '错误次数',
  `last_error_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最后错误时间',
  `status` varchar(10) DEFAULT 'active' COMMENT '状态: active/purged/reviewed',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_card` (`user_id`, `card_id`),
  KEY `idx_error_count` (`error_count` DESC),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='薄弱点记录表';

-- 每日学习统计快照表
CREATE TABLE `biz_daily_stats_snapshot` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `stats_date` date NOT NULL COMMENT '统计日期',
  `total_cards` int(11) DEFAULT 0 COMMENT '当日学习卡片数',
  `new_mastered` int(11) DEFAULT 0 COMMENT '当日新掌握卡片数',
  `forgotten` int(11) DEFAULT 0 COMMENT '当日遗忘卡片数',
  `study_duration` int(11) DEFAULT 0 COMMENT '当日学习时长(分钟)',
  `mastery_rate` decimal(5,2) DEFAULT 0.00 COMMENT '当日掌握率',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_date` (`user_id`, `stats_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='每日学习统计快照';
```

### 4.2 报告数据结构 (report_data JSON)

```json
{
  "period": {
    "start": "2026-04-28",
    "end": "2026-05-04",
    "type": "weekly",
    "weekNumber": 18
  },
  "overview": {
    "totalCards": 120,
    "newMastered": 35,
    "forgotten": 18,
    "streakDays": 7,
    "studyDuration": 480,
    "comparisonLastPeriod": {
      "totalCardsChange": "+20%",
      "newMasteredChange": "+15%",
      "forgottenChange": "-10%"
    }
  },
  "masteryTrend": {
    "startRate": 42,
    "endRate": 48,
    "changeRate": 6,
    "trendData": [
      {"date": "2026-04-28", "rate": 42},
      {"date": "2026-04-29", "rate": 43},
      {"date": "2026-04-30", "rate": 44},
      {"date": "2026-05-01", "rate": 45},
      {"date": "2026-05-02", "rate": 46},
      {"date": "2026-05-03", "rate": 47},
      {"date": "2026-05-04", "rate": 48}
    ]
  },
  "subjectAnalysis": [
    {
      "subjectId": 1,
      "subjectName": "数据结构",
      "totalCards": 150,
      "mastered": 72,
      "weakPoints": 23,
      "masteryRate": 48
    }
  ],
  "learningHabits": {
    "timeDistribution": {
      "morning": 45,
      "afternoon": 35,
      "evening": 20
    },
    "peakHour": "08:00-10:00",
    "mostActiveDay": "Saturday",
    "avgDailyDuration": 68,
    "studyFrequency": 6
  },
  "forgettingCurve": {
    "retentionRate": [
      {"day": 1, "rate": 100},
      {"day": 3, "rate": 75},
      {"day": 7, "rate": 45},
      {"day": 14, "rate": 30},
      {"day": 30, "rate": 20}
    ],
    "suggestedReviewDays": [3, 7, 14, 30]
  },
  "weakPoints": [
    {
      "cardId": 123,
      "frontContent": "三次握手四次挥手...",
      "errorCount": 3,
      "lastErrorTime": "2026-05-03"
    }
  ],
  "achievements": [
    {
      "code": "STREAK_7",
      "name": "连续7天学习",
      "unlockedAt": "2026-05-01"
    }
  ],
  "suggestions": [
    {
      "type": "subject",
      "priority": "high",
      "content": "计算机网络掌握率偏低，建议加强复习"
    },
    {
      "type": "card",
      "priority": "high",
      "content": "「三次握手四次挥手」相关卡片建议重新学习"
    },
    {
      "type": "habit",
      "priority": "medium",
      "content": "保持当前学习节奏，连续学习有助于记忆巩固"
    }
  ]
}
```

---

## 五、API 接口设计

### 5.1 接口列表

| # | 方法 | 路径 | 说明 |
|---|------|------|------|
| 1 | GET | `/api/learning/report/current` | 获取当前周期报告 |
| 2 | GET | `/api/learning/report/history` | 获取历史报告列表 |
| 3 | GET | `/api/learning/report/{id}` | 获取指定报告详情 |
| 4 | GET | `/api/learning/weak-points` | 获取薄弱点列表 |
| 5 | POST | `/api/learning/weak-points/{cardId}/review` | 标记薄弱点已复习 |
| 6 | GET | `/api/learning/stats/daily` | 获取每日统计 |
| 7 | GET | `/api/learning/analysis/trend` | 获取趋势分析 |

### 5.2 接口详情

#### 接口1: 获取当前周期报告

```
GET /api/learning/report/current?type=weekly

响应:
{
  "code": 200,
  "data": {
    "reportId": 123,
    "reportType": "weekly",
    "periodStart": "2026-04-28",
    "periodEnd": "2026-05-04",
    "isGenerated": true,
    "report": { ... }
  }
}
```

#### 接口2: 获取历史报告列表

```
GET /api/learning/report/history?type=weekly&page=1&size=4

响应:
{
  "code": 200,
  "data": {
    "records": [
      {
        "reportId": 123,
        "periodStart": "2026-04-28",
        "periodEnd": "2026-05-04",
        "weekNumber": 18,
        "overview": {
          "totalCards": 120,
          "masteryRate": 48,
          "streakDays": 7
        }
      }
    ],
    "total": 8,
    "pages": 2
  }
}
```

#### 接口3: 获取薄弱点列表

```
GET /api/learning/weak-points?page=1&size=20

响应:
{
  "code": 200,
  "data": {
    "records": [
      {
        "cardId": 123,
        "subjectName": "计算机网络",
        "frontContent": "三次握手四次挥手...",
        "errorCount": 3,
        "lastErrorTime": "2026-05-03 20:30:00"
      }
    ],
    "total": 15
  }
}
```

---

## 六、服务端逻辑

### 6.1 报告生成时机

| 类型 | 生成时机 | 说明 |
|------|----------|------|
| 周报 | 每周一 00:05 | 统计上周一至周日数据 |
| 月报 | 每月1日 00:05 | 统计上月1日至最后一日 |

### 6.2 报告生成流程

```
1. 定时任务触发 (每周一/每月1日 00:05)
         │
         ▼
2. 查询所有活跃用户
         │
         ▼
3. 对每个用户生成报告
   ┌─────────────────────────────────┐
   │ 3.1 统计周期内学习数据            │
   │     - 学习卡片数、掌握数、遗忘数   │
   │     - 从biz_study_history聚合     │
   │     - 从biz_user_progress计算     │
   ├─────────────────────────────────┤
   │ 3.2 计算各项指标                  │
   │     - 掌握率、遗忘曲线            │
   │     - 学习习惯分析                │
   │     - 科目对比                   │
   ├─────────────────────────────────┤
   │ 3.3 识别薄弱点                   │
   │     - 错误次数 >= 2的卡片         │
   │     - 更新biz_weak_point表        │
   ├─────────────────────────────────┤
   │ 3.4 生成改进建议                  │
   │     - 基于数据的分析              │
   │     - 重点科目提示                │
   │     - 习惯优化建议                │
   ├─────────────────────────────────┤
   │ 3.5 组装报告JSON                  │
   │     - 存入biz_learning_report     │
   └─────────────────────────────────┘
         │
         ▼
4. 记录每日统计快照
   - 写入biz_daily_stats_snapshot
   - 用于历史趋势分析
```

### 6.3 薄弱点识别逻辑

```java
// 复习提交时调用
public void recordWeakPoint(Long userId, Long cardId, Integer status) {
    // 当复习结果为"模糊"或"忘记"时记录
    if (status == 0 || status == 1) {
        BizWeakPoint weakPoint = weakPointMapper.findByUserAndCard(userId, cardId);
        if (weakPoint == null) {
            weakPoint = new BizWeakPoint();
            weakPoint.setUserId(userId);
            weakPoint.setCardId(cardId);
            weakPoint.setErrorCount(1);
            weakPointMapper.insert(weakPoint);
        } else {
            weakPoint.setErrorCount(weakPoint.getErrorCount() + 1);
            weakPoint.setLastErrorTime(LocalDateTime.now());
            weakPointMapper.update(weakPoint);
        }
    } else if (status == 2) {
        // 掌握后清除薄弱点标记
        weakPointMapper.deleteByUserAndCard(userId, cardId);
    }
}
```

---

## 七、前端设计

### 7.1 iOS端 - 报告查看页面

```
┌─────────────────────────────────────────────────────┐
│  ◀ 返回        我的报告           ⚙️ 报告设置        │
├─────────────────────────────────────────────────────┤
│                                                     │
│  [📅 周报] [📆 月报]    ← Tab切换                  │
│  ─────────────────────────────────────              │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │ 📊 第18期学习周报                             │   │
│  │ 2026-04-28 ~ 2026-05-04                      │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  【📈 学习概览】                                   │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐           │
│  │ 120  │ │  35  │ │  18  │ │  7天  │           │
│  │  本周 │ │ 掌握 │ │ 遗忘 │ │ 连续  │           │
│  │ 学习  │ │ 卡片 │ │ 卡片 │ │ 天数  │           │
│  └──────┘ └──────┘ └──────┘ └──────┘           │
│                                                     │
│  【🎯 掌握率趋势】                                  │
│  ┌─────────────────────────────────────────────┐   │
│  │                                             │   │
│  │   42% ────────────▶ 48%                   │   │
│  │        ↑ +6% 超过85%用户                    │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  【📚 科目进度】                                    │
│  ┌─────────────────────────────────────────────┐   │
│  │ 数据结构   ████████████████░░░░░  65%     │   │
│  │ 操作系统   ████████████░░░░░░░░░  52%     │   │
│  │ 计算机网络 ██████████░░░░░░░░░░░░  38% ⚠️ │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  【🔔 薄弱点预警】                                   │
│  ┌─────────────────────────────────────────────┐   │
│  │ ⚠️ 三次握手四次挥手 - 错误3次              │   │
│  │ ⚠️ TCP滑动窗口 - 错误2次                   │   │
│  │ ⚠️ 进程与线程区别 - 错误2次                │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  【💡 改进建议】                                    │
│  ┌─────────────────────────────────────────────┐   │
│  │ 1. 计算机网络掌握率偏低，建议加强复习       │   │
│  │ 2. 薄弱卡片建议重新学习理论后重试           │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  [查看历史报告]                                     │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### 7.2 管理后台 - 报告配置

```
┌─────────────────────────────────────────────────────┐
│  学习报告配置                                        │
├─────────────────────────────────────────────────────┤
│                                                     │
│  报告开关:  [✓] 启用  [ ] 禁用                      │
│                                                     │
│  周报设置:                                           │
│    [✓] 自动生成周报                                  │
│    生成时间: [00:05 ▼] 每周一                        │
│    [✓] 推送通知用户                                  │
│                                                     │
│  月报设置:                                           │
│    [✓] 自动生成月报                                  │
│    生成时间: [00:05 ▼] 每月1日                       │
│    [✓] 推送通知用户                                  │
│                                                     │
│  报告内容:                                           │
│    [✓] 学习概览                                      │
│    [✓] 掌握率趋势                                    │
│    [✓] 遗忘曲线分析                                  │
│    [✓] 科目对比                                      │
│    [✓] 学习习惯分析                                  │
│    [✓] 薄弱点预警                                    │
│    [✓] 成就解锁                                      │
│    [✓] 改进建议                                      │
│                                                     │
│  [保存配置]                                          │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## 八、文件变更清单

### 8.1 后端 (Spring Boot)

| 文件 | 操作 | 说明 |
|------|------|------|
| `entity/BizLearningReport.java` | 新增 | 学习报告实体 |
| `entity/BizWeakPoint.java` | 新增 | 薄弱点实体 |
| `entity/BizDailyStatsSnapshot.java` | 新增 | 每日统计快照实体 |
| `dto/ReportQueryDTO.java` | 新增 | 报告查询DTO |
| `vo/WeeklyReportVO.java` | 新增 | 周报VO |
| `vo/MonthlyReportVO.java` | 新增 | 月报VO |
| `vo/WeakPointVO.java` | 新增 | 薄弱点VO |
| `vo/SuggestionVO.java` | 新增 | 建议VO |
| `vo/TrendAnalysisVO.java` | 新增 | 趋势分析VO |
| `IMeasurementService.java` | 新增 | 统计服务接口 |
| `MeasurementServiceImpl.java` | 新增 | 统计服务实现 |
| `IReportService.java` | 新增 | 报告服务接口 |
| `ReportServiceImpl.java` | 新增 | 报告服务实现 |
| `IWeakPointService.java` | 新增 | 薄弱点服务接口 |
| `WeakPointServiceImpl.java` | 新增 | 薄弱点服务实现 |
| `LearningReportController.java` | 新增 | 报告控制器 |
| `WeakPointController.java` | 新增 | 薄弱点控制器 |
| `LearningServiceImpl.java` | 修改 | 复习时记录薄弱点 |
| `SQL: V15_20260505_learning_report.sql` | 新增 | 相关表结构 |

### 8.2 iOS端 (SwiftUI)

| 文件 | 操作 | 说明 |
|------|------|------|
| `Views/ReportView.swift` | 新增 | 报告查看页面 |
| `Views/WeakPointListView.swift` | 新增 | 薄弱点列表 |
| `Views/WeakPointDetailView.swift` | 新增 | 薄弱点详情/复习 |
| `Models/ReportModels.swift` | 新增 | 报告相关模型 |
| `Services/ReportApiService.swift` | 新增 | 报告API服务 |

### 8.3 管理后台 (Vue)

| 文件 | 操作 | 说明 |
|------|------|------|
| `views/stats/report-config/index.vue` | 新增 | 报告配置页面 |
| `api/report.ts` | 新增 | 报告API |
| `api/types.ts` | 修改 | 添加报告相关类型 |

---

## 九、待确认事项

- [ ] 报告生成时机是否合适（每周一00:05）
- [ ] 是否需要推送通知用户有新报告
- [ ] 是否需要支持手动生成报告
- [ ] 历史报告保留多长时间（默认12周/12月）

---

**文档版本**: v1.0
**最后更新**: 2026-05-05
