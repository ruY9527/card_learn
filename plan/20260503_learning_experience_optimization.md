# 学习体验优化方案 - Web端与iOS端迭代计划

## 项目背景

**目标**：基于现有 408 知识点学习卡片系统，进行 Web 端和 iOS 端的同步迭代，重点优化学习体验

**约束**：
- 后端技术栈保持不变
- 小程序端暂不迭代
- Web 端和 iOS 端同步开发
- iOS 端偏好 SwiftUI（不使用跨端方案如 Flutter）

---

## 一、现状分析

### 1.1 当前学习模块的不足

| 问题 | 说明 |
|------|------|
| 艾宾浩斯算法过于简化 | 固定 3 天/7 天间隔，非自适应 |
| 无复习提醒机制 | 用户依赖主动学习，无推送通知 |
| 无离线学习能力 | 必须在线才能学习 |
| 学习数据单一 | 只有状态和间隔，无多维度分析 |
| 无个性化学习路径 | 所有用户相同推荐 |
| 无连续学习激励 | 无 Streak 等 gamification 元素 |

### 1.2 优化方向

- **P0**：SM-2 自适应算法、深色模式、离线学习
- **P1**：推送通知、学习统计、Streak 系统
- **P2**：Widget、数据同步、收藏夹

---

## 二、Web 端（card-ui）优化

### 2.1 功能清单

| 功能 | 优先级 | 工作量 | 说明 |
|------|--------|--------|------|
| 深色模式 | P0 | 1天 | CSS 变量 + Element Plus 适配 |
| Markdown 实时预览 | P0 | 2天 | marked + highlight.js |
| 批量导入/导出 | P1 | 5天 | Excel 导入导出 |
| 学习数据看板 | P1 | 4天 | ECharts 热力图、雷达图 |
| 收藏夹功能 | P2 | 3天 | 卡片组合收藏 |

### 2.2 深色模式实现

#### 文件变更

```
card-ui/src/
├── styles/
│   ├── variables.scss      # 新增：CSS 变量定义
│   └── dark-theme.scss     # 新增：深色主题变量覆盖
├── composables/
│   └── useTheme.ts         # 新增：主题切换逻辑
└── App.vue                 # 修改：挂载主题状态
```

#### 核心实现

```typescript
// useTheme.ts
export const useTheme = () => {
  const isDark = ref(false)

  const toggleTheme = () => {
    isDark.value = !isDark.value
    applyTheme(isDark.value)
    localStorage.setItem('theme', isDark.value ? 'dark' : 'light')
  }

  const applyTheme = (dark: boolean) => {
    document.documentElement.setAttribute(
      'data-theme',
      dark ? 'dark' : 'light'
    )
  }

  onMounted(() => {
    const saved = localStorage.getItem('theme')
    if (saved) {
      isDark.value = saved === 'dark'
      applyTheme(isDark.value)
    }
  })

  return { isDark, toggleTheme }
}
```

#### Element Plus 适配

```scss
// dark-theme.scss
html[data-theme="dark"] {
  --el-bg-color: #1a1a1a;
  --el-text-color-primary: #e5eaf3;
  --el-border-color: #4a4a4a;
}
```

### 2.3 Markdown 编辑器实时预览

#### 新增依赖

```json
{
  "dependencies": {
    "marked": "^12.0.0",
    "highlight.js": "^11.9.0",
    "katex": "^0.16.9"
  }
}
```

#### 组件结构

```
card-ui/src/components/
└── MarkdownEditor/
    ├── index.vue           # 主组件
    ├── EditorPane.vue      # 编辑区
    └── PreviewPane.vue     # 预览区
```

#### 核心实现

```vue
<!-- MarkdownEditor/index.vue -->
<template>
  <div class="markdown-editor">
    <div class="editor-pane">
      <textarea v-model="content" @input="handleInput" />
    </div>
    <div class="preview-pane">
      <div v-html="renderedContent" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { marked } from 'marked'
import hljs from 'highlight.js'

marked.setOptions({
  highlight: (code, lang) => {
    if (lang && hljs.getLanguage(lang)) {
      return hljs.highlight(code, { language: lang }).value
    }
    return code
  }
})

const content = ref('')
const renderedContent = computed(() => marked.parse(content.value))
</script>
```

