import Foundation

// 专业模型
struct Major: Codable, Identifiable {
    let majorId: Int
    let majorName: String
    let description: String?
    
    var id: Int { majorId }
}

// 科目模型
struct Subject: Codable, Identifiable {
    let subjectId: Int
    let subjectName: String
    let majorId: Int?
    
    var id: Int { subjectId }
}

// 卡片模型
struct Card: Codable, Identifiable, Equatable {
    let cardId: Int
    let subjectId: Int
    let subjectName: String?
    let frontContent: String
    let backContent: String
    let difficultyLevel: Int?
    let tags: [String]?
    let status: Int?  // 0: 未学, 1: 模糊, 2: 掌握
    let updateTime: String?
    let lastStudyTime: String?

    var id: Int { cardId }

    static func == (lhs: Card, rhs: Card) -> Bool {
        lhs.cardId == rhs.cardId
    }

    // 格式化时间显示
    var formattedTime: String {
        guard let timeStr = updateTime else { return "" }
        return DateUtils.formatDisplayTime(timeStr)
    }
}

// 分页响应
struct PageResponse<T: Codable>: Codable {
    let records: [T]
    let total: Int
    let size: Int
    let current: Int
    let pages: Int?

    enum CodingKeys: String, CodingKey {
        case records
        case total
        case size
        case current
        case pages
    }
}

// API 响应
struct APIResponse<T: Codable>: Codable {
    let code: Int
    let message: String?
    let data: T?
}

// 冲刺配置
struct SprintConfig: Codable {
    let enabled: Bool
    let examName: String?
    let examDate: String?
    let daysRemaining: Int?
    let isExpired: Bool?
}

// 科目统计
struct SubjectStats: Codable {
    let learned: Int?
    let mastered: Int?
    let review: Int?
    let unlearned: Int?
    let total: Int?
}

// 反馈类型
enum FeedbackType: String, Codable, CaseIterable {
    case suggestion = "SUGGESTION"
    case error = "ERROR"
    case function = "FUNCTION"
    case other = "OTHER"
    
    var label: String {
        switch self {
        case .suggestion: return "建议"
        case .error: return "纠错"
        case .function: return "功能问题"
        case .other: return "其他"
        }
    }
}

// 反馈模型
struct Feedback: Codable, Identifiable {
    let id: Int
    let userId: Int?
    let cardId: Int?
    let majorId: Int?
    let subjectId: Int?
    let type: String
    let rating: Int?
    let content: String
    let contact: String?
    let images: String?
    let status: String?
    let adminReply: String?
    let createTime: String?
}

// 验证码响应
struct CaptchaResponse: Codable {
    let key: String
    let image: String
}

// 登录响应
struct LoginResponse: Codable {
    let token: String
    let user: UserInfo
}

// 进度更新请求
struct ProgressUpdate: Codable {
    let cardId: Int
    let appUserId: Int?
    let status: Int

    enum CodingKeys: String, CodingKey {
        case cardId
        case appUserId = "userId"
        case status
    }
}

// 我的卡片模型（用户贡献的卡片草稿）
struct MyCard: Codable, Identifiable {
    let draftId: Int
    let subjectId: Int
    let subjectName: String?
    let frontContent: String
    let backContent: String
    let difficultyLevel: Int?
    let auditStatus: String  // 0: 待审批, 1: 已通过, 2: 已拒绝
    let auditRemark: String?
    let createTime: String?
    let updateTime: String?

    var id: Int { draftId }

    var statusLabel: String {
        switch auditStatus {
        case "0": return "待审批"
        case "1": return "已通过"
        case "2": return "已拒绝"
        default: return "未知"
        }
    }

    var statusColor: String {
        switch auditStatus {
        case "0": return "FF9800"  // 橙色
        case "1": return "4CAF50"  // 绿色
        case "2": return "F44336"  // 红色
        default: return "9E9E9E"
        }
    }
}

// 我的卡片统计
struct MyCardStats: Codable {
    let pending: Int?
    let passed: Int?
    let rejected: Int?
    let total: Int?
}

// 学习历史记录
struct StudyHistory: Codable, Identifiable {
    let id: Int
    let subjectId: Int
    let subjectName: String?
    let studyTime: String?
    let progress: Int?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        subjectId = try container.decode(Int.self, forKey: .subjectId)
        subjectName = try container.decodeIfPresent(String.self, forKey: .subjectName)
        studyTime = try container.decodeIfPresent(String.self, forKey: .studyTime)
        progress = try container.decodeIfPresent(Int.self, forKey: .progress)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case subjectId
        case subjectName
        case studyTime
        case progress
    }
}

