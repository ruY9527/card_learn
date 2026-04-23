import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var showLoginModal: Bool = false
    @State private var sprintConfig: SprintConfig?
    @State private var showFeedback: Bool = false
    @State private var showFeedbackList: Bool = false
    @State private var showProgressCards: Bool = false
    @State private var progressType: String = ""
    
    private let apiService = APIService.shared
    
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
                    
                    // 学习统计
                    VStack(alignment: .leading, spacing: 12) {
                        Text("学习统计")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "303133"))
                            .padding(.horizontal, 16)
                        
                        StatsGrid(
                            learned: appState.stats.learned,
                            mastered: appState.stats.mastered,
                            review: appState.stats.review
                        ) { type in
                            if appState.isLoggedIn {
                                progressType = type
                                showProgressCards = true
                            } else {
                                showLoginModal = true
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // 设置
                    VStack(alignment: .leading, spacing: 12) {
                        Text("设置")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "303133"))
                            .padding(.horizontal, 16)
                        
                        SettingsSection()
                            .padding(.horizontal, 16)
                    }
                    
                    // 反馈入口
                    VStack(alignment: .leading, spacing: 12) {
                        Text("帮助与反馈")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "303133"))
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
            .navigationDestination(isPresented: $showProgressCards) {
                ProgressCardsView(type: progressType)
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
                colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
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
                              LinearGradient(colors: [Color(hex: "667eea"), Color(hex: "764ba2")], startPoint: .topLeading, endPoint: .bottomTrailing) :
                              LinearGradient(colors: [Color(hex: "E0E0E0"), Color(hex: "E0E0E0")], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 60, height: 60)
                    
                    Text(isLoggedIn ? String(userInfo?.nickname.prefix(1) ?? "U") : "游")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(isLoggedIn ? userInfo?.nickname ?? "" : "游客模式")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "303133"))
                    
                    Text(isLoggedIn ? "已登录" : "点击登录保存学习进度")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "909399"))
                }
                
                Spacer()
                
                if isLoggedIn {
                    Button(action: logout) {
                        Text("退出")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "F56C6C"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(hex: "FEF0F0"))
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
            StatItem(value: learned, label: "已学习", color: Color(hex: "409EFF"), onTap: { onTap("learned") })
            StatItem(value: mastered, label: "已掌握", color: Color(hex: "67C23A"), onTap: { onTap("mastered") })
            StatItem(value: review, label: "待复习", color: Color(hex: "E6A23C"), onTap: { onTap("review") })
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
                    .foregroundColor(Color(hex: "909399"))
                
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
    @State private var notificationEnabled: Bool = UserDefaults.standard.bool(forKey: "notification")
    @State private var soundEnabled: Bool = UserDefaults.standard.bool(forKey: "sound")
    
    var body: some View {
        VStack(spacing: 12) {
            SettingItem(label: "学习提醒", isOn: notificationEnabled) {
                notificationEnabled.toggle()
                UserDefaults.standard.set(notificationEnabled, forKey: "notification")
            }
            
            SettingItem(label: "音效", isOn: soundEnabled) {
                soundEnabled.toggle()
                UserDefaults.standard.set(soundEnabled, forKey: "sound")
            }
            
            Button(action: clearCache) {
                HStack {
                    Text("清除缓存")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "303133"))
                    
                    Spacer()
                    
                    Text("12KB")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "909399"))
                }
                .padding(12)
                .background(Color.white)
                .cornerRadius(12)
            }
        }
    }
    
    private func clearCache() {
        // 清除缓存逻辑
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
                .foregroundColor(Color(hex: "303133"))
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { isOn },
                set: { _ in onChange() }
            ))
            .labelsHidden()
            .tint(Color(hex: "409EFF"))
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
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
                        .foregroundColor(Color(hex: "303133"))
                    
                    Spacer()
                    
                    Text("→")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "667eea"))
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
                            .foregroundColor(Color(hex: "303133"))
                        
                        Spacer()
                        
                        Text("→")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "667eea"))
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
                }
            }
        }
    }
}