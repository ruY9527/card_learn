import SwiftUI

struct ProgressCardsView: View {
    @EnvironmentObject var appState: AppState

    let type: String
    var subjectId: Int? = nil

    @State private var cardList: [Card] = []
    @State private var totalCount: Int = 0
    @State private var isLoading: Bool = false
    @State private var pageNum: Int = 1
    @State private var hasMore: Bool = true
    @State private var selectedCard: Card?
    @State private var showCardDetail: Bool = false
    @State private var selectedCardIndex: Int = 0

    private let apiService = APIService.shared

    private var title: String {
        switch type {
        case "learned": return "已学习"
        case "mastered": return "已掌握"
        case "review": return "待复习"
        case "all": return "全部卡片"
        default: return "学习进度"
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // 统计信息
                    HStack {
                        Text("共 \(totalCount) 张卡片")
                            .font(.system(size: 14))
                            .foregroundColor(AppColor.textSecondary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    
                    // 卡片列表
                    if !cardList.isEmpty {
                        LazyVStack(spacing: 16) {
                            ForEach(Array(cardList.enumerated()), id: \.element.cardId) { index, card in
                                ProgressCardItem(card: card, type: type)
                                    .onTapGesture {
                                        selectedCard = card
                                        selectedCardIndex = index
                                        showCardDetail = true
                                    }
                            }
                            
                            // 无更多数据
                            if !hasMore && !cardList.isEmpty {
                                Text("— 已加载全部 —")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColor.textSecondary)
                                    .padding(.vertical, 16)
                            }
                            
                            // 加载更多
                            if hasMore && !isLoading {
                                Button(action: loadMore) {
                                    Text("加载更多")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppColor.primary)
                                }
                                .padding(.vertical, 16)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // 加载状态
                    if isLoading && cardList.isEmpty {
                        VStack(spacing: 12) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: AppColor.primary))
                            
                            Text("加载中...")
                                .font(.system(size: 14))
                                .foregroundColor(AppColor.textSecondary)
                        }
                        .padding(.top, 100)
                    }
                    
                    // 空状态
                    if cardList.isEmpty && !isLoading {
                        VStack(spacing: 16) {
                            Text("📭")
                                .font(.system(size: 48))
                            
                            Text("暂无相关卡片")
                                .font(.system(size: 16))
                                .foregroundColor(AppColor.textMedium)
                            
                            Text("快去学习更多卡片吧！")
                                .font(.system(size: 14))
                                .foregroundColor(AppColor.textSecondary)
                        }
                        .padding(.top, 100)
                    }
                }
                .padding(.top, 16)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showCardDetail) {
                if let card = selectedCard {
                    CardDetailView(
                        cardList: cardList,
                        currentIndex: selectedCardIndex,
                        subjectId: card.subjectId,
                        subjectName: card.subjectName ?? "知识点卡片"
                    )
                }
            }
        }
        .onAppear {
            pageNum = 1
            cardList = []
            hasMore = true
            fetchCards()
        }
    }
    
    private func fetchCards() {
        guard let userId = appState.userInfo?.userId else { return }

        isLoading = true

        Task {
            do {
                let statusParam: String? = type == "all" ? nil : (type == "mastered" ? "mastered" : type == "review" ? "review" : "learned")
                let pageData = try await apiService.getCardPage(
                    subjectId: subjectId,
                    frontContent: nil,
                    appUserId: userId,
                    status: statusParam,
                    pageNum: pageNum,
                    pageSize: 20
                )

                if pageNum == 1 {
                    cardList = pageData.records
                } else {
                    cardList.append(contentsOf: pageData.records)
                }

                totalCount = pageData.total
                hasMore = cardList.count < totalCount
                isLoading = false
            } catch {
                isLoading = false
            }
        }
    }
    
    private func loadMore() {
        guard hasMore && !isLoading else { return }
        pageNum += 1
        fetchCards()
    }
}

// 进度卡片项组件
struct ProgressCardItem: View {
    let card: Card
    let type: String

    private var displayTime: String {
        if let lastStudyTime = card.lastStudyTime {
            return DateUtils.formatDisplayTime(lastStudyTime)
        }
        return card.formattedTime
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 头部
            HStack {
                // 科目名称
                if let subjectName = card.subjectName {
                    HStack(spacing: 4) {
                        Text("📚")
                            .font(.system(size: 14))

                        Text(subjectName)
                            .font(.system(size: 12))
                            .foregroundColor(AppColor.primary)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AppColor.infoLight)
                    .cornerRadius(4)
                }

                Spacer()

                // 状态标签
                Text(card.status == 2 ? "已掌握" : card.status == 1 ? "待复习" : "未学习")
                    .font(.system(size: 12))
                    .foregroundColor(card.status == 2 ? AppColor.success :
                                     card.status == 1 ? AppColor.warning :
                                     AppColor.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(card.status == 2 ? AppColor.successLight :
                                card.status == 1 ? AppColor.warningLight :
                                AppColor.backgroundGray)
                    .cornerRadius(4)
            }

            // 学习时间显示
            let timeStr = displayTime
            if !timeStr.isEmpty {
                HStack(spacing: 8) {
                    Text("🕐")
                        .font(.system(size: 14))

                    Text(timeStr)
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.textMedium)

                    Text(type == "mastered" ? "掌握于" : type == "review" ? "复习于" : "学习于")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.textSecondary)
                }
                .padding(.vertical, 8)
                .background(AppColor.backgroundLight)
                .cornerRadius(8)
            }

            // 内容
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    Text("❓")
                        .font(.system(size: 14))

                    Text("问题")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.textSecondary)
                }

                Text(card.frontContent.count > 80 ?
                     String(card.frontContent.prefix(80)) + "..." :
                     card.frontContent)
                    .font(.system(size: 14))
                    .foregroundColor(AppColor.textPrimary)
                    .lineSpacing(4)
            }

            // 底部
            HStack {
                // 标签
                if let tags = card.tags, !tags.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(tags.prefix(3), id: \.self) { tag in
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

                Spacer()

                // 难度
                HStack(spacing: 4) {
                    Text("难度")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.textSecondary)

                    HStack(spacing: 2) {
                        ForEach(1..<6, id: \.self) { index in
                            Text("★")
                                .font(.system(size: 10))
                                .foregroundColor(index <= (card.difficultyLevel ?? 1) ? AppColor.gold : AppColor.divider)
                        }
                    }
                }
            }

            // 操作提示
            HStack {
                Spacer()

                Text("点击查看详情 →")
                    .font(.system(size: 12))
                    .foregroundColor(AppColor.primary)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}