// 评论模型
struct Comment: Codable, Identifiable {
    let commentId: Int
    let cardId: Int
    let userId: Int
    let userNickname: String?
    let content: String
    let rating: Int?
    let commentType: String
    let commentTypeText: String?
    let status: String?
    let adminReply: String?
    let isNote: Int?
    let likeCount: Int?
    let dislikeCount: Int?
    let replyCount: Int?
    let likeStatus: Int?
    let createTime: String?

    var id: Int { commentId }

    var typeLabel: String {
        switch commentType {
        case "QUALITY": return "优质内容"
        case "POOR": return "劣质内容"
        default: return "中性评价"
        }
    }

    var typeColor: String {
        switch commentType {
        case "QUALITY": return "67C23A"  // 绿色
        case "POOR": return "F56C6C"  // 红色
        default: return "909399"  // 灰色
        }
    }
}

// 回复模型
struct Reply: Codable, Identifiable {
    let replyId: Int
    let commentId: Int
    let userId: Int
    let userNickname: String?
    let content: String
    let likeCount: Int?
    let dislikeCount: Int?
    let likeStatus: Int?
    let parentReplyId: Int?
    let children: [Reply]?
    let hasMoreChildren: Bool?
    let createTime: String?

    var id: Int { replyId }
}

// 评论统计
struct CommentStats: Codable {
    let totalComments: Int?
    let qualityCount: Int?
    let poorCount: Int?
    let avgRating: Double?
}

// 笔记模型
struct Note: Codable, Identifiable {
    let commentId: Int
    let cardId: Int
    let cardFrontContent: String?
    let subjectName: String?
    let userId: Int
    let userNickname: String?
    let content: String
    let rating: Int?
    let likeCount: Int?
    let replyCount: Int?
    let createTime: String?
    let updateTime: String?

    var id: Int { commentId }
}

// MARK: - SM-2 相关模型

// SM-2学习进度
struct SM2Progress: Codable {
    let cardId: Int
    let easeFactor: Double?
    let repetitions: Int?
    let interval: Int?
    let nextReviewTime: String?
}

// 复习计划
struct ReviewPlanResponse: Codable, Identifiable {
    let cardId: Int
    let scheduledDate: String
    let frontContent: String
    let backContent: String?
    let subjectName: String?
    let difficultyLevel: Int?
    let studyCount: Int?

    var id: Int { cardId }
}

// 卡片学习历史响应
struct CardStudyHistoryResponse: Codable {
    let cardId: Int
    let frontContent: String?
    let records: [StudyHistoryRecordItem]?
    let total: Int?
}

// 学习历史记录项
struct StudyHistoryRecordItem: Codable, Identifiable {
    let id: Int
    let userId: Int?
    let nickname: String?
    let cardId: Int?
    let status: Int?
    let createTime: String?

    var statusText: String {
        switch status {
        case 0: return "未学"
        case 1: return "模糊"
        case 2: return "掌握"
        default: return "未知"
        }
    }

    var statusColorHex: String {
        switch status {
        case 0: return "9E9E9E"
        case 1: return "FF9800"
        case 2: return "4CAF50"
        default: return "9E9E9E"
        }
    }
}

// 科目进度
struct SubjectProgressResponse: Codable, Identifiable {
    let subjectId: Int
    let subjectName: String
    let majorId: Int?
    let majorName: String?
    let totalCards: Int
    let masteredCount: Int
    let learnedCount: Int
    let masteryRate: Double

    var id: Int { subjectId }
}

// 每日学习趋势
struct DailyLearnTrend: Codable, Identifiable {
    let date: String
    let count: Int

    var id: String { date }
}

// 学习统计
struct LearningStatsResponse: Codable {
    let currentStreak: Int
    let longestStreak: Int
    let totalStudyDays: Int
    let masteredToday: Int
    let learnedToday: Int
}

// 复习提交请求
struct ReviewSubmitRequest: Codable {
    let cardId: Int
    let userId: Int
    let quality: Int
    let easeFactor: Double
    let repetitions: Int
    let interval: Int
    let nextReviewTime: String
}

// 简化复习请求（服务端计算SM-2）
struct SimpleReviewRequest: Codable {
    let cardId: Int
    let userId: Int
    let status: Int
}

// 简化复习结果
struct ReviewResultVO: Codable {
    let cardId: Int
    let status: Int
    let easeFactor: Double
    let repetitions: Int
    let intervalDays: Int
    let nextReviewTime: String?
}

// MARK: - 激励系统模型

// 成就
struct Achievement: Codable, Identifiable {
    let achievementId: Int
    let code: String
    let name: String
    let description: String?
    let icon: String?
    let tier: Int
    let category: String
    let conditionValue: Int?
    let expReward: Int?
    let unlocked: Bool?
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
        case 1: return "CD7F32"
        case 2: return "C0C0C0"
        case 3: return "FFD700"
        case 4: return "B9F2FF"
        default: return "9E9E9E"
        }
    }
}

