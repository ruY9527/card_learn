# 学习激励系统 - 完整设计方案

> 创建日期：2026-05-05
> 项目：card_learn 考研知识点学习卡片系统
> 模块：激励系统（成就、等级、目标、排行榜）

---

## 一、项目现状分析

### 1.1 现有业务功能

| 功能 | 后端 | iOS | Web管理 |
|------|------|-----|---------|
| 卡片学习（翻转查看问答） | ✅ | ✅ | ✅ |
| SM-2间隔重复算法 | ✅ | ✅ | - |
| 复习计划生成 | ✅ | ✅ | ✅ |
| 学习进度追踪 | ✅ | ✅ | ✅ |
| 学习连续（streak）统计 | ✅ | ✅ | ✅ |
| 科目掌握度统计 | ✅ | ✅ | ✅ |
| 卡片评论/回复 | ✅ | ✅ | ✅ |
| 卡片点赞 | ✅ | ✅ | ✅ |
| 用户反馈纠错 | ✅ | ✅ | ✅ |
| 用户自主投稿卡片 | ✅ | ✅ | ✅ |
| 卡片审批流程 | ✅ | - | ✅ |
| 专业/科目/标签管理 | ✅ | - | ✅ |
| Markdown/LaTeX支持 | ✅ | ✅ | ✅ |
| 用户/角色/权限管理 | ✅ | - | ✅ |

### 1.2 可扩展方向

1. **学习目标与激励系统** - 每日目标、成就徽章、学习等级、排行榜
2. **智能推荐与专项训练** - 薄弱点推荐、错题本、专项训练
3. **模拟考试与自测** - 随机抽题测试、限时答题、历史成绩
4. **社交学习功能** - 学习小组、心得分享、关注功能

---

## 二、激励系统功能设计

### 2.1 功能模块总览

```
激励系统
├── 每日/每周学习目标
├── 成就徽章系统
├── 学习等级/经验值
├── 排行榜
└── 激励中心（展示已获得成就、当前进度）
```

### 2.2 具体功能

#### 每日/每周学习目标

| 功能 | 描述 |
|------|------|
| 目标设置 | 用户设置每日学习目标（如：学习20张、复习30张） |
| 目标类型 | 可按"学习卡片数"或"掌握卡片数"设置 |
| 目标提醒 | 目标未完成时推送提醒（后续实现） |
| 目标达成 | 达成时显示庆祝动画/获得奖励 |

#### 成就徽章系统

| 分类 | 成就示例 |
|------|---------|
| 学习入门 | 首次学习、首次复习、首次掌握 |
| 连续学习 | 连续3天、7天、30天、100天 |
| 数量成就 | 学习100张、500张、1000张；掌握50张、200张 |
| 科目成就 | 某个科目100%掌握、某科目全部学完 |
| 时间成就 | 单日学习超过2小时、一周内每天都有学习 |
| 社交成就 | 首次评论、首次投稿、投稿被采纳 |
| 特殊成就 | 纠错被采纳、帮助他人等 |

**徽章等级**：铜牌 → 银牌 → 金牌 → 钻石

#### 学习等级/经验值

| 等级 | 名称 | 所需经验 |
|------|------|----------|
| 1 | 入门学徒 | 0 |
| 2 | 初出茅庐 | 100 |
| 3 | 勤学苦练 | 300 |
| 4 | 小有所成 | 600 |
| 5 | 学富五车 | 1000 |
| 6 | 融会贯通 | 1500 |
| 7 | 登堂入室 | 2100 |
| 8 | 炉火纯青 | 2800 |
| 9 | 博学多才 | 3600 |
| 10 | 学贯中西 | 4500 |

**经验值获取**：
| 行为 | 经验值 |
|------|--------|
| 学习一张卡片（翻转背面） | +1 |
| 标记为"掌握" | +5 |
| 完成每日目标 | +10 |
| 完成每日掌握目标 | +15 |
| 连续3天完成目标 | +20 |
| 复习卡片 | +2 |
| 评论卡片 | +2 |
| 投稿被采纳 | +30 |
| 纠错被采纳 | +15 |

#### 排行榜

| 排行榜类型 | 展示内容 |
|-----------|----------|
| 总排行榜 | 按经验值/等级排名 |
| 周排行榜 | 本周学习数量排名 |
| 连续天数排行榜 | 学习连续天数排名 |

---

## 三、数据库设计

### 3.1 数据库表结构（6张新表）

```sql
-- =============================================
-- 激励系统数据库表结构
-- =============================================

-- 1. 成就定义表
CREATE TABLE IF NOT EXISTS `biz_achievement` (
  `achievement_id` bigint NOT NULL AUTO_INCREMENT COMMENT '成就ID',
  `achievement_code` varchar(64) NOT NULL COMMENT '成就代码(唯一标识)',
  `name` varchar(64) NOT NULL COMMENT '成就名称',
  `description` varchar(255) DEFAULT NULL COMMENT '成就描述',
  `icon` varchar(128) DEFAULT NULL COMMENT '成就图标(Unicode或SF Symbols)',
  `tier` tinyint NOT NULL DEFAULT 1 COMMENT '等级(1铜牌2银牌3金牌4钻石)',
  `category` varchar(32) NOT NULL COMMENT '分类(streak/count/subject/social)',
  `condition_type` varchar(32) NOT NULL COMMENT '条件类型(streak_days/learn_count/master_count/review_count/comment_count/contribute_count)',
  `condition_value` int NOT NULL DEFAULT 0 COMMENT '条件值',
  `exp_reward` int NOT NULL DEFAULT 0 COMMENT '奖励经验值',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '排序',
  `enabled` tinyint NOT NULL DEFAULT 1 COMMENT '是否启用(0禁用1启用)',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`achievement_id`),
  UNIQUE KEY `uk_code` (`achievement_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='成就定义表';

