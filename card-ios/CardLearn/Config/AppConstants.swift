import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

enum AppColor {
    // 主色调
    static let primary = Color(hex: "667eea")
    static let primaryGradientEnd = Color(hex: "764ba2")

    // 文字色
    static let textPrimary = Color(hex: "303133")
    static let textMedium = Color(hex: "606266")
    static let textSecondary = Color(hex: "909399")
    static let disabledText = Color(hex: "C0C4CC")

    // 背景/边框
    static let backgroundLight = Color(hex: "F5F7FA")
    static let backgroundGray = Color(hex: "F5F5F5")
    static let border = Color(hex: "DCDFE6")
    static let divider = Color(hex: "E0E0E0")
    static let neutralGray = Color(hex: "9E9E9E")
    static let inactive = Color(hex: "999999")

    // 语义色
    static let info = Color(hex: "409EFF")
    static let success = Color(hex: "67C23A")
    static let warning = Color(hex: "E6A23C")
    static let error = Color(hex: "F56C6C")
    static let danger = Color(hex: "F44336")
    static let orange = Color(hex: "FF9800")
    static let green = Color(hex: "4CAF50")
    static let gold = Color(hex: "FFD700")
    static let amber = Color(hex: "FFC107")

    // 强调绿
    static let accentGreen = Color(hex: "43e97b")
    static let accentGreenEnd = Color(hex: "38f9d7")

    // 浅色背景
    static let infoLight = Color(hex: "F0F5FF")
    static let errorLight = Color(hex: "FEF0F0")
    static let warningLight = Color(hex: "FDF6EC")
    static let successLight = Color(hex: "F0F9EB")
    static let orangeLight = Color(hex: "FFF3E0")
    static let dangerLight = Color(hex: "FFEBEE")
    static let amberLight = Color(hex: "FFF8E1")
    static let greenLight = Color(hex: "E8F5E9")
    static let blueLight = Color(hex: "ECF5FF")
}

enum AppKey {
    static let token = "token"
    static let userInfo = "userInfo"
    static let stats = "stats"
    static let selectedMajorId = "selected_major_id"
    static let selectedMajorName = "selected_major_name"
    static let notification = "notification"
    static let sound = "sound"
    static let environment = "environment"
}

enum AppPageSize {
    static let cards = 20
    static let feedback = 10
    static let myCards = 10
    static let comments = 10
}
