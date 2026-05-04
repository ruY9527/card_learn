import SwiftUI

struct StudyView: View {
    @EnvironmentObject var appState: AppState
    let subjectId: Int
    let subjectName: String
    
    @State private var cardList: [Card] = []
    @State private var cardListTotal: Int = 0
    @State private var learnedCount: Int = 0
    @State private var masteredCount: Int = 0
    @State private var reviewCount: Int = 0
    @State private var totalCount: Int = 0
    @State private var currentTab: String = "all"
    @State private var pageNum: Int = 1
    @State private var hasMore: Bool = true
    @State private var isLoading: Bool = false
    @State private var searchKeyword: String = ""
    @FocusState private var isSearchFocused: Bool
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    @State private var navigateToCardDetail: Bool = false
    @State private var selectedCard: Card?
    @State private var selectedCardIndex: Int = 0
    @State private var navigateToProgressCards: Bool = false
    @State private var progressCardsType: String = "learned"
    
    private let apiService = APIService.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 头部统计区域
                HeaderSection(
                    subjectName: subjectName,
                    learned: learnedCount,
                    mastered: masteredCount,
                    review: reviewCount,
                    total: totalCount,
                    onStatTap: { type in
                        progressCardsType = type
                        navigateToProgressCards = true
                    }
                )
                
                ScrollView {
                    VStack(spacing: 16) {
                        // 搜索区域
                        SearchSection(
                            keyword: $searchKeyword,
                            isFocused: $isSearchFocused,
                            onSearch: {
                                pageNum = 1
                                fetchCards()
                            },
                            onClear: {
                                searchKeyword = ""
                                pageNum = 1
                                fetchCards()
                            }
                        )

                        // 快速开始按钮
                        if !cardList.isEmpty {
                            QuickStartButton {
                                startStudy()
                            }
                        }

                        // 筛选标签
                        FilterTabs(
                            currentTab: currentTab,
                            total: cardListTotal,
                            learned: learnedCount,
                            onChange: { tab in
                                currentTab = tab
                                pageNum = 1
                                fetchCards()
                            }
                        )

                        // 卡片列表
                        LazyVStack(spacing: 12) {
                            ForEach(Array(cardList.enumerated()), id: \.element.cardId) { index, card in
                                CardListItem(card: card)
                                    .onTapGesture {
                                        selectedCard = card
                                        selectedCardIndex = index
                                        navigateToCardDetail = true
                                    }
                            }

                            // 加载更多
                            if hasMore && !isLoading {
                                LoadMoreButton {
                                    loadMore()
                                }
                            }

                            // 已加载全部
                            if !hasMore && !cardList.isEmpty {
                                AllLoadedText(total: cardListTotal)
                            }
                        }
                        .padding(.horizontal, 16)

                        // 加载中指示器（列表底部，不影响已有内容）
                        if isLoading {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: AppColor.primary))
                                    .scaleEffect(0.8)
                                Text("加载中...")
                                    .font(.system(size: 13))
                                    .foregroundColor(AppColor.textSecondary)
                            }
                            .padding(.vertical, 12)
                        }

                        // 空状态（仅在非加载且列表为空时显示）
                        if cardList.isEmpty && !isLoading {
                            EmptyState(tab: currentTab)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 80)
                }
            }
            .navigationTitle(subjectName)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $navigateToCardDetail) {
                if selectedCard != nil {
                    CardDetailView(
                        cardList: cardList,
                        currentIndex: selectedCardIndex,
                        subjectId: subjectId,
                        subjectName: subjectName
                    )
                }
            }
            .navigationDestination(isPresented: $navigateToProgressCards) {
                ProgressCardsView(type: progressCardsType, subjectId: subjectId)
            }
        }
        .onAppear {
            pageNum = 1
            cardList = []
            hasMore = true
            fetchCards()
            fetchStats()
        }
        .alert("加载失败", isPresented: $showError) {
            Button("重试") {
                fetchCards()
                fetchStats()
            }
            Button("确定", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private func fetchCards() {
        guard !isLoading else { return }

        Task {
            isLoading = true

            do {
                let userId = appState.userInfo?.userId
                let pageData = try await apiService.getCardPage(
                    subjectId: subjectId,
                    frontContent: searchKeyword.isEmpty ? nil : searchKeyword,
                    appUserId: userId,
                    status: currentTab,
                    pageNum: pageNum,
                    pageSize: 20
                )
                
                let cards = pageData.records
                let total = pageData.total

                if pageNum == 1 {
                    cardList = cards
                } else {
                    cardList.append(contentsOf: cards)
                }

                cardListTotal = total
                hasMore = cardList.count < total
            } catch {
                if pageNum == 1 {
                    cardList = []
                }
                errorMessage = error.localizedDescription
                showError = true
            }

            isLoading = false
        }
    }
    
    private func fetchStats() {
        Task {
            do {
                let userId = appState.userInfo?.userId
                let stats = try await apiService.getSubjectStats(subjectId: subjectId, appUserId: userId)
                
                learnedCount = stats.learned ?? 0
                masteredCount = stats.mastered ?? 0
                reviewCount = stats.review ?? 0
                totalCount = stats.total ?? 0
            } catch {
                // 统计加载失败不影响卡片显示，静默处理
            }
        }
    }
    
    private func loadMore() {
        guard hasMore && !isLoading else { return }
        pageNum += 1
        fetchCards()
    }
    
    private func startStudy() {
        // 找到第一个未学习的卡片
        let firstUnlearned = cardList.first { ($0.status ?? 0) == 0 }
        selectedCard = firstUnlearned ?? cardList.first
        selectedCardIndex = cardList.firstIndex(of: selectedCard!) ?? 0
        navigateToCardDetail = true
    }
}

// 搜索区域
struct SearchSection: View {
    @Binding var keyword: String
    var isFocused: FocusState<Bool>.Binding
    let onSearch: () -> Void
    let onClear: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15))
                    .foregroundColor(AppColor.disabledText)

                TextField("搜索卡片内容", text: $keyword)
                    .focused(isFocused)
                    .font(.system(size: 15))
                    .submitLabel(.search)
                    .onSubmit {
                        onSearch()
                    }

                if !keyword.isEmpty {
                    Button(action: onClear) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 15))
                            .foregroundColor(AppColor.disabledText)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)

            Button(action: onSearch) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(AppColor.primary)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal, 16)
    }
}

