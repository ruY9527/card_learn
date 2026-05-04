import SwiftUI

struct MyCardsView: View {
    @EnvironmentObject var appState: AppState
    @State private var cardList: [MyCard] = []
    @State private var stats: MyCardStats?
    @State private var currentTab: String = "all"
    @State private var pageNum: Int = 1
    @State private var hasMore: Bool = true
    @State private var isLoading: Bool = false
    @State private var showDeleteConfirm: Bool = false
    @State private var cardToDelete: MyCard?

    private let apiService = UserCardApiService.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 统计区域
                if let stats = stats {
                    StatsSection(stats: stats)
                }

                // 状态筛选标签
                StatusTabs(
                    currentTab: currentTab,
                    stats: stats,
                    onChange: { tab in
                        currentTab = tab
                        pageNum = 1
                        cardList = []
                        fetchCards()
                    }
                )

                ScrollView {
                    VStack(spacing: 12) {
                        // 卡片列表
                        if !isLoading || !cardList.isEmpty {
                            ForEach(cardList) { card in
                                MyCardItem(
                                    card: card,
                                    onDelete: {
                                        if card.auditStatus == "0" {
                                            cardToDelete = card
                                            showDeleteConfirm = true
                                        }
                                    }
                                )
                            }

                            // 加载更多
                            if hasMore && !isLoading {
                                LoadMoreButton {
                                    loadMore()
                                }
                            }

                            // 已加载全部
                            if !hasMore && !cardList.isEmpty {
                                AllLoadedText(total: cardList.count)
                            }
                        }

                        // 加载状态
                        if isLoading && cardList.isEmpty {
                            LoadingSection()
                        }

                        // 空状态
                        if cardList.isEmpty && !isLoading {
                            EmptyMyCardsState(tab: currentTab)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 80)
                }
            }
            .navigationTitle("我的卡片")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                pageNum = 1
                cardList = []
                hasMore = true
                fetchStats()
                fetchCards()
            }
            .alert("确认删除", isPresented: $showDeleteConfirm) {
                Button("取消", role: .cancel) {
                    cardToDelete = nil
                }
                Button("删除", role: .destructive) {
                    if let card = cardToDelete {
                        deleteCard(card)
                    }
                }
            } message: {
                Text("删除后无法恢复，是否确认删除这张待审批的卡片？")
            }
        }
    }

    private func fetchStats() {
        let token = appState.token
        guard !token.isEmpty else { return }

        Task {
            do {
                stats = try await apiService.getMyCardStats(token: token)
            } catch {
                // 使用默认值
            }
        }
    }

    private func fetchCards() {
        guard !isLoading else { return }
        let token = appState.token
        guard !token.isEmpty else { return }

        isLoading = true

        Task {
            do {
                let statusParam: String? = currentTab == "all" ? nil : currentTab
                let pageData = try await apiService.getMyCards(
                    auditStatus: statusParam,
                    pageNum: pageNum,
                    pageSize: 10,
                    token: token
                )

                let cards = pageData.records
                let total = pageData.total

                if pageNum == 1 {
                    cardList = cards
                } else {
                    cardList.append(contentsOf: cards)
                }

                hasMore = cardList.count < total
            } catch {
                if pageNum == 1 {
                    cardList = []
                }
            }

            isLoading = false
        }
    }

    private func loadMore() {
        guard hasMore && !isLoading else { return }
        pageNum += 1
        fetchCards()
    }

    private func deleteCard(_ card: MyCard) {
        let token = appState.token
        guard !token.isEmpty else { return }

        Task {
            do {
                try await apiService.deleteMyCard(draftId: card.draftId, token: token)
                cardList.removeAll { $0.draftId == card.draftId }
                fetchStats()
            } catch {
                // 删除失败，保留卡片在列表中
            }
            cardToDelete = nil
        }
    }
}

// 统计区域
struct StatsSection: View {
    let stats: MyCardStats

