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

    var id: Int { cardId }
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        lhs.cardId == rhs.cardId
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