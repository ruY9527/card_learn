import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var showLoginModal: Bool = false
    @State private var sprintConfig: SprintConfig?
    @State private var showFeedback: Bool = false
    @State private var showFeedbackList: Bool = false
    @State private var showAddCard: Bool = false
    @State private var showMyCards: Bool = false
    @State private var showMyNotes: Bool = false
    @State private var showIncentiveCenter: Bool = false

    private let apiService = CardApiService.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // 冲刺倒计时
                    if let config = sprintConfig, config.enabled, !(config.isExpired ?? true) {
                        SprintCard(config: config)
                    }

                    // 用户信息卡片
                    UserCard(
                        isLoggedIn: appState.isLoggedIn,
                        userInfo: appState.userInfo
                    ) {
                        if !appState.isLoggedIn {
                            showLoginModal = true
                        }
                    }
                    .padding(.horizontal, 16)

                    // 设置
                    VStack(alignment: .leading, spacing: 12) {
                        Text("设置")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppColor.textPrimary)
                            .padding(.horizontal, 16)

                        SettingsSection()
                            .padding(.horizontal, 16)
                    }

                    // 知识贡献入口
                    VStack(alignment: .leading, spacing: 12) {
                        Text("知识贡献")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppColor.textPrimary)
                            .padding(.horizontal, 16)

                        ContributionSection(
                            isLoggedIn: appState.isLoggedIn,
                            onAddCardTap: {
                                if appState.isLoggedIn {
                                    showAddCard = true
                                } else {
                                    showLoginModal = true
                                }
                            },
                            onMyCardsTap: {
                                if appState.isLoggedIn {
                                    showMyCards = true
                                } else {
                                    showLoginModal = true
                                }
                            },
                            onMyNotesTap: {
                                if appState.isLoggedIn {
                                    showMyNotes = true
                                } else {
                                    showLoginModal = true
                                }
                            }
                        )
                        .padding(.horizontal, 16)
                    }

                    // 激励中心入口
                    VStack(alignment: .leading, spacing: 12) {
                        Text("学习激励")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppColor.textPrimary)
                            .padding(.horizontal, 16)

                        Button(action: {
                            if appState.isLoggedIn {
                                showIncentiveCenter = true
                            } else {
                                showLoginModal = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "trophy.fill")
                                    .foregroundColor(Color(hex: "FFD700"))
                                    .frame(width: 24)
                                Text("激励中心")
                                    .foregroundColor(AppColor.textPrimary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(AppColor.disabledText)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 16)
                    }

                    // 反馈入口
                    VStack(alignment: .leading, spacing: 12) {
                        Text("帮助与反馈")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppColor.textPrimary)
                            .padding(.horizontal, 16)

                        FeedbackSection(
                            isLoggedIn: appState.isLoggedIn,
                            onFeedbackTap: { showFeedback = true },
                            onFeedbackListTap: { showFeedbackList = true }
                        )
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 80)
            }
            .navigationTitle("我的")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await fetchSprintConfig()
            }
            .navigationDestination(isPresented: $showFeedback) {
                FeedbackView(cardId: nil, cardContent: nil)
            }
            .navigationDestination(isPresented: $showFeedbackList) {
                FeedbackListView()
            }
            .navigationDestination(isPresented: $showAddCard) {
                AddCardView()
            }
            .navigationDestination(isPresented: $showMyCards) {
                MyCardsView()
            }
            .navigationDestination(isPresented: $showMyNotes) {
                NoteListView()
            }
            .navigationDestination(isPresented: $showIncentiveCenter) {
                IncentiveCenterView()
            }
            .sheet(isPresented: $showLoginModal) {
                LoginModal(onSuccess: {
                    showLoginModal = false
                })
            }
        }
        .onAppear {
            Task {
                await fetchSprintConfig()
            }
        }
    }

    private func fetchSprintConfig() async {
        do {
            sprintConfig = try await apiService.getSprintConfig()
        } catch {
            sprintConfig = nil
        }
    }
}

// 冲刺卡片
struct SprintCard: View {
    let config: SprintConfig

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(config.examName ?? "")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                Text("考试日期：\(config.examDate ?? "")")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
            }

            HStack(spacing: 8) {
                Text("\(config.daysRemaining ?? 0)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)

                Text("天")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
            }

            Text("坚持复习，冲刺成功！")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [AppColor.primary, AppColor.primaryGradientEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .padding(.horizontal, 16)
    }
}

// 用户卡片
struct UserCard: View {
    let isLoggedIn: Bool
    let userInfo: UserInfo?
    let action: () -> Void

    @EnvironmentObject var appState: AppState

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // 头像
                ZStack {
                    Circle()
                        .fill(isLoggedIn ?
                              LinearGradient(colors: [AppColor.primary, AppColor.primaryGradientEnd], startPoint: .topLeading, endPoint: .bottomTrailing) :
                              LinearGradient(colors: [AppColor.divider, AppColor.divider], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 60, height: 60)

                    Text(isLoggedIn ? String(userInfo?.nickname.prefix(1) ?? "U") : "游")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(isLoggedIn ? userInfo?.nickname ?? "" : "游客模式")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColor.textPrimary)

                    Text(isLoggedIn ? "已登录" : "点击登录保存学习进度")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.textSecondary)
                }

                Spacer()

                if isLoggedIn {
                    Button(action: logout) {
                        Text("退出")
                            .font(.system(size: 14))
                            .foregroundColor(AppColor.error)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppColor.errorLight)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }

    private func logout() {
        appState.logout()
    }
}