### 2.4 批量导入/导出

#### Excel 模板格式

| front_content | back_content | subject_name | difficulty | tags |
|---------------|--------------|--------------|------------|------|
| 什么是时间复杂度？ | 表示算法执行时间与输入规模的关系... | 数据结构 | 2 | 复杂度;基础 |

#### 新增 API

```java
@PostMapping("/import")
public Result<ImportResultVO> importCards(@RequestParam("file") MultipartFile file)

@PostMapping("/import/confirm")
public Result<Integer> confirmImport(@RequestBody ImportConfirmDTO dto)

@GetMapping("/export")
public void exportCards(@RequestParam(required = false) Long subjectId,
                        HttpServletResponse response)
```

### 2.5 学习数据看板

#### 页面位置

`card-ui/src/views/stats/learning-dashboard/index.vue`

#### 图表类型

| 图表 | 类型 | 数据源 |
|------|------|--------|
| 热力图 | ECharts calendar | 用户每日学习活跃度 |
| 雷达图 | ECharts radar | 各科目掌握度对比 |
| 柱状图 | ECharts bar | 科目卡片数量 vs 已学 |
| 折线图 | ECharts line | 学习趋势 7天/30天 |

#### SQL 查询

```sql
-- 热力图数据
SELECT
    DATE(p.update_time) as date,
    COUNT(DISTINCT p.user_id) as userCount,
    COUNT(*) as studyCount
FROM biz_study_history p
WHERE p.update_time >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
GROUP BY DATE(p.update_time)

-- 科目卡片总数（纯计数，不做计算）
SELECT
    s.subject_id,
    s.subject_name,
    COUNT(c.card_id) as totalCards
FROM biz_subject s
LEFT JOIN biz_card c ON s.subject_id = c.subject_id AND c.del_flag = '0'
GROUP BY s.subject_id, s.subject_name

-- 科目学习进度（按状态分组统计，纯计数）
SELECT
    c.subject_id,
    p.status,
    COUNT(*) as count
FROM biz_card c
INNER JOIN biz_user_progress p ON c.card_id = p.card_id
WHERE c.del_flag = '0'
GROUP BY c.subject_id, p.status
```

#### Java 计算逻辑

```java
// Service 层计算科目掌握度
public List<SubjectMasteryVO> getSubjectMastery() {
    // 1. 查询各科目卡片总数
    List<SubjectTotalVO> totals = subjectMapper.selectSubjectCardTotals();

    // 2. 查询各科目各状态进度数
    List<SubjectStatusCountVO> statusCounts = progressMapper.selectSubjectStatusCounts();

    // 3. Java 代码计算掌握度（避免SQL计算）
    Map<Long, SubjectTotalVO> totalMap = totals.stream()
        .collect(Collectors.toMap(SubjectTotalVO::getSubjectId, t -> t));

    Map<Long, Map<Integer, Integer>> statusMap = statusCounts.stream()
        .collect(Collectors.groupingBy(
            SubjectStatusCountVO::getSubjectId,
            Collectors.toMap(SubjectStatusCountVO::getStatus, SubjectStatusCountVO::getCount)
        ));

    List<SubjectMasteryVO> result = new ArrayList<>();
    for (SubjectTotalVO total : totals) {
        SubjectMasteryVO vo = new SubjectMasteryVO();
        vo.setSubjectId(total.getSubjectId());
        vo.setSubjectName(total.getSubjectName());
        vo.setTotalCards(total.getTotalCards());

        Map<Integer, Integer> statusCount = statusMap.getOrDefault(total.getSubjectId(), Map.of());
        int masteredCount = statusCount.getOrDefault(2, 0);
        int learnedCount = statusCount.getOrDefault(1, 0) + masteredCount;

        vo.setMasteredCount(masteredCount);
        vo.setLearnedCount(learnedCount);

        // 计算掌握率（在Java中计算，不在SQL中）
        if (total.getTotalCards() > 0) {
            double masteryRate = Math.round(masteredCount * 1000.0 / total.getTotalCards()) / 10.0;
            vo.setMasteryRate(masteryRate);
        } else {
            vo.setMasteryRate(0.0);
        }

        result.add(vo);
    }
    return result;
}
```

