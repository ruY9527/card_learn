import SwiftUI

/// 复习计划列表页面
struct ReviewListView: View {
    @EnvironmentObject var appState: AppState
    @State private var reviewPlans: [ReviewPlanResponse] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedCard: ReviewPlanResponse?
    @State private var showHistorySheet = false
    @State private var historyCardId: Int?
    @State private var studyHistory: [StudyHistoryRecordItem] = []
    @State private var isLoadingHistory = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if isLoading && reviewPlans.isEmpty {
                    LoadingSection()
                } else if reviewPlans.isEmpty {
                    emptyState
                } else {
                    planList
                }
            }
            .navigationTitle("复习计划")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await loadReviewPlan()
            }
            .sheet(isPresented: $showHistorySheet) {
                if let cardId = historyCardId {
                    studyHistorySheet(cardId: cardId)
                }
            }
            .sheet(item: $selectedCard) { card in
                ReviewCardDetailView(
                    card: card,
                    userId: appState.userInfo?.userId,
                    onDismiss: { selectedCard = nil }
                )
            }
        }
        .task {
            await loadReviewPlan()
        }
    }

    // MARK: - 空状态

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(AppColor.success)
            Text("暂无待复习卡片")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(AppColor.textPrimary)
            Text("今日卡片都已复习完毕，继续保持！")
                .font(.system(size: 14))
                .foregroundColor(AppColor.textSecondary)
            Spacer()
        }
        .padding()
    }

    // MARK: - 计划列表

    private var planList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                // 概览卡片
                overviewCard

                // 按日期分组
                ForEach(groupedPlans.keys.sorted(), id: \.self) { date in
                    Section(header: dateHeader(date)) {
                        ForEach(groupedPlans[date] ?? []) { plan in
                            ReviewPlanCard(
                                plan: plan,
                                onTap: {
                                    selectedCard = plan
                                },
                                onHistoryTap: {
                                    historyCardId = plan.cardId
                                    showHistorySheet = true
                                    Task { await loadStudyHistory(cardId: plan.cardId) }
                                }
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
    }

    // MARK: - 概览卡片

    private var overviewCard: some View {
        HStack(spacing: 20) {
            VStack(spacing: 4) {
                Text("\(reviewPlans.count)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppColor.primary)
                Text("待复习")
                    .font(.system(size: 12))
                    .foregroundColor(AppColor.textSecondary)
            }
            .frame(maxWidth: .infinity)

            Divider()
                .frame(height: 40)

            VStack(spacing: 4) {
                Text(todayCount)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppColor.warning)
                Text("今日")
                    .font(.system(size: 12))
                    .foregroundColor(AppColor.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    // MARK: - 日期分组

    private var groupedPlans: [String: [ReviewPlanResponse]] {
        Dictionary(grouping: reviewPlans, by: { $0.scheduledDate })
    }

    private func dateHeader(_ date: String) -> some View {
        HStack {
            Text(formatDate(date))
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColor.textMedium)
            Spacer()
            Text("\(groupedPlans[date]?.count ?? 0)张")
                .font(.system(size: 12))
                .foregroundColor(AppColor.textSecondary)
        }
        .padding(.top, 8)
    }

    // MARK: - 数据加载

    private var todayCount: String {
        let today = formatDateString(Date())
        let count = reviewPlans.filter { $0.scheduledDate == today }.count
        return "\(count)"
    }

    private func loadReviewPlan() async {
        guard appState.isLoggedIn, let userId = appState.userInfo?.userId else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            reviewPlans = try await APIService.shared.getReviewPlan(appUserId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func formatDate(_ dateStr: String) -> String {
        let today = formatDateString(Date())
        let tomorrow = formatDateString(Calendar.current.date(byAdding: .day, value: 1, to: Date())!)

        if dateStr == today {
            return "今天"
        } else if dateStr == tomorrow {
            return "明天"
        } else {
            let parts = dateStr.split(separator: "-")
            if parts.count == 3 {
                return "\(parts[1])月\(parts[2])日"
            }
            return dateStr
        }
    }

    private func formatDateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    // MARK: - 学习历史

    private func loadStudyHistory(cardId: Int) async {
        guard let userId = appState.userInfo?.userId else { return }
        isLoadingHistory = true
        studyHistory = []
        defer { isLoadingHistory = false }

        do {
            let response = try await APIService.shared.getCardStudyHistory(cardId: cardId, userId: userId)
            studyHistory = response.records ?? []
        } catch {
            studyHistory = []
        }
    }

    private func studyHistorySheet(cardId: Int) -> some View {
        NavigationStack {
            VStack(spacing: 0) {
                if isLoadingHistory {
                    Spacer()
                    ProgressView("加载中...")
                    Spacer()
                } else if studyHistory.isEmpty {
                    Spacer()
                    Text("暂无学习记录")
                        .font(.system(size: 15))
                        .foregroundColor(AppColor.textSecondary)
                    Spacer()
                } else {
                    List {
                        ForEach(studyHistory) { record in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color(hex: record.statusColorHex))
                                    .frame(width: 8, height: 8)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(record.statusText)
                                        .font(.system(size: 14))
                                        .foregroundColor(AppColor.textPrimary)

                                    if let time = record.createTime {
                                        Text(time)
                                            .font(.system(size: 12))
                                            .foregroundColor(AppColor.textSecondary)
                                    }
                                }

                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("学习记录")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - 复习计划卡片

struct ReviewPlanCard: View {
    let plan: ReviewPlanResponse
    let onTap: () -> Void
    let onHistoryTap: () -> Void

    private var difficultyColor: Color {
        switch plan.difficultyLevel {
        case 1: return AppColor.success
        case 2: return AppColor.info
        case 3: return AppColor.warning
        case 4: return AppColor.error
        default: return AppColor.neutralGray
        }
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // 难度指示器
                RoundedRectangle(cornerRadius: 3)
                    .fill(difficultyColor)
                    .frame(width: 4, height: 50)

                VStack(alignment: .leading, spacing: 6) {
                    Text(plan.frontContent)
                        .font(.system(size: 15))
                        .foregroundColor(AppColor.textPrimary)
                        .lineLimit(2)

                    HStack(spacing: 8) {
                        if let subject = plan.subjectName {
                            Text(subject)
                                .font(.system(size: 11))
                                .foregroundColor(AppColor.info)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppColor.infoLight)
                                .cornerRadius(4)
                        }

                        if let count = plan.studyCount, count > 0 {
                            Button(action: onHistoryTap) {
                                Text("学习\(count)次")
                                    .font(.system(size: 11))
                                    .foregroundColor(AppColor.accentGreen)
                                    .underline()
                            }
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(AppColor.textSecondary)
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

// MARK: - 复习卡片详情

struct ReviewCardDetailView: View {
    let card: ReviewPlanResponse
    let userId: Int?
    let onDismiss: () -> Void

    @State private var isFlipped = false
    @State private var isSubmitting = false
    @State private var submitted = false
    @State private var showError = false
    @State private var errorMessage = ""

    private let apiService = APIService.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // 卡片内容
                VStack(spacing: 16) {
                    // 正面
                    VStack(alignment: .leading, spacing: 8) {
                        Text("问题")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AppColor.textSecondary)
                        Text(card.frontContent)
                            .font(.system(size: 18))
                            .foregroundColor(AppColor.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)

                    // 背面（点击翻转）
                    if isFlipped {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("答案")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(AppColor.textSecondary)
                            Text(card.backContent ?? "暂无答案")
                                .font(.system(size: 16))
                                .foregroundColor(AppColor.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(AppColor.infoLight)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding(.horizontal, 20)

                // 翻转按钮
                if !isFlipped {
                    Button(action: { withAnimation(.easeInOut(duration: 0.3)) { isFlipped = true } }) {
                        Text("查看答案")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(14)
                            .background(AppColor.primary)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                }

                // 复习按钮
                if isFlipped && !submitted {
                    VStack(spacing: 12) {
                        Text("掌握程度")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColor.textSecondary)

                        HStack(spacing: 12) {
                            ReviewStatusButton(
                                title: "不熟",
                                color: AppColor.danger,
                                action: { submitReview(status: 0) }
                            )
                            ReviewStatusButton(
                                title: "模糊",
                                color: AppColor.orange,
                                action: { submitReview(status: 1) }
                            )
                            ReviewStatusButton(
                                title: "掌握",
                                color: AppColor.green,
                                action: { submitReview(status: 2) }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // 提交成功提示
                if submitted {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(AppColor.success)
                        Text("复习记录已保存")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(AppColor.textPrimary)
                    }
                }

                Spacer()
            }
            .navigationTitle("复习卡片")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") { onDismiss() }
                        .foregroundColor(AppColor.primary)
                }
            }
            .alert("提交失败", isPresented: $showError) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func submitReview(status: Int) {
        guard !isSubmitting, let userId = userId else { return }
        isSubmitting = true

        Task {
            do {
                _ = try await apiService.submitSimpleReview(
                    cardId: card.cardId,
                    userId: userId,
                    status: status
                )
                await MainActor.run {
                    submitted = true
                    isSubmitting = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    isSubmitting = false
                }
            }
        }
    }
}

struct ReviewStatusButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(14)
                .background(color)
                .cornerRadius(12)
        }
    }
}