// 统计网格
struct StatsGrid: View {
    let learned: Int
    let mastered: Int
    let review: Int
    let onTap: (String) -> Void

    var body: some View {
        HStack(spacing: 12) {
            StatItem(value: learned, label: "已学习", color: AppColor.info, onTap: { onTap("learned") })
            StatItem(value: mastered, label: "已掌握", color: AppColor.success, onTap: { onTap("mastered") })
            StatItem(value: review, label: "待复习", color: AppColor.warning, onTap: { onTap("review") })
        }
    }
}

struct StatItem: View {
    let value: Int
    let label: String
    let color: Color
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text("\(value)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(color)

                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(AppColor.textSecondary)

                Text("点击查看")
                    .font(.system(size: 10))
                    .foregroundColor(color.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

// 设置区域
struct SettingsSection: View {
    @EnvironmentObject var appState: AppState
    @State private var notificationEnabled: Bool = NotificationPreferences.shared.reminderEnabled
    @State private var soundEnabled: Bool = UserDefaults.standard.bool(forKey: AppKey.sound)

    var body: some View {
        VStack(spacing: 12) {
            SettingItem(label: "学习提醒", isOn: notificationEnabled) {
                notificationEnabled.toggle()
                let prefs = NotificationPreferences.shared
                prefs.reminderEnabled = notificationEnabled
                prefs.syncLocalNotification()

                if notificationEnabled {
                    Task {
                        let granted = await NotificationService.shared.requestAuthorization()
                        await MainActor.run {
                            appState.notificationPermissionGranted = granted
                            if !granted {
                                notificationEnabled = false
                                prefs.reminderEnabled = false
                                prefs.syncLocalNotification()
                            }
                        }
                    }
                }
            }

            SettingItem(label: "音效", isOn: soundEnabled) {
                soundEnabled.toggle()
                UserDefaults.standard.set(soundEnabled, forKey: AppKey.sound)
            }

#if DEBUG
            HStack {
                Text("环境切换")
                    .font(.system(size: 14))
                    .foregroundColor(AppColor.textPrimary)

                Spacer()

                Picker("", selection: Binding(
                    get: { EnvConfig.current == .production ? "production" : "development" },
                    set: {
                        EnvConfig.current = $0 == "production" ? .production : .development
                    }
                )) {
                    Text("开发").tag("development")
                    Text("生产").tag("production")
                }
                .pickerStyle(.segmented)
                .frame(width: 120)
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(12)
#endif

            Button(action: {}) {
                HStack {
                    Text("清除缓存")
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.textSecondary)

                    Spacer()

                    Text("0 KB")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.textSecondary)
                }
                .padding(12)
                .background(Color.white)
                .cornerRadius(12)
            }
            .disabled(true)
        }
    }

}

struct SettingItem: View {
    let label: String
    let isOn: Bool
    let onChange: () -> Void

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(AppColor.textPrimary)

            Spacer()

            Toggle("", isOn: Binding(
                get: { isOn },
                set: { _ in onChange() }
            ))
            .labelsHidden()
            .tint(AppColor.info)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
    }
}

// 知识贡献区域
struct ContributionSection: View {
    let isLoggedIn: Bool
    let onAddCardTap: () -> Void
    let onMyCardsTap: () -> Void
    let onMyNotesTap: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Button(action: onAddCardTap) {
                HStack {
                    Text("✏️")
                        .font(.system(size: 20))

                    Text("添加卡片")
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.textPrimary)

                    Spacer()

                    Text("贡献知识")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.accentGreen)
                }
                .padding(12)
                .background(Color.white)
                .cornerRadius(12)
            }

            if isLoggedIn {
                Button(action: onMyCardsTap) {
                    HStack {
                        Text("📚")
                            .font(.system(size: 20))

                        Text("我的卡片")
                            .font(.system(size: 14))
                            .foregroundColor(AppColor.textPrimary)

                        Spacer()

                        Text("→")
                            .font(.system(size: 14))
                            .foregroundColor(AppColor.primary)
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
                }

                Button(action: onMyNotesTap) {
                    HStack {
                        Image(systemName: "note.text")
                            .font(.system(size: 18))
                            .foregroundColor(AppColor.primary)

                        Text("我的笔记")
                            .font(.system(size: 14))
                            .foregroundColor(AppColor.textPrimary)

                        Spacer()

                        Text("→")
                            .font(.system(size: 14))
                            .foregroundColor(AppColor.primary)
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
                }
            }
        }
    }
}

// 反馈区域
struct FeedbackSection: View {
    let isLoggedIn: Bool
    let onFeedbackTap: () -> Void
    let onFeedbackListTap: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Button(action: onFeedbackTap) {
                HStack {
                    Text("📝")
                        .font(.system(size: 20))

                    Text("提交反馈")
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.textPrimary)

                    Spacer()

                    Text("→")
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.primary)
                }
                .padding(12)
                .background(Color.white)
                .cornerRadius(12)
            }

            if isLoggedIn {
                Button(action: onFeedbackListTap) {
                    HStack {
                        Text("📋")
                            .font(.system(size: 20))

                        Text("我的反馈记录")
                            .font(.system(size: 14))
                            .foregroundColor(AppColor.textPrimary)

                        Spacer()

                        Text("→")
                            .font(.system(size: 14))
                            .foregroundColor(AppColor.primary)
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
                }
            }
        }
    }
}