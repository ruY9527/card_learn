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

    var id: Int { cardId }

    static func == (lhs: Card, rhs: Card) -> Bool {
        lhs.cardId == rhs.cardId
    }

    // 格式化时间显示
    var formattedTime: String {
        guard let timeStr = updateTime else { return "" }

        // 解析时间字符串
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = dateFormatter.date(from: timeStr) else {
            // 尝试其他格式
            let alternateFormatter = DateFormatter()
            alternateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            guard let date = alternateFormatter.date(from: timeStr) else { return "" }
            return formatRelativeTime(date)
        }
        return formatRelativeTime(date)
    }

    private func formatRelativeTime(_ date: Date) -> String {
        let now = Date()
        let diff = now.timeIntervalSince(date)

        let minutes = Int(diff / 60)
        let hours = Int(diff / 3600)
        let days = Int(diff / 86400)

        if minutes < 1 {
            return "刚刚"
        } else if minutes < 60 {
            return "\(minutes)分钟前"
        } else if hours < 24 {
            return "\(hours)小时前"
        } else if days < 7 {
            return "\(days)天前"
        } else {
            let calendar = Calendar.current
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            return "\(month)月\(day)日"
        }
    }
}

// 分页响应
struct PageResponse<T: Codable>: Codable {
    let records: [T]
    let total: Int
    let size: Int
    let current: Int
    let pages: Int?
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
    let appUserId: Int?
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
    let appUserId: Int
    let userNickname: String?
    let content: String
    let rating: Int?
    let commentType: String
    let commentTypeText: String?
    let status: String?
    let adminReply: String?
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

// 评论统计
struct CommentStats: Codable {
    let totalComments: Int?
    let qualityCount: Int?
    let poorCount: Int?
    let avgRating: Double?
}