import SwiftUI

/// 学习统计页面
struct StatsView: View {
    @EnvironmentObject var appState: AppState
    @State private var stats: LearningStatsResponse?
    @State private var subjectProgress: [SubjectProgressResponse] = []
    @State private var selectedMajorId: Int? = nil
    @State private var isLoading = false
    @State private var navigateToTodayLearned = false
    @State private var navigateToTodayMastered = false
    @State private var navigateToCurrentStreak = false
    @State private var navigateToLongestStreak = false
    @State private var navigateToTotalDays = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if isLoading && stats == nil {
                        LoadingSection()
                    } else {
                        // Streak 卡片
                        streakCard

                        // 今日学习
                        todayCard

                        // 学习报告入口
                        reportEntry

                        // 科目进度
                        subjectProgressSection
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
            .navigationTitle("学习统计")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await loadData()
            }
            .navigationDestination(isPresented: $navigateToTodayLearned) {
                TodayCardsView(type: "todayLearned", date: todayDateString)
            }
            .navigationDestination(isPresented: $navigateToTodayMastered) {
                TodayCardsView(type: "todayMastered", date: todayDateString)
            }
            .navigationDestination(isPresented: $navigateToCurrentStreak) {
                StreakDetailView(streakType: .current, streakValue: stats?.currentStreak ?? 0)
            }
            .navigationDestination(isPresented: $navigateToLongestStreak) {
                StreakDetailView(streakType: .longest, streakValue: stats?.longestStreak ?? 0)
            }
            .navigationDestination(isPresented: $navigateToTotalDays) {
                StreakDetailView(streakType: .total, streakValue: stats?.totalStudyDays ?? 0)
            }
        }
        .task {
            await loadData()
        }
    }

    // MARK: - Streak 卡片

    private var streakCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("学习连续记录")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }

            HStack(spacing: 0) {
                streakItem(
                    value: stats?.currentStreak ?? 0,
                    label: "当前连续",
                    icon: "flame.fill",
                    color: .white
                )
                .onTapGesture { navigateToCurrentStreak = true }

                Divider()
                    .frame(height: 40)
                    .background(Color.white.opacity(0.3))

                streakItem(
                    value: stats?.longestStreak ?? 0,
                    label: "最长连续",
                    icon: "trophy.fill",
                    color: .white
                )
                .onTapGesture { navigateToLongestStreak = true }

                Divider()
                    .frame(height: 40)
                    .background(Color.white.opacity(0.3))

                streakItem(
                    value: stats?.totalStudyDays ?? 0,
                    label: "累计天数",
                    icon: "calendar",
                    color: .white
                )
                .onTapGesture { navigateToTotalDays = true }
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [AppColor.primary, AppColor.primaryGradientEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: AppColor.primary.opacity(0.3), radius: 8, x: 0, y: 4)
    }

    private func streakItem(value: Int, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)

            Text("\(value)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)

            Text(label)
                .font(.system(size: 11))
                .foregroundColor(color.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - 今日学习

    private var todayCard: some View {
        HStack(spacing: 16) {
            todayItem(
                count: stats?.learnedToday ?? 0,
                label: "今日学习",
                color: AppColor.info
            )
            .onTapGesture { navigateToTodayLearned = true }

            todayItem(
                count: stats?.masteredToday ?? 0,
                label: "今日掌握",
                color: AppColor.success
            )
            .onTapGesture { navigateToTodayMastered = true }
        }
    }

    private func todayItem(count: Int, label: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "book.fill")
                .font(.system(size: 20))
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(count)")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(AppColor.textPrimary)
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(AppColor.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    // MARK: - 学习报告入口

    private var reportEntry: some View {
        NavigationLink(destination: ReportView()) {
            HStack(spacing: 12) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "667eea"))

                VStack(alignment: .leading, spacing: 2) {
                    Text("学习报告")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColor.textPrimary)
                    Text("查看周报和月报，了解学习趋势")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }

    // MARK: - 科目进度

    /// 去重后的专业列表
    private var majors: [(id: Int?, name: String)] {
        var seen = Set<Int>()
        var result: [(id: Int?, name: String)] = []
        for s in subjectProgress {
            if let mid = s.majorId, !seen.contains(mid) {
                seen.insert(mid)
                result.append((id: mid, name: s.majorName ?? "未知专业"))
            }
        }
        return result
    }

    /// 根据选择的专业过滤科目
    private var filteredSubjects: [SubjectProgressResponse] {
        if let selectedId = selectedMajorId {
            return subjectProgress.filter { $0.majorId == selectedId }
        }
        return subjectProgress
    }

    private var subjectProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("科目进度")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColor.textPrimary)

                Spacer()

                // 专业下拉选择
                Menu {
                    Button("全部专业") { selectedMajorId = nil }
                    ForEach(majors, id: \.id) { major in
                        Button(major.name) { selectedMajorId = major.id }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(selectedMajorName)
                            .font(.system(size: 13))
                            .foregroundColor(AppColor.primary)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10))
                            .foregroundColor(AppColor.primary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppColor.primary.opacity(0.1))
                    .cornerRadius(8)
                }
            }

            if filteredSubjects.isEmpty {
                Text("暂无学习数据")
                    .font(.system(size: 14))
                    .foregroundColor(AppColor.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                ForEach(filteredSubjects) { subject in
                    SubjectProgressCard(subject: subject)
                }
            }
        }
    }

    private var selectedMajorName: String {
        if let selectedId = selectedMajorId,
           let major = majors.first(where: { $0.id == selectedId }) {
            return major.name
        }
        return "全部专业"
    }

    // MARK: - 数据加载

    private var todayDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    private func loadData() async {
        guard appState.isLoggedIn, let userId = appState.userInfo?.userId else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            async let statsResult = LearningApiService.shared.getLearningStats(appUserId: userId)
            async let progressResult = LearningApiService.shared.getSubjectProgress(appUserId: userId)

            stats = try await statsResult
            subjectProgress = try await progressResult
        } catch {
            print("[StatsView] 加载数据失败: \(error)")
        }
    }
}

