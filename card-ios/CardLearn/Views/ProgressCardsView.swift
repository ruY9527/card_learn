import SwiftUI

struct ProgressCardsView: View {
    @EnvironmentObject var appState: AppState
    
    let type: String
    
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
                            .foregroundColor(Color(hex: "909399"))
                        
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
                                    .foregroundColor(Color(hex: "909399"))
                                    .padding(.vertical, 16)
                            }
                            
                            // 加载更多
                            if hasMore && !isLoading {
                                Button(action: loadMore) {
                                    Text("加载更多")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(hex: "667eea"))
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
                                .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "667eea")))
                            
                            Text("加载中...")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "909399"))
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
                                .foregroundColor(Color(hex: "606266"))
                            
                            Text("快去学习更多卡片吧！")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "909399"))
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
            fetchCards()
        }
    }
    
    private func fetchCards() {
        guard let userId = appState.userInfo?.userId else { return }
        
        isLoading = true
        
        Task {
            do {
                let statusParam = type == "mastered" ? "mastered" : type == "review" ? "review" : "learned"
                let pageData = try await apiService.getProgressCards(
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
                            .foregroundColor(Color(hex: "667eea"))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(hex: "F0F5FF"))
                    .cornerRadius(4)
                }
                
                Spacer()
                
                // 状态标签
                Text(card.status == 2 ? "已掌握" : card.status == 1 ? "待复习" : "未学习")
                    .font(.system(size: 12))
                    .foregroundColor(card.status == 2 ? Color(hex: "67C23A") :
                                     card.status == 1 ? Color(hex: "E6A23C") :
                                     Color(hex: "909399"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(card.status == 2 ? Color(hex: "F0F9EB") :
                                card.status == 1 ? Color(hex: "FDF6EC") :
                                Color(hex: "F5F5F5"))
                    .cornerRadius(4)
            }
            
            // 内容
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    Text("❓")
                        .font(.system(size: 14))
                    
                    Text("问题")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "909399"))
                }
                
                Text(card.frontContent.count > 80 ?
                     String(card.frontContent.prefix(80)) + "..." :
                     card.frontContent)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "303133"))
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
                                .foregroundColor(Color(hex: "909399"))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(hex: "F5F7FA"))
                                .cornerRadius(4)
                        }
                    }
                }
                
                Spacer()
                
                // 难度
                HStack(spacing: 4) {
                    Text("难度")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "909399"))
                    
                    HStack(spacing: 2) {
                        ForEach(1..<6, id: \.self) { index in
                            Text("★")
                                .font(.system(size: 10))
                                .foregroundColor(index <= (card.difficultyLevel ?? 1) ? Color(hex: "FFD700") : Color(hex: "E0E0E0"))
                        }
                    }
                }
            }
            
            // 操作提示
            HStack {
                Spacer()
                
                Text("点击查看详情 →")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "667eea"))
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}