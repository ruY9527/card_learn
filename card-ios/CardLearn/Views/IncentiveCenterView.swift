import SwiftUI

/// 激励中心首页
struct IncentiveCenterView: View {
    @EnvironmentObject var appState: AppState
    @State private var userLevel: UserLevel?
    @State private var goalProgress: GoalProgress?
    @State private var recentAchievements: [Achievement] = []
    @State private var userRank: RankPosition?
    @State private var weekRecords: [WeekGoalRecord] = []
    @State private var isLoading = true

    @State private var showAchievementView = false
    @State private var showRankListView = false
    @State private var showGoalSettingView = false
    @State private var showExpLogView = false

    private let apiService = IncentiveApiService.shared

    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView("加载中...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 100)
            } else {
                VStack(spacing: 16) {
                    // 等级卡片
                    levelCard

                    // 今日目标
                    goalCard

                    // 本周目标日历
                    weekGoalCard

                    // 成就入口
                    achievementEntry

                    // 排行榜入口
                    rankEntry
                }
                .padding()
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("激励中心")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(isPresented: $showAchievementView) {
            AchievementView()
        }
        .navigationDestination(isPresented: $showRankListView) {
            RankListView()
        }
        .navigationDestination(isPresented: $showGoalSettingView) {
            GoalSettingView()
        }
        .navigationDestination(isPresented: $showExpLogView) {
            ExpLogView()
        }
        .task {
            await loadData()
        }
    }

    // MARK: - 等级卡片

    private var levelCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Lv.\(userLevel?.level ?? 1)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    Text(userLevel?.levelName ?? "入门学徒")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("累计经验")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(userLevel?.totalExp ?? 0)")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }
            }

            // 经验进度条
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("距下一级还需 \(userLevel?.expToNextLevel ?? 0) 经验")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text(String(format: "%.0f%%", userLevel?.progressPercent ?? 0))
                        .font(.caption.bold())
                        .foregroundColor(.white)
                }
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 8)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white)
                            .frame(width: geometry.size.width * (userLevel?.progressPercent ?? 0) / 100, height: 8)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding()
        .background(
            LinearGradient(colors: [Color(hex: "667eea"), Color(hex: "764ba2")], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(16)
        .onTapGesture { showExpLogView = true }
    }

    // MARK: - 今日目标

    private var goalCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("今日目标")
                    .font(.headline)
                Spacer()
                Button("设置") { showGoalSettingView = true }
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "667eea"))
            }

            HStack(spacing: 24) {
                goalProgressRing(
                    progress: goalProgress?.learnProgress ?? 0,
                    target: goalProgress?.learnTarget ?? 20,
                    label: "学习",
                    color: Color(hex: "667eea")
                )
                goalProgressRing(
                    progress: goalProgress?.masterProgress ?? 0,
                    target: goalProgress?.masterTarget ?? 10,
                    label: "掌握",
                    color: Color(hex: "f093fb")
                )
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    private func goalProgressRing(progress: Int, target: Int, label: String, color: Color) -> some View {
        let percent = target > 0 ? Double(progress) / Double(target) : 0
        return VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: min(percent, 1.0))
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 2) {
                    Text("\(progress)")
                        .font(.title2.bold())
                    Text("/\(target)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 80, height: 80)
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - 本周目标日历

    private var weekGoalCard: some View {
        let weekDays = ["一", "二", "三", "四", "五", "六", "日"]
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date())
        // Monday=1, Sunday=7 in our display, but Calendar uses Sunday=1
        let todayIndex = today == 1 ? 6 : today - 2

        return VStack(alignment: .leading, spacing: 8) {
            Text("本周目标")
                .font(.headline)
            HStack(spacing: 8) {
                ForEach(0..<7, id: \.self) { index in
                    let isToday = index == todayIndex
                    let record = weekRecords.first(where: { r in
                        // Match by weekday index
                        let dateStr = r.date
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        guard let date = formatter.date(from: dateStr) else { return false }
                        let weekday = calendar.component(.weekday, from: date)
                        let dayIndex = weekday == 1 ? 6 : weekday - 2
                        return dayIndex == index
                    })
                    let learnDone = record?.learnCompleted == true
                    let masterDone = record?.masterCompleted == true

                    VStack(spacing: 4) {
                        Text(weekDays[index])
                            .font(.caption2)
                            .foregroundColor(isToday ? Color(hex: "667eea") : .secondary)
                        ZStack {
                            Circle()
                                .fill(learnDone && masterDone ? Color.green.opacity(0.3) :
                                      learnDone || masterDone ? Color(hex: "667eea").opacity(0.2) :
                                      Color(.systemGray5))
                                .frame(width: 28, height: 28)
                            if learnDone && masterDone {
                                Image(systemName: "checkmark")
                                    .font(.caption2.bold())
                                    .foregroundColor(.green)
                            } else if learnDone || masterDone {
                                Circle()
                                    .fill(Color(hex: "667eea"))
                                    .frame(width: 8, height: 8)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    // MARK: - 成就入口

    private var achievementEntry: some View {
        Button(action: { showAchievementView = true }) {
            HStack {
                Image(systemName: "trophy.fill")
                    .font(.title2)
                    .foregroundColor(Color(hex: "FFD700"))
                VStack(alignment: .leading) {
                    Text("我的成就")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("已解锁 \(recentAchievements.filter { $0.unlocked == true }.count)/\(recentAchievements.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
        }
    }

    // MARK: - 排行榜入口

    private var rankEntry: some View {
        Button(action: { showRankListView = true }) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.title2)
                    .foregroundColor(Color(hex: "667eea"))
                VStack(alignment: .leading) {
                    Text("排行榜")
                        .font(.headline)
                        .foregroundColor(.primary)
                    if let rank = userRank {
                        Text("总排名: 第\(rank.rank ?? 0)名 | 连续: \(rank.currentStreak ?? 0)天")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
        }
    }

    // MARK: - 数据加载

    private func loadData() async {
        guard let userId = appState.userInfo?.userId else {
            isLoading = false
            return
        }
        isLoading = true
        do {
            async let levelTask = apiService.getLevelInfo(userId: userId)
            async let goalTask = apiService.getGoalProgress(userId: userId)
            async let achieveTask = apiService.getAchievementList(userId: userId)
            async let rankTask = apiService.getUserRank(userId: userId)
            async let weekTask = apiService.getWeekGoalProgress(userId: userId)

            let (level, goal, achievements, rank, week) = try await (levelTask, goalTask, achieveTask, rankTask, weekTask)

            await MainActor.run {
                self.userLevel = level
                self.goalProgress = goal
                self.recentAchievements = achievements
                self.userRank = rank
                self.weekRecords = week
                self.isLoading = false
            }
        } catch {
            await MainActor.run { self.isLoading = false }
        }
    }
}