#### 优化说明

| 优化点 | 原方案 | 优化后 |
|--------|--------|--------|
| 掌握度计算 | SQL CASE WHEN + ROUND | Java 计算 |
| 状态统计 | LEFT JOIN 后聚合 | 独立查询按 status GROUP BY |
| 索引命中 | 复杂 JOIN 无法命中索引 | 简单 GROUP BY 可命中索引 |
| 可维护性 | 计算逻辑分散在 SQL | 集中到 Java Service |

---

## 三、iOS 端（SwiftUI）开发

### 3.1 现有技术栈

基于 `card-ios` 项目现有架构：

| 组件 | 技术 | 说明 |
|------|------|------|
| UI框架 | SwiftUI | 现有Views/下均为SwiftUI组件 |
| 网络层 | 现有APIService | URLSession + JSONDecoder + 重试机制 |
| 数据模型 | 现有Models.swift | Codable模型 |
| 存储 | UserDefaults | 现有AppConstants.swift |
| 样式 | 现有AppColor | 颜色常量定义 |

### 3.2 项目结构（增量开发）

在现有 `card-ios/CardLearn/` 基础上增量开发：

```
CardLearn/
├── Services/
│   └── APIService.swift       # 扩展：新增SM-2相关API
├── Models/
│   └── Models.swift           # 扩展：新增SM-2相关模型
├── Core/
│   └── SM2Algorithm.swift     # 新增：SM-2 间隔重复算法
├── Views/
│   ├── StudyView.swift        # 改造：增加翻转学习模式
│   ├── CardFlipView.swift     # 新增：翻转卡片组件
│   ├── QualityRatingView.swift # 新增：质量评分组件
│   ├── ReviewListView.swift   # 新增：复习计划列表
│   ├── StatsView.swift        # 新增：学习统计
│   └── StreakView.swift       # 新增：连续学习激励
└── ViewModels/
    ├── StudyViewModel.swift   # 新增：学习ViewModel
    └── StatsViewModel.swift   # 新增：统计ViewModel
```

**说明**：
- 复用现有 `APIService.swift`、`Models.swift`、`AppConstants.swift`
- 新增组件遵循现有代码风格（组件化、颜色常量复用）
- 不引入新依赖，不创建新数据库

### 3.2 SM-2 算法实现

#### 算法原理

SM-2 是真正的自适应间隔重复算法，根据用户每次复习的表现动态调整下次复习间隔。

#### 核心公式

```
EF' = EF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
EF = max(1.3, EF)

间隔计算：
- 第 1 次正确：1 天
- 第 2 次正确：6 天
- 第 3+ 次正确：interval * EF
- 错误时：重置为 1 天
```

#### SM2Algorithm.swift（新增文件）