// 成就列表响应
struct AchievementListResponse: Codable {
    let unlockedCount: Int
    let totalCount: Int
    let achievements: [Achievement]
}

// 成就检查响应
struct AchievementCheckResponse: Codable {
    let newAchievements: [Achievement]
    let totalExp: Int
    let level: Int
    let leveledUp: Bool
}

// 用户等级
struct UserLevel: Codable {
    let level: Int
    let levelName: String
    let currentExp: Int
    let totalExp: Int
    let nextLevelExp: Int
    let progressPercent: Double
    let expToNextLevel: Int
}

// 经验值日志
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

// 学习目标
struct LearningGoal: Codable {
    let dailyLearnTarget: Int
    let dailyMasterTarget: Int
    let enabled: Bool
}

// 目标进度
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

// 周目标记录
struct WeekGoalRecord: Codable, Identifiable {
    let date: String
    let learnProgress: Int?
    let learnTarget: Int?
    let learnCompleted: Bool?
    let masterProgress: Int?
    let masterTarget: Int?
    let masterCompleted: Bool?

    var id: String { date }
}

// 目标设置请求
struct GoalSetRequest: Codable {
    var dailyLearnTarget: Int?
    var dailyMasterTarget: Int?
    var enabled: Bool?
}

// 排行榜项
struct RankItem: Codable, Identifiable {
    let rank: Int
    let userId: Int
    let nickname: String
    let avatar: String?
    let level: Int
    let levelName: String?
    let totalExp: Int?
    let weekLearnCount: Int?
    let currentStreak: Int?

    var id: Int { userId }
}

// 用户排名
struct RankPosition: Codable {
    let userId: Int
    let rank: Int?
    let totalExp: Int?
    let weekRank: Int?
    let weekLearnCount: Int?
    let streakRank: Int?
    let currentStreak: Int?
}

// 成就分类枚举
enum AchievementCategory: String, CaseIterable {
    case all = ""
    case streak = "streak"
    case count = "count"
    case subject = "subject"
    case social = "social"

    var label: String {
        switch self {
        case .all: return "全部"
        case .streak: return "连续"
        case .count: return "数量"
        case .subject: return "科目"
        case .social: return "社交"
        }
    }
}

// MARK: - 学习报告模型

// 报告详情
struct ReportDetail: Codable {
    let reportId: Int?
    let reportType: String
    let periodStart: String
    let periodEnd: String
    let overview: ReportOverview
    let masteryTrend: MasteryTrend?
    let subjectAnalysis: [SubjectAnalysis]?
    let learningHabits: LearningHabits?
    let weakPoints: [WeakPoint]?
    let suggestions: [Suggestion]?
}

// 报告概览
struct ReportOverview: Codable {
    let totalCards: Int
    let newMastered: Int
    let forgotten: Int
    let streakDays: Int
    let studyDuration: Int?
    let comparison: Comparison?
}

// 与上期对比
struct Comparison: Codable {
    let totalCardsChange: String?
    let newMasteredChange: String?
    let forgottenChange: String?
}

// 掌握率趋势
struct MasteryTrend: Codable {
    let startRate: Int
    let endRate: Int
    let changeRate: Int
    let trendData: [TrendPoint]?
}

// 趋势数据点
struct TrendPoint: Codable, Identifiable {
    let date: String
    let rate: Int

    var id: String { date }
}

// 科目分析
struct SubjectAnalysis: Codable, Identifiable {
    let subjectId: Int
    let subjectName: String
    let totalCards: Int
    let mastered: Int
    let weakPoints: Int
    let masteryRate: Int

    var id: Int { subjectId }
}

// 学习习惯
struct LearningHabits: Codable {
    let morning: Int
    let afternoon: Int
    let evening: Int
    let peakHour: String
    let mostActiveDay: String
    let avgDailyDuration: Int
    let studyFrequency: Int
}

// 薄弱点
struct WeakPoint: Codable, Identifiable {
    let cardId: Int
    let subjectName: String?
    let frontContent: String?
    let errorCount: Int
    let lastErrorTime: String?

    var id: Int { cardId }
}

// 改进建议
struct Suggestion: Codable, Identifiable {
    let type: String
    let priority: String
    let content: String

    var id: String { content }
}

// 历史报告列表项
struct ReportListItem: Codable, Identifiable {
    let reportId: Int
    let reportType: String
    let periodStart: String
    let periodEnd: String
    let overview: ReportOverview?

    var id: Int { reportId }
}

// 历史报告响应
struct ReportHistoryResponse: Codable {
    let records: [ReportListItem]
    let total: Int
    let pages: Int
}

// 薄弱点响应
struct WeakPointResponse: Codable {
    let records: [WeakPoint]
    let total: Int
}
