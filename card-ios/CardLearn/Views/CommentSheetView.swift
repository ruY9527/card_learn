import SwiftUI

struct CommentSheetView: View {
    let cardId: Int
    let userId: Int

    @State private var comments: [Comment] = []
    @State private var stats: CommentStats?
    @State private var isLoading = false
    @State private var pageNum = 1
    @State private var hasMore = true

    // Submit form state
    @State private var rating: Int = 3
    @State private var commentType: String = "NEUTRAL"
    @State private var content: String = ""
    @State private var isSubmitting = false
    @State private var saveAsNote = false
    @State private var submitSuccess = false
    @State private var showError = false
    @State private var errorMessage = ""

    // Reply state
    @State private var replyingTo: Comment? = nil
    @State private var replyContent: String = ""
    @State private var isSubmittingReply = false

    @Environment(\.dismiss) private var dismiss

    private let apiService = CommentApiService.shared

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Stats header
                if let stats = stats {
                    statsHeader(stats)
                }

                Divider()

                // Comment list
                if isLoading && comments.isEmpty {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColor.primary))
                    Spacer()
                } else if comments.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 40))
                            .foregroundColor(AppColor.divider)
                        Text("暂无评论")
                            .font(.system(size: 14))
                            .foregroundColor(AppColor.textSecondary)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(comments) { comment in
                            CommentRowView(
                                comment: comment,
                                userId: userId,
                                onReply: {
                                    replyingTo = comment
                                    replyContent = ""
                                },
                                onLikeUpdated: { newLikeCount, newDislikeCount, newLikeStatus in
                                    if let idx = comments.firstIndex(where: { $0.commentId == comment.commentId }) {
                                        comments[idx] = Comment(
                                            commentId: comment.commentId,
                                            cardId: comment.cardId,
                                            userId: comment.userId,
                                            userNickname: comment.userNickname,
                                            content: comment.content,
                                            rating: comment.rating,
                                            commentType: comment.commentType,
                                            commentTypeText: comment.commentTypeText,
                                            status: comment.status,
                                            adminReply: comment.adminReply,
                                            isNote: comment.isNote,
                                            likeCount: newLikeCount,
                                            dislikeCount: newDislikeCount,
                                            replyCount: comment.replyCount,
                                            likeStatus: newLikeStatus,
                                            createTime: comment.createTime
                                        )
                                    }
                                }
                            )
                            .onAppear {
                                if comment.id == comments.last?.id && hasMore && !isLoading {
                                    loadMore()
                                }
                            }
                        }
                        if isLoading && !comments.isEmpty {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: AppColor.primary))
                                Spacer()
                            }
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                }

                Divider()

                // Reply input (when replying to a comment)
                if let replying = replyingTo {
                    replyInputBar(replying)
                }

                // Submit form
                if replyingTo == nil {
                    submitForm
                }
            }
            .navigationTitle("评论")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") { dismiss() }
                }
            }
        }
        .onAppear {
            loadData()
        }
        .alert("提交失败", isPresented: $showError) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .alert("提交成功", isPresented: $submitSuccess) {
            Button("确定", role: .cancel) {}
        } message: {
            Text("感谢你的评论！")
        }
    }

    // MARK: - Stats Header

    private func statsHeader(_ stats: CommentStats) -> some View {
        HStack(spacing: 20) {
            VStack(spacing: 2) {
                Text("\(stats.totalComments ?? 0)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColor.primary)
                Text("评论")
                    .font(.system(size: 11))
                    .foregroundColor(AppColor.textSecondary)
            }

            VStack(spacing: 2) {
                HStack(spacing: 2) {
                    Text(String(format: "%.1f", stats.avgRating ?? 0))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColor.gold)
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.gold)
                }
                Text("评分")
                    .font(.system(size: 11))
                    .foregroundColor(AppColor.textSecondary)
            }

            VStack(spacing: 2) {
                Text("\(stats.qualityCount ?? 0)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColor.success)
                Text("优质")
                    .font(.system(size: 11))
                    .foregroundColor(AppColor.textSecondary)
            }

            VStack(spacing: 2) {
                Text("\(stats.poorCount ?? 0)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColor.error)
                Text("劣质")
                    .font(.system(size: 11))
                    .foregroundColor(AppColor.textSecondary)
            }
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(AppColor.backgroundLight)
    }

    // MARK: - Reply Input Bar

    private func replyInputBar(_ comment: Comment) -> some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 8) {
                Button(action: { replyingTo = nil }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(AppColor.textSecondary)
                }

                Text("回复 \(comment.userNickname ?? "匿名用户")")
                    .font(.system(size: 12))
                    .foregroundColor(AppColor.textSecondary)

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.top, 6)

            HStack(spacing: 10) {
                TextField("写下你的回复...", text: $replyContent, axis: .vertical)
                    .lineLimit(1...3)
                    .font(.system(size: 14))
                    .padding(10)
                    .background(AppColor.backgroundLight)
                    .cornerRadius(8)

                Button(action: { submitReply(to: comment) }) {
                    if isSubmittingReply {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("回复")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 60, height: 36)
                .background(replyContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? AppColor.divider : AppColor.primary)
                .cornerRadius(8)
                .disabled(replyContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmittingReply)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: -2)
    }

    // MARK: - Submit Form

    private var submitForm: some View {
        VStack(spacing: 12) {
            // Rating + Type
            HStack {
                // Star rating picker
                HStack(spacing: 4) {
                    ForEach(1..<6, id: \.self) { index in
                        Image(systemName: index <= rating ? "star.fill" : "star")
                            .font(.system(size: 20))
                            .foregroundColor(index <= rating ? AppColor.gold : AppColor.divider)
                            .onTapGesture {
                                rating = index
                            }
                    }
                }

                Spacer()

                // Comment type picker
                HStack(spacing: 6) {
                    typeButton("优质", type: "QUALITY", color: AppColor.success)
                    typeButton("中性", type: "NEUTRAL", color: AppColor.textSecondary)
                    typeButton("劣质", type: "POOR", color: AppColor.error)
                }
            }

            // Save as note toggle
            Toggle(isOn: $saveAsNote) {
                HStack(spacing: 4) {
                    Image(systemName: "note.text")
                        .font(.system(size: 13))
                        .foregroundColor(AppColor.primary)
                    Text("同时保存为笔记")
                        .font(.system(size: 13))
                        .foregroundColor(AppColor.textSecondary)
                }
            }
            .tint(AppColor.primary)

            // Content + Submit
            HStack(spacing: 10) {
                TextField("写下你的评论...", text: $content, axis: .vertical)
                    .lineLimit(1...3)
                    .font(.system(size: 14))
                    .padding(10)
                    .background(AppColor.backgroundLight)
                    .cornerRadius(8)

                Button(action: submit) {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("发送")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 60, height: 36)
                .background(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? AppColor.divider : AppColor.primary)
                .cornerRadius(8)
                .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmitting)
            }
        }
        .padding(12)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: -2)
    }

    private func typeButton(_ label: String, type: String, color: Color) -> some View {
        Text(label)
            .font(.system(size: 12))
            .foregroundColor(commentType == type ? .white : color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(commentType == type ? color : color.opacity(0.1))
            .cornerRadius(12)
            .onTapGesture {
                commentType = type
            }
    }

    // MARK: - Data Loading

    private func loadData() {
        loadStats()
        loadComments()
    }

    private func loadStats() {
        Task {
            do {
                let result = try await apiService.getCommentStats(cardId: cardId)
                await MainActor.run {
                    stats = result
                }
            } catch {
                // Silent fail for stats
            }
        }
    }

    private func loadComments() {
        guard !isLoading else { return }
        isLoading = true

        Task {
            do {
                let pageData = try await apiService.getCardComments(cardId: cardId, pageNum: pageNum, userId: userId)
                await MainActor.run {
                    comments.append(contentsOf: pageData.records)
                    hasMore = comments.count < (pageData.total ?? 0)
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }

    private func loadMore() {
        pageNum += 1
        loadComments()
    }

    private func submit() {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        isSubmitting = true

        Task {
            do {
                _ = try await apiService.submitComment(
                    cardId: cardId,
                    appUserId: userId,
                    content: trimmed,
                    rating: rating,
                    commentType: commentType,
                    isNote: saveAsNote ? 1 : 0
                )
                await MainActor.run {
                    isSubmitting = false
                    content = ""
                    rating = 3
                    commentType = "NEUTRAL"
                    saveAsNote = false
                    submitSuccess = true
                    // Refresh
                    comments = []
                    pageNum = 1
                    hasMore = true
                    loadData()
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }

    private func submitReply(to comment: Comment) {
        let trimmed = replyContent.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        isSubmittingReply = true

        Task {
            do {
                _ = try await apiService.submitReply(
                    commentId: comment.commentId,
                    userId: userId,
                    content: trimmed
                )
                await MainActor.run {
                    isSubmittingReply = false
                    replyContent = ""
                    replyingTo = nil
                    // Refresh
                    comments = []
                    pageNum = 1
                    hasMore = true
                    loadData()
                }
            } catch {
                await MainActor.run {
                    isSubmittingReply = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

// MARK: - Comment Row View

struct CommentRowView: View {
    let comment: Comment
    let userId: Int
    let onReply: () -> Void
    let onLikeUpdated: (Int, Int, Int) -> Void  // (likeCount, dislikeCount, likeStatus)

    @State private var likeStatus: Int = 0  // 0=none, 1=like, 2=dislike
    @State private var likeCount: Int = 0
    @State private var dislikeCount: Int = 0
    @State private var isToggling = false
    @State private var showReplies = false
    @State private var replies: [Reply] = []
    @State private var isLoadingReplies = false

    private let apiService = CommentApiService.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header: nickname + time + type badge
            HStack {
                Text(comment.userNickname ?? "匿名用户")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColor.textPrimary)

                // Type badge
                Text(comment.typeLabel)
                    .font(.system(size: 10))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(hex: comment.typeColor))
                    .cornerRadius(4)

                Spacer()

                Text(comment.createTime ?? "")
                    .font(.system(size: 11))
                    .foregroundColor(AppColor.textSecondary)
            }

            // Star rating
            if let rating = comment.rating, rating > 0 {
                HStack(spacing: 2) {
                    ForEach(1..<6, id: \.self) { index in
                        Image(systemName: index <= rating ? "star.fill" : "star")
                            .font(.system(size: 12))
                            .foregroundColor(index <= rating ? AppColor.gold : AppColor.divider)
                    }
                }
            }

            // Content
            Text(comment.content)
                .font(.system(size: 14))
                .foregroundColor(AppColor.textPrimary)
                .lineSpacing(4)

            // Admin reply
            if let reply = comment.adminReply, !reply.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "arrow.turn.down.right")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.primary)
                        .padding(.top, 2)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("管理员回复")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppColor.primary)
                        Text(reply)
                            .font(.system(size: 13))
                            .foregroundColor(AppColor.textSecondary)
                            .lineSpacing(3)
                    }
                }
                .padding(10)
                .background(AppColor.primary.opacity(0.05))
                .cornerRadius(8)
            }

            // Action bar: thumbs up + thumbs down + reply
            HStack(spacing: 0) {
                // Thumbs up button
                Button(action: { toggleLike(type: 1) }) {
                    HStack(spacing: 4) {
                        Image(systemName: likeStatus == 1 ? "hand.thumbsup.fill" : "hand.thumbsup")
                            .font(.system(size: 14))
                            .foregroundColor(likeStatus == 1 ? Color(hex: "1677FF") : AppColor.textSecondary)
                        if likeCount > 0 {
                            Text("\(likeCount)")
                                .font(.system(size: 12))
                                .foregroundColor(likeStatus == 1 ? Color(hex: "1677FF") : AppColor.textSecondary)
                        }
                    }
                    .frame(minWidth: 44, minHeight: 36)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(isToggling)

                // Thumbs down button
                Button(action: { toggleLike(type: 2) }) {
                    HStack(spacing: 4) {
                        Image(systemName: likeStatus == 2 ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                            .font(.system(size: 14))
                            .foregroundColor(likeStatus == 2 ? Color(hex: "F56C6C") : AppColor.textSecondary)
                        if dislikeCount > 0 {
                            Text("\(dislikeCount)")
                                .font(.system(size: 12))
                                .foregroundColor(likeStatus == 2 ? Color(hex: "F56C6C") : AppColor.textSecondary)
                        }
                    }
                    .frame(minWidth: 44, minHeight: 36)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(isToggling)

                // Reply button
                Button(action: onReply) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 14))
                            .foregroundColor(AppColor.textSecondary)
                        let rc = comment.replyCount ?? 0
                        if rc > 0 {
                            Text("\(rc)")
                                .font(.system(size: 12))
                                .foregroundColor(AppColor.textSecondary)
                        }
                    }
                    .frame(minWidth: 44, minHeight: 36)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                // Show replies toggle
                if (comment.replyCount ?? 0) > 0 {
                    Button(action: { toggleReplies() }) {
                        Text(showReplies ? "收起回复" : "查看 \(comment.replyCount ?? 0) 条回复")
                            .font(.system(size: 12))
                            .foregroundColor(AppColor.primary)
                            .frame(minHeight: 36)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }

                Spacer()
            }
            .padding(.top, 4)

            // Replies list
            if showReplies {
                if isLoadingReplies {
                    HStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppColor.primary))
                            .scaleEffect(0.8)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                } else {
                    ForEach(replies) { reply in
                        ReplyRowView(
                            reply: reply,
                            userId: userId,
                            onLikeUpdated: { newLikeCount, newDislikeCount, newLikeStatus in
                                if let idx = replies.firstIndex(where: { $0.replyId == reply.replyId }) {
                                    replies[idx] = Reply(
                                        replyId: reply.replyId,
                                        commentId: reply.commentId,
                                        userId: reply.userId,
                                        userNickname: reply.userNickname,
                                        content: reply.content,
                                        likeCount: newLikeCount,
                                        dislikeCount: newDislikeCount,
                                        likeStatus: newLikeStatus,
                                        parentReplyId: reply.parentReplyId,
                                        children: reply.children,
                                        hasMoreChildren: reply.hasMoreChildren,
                                        createTime: reply.createTime
                                    )
                                }
                            }
                        )
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .onAppear {
            likeStatus = comment.likeStatus ?? 0
            likeCount = comment.likeCount ?? 0
            dislikeCount = comment.dislikeCount ?? 0
        }
    }

    private func toggleLike(type: Int) {
        guard !isToggling else { return }
        isToggling = true

        Task {
            do {
                let result = try await apiService.toggleCommentLike(commentId: comment.commentId, userId: userId, likeType: type)
                await MainActor.run {
                    // result: 0=removed, 1=liked, 2=disliked
                    let oldStatus = likeStatus

                    // Adjust counts based on old and new status
                    if oldStatus == 1 {
                        likeCount -= 1
                    } else if oldStatus == 2 {
                        dislikeCount -= 1
                    }

                    if result == 1 {
                        likeCount += 1
                    } else if result == 2 {
                        dislikeCount += 1
                    }

                    likeStatus = result
                    onLikeUpdated(likeCount, dislikeCount, likeStatus)
                    isToggling = false
                }
            } catch {
                await MainActor.run {
                    isToggling = false
                }
            }
        }
    }

    private func toggleReplies() {
        showReplies.toggle()
        if showReplies && replies.isEmpty {
            loadReplies()
        }
    }

    private func loadReplies() {
        isLoadingReplies = true
        Task {
            do {
                let pageData = try await apiService.getReplies(commentId: comment.commentId, userId: userId)
                await MainActor.run {
                    replies = pageData.records
                    isLoadingReplies = false
                }
            } catch {
                await MainActor.run {
                    isLoadingReplies = false
                }
            }
        }
    }
}

// MARK: - Reply Row View

struct ReplyRowView: View {
    let reply: Reply
    let userId: Int
    let onLikeUpdated: (Int, Int, Int) -> Void  // (likeCount, dislikeCount, likeStatus)

    @State private var likeStatus: Int = 0  // 0=none, 1=like, 2=dislike
    @State private var likeCount: Int = 0
    @State private var dislikeCount: Int = 0
    @State private var isToggling = false

    private let apiService = CommentApiService.shared

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // Indent line
            Rectangle()
                .fill(AppColor.divider)
                .frame(width: 2)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(reply.userNickname ?? "匿名用户")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppColor.textPrimary)

                    Spacer()

                    Text(reply.createTime ?? "")
                        .font(.system(size: 10))
                        .foregroundColor(AppColor.textSecondary)
                }

                Text(reply.content)
                    .font(.system(size: 13))
                    .foregroundColor(AppColor.textPrimary)
                    .lineSpacing(3)

                // Thumbs up/down for reply
                HStack(spacing: 0) {
                    // Thumbs up
                    Button(action: { toggleLike(type: 1) }) {
                        HStack(spacing: 4) {
                            Image(systemName: likeStatus == 1 ? "hand.thumbsup.fill" : "hand.thumbsup")
                                .font(.system(size: 12))
                                .foregroundColor(likeStatus == 1 ? Color(hex: "1677FF") : AppColor.textSecondary)
                            if likeCount > 0 {
                                Text("\(likeCount)")
                                    .font(.system(size: 11))
                                    .foregroundColor(likeStatus == 1 ? Color(hex: "1677FF") : AppColor.textSecondary)
                            }
                        }
                        .frame(minWidth: 44, minHeight: 32)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(isToggling)

                    // Thumbs down
                    Button(action: { toggleLike(type: 2) }) {
                        HStack(spacing: 4) {
                            Image(systemName: likeStatus == 2 ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                                .font(.system(size: 12))
                                .foregroundColor(likeStatus == 2 ? Color(hex: "F56C6C") : AppColor.textSecondary)
                            if dislikeCount > 0 {
                                Text("\(dislikeCount)")
                                    .font(.system(size: 11))
                                    .foregroundColor(likeStatus == 2 ? Color(hex: "F56C6C") : AppColor.textSecondary)
                            }
                        }
                        .frame(minWidth: 44, minHeight: 32)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(isToggling)
                }
            }
        }
        .padding(.vertical, 6)
        .padding(.leading, 12)
        .onAppear {
            likeStatus = reply.likeStatus ?? 0
            likeCount = reply.likeCount ?? 0
            dislikeCount = reply.dislikeCount ?? 0
        }
    }

    private func toggleLike(type: Int) {
        guard !isToggling else { return }
        isToggling = true

        Task {
            do {
                let result = try await apiService.toggleReplyLike(replyId: reply.replyId, userId: userId, likeType: type)
                await MainActor.run {
                    let oldStatus = likeStatus

                    if oldStatus == 1 {
                        likeCount -= 1
                    } else if oldStatus == 2 {
                        dislikeCount -= 1
                    }

                    if result == 1 {
                        likeCount += 1
                    } else if result == 2 {
                        dislikeCount += 1
                    }

                    likeStatus = result
                    onLikeUpdated(likeCount, dislikeCount, likeStatus)
                    isToggling = false
                }
            } catch {
                await MainActor.run {
                    isToggling = false
                }
            }
        }
    }
}