// 头部统计区域
struct HeaderSection: View {
    let subjectName: String
    let learned: Int
    let mastered: Int
    let review: Int
    let total: Int
    let onStatTap: (String) -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColor.primary, AppColor.primaryGradientEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 12) {
                Text(subjectName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)

                HStack(spacing: 0) {
                    StatBox(value: learned, label: "已学习", color: .white)
                        .onTapGesture { onStatTap("learned") }
                    StatBox(value: mastered, label: "已掌握", color: AppColor.accentGreen)
                        .onTapGesture { onStatTap("mastered") }
                    StatBox(value: review, label: "待复习", color: AppColor.gold)
                        .onTapGesture { onStatTap("review") }
                    StatBox(value: total, label: "总卡片", color: .white.opacity(0.8))
                        .onTapGesture { onStatTap("all") }
                }
                .padding(8)
                .background(Color.white.opacity(0.15))
                .cornerRadius(12)
            }
            .padding(20)
        }
        .frame(height: 140)
        .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
        .padding(.bottom, -20)
    }
}

struct StatBox: View {
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)

            HStack(spacing: 2) {
                Text(label)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.7))

                Image(systemName: "chevron.right")
                    .font(.system(size: 8))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// 快速开始按钮
struct QuickStartButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text("📖")
                    .font(.system(size: 24))
                
                Text("开始学习")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("左右滑动切换卡片")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(
                LinearGradient(
                    colors: [AppColor.accentGreen, AppColor.accentGreenEnd],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .shadow(color: AppColor.accentGreen.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal, 16)
    }
}

