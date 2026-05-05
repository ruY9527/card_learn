import SwiftUI

/// 学习报告页面
struct ReportView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0  // 0=周报, 1=月报
    @State private var report: ReportDetail?
    @State private var isLoading = true
    @State private var errorMessage: String?

    private let apiService = ReportApiService.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Tab切换
                tabBar

                if isLoading {
                    ProgressView("加载中...")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                } else if let report = report {
                    // 报告头部
                    reportHeader(report)

                    // 学习概览
                    overviewCard(report.overview)

                    // 掌握率趋势
                    if let trend = report.masteryTrend {
                        masteryTrendCard(trend)
                    }

                    // 科目分析
                    if let subjects = report.subjectAnalysis, !subjects.isEmpty {
                        subjectAnalysisCard(subjects)
                    }

                    // 学习习惯
                    if let habits = report.learningHabits {
                        learningHabitsCard(habits)
                    }

                    // 薄弱点预警
                    if let weakPoints = report.weakPoints, !weakPoints.isEmpty {
                        weakPointsCard(weakPoints)
                    }

                    // 改进建议
                    if let suggestions = report.suggestions, !suggestions.isEmpty {
                        suggestionsCard(suggestions)
                    }
                } else {
                    Text("暂无报告数据")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("学习报告")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadReport() }
        .onChange(of: selectedTab) { _ in
            Task { await loadReport() }
        }
    }

    // MARK: - Tab栏

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabButton(title: "周报", index: 0)
            tabButton(title: "月报", index: 1)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    private func tabButton(title: String, index: Int) -> some View {
        Button(action: { withAnimation(.easeInOut(duration: 0.2)) { selectedTab = index } }) {
            Text(title)
                .font(.system(size: 15, weight: selectedTab == index ? .bold : .medium))
                .foregroundColor(selectedTab == index ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(selectedTab == index ? Color(hex: "667eea") : Color.clear)
                .cornerRadius(12)
        }
    }

    // MARK: - 报告头部

    private func reportHeader(_ report: ReportDetail) -> some View {
        VStack(spacing: 4) {
            Text(report.reportType == "weekly" ? "学习周报" : "学习月报")
                .font(.system(size: 20, weight: .bold))
            Text("\(formatDate(report.periodStart)) ~ \(formatDate(report.periodEnd))")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    // MARK: - 学习概览

    private func overviewCard(_ overview: ReportOverview) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("学习概览")
                .font(.headline)

            HStack(spacing: 0) {
                overviewItem(value: "\(overview.totalCards)", label: "学习卡片", icon: "book.fill", color: Color(hex: "667eea"))
                Divider().frame(height: 40)
                overviewItem(value: "\(overview.newMastered)", label: "新掌握", icon: "checkmark.circle.fill", color: Color(hex: "4CAF50"))
                Divider().frame(height: 40)
                overviewItem(value: "\(overview.forgotten)", label: "遗忘", icon: "exclamationmark.triangle.fill", color: Color(hex: "FF6B6B"))
                Divider().frame(height: 40)
                overviewItem(value: "\(overview.streakDays)", label: "连续天数", icon: "flame.fill", color: Color(hex: "FFD700"))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    private func overviewItem(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - 掌握率趋势

    private func masteryTrendCard(_ trend: MasteryTrend) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("掌握率趋势")
                .font(.headline)

            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("期初")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(trend.startRate)%")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                }

                Image(systemName: "arrow.right")
                    .foregroundColor(.secondary)

                VStack(spacing: 4) {
                    Text("期末")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(trend.endRate)%")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "4CAF50"))
                }

                Spacer()

                VStack(spacing: 4) {
                    Text("变化")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack(spacing: 2) {
                        Image(systemName: trend.changeRate >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 12))
                        Text("\(abs(trend.changeRate))%")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundColor(trend.changeRate >= 0 ? Color(hex: "4CAF50") : Color(hex: "FF6B6B"))
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    // MARK: - 科目分析

    private func subjectAnalysisCard(_ subjects: [SubjectAnalysis]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("科目进度")
                .font(.headline)

            ForEach(subjects) { subject in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(subject.subjectName)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        Spacer()
                        Text("\(subject.masteryRate)%")
                            .font(.subheadline.bold())
                            .foregroundColor(subject.masteryRate < 40 ? Color(hex: "FF6B6B") : Color(hex: "4CAF50"))
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray5))
                                .frame(height: 8)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(subject.masteryRate < 40 ? Color(hex: "FF6B6B") : Color(hex: "667eea"))
                                .frame(width: geo.size.width * CGFloat(subject.masteryRate) / 100, height: 8)
                        }
                    }
                    .frame(height: 8)
                }

                if subject.id != subjects.last?.id {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    // MARK: - 学习习惯

    private func learningHabitsCard(_ habits: LearningHabits) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("学习习惯")
                .font(.headline)

            HStack(spacing: 0) {
                habitItem(label: "上午", percent: habits.morning, color: Color(hex: "FFD700"))
                habitItem(label: "下午", percent: habits.afternoon, color: Color(hex: "667eea"))
                habitItem(label: "晚上", percent: habits.evening, color: Color(hex: "9C27B0"))
            }

            Divider()

            HStack {
                Label(habits.peakHour, systemImage: "clock.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Label("最活跃: \(habits.mostActiveDay)", systemImage: "star.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    private func habitItem(label: String, percent: Int, color: Color) -> some View {
        VStack(spacing: 6) {
            Text("\(percent)%")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - 薄弱点预警

    private func weakPointsCard(_ weakPoints: [WeakPoint]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("薄弱点预警")
                    .font(.headline)
                Spacer()
                NavigationLink("查看全部") {
                    WeakPointListView()
                }
                .font(.caption)
            }

            ForEach(weakPoints.prefix(5)) { wp in
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(Color(hex: "FF6B6B"))
                        .font(.system(size: 14))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(wp.frontContent ?? "未知卡片")
                            .font(.subheadline)
                            .lineLimit(1)
                        Text(wp.subjectName ?? "")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Text("错误\(wp.errorCount)次")
                        .font(.caption)
                        .foregroundColor(Color(hex: "FF6B6B"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: "FF6B6B").opacity(0.1))
                        .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    // MARK: - 改进建议

    private func suggestionsCard(_ suggestions: [Suggestion]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("改进建议")
                .font(.headline)

            ForEach(Array(suggestions.enumerated()), id: \.offset) { index, suggestion in
                HStack(alignment: .top, spacing: 8) {
                    Text("\(index + 1).")
                        .font(.subheadline.bold())
                        .foregroundColor(Color(hex: "667eea"))

                    Text(suggestion.content)
                        .font(.subheadline)
                        .foregroundColor(.primary)

                    Spacer()

                    if suggestion.priority == "high" {
                        Text("重要")
                            .font(.caption2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(hex: "FF6B6B"))
                            .cornerRadius(4)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    // MARK: - 数据加载

    private func loadReport() async {
        isLoading = true
        errorMessage = nil
        let type = selectedTab == 0 ? "weekly" : "monthly"
        do {
            let data = try await apiService.getCurrentReport(userId: appState.userInfo?.userId, type: type)
            await MainActor.run {
                self.report = data
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    // MARK: - 辅助方法

    private func formatDate(_ dateStr: String) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        guard let date = fmt.date(from: dateStr) else { return dateStr }
        fmt.dateFormat = "M月d日"
        return fmt.string(from: date)
    }
}