```swift
import Foundation

/// SM-2 间隔重复算法
/// 复用现有 Models.swift 中的 Codable 风格
struct SM2Result: Codable {
    var interval: Int           // 下次间隔天数
    var easeFactor: Double      // 容易系数
    var repetitions: Int         // 连续正确次数
    var nextReviewDate: Date    // 下次复习日期

    static var initial: SM2Result {
        SM2Result(interval: 1, easeFactor: 2.5, repetitions: 0, nextReviewDate: Date())
    }
}

/// 复习质量评分
enum ReviewQuality: Int, Codable, CaseIterable {
    case blackout = 0           // 完全忘记
    case incorrectEasyRecall = 1 // 错误，看答案后想起
    case incorrectRecall = 2     // 错误，容易想起
    case correctDifficult = 3   // 正确但困难
    case correctHesitant = 4    // 正确有些犹豫
    case perfect = 5             // 完美记住
}

final class SM2Algorithm {
    static let shared = SM2Algorithm()
    private init() {}

    func calculate(quality: ReviewQuality, previous: SM2Result?) -> SM2Result {
        var result = previous ?? .initial
        let q = Double(quality.rawValue)

        var newEF = result.easeFactor + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
        newEF = max(1.3, newEF)

        let newInterval: Int
        let newReps: Int

        if quality.rawValue >= 3 {
            if result.repetitions == 0 { newInterval = 1 }
            else if result.repetitions == 1 { newInterval = 6 }
            else { newInterval = Int(Double(result.interval) * newEF) }
            newReps = result.repetitions + 1
        } else {
            newInterval = 1
            newReps = 0
        }

        return SM2Result(
            interval: newInterval,
            easeFactor: newEF,
            repetitions: newReps,
            nextReviewDate: Calendar.current.date(byAdding: .day, value: newInterval, to: Date()) ?? Date()
        )
    }
}
```

### 3.3 扩展现有 Models.swift

在现有 `card-ios/CardLearn/Models/Models.swift` 中新增：

```swift
// MARK: - SM-2 相关模型（新增）

struct SM2Progress: Codable {
    let cardId: Int
    let easeFactor: Double?   // 容易系数
    let repetitions: Int?      // 连续正确次数
    let interval: Int?         // 下次间隔天数
    let nextReviewTime: Date?  // 下次复习时间
}

struct ReviewPlanResponse: Codable {
    let cardId: Int
    let scheduledDate: String
    let card: Card
}

struct SubjectProgressResponse: Codable {
    let subjectId: Int
    let subjectName: String
    let totalCards: Int
    let masteredCount: Int
    let learnedCount: Int
    let masteryRate: Double
}

struct LearningStatsResponse: Codable {
    let currentStreak: Int
    let longestStreak: Int
    let totalStudyDays: Int
    let masteredToday: Int
    let learnedToday: Int
}

struct ReviewSubmitRequest: Codable {
    let cardId: Int
    let userId: Int
    let quality: Int
    let easeFactor: Double
    let repetitions: Int
    let interval: Int
    let nextReviewTime: String
}
```

### 3.4 扩展现有 APIService.swift

在现有 `card-ios/CardLearn/Services/APIService.swift` 中新增方法：

