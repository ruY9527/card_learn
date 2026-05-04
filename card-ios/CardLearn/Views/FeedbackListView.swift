import SwiftUI

struct FeedbackListView: View {
    @EnvironmentObject var appState: AppState
    @State private var feedbackList: [Feedback] = []
    @State private var isLoading: Bool = false
    @State private var pageNum: Int = 1
    @State private var hasMore: Bool = true
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    private let apiService = APIService.shared
    private let typeMap: [String: String] = [
        "SUGGESTION": "建议",
        "ERROR": "纠错",
        "FUNCTION": "功能问题",
        "OTHER": "其他"
    ]
    private let statusMap: [String: String] = [
        "0": "待处理",
        "1": "已采纳",
        "2": "已忽略"
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if !appState.isLoggedIn {
                        // 未登录提示
                        VStack(spacing: 16) {
                            Text("🔒")
                                .font(.system(size: 48))
                            
                            Text("请先登录后查看反馈记录")
                                .font(.system(size: 16))
                                .foregroundColor(AppColor.textMedium)
                        }
                        .padding(.top, 100)
                    } else {
                        // 反馈列表
                        if !feedbackList.isEmpty {
                            LazyVStack(spacing: 16) {
                                ForEach(feedbackList) { feedback in
                                    FeedbackItem(
                                        feedback: feedback,
                                        typeMap: typeMap,
                                        statusMap: statusMap
                                    )
                                }
                                
                                // 加载更多
                                if hasMore {
                                    Button(action: loadMore) {
                                        Text(isLoading ? "加载中..." : "加载更多")
                                            .font(.system(size: 14))
                                            .foregroundColor(AppColor.primary)
                                    }
                                    .padding(.vertical, 16)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // 空状态
                        if feedbackList.isEmpty && !isLoading {
                            VStack(spacing: 16) {
                                Text("📝")
                                    .font(.system(size: 48))
                                
                                Text("暂无反馈记录")
                                    .font(.system(size: 16))
                                    .foregroundColor(AppColor.textMedium)
                            }
                            .padding(.top, 100)
                        }
                        
                        // 加载状态
                        if isLoading && feedbackList.isEmpty {
                            VStack(spacing: 12) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: AppColor.primary))
                                
                                Text("加载中...")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColor.textSecondary)
                            }
                            .padding(.top, 100)
                        }
                    }
                }
                .padding(.top, 16)
            }
            .navigationTitle("我的反馈")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            if appState.isLoggedIn {
                fetchFeedbackList()
            }
        }
        .alert("加载失败", isPresented: $showError) {
            Button("重试") {
                fetchFeedbackList()
            }
            Button("确定", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func fetchFeedbackList() {
        guard let userId = appState.userInfo?.userId else { return }
        
        isLoading = true
        
        Task {
            do {
                let pageData = try await apiService.getUserFeedbackList(
                    appUserId: userId,
                    pageNum: pageNum,
                    pageSize: 10,
                    token: appState.token
                )
                
                if pageNum == 1 {
                    feedbackList = pageData.records
                } else {
                    feedbackList.append(contentsOf: pageData.records)
                }
                
                hasMore = feedbackList.count < pageData.total
                isLoading = false
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    private func loadMore() {
        guard hasMore && !isLoading else { return }
        pageNum += 1
        fetchFeedbackList()
    }
}

// 反馈项组件
struct FeedbackItem: View {
    let feedback: Feedback
    let typeMap: [String: String]
    let statusMap: [String: String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 类型标签
            HStack {
                TypeTag(type: feedback.type, label: typeMap[feedback.type] ?? feedback.type)
                
                Spacer()
                
                StatusTag(status: feedback.status ?? "0", label: statusMap[feedback.status ?? "0"] ?? "待处理")
            }
            
            // 内容
            Text(feedback.content)
                .font(.system(size: 14))
                .foregroundColor(AppColor.textPrimary)
                .lineSpacing(4)
            
            // 卡片关联
            if let cardId = feedback.cardId {
                HStack(spacing: 8) {
                    Text("关联卡片:")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.textSecondary)
                    
                    Text("#\(cardId)")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.primary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(AppColor.infoLight)
                        .cornerRadius(4)
                }
            }
            
            // 时间和评分
            HStack {
                Text(feedback.createTime ?? "")
                    .font(.system(size: 12))
                    .foregroundColor(AppColor.textSecondary)
                
                Spacer()
                
                if let rating = feedback.rating, rating > 0 {
                    HStack(spacing: 2) {
                        ForEach(1..<6, id: \.self) { index in
                            Text("★")
                                .font(.system(size: 10))
                                .foregroundColor(index <= rating ? AppColor.gold : AppColor.divider)
                        }
                    }
                }
            }
            
            // 管理员回复
            if let adminReply = feedback.adminReply, !adminReply.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("管理员回复:")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColor.primary)
                    
                    Text(adminReply)
                        .font(.system(size: 13))
                        .foregroundColor(AppColor.textMedium)
                        .padding(12)
                        .background(AppColor.backgroundLight)
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

struct TypeTag: View {
    let type: String
    let label: String
    
    var body: some View {
        Text(label)
            .font(.system(size: 12))
            .foregroundColor(type == "ERROR" ? AppColor.error :
                             type == "SUGGESTION" ? AppColor.info :
                             type == "FUNCTION" ? AppColor.warning :
                             AppColor.textSecondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(type == "ERROR" ? AppColor.errorLight :
                        type == "SUGGESTION" ? AppColor.blueLight :
                        type == "FUNCTION" ? AppColor.warningLight :
                        AppColor.backgroundGray)
            .cornerRadius(4)
    }
}

struct StatusTag: View {
    let status: String
    let label: String

    var body: some View {
        Text(label)
            .font(.system(size: 12))
            .foregroundColor(status == "1" ? AppColor.success :
                             status == "2" ? AppColor.textSecondary :
                             AppColor.warning)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(status == "1" ? AppColor.successLight :
                        status == "2" ? AppColor.backgroundGray :
                        AppColor.warningLight)
            .cornerRadius(4)
    }
}