// MARK: - 科目进度卡片

struct SubjectProgressCard: View {
    let subject: SubjectProgressResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(subject.subjectName)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppColor.textPrimary)

                Spacer()

                Text(String(format: "%.1f%%", subject.masteryRate))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(masteryColor)
            }

            // 进度条
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppColor.backgroundLight)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(masteryGradient)
                        .frame(width: geometry.size.width * CGFloat(subject.masteryRate / 100), height: 8)
                }
            }
            .frame(height: 8)

            HStack {
                Text("已学 \(subject.learnedCount)/\(subject.totalCards)")
                    .font(.system(size: 12))
                    .foregroundColor(AppColor.textSecondary)

                Spacer()

                Text("掌握 \(subject.masteredCount)")
                    .font(.system(size: 12))
                    .foregroundColor(AppColor.textSecondary)
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    private var masteryColor: Color {
        if subject.masteryRate >= 80 { return AppColor.success }
        if subject.masteryRate >= 50 { return AppColor.info }
        if subject.masteryRate >= 20 { return AppColor.warning }
        return AppColor.error
    }

    private var masteryGradient: LinearGradient {
        if subject.masteryRate >= 80 {
            return LinearGradient(colors: [AppColor.accentGreen, AppColor.accentGreenEnd], startPoint: .leading, endPoint: .trailing)
        }
        if subject.masteryRate >= 50 {
            return LinearGradient(colors: [AppColor.info, AppColor.primary], startPoint: .leading, endPoint: .trailing)
        }
        return LinearGradient(colors: [AppColor.warning, AppColor.orange], startPoint: .leading, endPoint: .trailing)
    }
}