```swift
// MARK: - SM-2 学习进度相关 API（新增）

// 获取用户SM-2进度
func getSM2Progress(cardId: Int, appUserId: Int?) async throws -> SM2Progress {
    var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/learning/sm2/progress"))!
    if let appUserId = appUserId {
        urlComponents.queryItems = [URLQueryItem(name: "userId", value: String(appUserId))]
    }
    let (data, _) = try await session.data(from: urlComponents.url!)
    let response = try JSONDecoder().decode(APIResponse<SM2Progress>.self, from: data)
    if response.code == 200, let progress = response.data {
        return progress
    }
    throw APIError.serverError(response.message ?? "获取SM2进度失败")
}

// 提交复习结果（SM-2）
func submitSM2Review(request: ReviewSubmitRequest, token: String?) async throws -> Bool {
    let url = URL(string: config.getApiUrl(path: "/api/learning/review"))!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    if let token = token {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
    request.httpBody = try JSONEncoder().encode(request)

    let (data, _) = try await session.data(for: request)
    let response = try JSONDecoder().decode(APIResponse<String>.self, from: data)
    return response.code == 200
}

// 获取复习计划
func getReviewPlan(appUserId: Int?) async throws -> [ReviewPlanResponse] {
    var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/learning/plan"))!
    if let appUserId = appUserId {
        urlComponents.queryItems = [URLQueryItem(name: "userId", value: String(appUserId))]
    }
    let (data, _) = try await session.data(from: urlComponents.url!)
    let response = try JSONDecoder().decode(APIResponse<[ReviewPlanResponse]>.self, from: data)
    if response.code == 200, let plans = response.data {
        return plans
    }
    throw APIError.serverError(response.message ?? "获取复习计划失败")
}

// 获取科目进度
func getSubjectProgress(appUserId: Int?) async throws -> [SubjectProgressResponse] {
    var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/learning/subject-progress"))!
    if let appUserId = appUserId {
        urlComponents.queryItems = [URLQueryItem(name: "userId", value: String(appUserId))]
    }
    let (data, _) = try await session.data(from: urlComponents.url!)
    let response = try JSONDecoder().decode(APIResponse<[SubjectProgressResponse]>.self, from: data)
    if response.code == 200, let progress = response.data {
        return progress
    }
    throw APIError.serverError(response.message ?? "获取科目进度失败")
}

// 获取学习统计（扩展）
func getLearningStats(appUserId: Int?) async throws -> LearningStatsResponse {
    var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/learning/stats"))!
    if let appUserId = appUserId {
        urlComponents.queryItems = [URLQueryItem(name: "userId", value: String(appUserId))]
    }
    let (data, _) = try await session.data(from: urlComponents.url!)
    let response = try JSONDecoder().decode(APIResponse<LearningStatsResponse>.self, from: data)
    if response.code == 200, let stats = response.data {
        return stats
    }
    throw APIError.serverError(response.message ?? "获取学习统计失败")
}
```

### 3.5 学习页面 SwiftUI

#### 现有组件改造

**`CardDetailView.swift`** - 改造为翻转学习模式：
- 增加卡片翻转动画（3D rotation）
- 显示正反面内容切换
- 点击触发翻转

#### 新增组件

**`CardFlipView.swift`** - 翻转卡片组件：
```swift
struct CardFlipView: View {
    let frontContent: String
    let backContent: String
    @Binding var isFlipped: Bool
    @Binding var rotation: Double

    var body: some View {
        ZStack {
            CardContentView(content: frontContent)
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            CardContentView(content: backContent)
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 400)
    }
}
```

**`QualityRatingView.swift`** - 质量评分组件：
- 4个评分按钮：忘记(红)、困难(蓝)、犹豫(绿)、完美(紫)
- 使用 `UIImpactFeedbackGenerator` 触觉反馈
- 复用现有 `AppColor` 颜色常量

**`ViewModels/StudyViewModel.swift`** - 学习ViewModel：
- 管理卡片列表和当前卡片状态
- 调用 `SM2Algorithm` 计算复习间隔
- 调用 `APIService.submitSM2Review` 提交结果

#### 代码风格

遵循现有 `card-ios` 代码规范：
- 使用现有 `AppColor` 颜色常量
- 使用现有 `AppPageSize` 分页常量
- 使用现有组件化方式（SearchSection, FilterTabs 等）
- 使用 SwiftUI 动画 `withAnimation(.easeInOut)`

### 3.6 复习列表页面

**新增 `Views/ReviewListView.swift`**：
- 调用 `APIService.getReviewPlan()` 获取复习计划
- 按日期分组展示待复习卡片
- 点击跳转到学习页面

**新增 `Views/StatsView.swift`**：
- 调用 `APIService.getLearningStats()` 获取统计数据
- 展示 Streak 信息（当前连续、最长连续、累计天数）
- 调用 `APIService.getSubjectProgress()` 展示科目进度

### 3.7 推送通知服务

在 `card-ios` 中新增 `Services/NotificationService.swift`：

```swift
import UserNotifications

final class NotificationService: NSObject {
    static let shared = NotificationService()

    // 请求通知权限
    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    // 安排复习提醒
    func scheduleReviewReminder(cardId: Int, cardTitle: String, at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "复习提醒"
        content.body = "「\(cardTitle)」已到复习时间，点击查看"
        content.sound = .default
        content.userInfo = ["cardId": cardId]
        content.categoryIdentifier = "REVIEW"

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "review-\(cardId)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // 设置每日提醒
    func setupDailyReminder(hour: Int, minute: Int) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily-reminder"])

        let content = UNMutableNotificationContent()
        content.title = "学习提醒"
        content.body = "今天的学习任务还没完成哦，快来复习吧！"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-reminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
```

