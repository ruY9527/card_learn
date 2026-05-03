import Foundation

struct DateUtils {
    static func parseDate(from timeStr: String) -> Date? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: timeStr) {
            return date
        }

        let altFormatter = DateFormatter()
        altFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = altFormatter.date(from: timeStr) {
            return date
        }

        let altFormatter2 = DateFormatter()
        altFormatter2.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = altFormatter2.date(from: timeStr) {
            return date
        }

        return nil
    }

    static func formatRelativeTime(_ date: Date) -> String {
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

    static func formatDisplayTime(_ timeStr: String) -> String {
        guard let date = parseDate(from: timeStr) else { return "" }
        return formatRelativeTime(date)
    }
}