-- 2. 用户成就记录表
CREATE TABLE IF NOT EXISTS `biz_user_achievement` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `achievement_id` bigint NOT NULL COMMENT '成就ID',
  `achievement_code` varchar(64) NOT NULL COMMENT '成就代码',
  `achieved_at` datetime NOT NULL COMMENT '获得时间',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_achievement_id` (`achievement_id`),
  UNIQUE KEY `uk_user_achievement` (`user_id`, `achievement_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户成就记录表';

-- 3. 用户等级表
CREATE TABLE IF NOT EXISTS `biz_user_level` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `level` int NOT NULL DEFAULT 1 COMMENT '当前等级',
  `current_exp` int NOT NULL DEFAULT 0 COMMENT '当前等级经验',
  `total_exp` int NOT NULL DEFAULT 0 COMMENT '累计获得经验',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户等级表';

-- 4. 经验值变动日志表
CREATE TABLE IF NOT EXISTS `biz_exp_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `exp_change` int NOT NULL COMMENT '经验变化(正数增加)',
  `source_type` varchar(32) NOT NULL COMMENT '来源类型(STUDY/MASTER/REVIEW/GOAL/ACHIEVEMENT/COMMENT/CONTRIBUTE)',
  `source_id` varchar(64) DEFAULT NULL COMMENT '来源ID(如卡片ID)',
  `description` varchar(128) DEFAULT NULL COMMENT '变动描述',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='经验值变动日志表';

-- 5. 用户学习目标表
CREATE TABLE IF NOT EXISTS `biz_learning_goal` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `goal_type` varchar(16) NOT NULL COMMENT '目标类型(daily_learn/daily_master)',
  `target_count` int NOT NULL DEFAULT 20 COMMENT '目标数量',
  `enabled` tinyint NOT NULL DEFAULT 1 COMMENT '是否启用(0禁用1启用)',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_goal_type` (`user_id`, `goal_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户学习目标表';

-- 6. 每日目标完成记录表
CREATE TABLE IF NOT EXISTS `biz_goal_record` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `goal_date` date NOT NULL COMMENT '目标日期',
  `goal_type` varchar(16) NOT NULL COMMENT '目标类型',
  `target_count` int NOT NULL COMMENT '目标数量',
  `actual_count` int NOT NULL DEFAULT 0 COMMENT '实际完成',
  `completed` tinyint NOT NULL DEFAULT 0 COMMENT '是否完成(0未完成1完成)',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_date_type` (`user_id`, `goal_date`, `goal_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='每日目标完成记录表';

-- 7. 用户学习计数表(用于高效统计每日学习数)
CREATE TABLE IF NOT EXISTS `biz_user_daily_count` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `count_date` date NOT NULL COMMENT '统计日期',
  `learn_count` int NOT NULL DEFAULT 0 COMMENT '当日学习卡片数',
  `master_count` int NOT NULL DEFAULT 0 COMMENT '当日掌握卡片数',
  `review_count` int NOT NULL DEFAULT 0 COMMENT '当日复习卡片数',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_date` (`user_id`, `count_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户每日学习计数表';
```

### 3.2 初始成就数据

```sql
-- =============================================
-- 初始成就数据
-- =============================================

-- 学习入门类
INSERT INTO `biz_achievement` (`achievement_code`, `name`, `description`, `icon`, `tier`, `category`, `condition_type`, `condition_value`, `exp_reward`, `sort_order`) VALUES
('FIRST_LEARN', '初次学习', '完成第一次卡片学习', 'book.fill', 1, 'count', 'learn_count', 1, 10, 1),
('FIRST_MASTER', '初次掌握', '掌握第一张卡片', 'star.fill', 1, 'count', 'master_count', 1, 15, 2),
('FIRST_REVIEW', '初次复习', '完成第一次复习', 'arrow.clockwise', 1, 'count', 'review_count', 1, 5, 3),
('FIRST_COMMENT', '初发议论', '首次评论卡片', 'bubble.left.fill', 1, 'social', 'comment_count', 1, 10, 4);

-- 连续学习类
INSERT INTO `biz_achievement` (`achievement_code`, `name`, `description`, `icon`, `tier`, `category`, `condition_type`, `condition_value`, `exp_reward`, `sort_order`) VALUES
('STREAK_3', '初露锋芒', '连续学习3天', 'flame', 1, 'streak', 'streak_days', 3, 30, 10),
('STREAK_7', '持之以恒', '连续学习7天', 'flame.fill', 2, 'streak', 'streak_days', 7, 80, 11),
('STREAK_14', '坚持不懈', '连续学习14天', 'bolt.fill', 2, 'streak', 'streak_days', 14, 150, 12),
('STREAK_30', '锲而不舍', '连续学习30天', 'flame.circle.fill', 3, 'streak', 'streak_days', 30, 300, 13),
('STREAK_60', '悬梁刺股', '连续学习60天', 'crown.fill', 3, 'streak', 'streak_days', 60, 600, 14),
('STREAK_100', '学业有成', '连续学习100天', 'crown.circle.fill', 4, 'streak', 'streak_days', 100, 1000, 15);

-- 学习数量类
INSERT INTO `biz_achievement` (`achievement_code`, `name`, `description`, `icon`, `tier`, `category`, `condition_type`, `condition_value`, `exp_reward`, `sort_order`) VALUES
('LEARN_50', '学而时习', '累计学习50张卡片', 'book', 1, 'count', 'learn_count', 50, 30, 20),
('LEARN_100', '学而不厌', '累计学习100张卡片', 'books.vertical.fill', 1, 'count', 'learn_count', 100, 50, 21),
('LEARN_300', '力学笃行', '累计学习300张卡片', 'graduationcap.fill', 2, 'count', 'learn_count', 300, 150, 22),
('LEARN_500', '博学多识', '累计学习500张卡片', 'brain.head.profile', 2, 'count', 'learn_count', 500, 250, 23),
('LEARN_1000', '学富五车', '累计学习1000张卡片', 'book.circle.fill', 3, 'count', 'learn_count', 1000, 500, 24);

-- 掌握数量类
INSERT INTO `biz_achievement` (`achievement_code`, `name`, `description`, `icon`, `tier`, `category`, `condition_type`, `condition_value`, `exp_reward`, `sort_order`) VALUES
('MASTER_10', '初窥门径', '累计掌握10张卡片', 'star', 1, 'count', 'master_count', 10, 30, 30),
('MASTER_50', '小有所成', '累计掌握50张卡片', 'star.fill', 1, 'count', 'master_count', 50, 100, 31),
('MASTER_100', '融会贯通', '累计掌握100张卡片', 'star.circle.fill', 2, 'count', 'master_count', 100, 200, 32),
('MASTER_300', '学有小成', '累计掌握300张卡片', 'sparkles', 2, 'count', 'master_count', 300, 450, 33),
('MASTER_500', '学贯中西', '累计掌握500张卡片', 'star.square.fill', 3, 'count', 'master_count', 500, 750, 34);

-- 科目成就类
INSERT INTO `biz_achievement` (`achievement_code`, `name`, `description`, `icon`, `tier`, `category`, `condition_type`, `condition_value`, `exp_reward`, `sort_order`) VALUES
('SUBJECT_FIRST', '学科入门', '完成任意科目第一张卡片学习', 'bookmark.fill', 1, 'subject', 'subject_first', 1, 20, 40),
('SUBJECT_LEARN_ALL', '学无遗阙', '学习某科目全部卡片', 'checkmark.seal.fill', 2, 'subject', 'subject_learn_rate', 100, 200, 41),
('SUBJECT_MASTER_HALF', '半壁江山', '掌握某科目50%以上卡片', 'chart.pie.fill', 2, 'subject', 'subject_master_rate', 50, 150, 42),
('SUBJECT_MASTER_ALL', '学科全通', '掌握某科目全部卡片', 'checkmark.seal.circle.fill', 3, 'subject', 'subject_master_rate', 100, 500, 43);

-- 社交类
INSERT INTO `biz_achievement` (`achievement_code`, `name`, `description`, `icon`, `tier`, `category`, `condition_type`, `condition_value`, `exp_reward`, `sort_order`) VALUES
('FIRST_CONTRIBUTE', '初次投稿', '首次提交卡片', 'square.and.pencil', 1, 'social', 'contribute_count', 1, 30, 50),
('CONTRIBUTE_ADOPTED', '稿件采纳', '投稿被采纳', 'checkmark.circle.fill', 2, 'social', 'contribute_adopted', 1, 100, 51),
('FIRST_CORRECTION', '捉虫大师', '首次纠错被采纳', 'ant.fill', 1, 'social', 'correction_adopted', 1, 50, 52);
```

---

## 四、后端API设计

### 4.1 API接口清单

| 方法 | 路径 | 描述 | 认证 |
|------|------|------|------|
| GET | `/api/achievement/list` | 获取所有成就列表 | 是 |
| GET | `/api/achievement/user` | 获取用户已解锁成就 | 是 |
| POST | `/api/achievement/check` | 检查并解锁新成就 | 是 |
| GET | `/api/level/info` | 获取用户等级信息 | 是 |
| GET | `/api/level/exp-log` | 获取经验值日志 | 是 |
| GET | `/api/goal/current` | 获取当前目标设置 | 是 |
| POST | `/api/goal/set` | 设置学习目标 | 是 |
| GET | `/api/goal/progress` | 获取今日目标进度 | 是 |
| GET | `/api/goal/week` | 获取本周目标完成情况 | 是 |
| GET | `/api/rank/total` | 总排行榜 | 是 |
| GET | `/api/rank/week` | 周排行榜 | 是 |
| GET | `/api/rank/streak` | 连击排行榜 | 是 |
| GET | `/api/rank/user/{userId}` | 获取用户排名 | 是 |

### 4.2 API详细定义

#### 成就相关API

**GET /api/achievement/list**
```
描述: 获取所有成就列表（含用户解锁状态）

响应:
{
  "code": 200,
  "data": [
    {
      "achievementId": 1,
      "code": "FIRST_LEARN",
      "name": "初次学习",
      "description": "完成第一次卡片学习",
      "icon": "book.fill",
      "tier": 1,
      "category": "count",
      "unlocked": true,
      "achievedAt": "2025-05-05 10:30:00"
    }
  ]
}
```

**GET /api/achievement/user**
```
响应:
{
  "code": 200,
  "data": {
    "unlockedCount": 5,
    "totalCount": 30,
    "achievements": [...]
  }
}
```

**POST /api/achievement/check**
```
请求体: { "userId": 1, "actionType": "learn" }
响应: { "newAchievements": [], "totalExp": 150, "level": 3, "leveledUp": false }
```

#### 等级相关API

**GET /api/level/info**
```
响应:
{
  "code": 200,
  "data": {
    "level": 5,
    "levelName": "学富五车",
    "currentExp": 350,
    "totalExp": 1000,
    "nextLevelExp": 1500,
    "progressPercent": 70.0,
    "expToNextLevel": 150
  }
}
```

**GET /api/level/exp-log**
```
参数: pageNum, pageSize, startDate, endDate
响应: { "records": [...], "total": 100, "size": 20, "current": 1 }
```

#### 目标相关API

**GET /api/goal/current**
```
响应: { "dailyLearnTarget": 20, "dailyMasterTarget": 10, "enabled": true }
```

**POST /api/goal/set**
```
请求体: { "dailyLearnTarget": 30, "dailyMasterTarget": 15, "enabled": true }
```

**GET /api/goal/progress**
```
响应:
{
  "date": "2025-05-05",
  "learnProgress": 15,
  "learnTarget": 20,
  "learnCompleted": false,
  "learnPercent": 75.0,
  "masterProgress": 8,
  "masterTarget": 10,
  "masterCompleted": false,
  "masterPercent": 80.0
}
```

**GET /api/goal/week**
```
响应: [{ "date": "2025-05-05", "weekday": "周一", "learnCompleted": true, "masterCompleted": true }, ...]
```

#### 排行榜相关API

**GET /api/rank/total**
```
响应: { "records": [{ "rank": 1, "userId": 1, "nickname": "学习达人", "level": 8, "levelName": "炉火纯青", "totalExp": 2800 }], "total": 1000 }
```

**GET /api/rank/week** - 同上，字段为 weekLearnCount
**GET /api/rank/streak** - 同上，字段为 currentStreak

**GET /api/rank/user/{userId}**
```
响应: { "totalRank": 15, "totalTotalExp": 1500, "weekRank": 8, "weekLearnCount": 45, "streakRank": 3, "currentStreak": 30 }
```

---

## 五、后端实体类设计

### 5.1 Entity

| 文件 | 字段 |
|------|------|
| `BizAchievement.java` | achievementId, achievementCode, name, description, icon, tier, category, conditionType, conditionValue, expReward, sortOrder, enabled |
| `BizUserAchievement.java` | id, userId, achievementId, achievementCode, achievedAt |
| `BizUserLevel.java` | id, userId, level, currentExp, totalExp |
| `BizExpLog.java` | id, userId, expChange, sourceType, sourceId, description |
| `BizLearningGoal.java` | id, userId, goalType, targetCount, enabled |
| `BizGoalRecord.java` | id, userId, goalDate, goalType, targetCount, actualCount, completed |
| `BizUserDailyCount.java` | id, userId, countDate, learnCount, masterCount, reviewCount |

### 5.2 VO

| 文件 | 字段 |
|------|------|
| `AchievementVO.java` | achievementId, code, name, description, icon, tier, category, unlocked, achievedAt |
| `UserLevelVO.java` | level, levelName, currentExp, nextLevelExp, progressPercent, totalExp |
| `ExpLogVO.java` | id, expChange, sourceType, description, createTime |
| `LearningGoalVO.java` | dailyLearnTarget, dailyMasterTarget, enabled |
| `GoalProgressVO.java` | date, learnProgress, learnTarget, learnCompleted, masterProgress, masterTarget, masterCompleted |
| `RankVO.java` | rank, userId, nickname, avatar, level, levelName, totalExp, weekLearnCount, currentStreak |

### 5.3 DTO

| 文件 | 字段 |
|------|------|
| `AchievementCheckDTO.java` | userId, actionType |
| `AwardExpDTO.java` | userId, exp, sourceType, sourceId, description |
| `GoalSetDTO.java` | dailyLearnTarget, dailyMasterTarget, enabled |

---

## 六、iOS端详细设计

### 6.1 文件结构

```
card-ios/CardLearn/
├── Services/
│   └── IncentiveApiService.swift    # 激励系统API服务
├── Models/
│   └── IncentiveModels.swift        # 激励系统模型
├── Views/
│   ├── IncentiveCenterView.swift    # 激励中心首页
│   ├── AchievementView.swift        # 成就页面
│   ├── AchievementDetailView.swift  # 成就详情弹窗
│   ├── RankListView.swift          # 排行榜页面
│   ├── GoalSettingView.swift       # 目标设置页面
│   ├── ExpLogView.swift            # 经验明细页面
│   └── ProfileView.swift           # 修改：添加激励中心入口
├── Config/
│   └── AppConstants.swift           # 修改：添加激励相关颜色
└── CardLearnApp.swift              # 修改：AppState添加激励数据
```

### 6.2 Swift Models

```swift
// IncentiveModels.swift

import Foundation

// MARK: - 成就相关模型

struct Achievement: Codable, Identifiable {
    let achievementId: Int
    let code: String
    let name: String
    let description: String?
    let icon: String?
    let tier: Int           // 1铜 2银 3金 4钻
    let category: String
    let unlocked: Bool
    let achievedAt: String?
    
    var id: Int { achievementId }
    
    var tierName: String {
        switch tier {
        case 1: return "铜牌"
        case 2: return "银牌"
        case 3: return "金牌"
        case 4: return "钻石"
        default: return "普通"
        }
    }
    
    var tierColor: String {
        switch tier {
        case 1: return "CD7F32"      // 铜色
        case 2: return "C0C0C0"      // 银色
        case 3: return "FFD700"      // 金色
        case 4: return "B9F2FF"      // 钻石蓝
        default: return "9E9E9E"
        }
    }
}

struct AchievementListResponse: Codable {
    let unlockedCount: Int
    let totalCount: Int
    let achievements: [Achievement]
}

struct AchievementCheckResponse: Codable {
    let newAchievements: [Achievement]
    let totalExp: Int
    let level: Int
    let leveledUp: Bool
}

// MARK: - 等级相关模型

struct UserLevel: Codable {
    let level: Int
    let levelName: String
    let currentExp: Int
    let totalExp: Int
    let nextLevelExp: Int
    let progressPercent: Double
    let expToNextLevel: Int
}

struct ExpLog: Codable, Identifiable {
    let id: Int
    let expChange: Int
    let sourceType: String
    let sourceId: String?
    let description: String?
    let createTime: String
    
    var sourceIcon: String {
        switch sourceType {
        case "STUDY": return "book.fill"
        case "MASTER": return "star.fill"
        case "REVIEW": return "arrow.clockwise"
        case "GOAL": return "target"
        case "ACHIEVEMENT": return "trophy.fill"
        case "COMMENT": return "bubble.left.fill"
        case "CONTRIBUTE": return "square.and.pencil"
        default: return "plus.circle.fill"
        }
    }
}

// MARK: - 目标相关模型

struct LearningGoal: Codable {
    let dailyLearnTarget: Int
    let dailyMasterTarget: Int
    let enabled: Bool
}

struct GoalProgress: Codable {
    let date: String
    let learnProgress: Int
    let learnTarget: Int
    let learnCompleted: Bool
    let learnPercent: Double
    let masterProgress: Int
    let masterTarget: Int
    let masterCompleted: Bool
    let masterPercent: Double
}

struct WeekGoalRecord: Codable, Identifiable {
    let date: String
    let weekday: String
    let learnCompleted: Bool
    let masterCompleted: Bool
    
    var id: String { date }
}

struct GoalSetRequest: Codable {
    var dailyLearnTarget: Int?
    var dailyMasterTarget: Int?
    var enabled: Bool?
}

// MARK: - 排行榜相关模型

struct RankItem: Codable, Identifiable {
    let rank: Int
    let userId: Int
    let nickname: String
    let avatar: String?
    let level: Int
    let levelName: String
    let totalExp: Int?
    let weekLearnCount: Int?
    let currentStreak: Int?
    let badge: String?
    
    var id: Int { rank }
}

struct RankPosition: Codable {
    let userId: Int
    let totalRank: Int?
    let totalTotalExp: Int?
    let weekRank: Int?
    let weekLearnCount: Int?
    let streakRank: Int?
    let currentStreak: Int?
}

// MARK: - 枚举

enum AchievementCategory: String, CaseIterable {
    case all = "全部"
    case streak = "连续"
    case count = "数量"
    case subject = "科目"
    case social = "社交"
    case unlocked = "已解锁"
    case locked = "未解锁"
}

enum RankType: String, CaseIterable {
    case total = "总榜"
    case week = "周榜"
    case streak = "连击榜"
}
```

### 6.3 API Service

```swift
// IncentiveApiService.swift

import Foundation

final class IncentiveApiService: BaseApiService {
    static let shared = IncentiveApiService()
    
    // MARK: - 成就API
    
    func getAchievementList() async throws -> [Achievement] {
        let response: APIResponse<[Achievement]> = try await get(url: buildUrl(path: "/api/achievement/list"))
        guard response.code == 200, let data = response.data else {
            throw APIError.serverError(response.message ?? "获取成就列表失败")
        }
        return data
    }
    
    func getUserAchievements() async throws -> AchievementListResponse {
        let response: APIResponse<AchievementListResponse> = try await get(url: buildUrl(path: "/api/achievement/user"))
        guard response.code == 200, let data = response.data else {
            throw APIError.serverError(response.message ?? "获取用户成就失败")
        }
        return data
    }
    
    func checkAchievement(userId: Int, actionType: String) async throws -> AchievementCheckResponse {
        var urlComponents = URLComponents(string: buildUrl(path: "/api/achievement/check"))!
        urlComponents.queryItems = [
            URLQueryItem(name: "userId", value: String(userId)),
            URLQueryItem(name: "actionType", value: actionType)
        ]
        let response: APIResponse<AchievementCheckResponse> = try await get(url: urlComponents.url!)
        guard response.code == 200, let data = response.data else {
            throw APIError.serverError(response.message ?? "检查成就失败")
        }
        return data
    }
    
    // MARK: - 等级API
    
    func getLevelInfo() async throws -> UserLevel {
        let response: APIResponse<UserLevel> = try await get(url: buildUrl(path: "/api/level/info"))
        guard response.code == 200, let data = response.data else {
            throw APIError.serverError(response.message ?? "获取等级信息失败")
        }
        return data
    }
    
    func getExpLog(pageNum: Int = 1, pageSize: Int = 20, startDate: String? = nil, endDate: String? = nil) async throws -> PageResponse<ExpLog> {
        var urlComponents = URLComponents(string: buildUrl(path: "/api/level/exp-log"))!
        var queryItems = [
            URLQueryItem(name: "pageNum", value: String(pageNum)),
            URLQueryItem(name: "pageSize", value: String(pageSize))
        ]
        if let start = startDate { queryItems.append(URLQueryItem(name: "startDate", value: start)) }
        if let end = endDate { queryItems.append(URLQueryItem(name: "endDate", value: end)) }
        urlComponents.queryItems = queryItems
        
        let response: APIResponse<PageResponse<ExpLog>> = try await get(url: urlComponents.url!)
        guard response.code == 200, let data = response.data else {
            throw APIError.serverError(response.message ?? "获取经验日志失败")
        }
        return data
    }
    
    // MARK: - 目标API
    
    func getCurrentGoal() async throws -> LearningGoal {
        let response: APIResponse<LearningGoal> = try await get(url: buildUrl(path: "/api/goal/current"))
        guard response.code == 200, let data = response.data else {
            throw APIError.serverError(response.message ?? "获取目标失败")
        }
        return data
    }
    
    func setGoal(request: GoalSetRequest) async throws -> LearningGoal {
        var urlComponents = URLComponents(string: buildUrl(path: "/api/goal/set"))!
        var queryItems: [URLQueryItem] = []
        if let learn = request.dailyLearnTarget { queryItems.append(URLQueryItem(name: "dailyLearnTarget", value: String(learn))) }
        if let master = request.dailyMasterTarget { queryItems.append(URLQueryItem(name: "dailyMasterTarget", value: String(master))) }
        if let enabled = request.enabled { queryItems.append(URLQueryItem(name: "enabled", value: String(enabled))) }
        urlComponents.queryItems = queryItems.isEmpty ? nil : queryItems
        
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = "POST"
        
        let response: APIResponse<LearningGoal> = try await post(urlRequest)
        guard response.code == 200, let data = response.data else {
            throw APIError.serverError(response.message ?? "设置目标失败")
        }
        return data
    }
    
    func getGoalProgress() async throws -> GoalProgress {
        let response: APIResponse<GoalProgress> = try await get(url: buildUrl(path: "/api/goal/progress"))
        guard response.code == 200, let data = response.data else {
            throw APIError.serverError(response.message ?? "获取目标进度失败")
        }
        return data
    }
    
    func getWeekGoalProgress() async throws -> [WeekGoalRecord] {
        let response: APIResponse<[WeekGoalRecord]> = try await get(url: buildUrl(path: "/api/goal/week"))
        guard response.code == 200, let data = response.data else {
            throw APIError.serverError(response.message ?? "获取周目标失败")
        }
        return data
    }
    
    // MARK: - 排行榜API
    
    func getTotalRank(pageNum: Int = 1, pageSize: Int = 20) async throws -> PageResponse<RankItem> {
        var urlComponents = URLComponents(string: buildUrl(path: "/api/rank/total"))!
        urlComponents.queryItems = [
            URLQueryItem(name: "pageNum", value: String(pageNum)),
            URLQueryItem(name: "pageSize", value: String(pageSize))
        ]
        let response: APIResponse<PageResponse<RankItem>> = try await get(url: urlComponents.url!)
        guard response.code == 200, let data = response.data else {
            throw APIError.serverError(response.message ?? "获取排行榜失败")
        }
        return data
    }
    
    func getWeekRank(pageNum: Int = 1, pageSize: Int = 20) async throws -> PageResponse<RankItem> {
        var urlComponents = URLComponents(string: buildUrl(path: "/api/rank/week"))!
        urlComponents.queryItems = [
            URLQueryItem(name: "pageNum", value: String(pageNum)),
            URLQueryItem(name: "pageSize", value: String(pageSize))
        ]
        let response: APIResponse<PageResponse<RankItem>> = try await get(url: urlComponents.url!)
        guard response.code == 200, let data = response.data else {
            throw APIError.serverError(response.message ?? "获取周榜失败")
        }
        return data
    }
    
    func getStreakRank(pageNum: Int = 1, pageSize: Int = 20) async throws -> PageResponse<RankItem> {
        var urlComponents = URLComponents(string: buildUrl(path: "/api/rank/streak"))!
        urlComponents.queryItems = [
            URLQueryItem(name: "pageNum", value: String(pageNum)),
            URLQueryItem(name: "pageSize", value: String(pageSize))
        ]
        let response: APIResponse<PageResponse<RankItem>> = try await get(url: urlComponents.url!)
        guard response.code == 200, let data = response.data else {
            throw APIError.serverError(response.message ?? "获取连击榜失败")
        }
        return data
    }
    
    func getUserRank(userId: Int) async throws -> RankPosition {
        let response: APIResponse<RankPosition> = try await get(url: buildUrl(path: "/api/rank/user/\(userId)"))
        guard response.code == 200, let data = response.data else {
            throw APIError.serverError(response.message ?? "获取用户排名失败")
        }
        return data
    }
    
    private func buildUrl(path: String) -> URL {
        URL(string: EnvConfig.config.getApiUrl(path: path))!
    }
}
```

### 6.4 页面布局说明

#### IncentiveCenterView（激励中心首页）
- 顶部：用户等级卡片（当前等级、经验进度条、下一级目标）
- 今日目标进度（两个环形进度：学习目标、掌握目标）
- 本周目标完成日历（7个小格子，完成的变绿）
- 成就入口（横向滚动展示最近获得的成就）
- 排行榜入口（总榜/周榜/连击榜排名预览）

#### AchievementView（成就页面）
- 顶部Tab：全部 / 已解锁 / 未解锁
- 成就网格（每行3个），按分类分组
- 点击成就显示详情弹窗

#### RankListView（排行榜页面）
- 顶部Tab：总榜 / 周榜 / 连击榜
- 当前用户排名置顶显示
- 列表项：排名 + 头像 + 昵称 + 等级 + 对应指标

#### GoalSettingView（目标设置页面）
- 每日学习目标：滑动条 5-100张
- 每日掌握目标：滑动条 5-50张
- 开启/关闭提醒

#### ExpLogView（经验明细页面）
- 经验值变动列表（来源图标 + 描述 + 经验变化 + 时间）

---

## 七、Web管理端详细设计

### 7.1 文件结构

```
card-ui/src/
├── api/
│   ├── incentive.ts          # 激励系统API
│   └── types.ts              # 修改：添加激励相关类型
├── views/
│   ├── layout/index.vue      # 修改：添加激励管理菜单
│   ├── incentive/            # 激励管理模块
│   │   ├── dashboard/index.vue    # 激励仪表盘
│   │   ├── achievement/index.vue # 成就管理
│   │   ├── level/index.vue        # 等级管理
│   │   ├── goal/index.vue         # 目标管理
│   │   └── rank/index.vue         # 排行榜
└── router/index.ts               # 修改：添加激励路由
```

### 7.2 API服务

```typescript
// src/api/incentive.ts

import request from './request'
import type { PageResult } from './types'

// ========== 类型定义 ==========

export interface Achievement {
  achievementId: number
  code: string
  name: string
  description: string
  icon: string
  tier: number
  category: string
  unlocked: boolean
  achievedAt: string
}

export interface AchievementListResponse {
  unlockedCount: number
  totalCount: number
  achievements: Achievement[]
}

export interface UserLevel {
  level: number
  levelName: string
  currentExp: number
  totalExp: number
  nextLevelExp: number
  progressPercent: number
  expToNextLevel: number
}

export interface ExpLog {
  id: number
  expChange: number
  sourceType: string
  sourceId: string
  description: string
  createTime: string
}

export interface LearningGoal {
  dailyLearnTarget: number
  dailyMasterTarget: number
  enabled: boolean
}

export interface RankItem {
  rank: number
  userId: number
  nickname: string
  avatar: string
  level: number
  levelName: string
  totalExp: number
  weekLearnCount: number
  currentStreak: number
  badge: string
}

// ========== 成就相关API ==========

export const getAchievementList = () => {
  return request.get<any, AchievementListResponse>('/api/achievement/list')
}

export const getUserAchievementPage = (params: { 
  userId?: number
  achievementId?: number
  pageNum: number
  pageSize: number 
}) => {
  return request.get<any, PageResult<any>>('/api/achievement/user/page', { params })
}

export const getAchievementStats = () => {
  return request.get<any, { totalUnlock: number, todayUnlock: number, byTier: any[] }>('/api/achievement/stats')
}

// ========== 等级相关API ==========

export const getUserLevelPage = (params: { 
  level?: number
  pageNum: number
  pageSize: number 
}) => {
  return request.get<any, PageResult<UserLevel>>('/api/level/page', { params })
}

export const getLevelDistribution = () => {
  return request.get<any, { level: number, count: number, name: string }[]>('/api/level/distribution')
}

export const getExpLogPage = (params: { 
  userId?: number
  sourceType?: string
  startDate?: string
  endDate?: string
  pageNum: number
  pageSize: number 
}) => {
  return request.get<any, PageResult<ExpLog>>('/api/level/exp-log', { params })
}

// ========== 目标相关API ==========

export const getGoalPage = (params: { 
  userId?: number
  enabled?: boolean
  pageNum: number
  pageSize: number 
}) => {
  return request.get<any, PageResult<LearningGoal>>('/api/goal/page', { params })
}

export const getGoalCompletionStats = (params?: { startDate?: string; endDate?: string }) => {
  return request.get<any, { totalUsers: number, activeUsers: number, completionRate: number }>('/api/goal/stats', { params })
}

// ========== 排行榜API ==========

export const getTotalRank = (params: { pageNum: number; pageSize: number }) => {
  return request.get<any, PageResult<RankItem>>('/api/rank/total', { params })
}

export const getWeekRank = (params: { pageNum: number; pageSize: number }) => {
  return request.get<any, PageResult<RankItem>>('/api/rank/week', { params })
}

export const getStreakRank = (params: { pageNum: number; pageSize: number }) => {
  return request.get<any, PageResult<RankItem>>('/api/rank/streak', { params })
}

export const getRankOverview = () => {
  return request.get<any, { topUser: RankItem; avgExp: number; topStreak: number }>('/api/rank/overview')
}
```

### 7.3 路由配置

```typescript
// src/router/index.ts 添加

{
  path: 'incentive',
  name: 'Incentive',
  redirect: '/incentive/dashboard',
  meta: { title: '激励管理' },
  children: [
    {
      path: 'dashboard',
      name: 'IncentiveDashboard',
      component: () => import('@/views/incentive/dashboard/index.vue'),
      meta: { title: '激励仪表盘' }
    },
    {
      path: 'achievement',
      name: 'IncentiveAchievement',
      component: () => import('@/views/incentive/achievement/index.vue'),
      meta: { title: '成就管理' }
    },
    {
      path: 'level',
      name: 'IncentiveLevel',
      component: () => import('@/views/incentive/level/index.vue'),
      meta: { title: '等级管理' }
    },
    {
      path: 'goal',
      name: 'IncentiveGoal',
      component: () => import('@/views/incentive/goal/index.vue'),
      meta: { title: '目标管理' }
    },
    {
      path: 'rank',
      name: 'IncentiveRank',
      component: () => import('@/views/incentive/rank/index.vue'),
      meta: { title: '排行榜' }
    }
  ]
}
```

### 7.4 菜单配置

```vue
<!-- src/views/layout/index.vue 添加菜单 -->

<el-sub-menu index="incentive">
  <template #title>
    <el-icon><Trophy /></el-icon>
    <span>激励管理</span>
  </template>
  <el-menu-item index="/incentive/dashboard">激励仪表盘</el-menu-item>
  <el-menu-item index="/incentive/achievement">成就管理</el-menu-item>
  <el-menu-item index="/incentive/level">等级管理</el-menu-item>
  <el-menu-item index="/incentive/goal">目标管理</el-menu-item>
  <el-menu-item index="/incentive/rank">排行榜</el-menu-item>
</el-sub-menu>
```

### 7.5 页面说明

#### incentive/dashboard/index.vue（激励仪表盘）
- 顶部统计卡片（成就总数、已解锁、用户总数、人均经验）
- 用户等级分布饼图
- 各等级成就解锁率
- 经验值排行榜TOP10
- 目标完成情况柱状图

#### incentive/achievement/index.vue（成就管理）
- 筛选条件（分类、等级、状态）
- 统计概览（总数、已解锁、今日新增、解锁率）
- 成就列表（图标、名称、等级、分类、条件值、奖励经验、解锁情况）
- 详情弹窗

#### incentive/level/index.vue（等级管理）
- 等级配置概览（10级展示）
- 用户等级列表（排名、用户、等级、进度、累计经验）

#### incentive/goal/index.vue（目标管理）
- 统计卡片（总用户、活跃用户、平均目标、完成率）
- 用户目标列表（目标设置、今日进度、完成状态）

#### incentive/rank/index.vue（排行榜）
- 排行榜类型切换（总榜/周榜/连击榜）
- TOP3用户展示（皇冠样式）
- 排行榜列表

---

## 八、实现工作量估算

### 8.1 后端

| 功能 | 工作量 |
|------|--------|
| 数据库表创建 + 初始数据 | 0.5天 |
| 经验值核心Service | 1天 |
| 成就检查逻辑 | 1天 |
| 等级/经验API | 0.5天 |
| 目标API | 0.5天 |
| 排行榜API | 0.5天 |
| 经验明细API | 0.5天 |
| **后端小计** | **4.5天** |

### 8.2 iOS端

| 功能 | 工作量 |
|------|--------|
| Models定义 | 0.5天 |
| API Service | 0.5天 |
| 激励中心首页 | 1天 |
| 成就页面 + 详情 | 1天 |
| 排行榜页面 | 0.5天 |
| 目标设置页面 | 0.5天 |
| 经验明细页面 | 0.5天 |
| Profile入口修改 | 0.25天 |
| **iOS小计** | **4.75天** |

### 8.3 Web管理端

| 功能 | 工作量 |
|------|--------|
| API服务 + 类型定义 | 0.5天 |
| 路由/菜单配置 | 0.25天 |
| 激励仪表盘 | 1天 |
| 成就管理 | 1天 |
| 等级管理 | 0.75天 |
| 目标管理 | 0.75天 |
| 排行榜 | 0.75天 |
| **Web小计** | **5天** |

### 8.4 完整工期

| 阶段 | 后端 | iOS | Web |
|------|------|-----|-----|
| Phase 1: 数据库 + 基础 | 1.5天 | 0.5天 | 0.5天 |
| Phase 2: 经验值 + 等级 | 1.5天 | 1天 | 1天 |
| Phase 3: 成就系统 | 1.5天 | 1.5天 | 1.5天 |
| Phase 4: 目标系统 | 1天 | 1天 | 1天 |
| Phase 5: 排行榜 | 1天 | 0.75天 | 1天 |
| **总计** | **6.5天** | **4.75天** | **5天** |

---

## 九、触发点说明

在 `LearningServiceImpl.submitSimpleReview()` 方法中，添加：

```java
// 学习完成后
awardExp(userId, 1, "STUDY", cardId, "学习卡片");
// 如果status=2(掌握)
if (status == 2) {
    awardExp(userId, 5, "MASTER", cardId, "掌握卡片");
    checkAchievement(userId, "master");
}
checkAchievement(userId, "learn");
```

---

## 十、后续可扩展功能

1. **智能学习** - 基于薄弱点的专项训练、错题本
2. **模拟考试** - 自测卷、限时答题、成绩分析
3. **社交学习** - 小组、关注、心得分享
4. **推送通知** - 复习提醒、目标完成提醒
5. **学习日历** - 可视化学习时间线