    var body: some View {
        HStack(spacing: 0) {
            StatBox(value: stats.total ?? 0, label: "全部", color: AppColor.primary)
            StatBox(value: stats.pending ?? 0, label: "待审批", color: AppColor.orange)
            StatBox(value: stats.passed ?? 0, label: "已通过", color: AppColor.green)
            StatBox(value: stats.rejected ?? 0, label: "已拒绝", color: AppColor.danger)
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [AppColor.primary, AppColor.primaryGradientEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

struct MyStatBox: View {
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(color)

            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }
}

// 状态筛选标签
struct StatusTabs: View {
    let currentTab: String
    let stats: MyCardStats?
    let onChange: (String) -> Void

    var body: some View {
        HStack(spacing: 12) {
            StatusTabItem(
                title: "全部(\(stats?.total ?? 0))",
                isSelected: currentTab == "all",
                action: { onChange("all") }
            )

            StatusTabItem(
                title: "待审批(\(stats?.pending ?? 0))",
                isSelected: currentTab == "0",
                action: { onChange("0") }
            )

            StatusTabItem(
                title: "已通过(\(stats?.passed ?? 0))",
                isSelected: currentTab == "1",
                action: { onChange("1") }
            )

            StatusTabItem(
                title: "已拒绝(\(stats?.rejected ?? 0))",
                isSelected: currentTab == "2",
                action: { onChange("2") }
            )
        }
        .padding(12)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct StatusTabItem: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: isSelected ? .medium : .regular))
                .foregroundColor(isSelected ? .white : AppColor.textMedium)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ?
                              AppColor.primary :
                              AppColor.backgroundLight)
                )
        }
    }
}

// 卡片列表项
struct MyCardItem: View {
    let card: MyCard
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 头部：状态标签
            HStack {
                Text(card.statusLabel)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(hex: card.statusColor))
                    .cornerRadius(4)

                Text("难度 \(card.difficultyLevel ?? 2)")
                    .font(.system(size: 12))
                    .foregroundColor(AppColor.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColor.backgroundLight)
                    .cornerRadius(4)

                Spacer()

                if let subjectName = card.subjectName {
                    Text(subjectName)
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.primary)
                }
            }

            // 正面内容
            Text(card.frontContent)
                .font(.system(size: 15))
                .foregroundColor(AppColor.textPrimary)
                .lineLimit(3)

            // 背面内容（预览）
            Text(card.backContent)
                .font(.system(size: 13))
                .foregroundColor(AppColor.textMedium)
                .lineLimit(2)

            // 审核备注（如果有）
            if card.auditStatus == "2", let remark = card.auditRemark, !remark.isEmpty {
                HStack(spacing: 8) {
                    Text("📝")
                        .font(.system(size: 12))
                    Text("审核备注：\(remark)")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.danger)
                }
                .padding(10)
                .background(AppColor.orangeLight)
                .cornerRadius(8)
            }

            // 底部：时间和删除按钮
            HStack {
                if let createTime = card.createTime {
                    Text(createTime)
                        .font(.system(size: 11))
                        .foregroundColor(AppColor.textSecondary)
                }

                Spacer()

                if card.auditStatus == "0" {
                    Button(action: onDelete) {
                        Text("删除")
                            .font(.system(size: 12))
                            .foregroundColor(AppColor.danger)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppColor.dangerLight)
                            .cornerRadius(6)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// 空状态
struct EmptyMyCardsState: View {
    let tab: String

    var body: some View {
        VStack(spacing: 12) {
            Text("📝")
                .font(.system(size: 40))

            Text(tab == "all" ? "还没有贡献过卡片" :
                 tab == "0" ? "没有待审批的卡片" :
                 tab == "1" ? "没有已通过的卡片" :
                 "没有已拒绝的卡片")
                .font(.system(size: 16))
                .foregroundColor(AppColor.textMedium)

            if tab == "all" {
                Text("点击下方按钮添加知识点卡片")
                    .font(.system(size: 13))
                    .foregroundColor(AppColor.textSecondary)
            }
        }
        .padding(.vertical, 50)
    }
}