### 3.8 iOS Widget

```swift
import UserNotifications
import UIKit

final class NotificationService: NSObject {
    static let shared = NotificationService()

    private override init() { super.init() }

    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func registerDeviceToken(_ token: Data) {
        let tokenString = token.map { String(format: "%02.2hhx", $0) }.joined()
        Task {
            try? await APIService.shared.registerDevice(token: tokenString, type: "ios")
        }
    }

    func scheduleReviewReminder(cardId: Int, cardTitle: String, at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "复习提醒"
        content.body = "「\(cardTitle)」已到复习时间，点击查看"
        content.sound = .default
        content.userInfo = ["cardId": cardId]
        content.categoryIdentifier = "REVIEW"

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: "review-\(cardId)-\(date.timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func setupDailyReminder(hour: Int, minute: Int) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily-reminder"])

        let content = UNMutableNotificationContent()
        content.title = "学习提醒"
        content.body = "今天的学习任务还没完成哦，快来复习吧！"
        content.sound = .default
        content.categoryIdentifier = "DAILY"

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: "daily-reminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    static func setupNotificationCategories() {
        let reviewAction = UNNotificationAction(identifier: "REVIEW_ACTION", title: "去复习", options: .foreground)
        let snoozeAction = UNNotificationAction(identifier: "SNOOZE_ACTION", title: "稍后提醒", options: [])

        let reviewCategory = UNNotificationCategory(
            identifier: "REVIEW",
            actions: [reviewAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([reviewCategory])
    }
}
```

### 3.8 iOS Widget

**说明**：Widget 为独立扩展，目标 App Extension 独立开发。

**核心功能**：
- 显示今日待复习卡片数量
- 显示当前连续学习天数
- 点击跳转到 App 相关页面

**数据来源**：
- 使用 App Groups 共享 UserDefaults
- 由主 App 在学习时更新数据

---

## 四、后端 API 适配

### 4.1 后端现有技术

基于 `card-learn-boot` 项目现有架构：

| 组件 | 技术 |
|------|------|
| 框架 | Spring Boot 2.7 |
| ORM | MyBatis Plus 3.5 |
| 数据库 | MySQL 8.0 |
| 安全 | Spring Security + JWT |
| API文档 | Knife4j |

### 4.2 新增 API 设计

**新增 Controller**：`card-learn-boot/.../controller/LearningController.java`

```java
@RestController
@RequestMapping("/api/learning")
public class LearningController {

    // 获取用户SM-2进度
    @GetMapping("/sm2/progress")
    public Result<SM2ProgressVO> getSM2Progress(@RequestParam Long userId, @RequestParam Long cardId)

    // 提交复习结果
    @PostMapping("/review")
    public Result<Void> submitReview(@RequestBody SM2ReviewDTO dto)

    // 获取复习计划
    @GetMapping("/plan")
    public Result<List<ReviewPlanVO>> getReviewPlan(@RequestParam Long userId)

    // 获取科目进度
    @GetMapping("/subject-progress")
    public Result<List<SubjectProgressVO>> getSubjectProgress(@RequestParam Long userId)

    // 获取学习统计（扩展）
    @GetMapping("/stats")
    public Result<LearningStatsVO> getLearningStats(@RequestParam Long userId)
}
```

**新增 Service**：`card-learn-boot/.../service/ILearningService.java`

**新增 Mapper**：`card-learn-boot/.../mapper/BizUserProgressMapper.java`

### 4.3 新增数据表