// 筛选标签
struct FilterTabs: View {
    let currentTab: String
    let total: Int
    let learned: Int
    let onChange: (String) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            FilterTabItem(
                title: "全部(\(total))",
                isSelected: currentTab == "all",
                action: { onChange("all") }
            )
            
            FilterTabItem(
                title: "已学(\(learned))",
                isSelected: currentTab == "learned",
                action: { onChange("learned") }
            )
            
            FilterTabItem(
                title: "未学(\(total - learned))",
                isSelected: currentTab == "unlearned",
                action: { onChange("unlearned") }
            )
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 16)
    }
}

struct FilterTabItem: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .medium : .regular))
                .foregroundColor(isSelected ? .white : AppColor.textMedium)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ?
                              LinearGradient(colors: [AppColor.primary, AppColor.primaryGradientEnd], startPoint: .topLeading, endPoint: .bottomTrailing) :
                              LinearGradient(colors: [AppColor.backgroundLight, AppColor.backgroundLight], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                )
        }
    }
}

// 卡片列表项
struct CardListItem: View {
    let card: Card
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                DifficultyBadge(level: card.difficultyLevel ?? 1)
                
                Spacer()
                
                StatusBadge(status: card.status ?? 0)
            }
            
            Text(card.frontContent)
                .font(.system(size: 15))
                .foregroundColor(AppColor.textPrimary)
                .lineLimit(3)
            
            HStack {
                if let subjectName = card.subjectName {
                    Text(subjectName)
                        .font(.system(size: 11))
                        .foregroundColor(AppColor.primary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(AppColor.infoLight)
                        .cornerRadius(4)
                }
                
                Text("#\(card.cardId)")
                    .font(.system(size: 11))
                    .foregroundColor(AppColor.textSecondary)
                
                Spacer()
                
                Text("点击查看 →")
                    .font(.system(size: 12))
                    .foregroundColor(AppColor.primary)
            }
            
            if let tags = card.tags, !tags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 11))
                            .foregroundColor(AppColor.textSecondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppColor.backgroundLight)
                            .cornerRadius(4)
                    }
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct DifficultyBadge: View {
    let level: Int
    
    var body: some View {
        Text("难度 \(level)")
            .font(.system(size: 11))
            .foregroundColor(level <= 2 ? AppColor.green :
                             level == 3 ? AppColor.orange :
                             AppColor.danger)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(level <= 2 ? AppColor.greenLight :
                        level == 3 ? AppColor.orangeLight :
                        AppColor.dangerLight)
            .cornerRadius(4)
    }
}

struct StatusBadge: View {
    let status: Int
    
    var body: some View {
        Text(status == 2 ? "✓ 掌握" : status == 1 ? "~ 模糊" : "✗ 未学")
            .font(.system(size: 11))
            .foregroundColor(status == 2 ? AppColor.green :
                             status == 1 ? AppColor.amber :
                             AppColor.neutralGray)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(status == 2 ? AppColor.greenLight :
                        status == 1 ? AppColor.amberLight :
                        AppColor.backgroundGray)
            .cornerRadius(4)
    }
}

// 空状态
struct EmptyState: View {
    let tab: String
    
    var body: some View {
        VStack(spacing: 12) {
            Text("📚")
                .font(.system(size: 40))
            
            Text(tab == "all" ? "该科目暂无卡片数据" :
                 tab == "learned" ? "还没有学习过的卡片" :
                 "所有卡片都已学习")
                .font(.system(size: 16))
                .foregroundColor(AppColor.textMedium)
            
            if tab == "all" {
                Text("请通过管理后台添加知识点卡片")
                    .font(.system(size: 13))
                    .foregroundColor(AppColor.textSecondary)
            }
        }
        .padding(.vertical, 50)
    }
}