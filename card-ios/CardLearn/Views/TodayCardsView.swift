import SwiftUI

/// 今日学习/今日掌握卡片列表
struct TodayCardsView: View {
    @EnvironmentObject var appState: AppState

    let type: String
    let date: String

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
        case "todayMastered": return "今日掌握"
        case "todayLearned": fallthrough
        default: return "今日学习"
        }
    }

    private var statusParam: String? {
        switch type {
        case "todayMastered": return "mastered"
        case "todayLearned": return "learned"
        default: return nil
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    Text("共 \(totalCount) 张卡片")
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.textSecondary)
                    Spacer()
                }
                .padding(.horizontal, 16)

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

                        if !hasMore && !cardList.isEmpty {
                            Text("— 已加载全部 —")
                                .font(.system(size: 14))
                                .foregroundColor(AppColor.textSecondary)
                                .padding(.vertical, 16)
                        }

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

                if cardList.isEmpty && !isLoading {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(AppColor.success)
                        Text(title == "今日掌握" ? "今日暂无掌握卡片" : "今日暂无学习卡片")
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
                let pageData = try await apiService.getCardPage(
                    subjectId: nil,
                    frontContent: nil,
                    appUserId: userId,
                    status: statusParam,
                    startDate: date,
                    endDate: date,
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
