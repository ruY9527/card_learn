import Foundation

/// 学习通知偏好（UserDefaults 持久化）
final class NotificationPreferences {
    static let shared = NotificationPreferences()
    private let defaults = UserDefaults.standard

    var reminderEnabled: Bool {
        get { defaults.bool(forKey: AppKey.reminderEnabled) }
        set { defaults.set(newValue, forKey: AppKey.reminderEnabled) }
    }

    var reminderHour: Int {
        get {
            let val = defaults.integer(forKey: AppKey.reminderHour)
            return val == 0 ? 20 : val  // 默认晚上 8 点
        }
        set { defaults.set(newValue, forKey: AppKey.reminderHour) }
    }

    var reminderMinute: Int {
        get { defaults.integer(forKey: AppKey.reminderMinute) }
        set { defaults.set(newValue, forKey: AppKey.reminderMinute) }
    }

    /// 根据当前偏好同步本地通知
    func syncLocalNotification() {
        let service = NotificationService.shared
        if reminderEnabled {
            service.setupDailyReminder(hour: reminderHour, minute: reminderMinute)
        } else {
            service.cancelDailyReminder()
        }
    }
}
