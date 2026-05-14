import UserNotifications
import UIKit

/// 推送通知服务
final class NotificationService: NSObject {
    static let shared = NotificationService()

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    // MARK: - 权限请求

    /// 请求通知权限
    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    // MARK: - 注册推送

    /// 注册远程推送
    func registerForRemoteNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    /// 处理设备Token注册
    func handleDeviceToken(_ token: Data, userId: Int) {
        let tokenString = token.map { String(format: "%02.2hhx", $0) }.joined()
        Task {
            try? await LearningApiService.shared.registerDevice(
                userId: userId,
                deviceToken: tokenString,
                deviceType: "ios"
            )
        }
    }

    // MARK: - 本地通知

    /// 安排复习提醒
    func scheduleReviewReminder(cardId: Int, cardTitle: String, at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "复习提醒"
        content.body = "「\(cardTitle)」已到复习时间，点击查看"
        content.sound = .default
        content.userInfo = ["cardId": cardId, "cardTitle": cardTitle]
        content.categoryIdentifier = "REVIEW"

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: "review-\(cardId)-\(Int(date.timeIntervalSince1970))",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    /// 设置每日提醒
    func setupDailyReminder(hour: Int, minute: Int) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["daily-reminder"]
        )

        let content = UNMutableNotificationContent()
        content.title = "学习提醒"
        content.body = "今天的学习任务还没完成哦，快来复习吧！"
        content.sound = .default
        content.categoryIdentifier = "DAILY"

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: "daily-reminder",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    /// 取消每日提醒
    func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["daily-reminder"]
        )
    }

    /// 取消所有待发送的复习提醒
    func cancelAllReviewReminders() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let reviewIds = requests
                .filter { $0.identifier.hasPrefix("review-") }
                .map { $0.identifier }
            UNUserNotificationCenter.current().removePendingNotificationRequests(
                withIdentifiers: reviewIds
            )
        }
    }

    /// 获取待发送通知数量
    func getPendingNotificationCount() async -> Int {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        return requests.count
    }

    // MARK: - 通知类别设置

    static func setupNotificationCategories() {
        let reviewAction = UNNotificationAction(
            identifier: "REVIEW_ACTION",
            title: "去复习",
            options: .foreground
        )
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "稍后提醒",
            options: []
        )

        let reviewCategory = UNNotificationCategory(
            identifier: "REVIEW",
            actions: [reviewAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )

        let dailyCategory = UNNotificationCategory(
            identifier: "DAILY",
            actions: [],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([reviewCategory, dailyCategory])
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {
    /// 前台收到通知时调用
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    /// 用户点击通知时调用
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        switch response.actionIdentifier {
        case "REVIEW_ACTION":
            if let cardId = userInfo["cardId"] as? Int {
                NotificationCenter.default.post(
                    name: .init("OpenCardDetail"),
                    object: nil,
                    userInfo: ["cardId": cardId]
                )
            }

        case "SNOOZE_ACTION":
            if let cardId = userInfo["cardId"] as? Int {
                let cardTitle = userInfo["cardTitle"] as? String ?? "学习卡片"
                let snoozeDate = Date().addingTimeInterval(30 * 60)
                scheduleReviewReminder(cardId: cardId, cardTitle: cardTitle, at: snoozeDate)
            }

        case UNNotificationDefaultActionIdentifier:
            if let cardId = userInfo["cardId"] as? Int {
                NotificationCenter.default.post(
                    name: .init("OpenCardDetail"),
                    object: nil,
                    userInfo: ["cardId": cardId]
                )
            }

        default:
            break
        }

        completionHandler()
    }
}
