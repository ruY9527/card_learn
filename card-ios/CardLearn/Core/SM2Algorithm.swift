import Foundation

/// SM-2 间隔重复算法
struct SM2Result: Codable {
    var interval: Int           // 下次间隔天数
    var easeFactor: Double      // 容易系数
    var repetitions: Int        // 连续正确次数
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
    case perfect = 5            // 完美记住

    var label: String {
        switch self {
        case .blackout: return "忘记"
        case .incorrectEasyRecall: return "模糊"
        case .incorrectRecall: return "困难"
        case .correctDifficult: return "犹豫"
        case .correctHesitant: return "想起"
        case .perfect: return "完美"
        }
    }

    var color: String {
        switch self {
        case .blackout, .incorrectEasyRecall: return "F56C6C"
        case .incorrectRecall: return "E6A23C"
        case .correctDifficult: return "409EFF"
        case .correctHesitant: return "67C23A"
        case .perfect: return "764BA2"
        }
    }

    /// 简化为4级评分(用于UI展示)
    var simplified: SimplifiedQuality {
        switch self {
        case .blackout, .incorrectEasyRecall: return .forgot
        case .incorrectRecall: return .hard
        case .correctDifficult: return .hesitant
        case .correctHesitant, .perfect: return .perfect
        }
    }
}

/// 简化4级评分
enum SimplifiedQuality: Int, CaseIterable {
    case forgot = 0    // 忘记
    case hard = 2      // 困难
    case hesitant = 3  // 犹豫
    case perfect = 5   // 完美

    var label: String {
        switch self {
        case .forgot: return "忘记"
        case .hard: return "困难"
        case .hesitant: return "犹豫"
        case .perfect: return "完美"
        }
    }

    var quality: ReviewQuality {
        switch self {
        case .forgot: return .blackout
        case .hard: return .incorrectRecall
        case .hesitant: return .correctDifficult
        case .perfect: return .perfect
        }
    }
}

final class SM2Algorithm {
    static let shared = SM2Algorithm()
    private init() {}

    /// 根据评分计算下次复习参数
    func calculate(quality: ReviewQuality, previous: SM2Result?) -> SM2Result {
        let result = previous ?? .initial
        let q = Double(quality.rawValue)

        // 计算新的容易系数
        var newEF = result.easeFactor + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
        newEF = max(1.3, newEF)

        let newInterval: Int
        let newReps: Int

        if quality.rawValue >= 3 {
            // 回答正确
            if result.repetitions == 0 {
                newInterval = 1
            } else if result.repetitions == 1 {
                newInterval = 6
            } else {
                newInterval = Int(Double(result.interval) * newEF)
            }
            newReps = result.repetitions + 1
        } else {
            // 回答错误，重置
            newInterval = 1
            newReps = 0
        }

        let nextDate = Calendar.current.date(byAdding: .day, value: newInterval, to: Date()) ?? Date()

        return SM2Result(
            interval: newInterval,
            easeFactor: newEF,
            repetitions: newReps,
            nextReviewDate: nextDate
        )
    }

    /// 格式化下次复习时间描述
    func formatNextReview(_ result: SM2Result) -> String {
        let days = result.interval
        if days == 0 {
            return "今天"
        } else if days == 1 {
            return "明天"
        } else if days < 7 {
            return "\(days)天后"
        } else if days < 30 {
            let weeks = days / 7
            return "\(weeks)周后"
        } else {
            let months = days / 30
            return "\(months)个月后"
        }
    }
}