```sql
-- 复习计划表
CREATE TABLE `biz_review_plan` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `card_id` bigint(20) NOT NULL,
  `scheduled_date` date NOT NULL,
  `status` char(1) DEFAULT '0',
  `actual_review_date` datetime DEFAULT NULL,
  `sm2_quality` tinyint(4) DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_date` (`user_id`,`scheduled_date`),
  KEY `idx_card_id` (`card_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 用户设备表
CREATE TABLE `biz_user_device` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `device_token` varchar(255) NOT NULL,
  `device_type` varchar(20) NOT NULL,
  `push_enabled` char(1) DEFAULT '1',
  `last_active_time` datetime DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_device_token` (`device_token`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 学习连续记录表
CREATE TABLE `biz_learning_streak` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `current_streak` int(11) DEFAULT '0',
  `longest_streak` int(11) DEFAULT '0',
  `last_study_date` date DEFAULT NULL,
  `total_days` int(11) DEFAULT '0',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

## 五、实施计划

### 5.1 Web 端优化

| 功能 | 优先级 | 工作量 | 交付物 |
|------|--------|--------|--------|
| 深色模式 | P0 | 1天 | 主题切换组件 |
| Markdown 实时预览 | P0 | 2天 | MarkdownEditor 组件 |
| 批量导入/导出 | P1 | 5天 | ImportDialog + ExportDialog |
| 学习数据看板 | P1 | 4天 | learning-dashboard 页面 |

### 5.2 iOS 端开发

| 功能 | 优先级 | 工作量 | 交付物 |
|------|--------|--------|--------|
| 项目搭建 + API 集成 | P0 | 2天 | Xcode 项目 + APIService |
| 核心学习流程 | P0 | 5天 | StudyView + 翻转动画 |
| SM-2 算法 | P0 | 2天 | SM2Algorithm |
| 复习列表 | P0 | 3天 | ReviewListView |
| 学习统计 | P1 | 4天 | StatsView + Streak |
| 推送通知 | P1 | 3天 | NotificationService |
| Widget | P2 | 3天 | CardLearnWidget |

**说明**：iOS 端纯 API 调用，不维护本地数据库，大幅减少工作量。

### 5.3 后端适配

| 功能 | 优先级 | 工作量 | 交付物 |
|------|--------|--------|--------|
| Learning Status API | P0 | 2天 | 新 API |
| Review Plan API | P0 | 2天 | 新 API |
| 复习提交 API | P0 | 2天 | 接收 SM-2 参数 |
| 设备注册 API | P1 | 1天 | 新 API |
| 科目进度 API | P1 | 1天 | 返回后端计算的进度数据 |

### 5.4 时间估算

| 阶段 | 任务 | 工期 |
|------|------|------|
| Web P0 | 深色模式 + Markdown 预览 | 1-3 周 |
| iOS P0 | 项目搭建 + 核心学习流程 | 2-3 周 |
| iOS P1 | 统计 + 通知 | 1-2 周 |
| 后端适配 | 新 API 开发 | 1-2 周 |

**iOS 端工作量减少**：原 23 天 → 现 17 天（减少 6 天离线存储开发）

---

## 六、技术选型

| 组件 | 方案 | 说明 |
|------|------|------|
| iOS UI Framework | SwiftUI | 复用现有代码 |
| iOS 网络层 | 现有APIService | URLSession + JSONDecoder |
| iOS 存储 | UserDefaults | 复用现有 AppConstants |
| iOS 推送 | APNs | iOS 原生推送 |
| Web 主题 | CSS 变量 | Element Plus 适配 |
| Web Markdown | marked + highlight.js | 新增依赖 |
| Web 图表 | ECharts | 已有技术栈 |
| 后端 | Spring Boot + MyBatis Plus | 复用现有 |

---

## 七、风险与注意事项

1. **iOS 推送需要中转服务器** - APNs 不能直接请求，需后端消息推送服务
2. **SM-2 需要数据积累** - 初期体验可能不如固定间隔
3. **后端需计算进度** - Java Service 层处理进度统计
4. **深色模式需组件重构** - Element Plus 需覆盖 CSS 变量
