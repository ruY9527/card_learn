import SwiftUI

struct CardDetailView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    let cardList: [Card]
    let currentIndex: Int
    let subjectId: Int
    let subjectName: String
    
    @State private var currentCardIndex: Int = 0
    @State private var isFlipped: Bool = false
    @State private var progress: Int = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging: Bool = false
    @State private var showFeedback: Bool = false
    
    private let apiService = APIService.shared
    
    private var currentCard: Card? {
        if currentCardIndex >= 0 && currentCardIndex < cardList.count {
            return cardList[currentCardIndex]
        }
        return nil
    }
    
    private var totalCount: Int {
        cardList.count
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部导航栏
            HStack {
                Button(action: goToPrev) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20))
                        .foregroundColor(AppColor.primary)
                }
                
                Spacer()
                
                Text(subjectName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColor.textPrimary)
                    .onTapGesture(count: 2) {
                        dismiss()
                    }
                
                Spacer()
                
                Button(action: goToNext) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 20))
                        .foregroundColor(AppColor.primary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            
            // 进度指示器
            HStack(spacing: 4) {
                ForEach(0..<min(totalCount, 10), id: \.self) { index in
                    Circle()
                        .fill(index <= currentCardIndex ? AppColor.primary : AppColor.divider)
                        .frame(width: 8, height: 8)
                }
                
                if totalCount > 10 {
                    Text("...")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.textSecondary)
                }
            }
            .padding(.vertical, 12)
            
            // 进度文字
            Text("\(currentCardIndex + 1) / \(totalCount)")
                .font(.system(size: 14))
                .foregroundColor(AppColor.textSecondary)
                .padding(.bottom, 12)
            
            // 卡片滑动区域
            if let card = currentCard {
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        ZStack {
                            // 滑动提示
                            if isDragging && dragOffset > 50 && currentCardIndex > 0 {
                                HStack {
                                    Text("← 上一张")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppColor.primary)
                                        .padding(.leading, 20)

                                    Spacer()
                                }
                            }

                            if isDragging && dragOffset < -50 {
                                HStack {
                                    Spacer()

                                    Text("下一张 →")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppColor.primary)
                                        .padding(.trailing, 20)
                                }
                            }

                            // 3D翻转卡片
                            FlipCardView(
                                frontContent: card.frontContent,
                                backContent: card.backContent,
                                difficulty: card.difficultyLevel ?? 1,
                                isFlipped: isFlipped,
                                onTap: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isFlipped.toggle()
                                    }
                                },
                                onFeedbackTap: {
                                    showFeedback = true
                                }
                            )
                            .offset(x: dragOffset)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        isDragging = true
                                        dragOffset = value.translation.width
                                    }
                                    .onEnded { value in
                                        isDragging = false
                                        withAnimation(.easeOut) {
                                            dragOffset = 0
                                        }

                                        if value.translation.width > 80 {
                                            goToPrev()
                                        } else if value.translation.width < -80 {
                                            goToNext()
                                        }
                                    }
                            )
                        }
                        .frame(maxHeight: .infinity)

                        // 标签展示
                        if let tags = card.tags, !tags.isEmpty {
                            HStack(spacing: 8) {
                                ForEach(tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.system(size: 12))
                                        .foregroundColor(AppColor.textSecondary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(AppColor.backgroundLight)
                                        .cornerRadius(6)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        }

                        // 学习状态按钮
                        if isFlipped {
                            StatusButtons(
                                onSelect: { status in
                                    handleStatus(status)
                                }
                            )
                        }
                    }
                }

                // 底部进度条
                VStack(spacing: 8) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(AppColor.divider)
                                .frame(height: 8)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(AppColor.primary)
                                .frame(width: geometry.size.width * CGFloat(progress) / 100, height: 8)
                        }
                    }
                    .frame(height: 8)

                    HStack {
                        Text("\(progress)%")
                            .font(.system(size: 12))
                            .foregroundColor(AppColor.primary)

                        Spacer()

                        Text("剩余 \(totalCount - currentCardIndex - 1) 张")
                            .font(.system(size: 12))
                            .foregroundColor(AppColor.textSecondary)
                    }
                }
                .padding(16)
                .background(Color.white)
            } else {
                // 加载状态
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColor.primary))
                    
                    Text("加载中...")
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.textSecondary)
                }
            }
        }
        .background(AppColor.backgroundLight)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showFeedback) {
            if let card = currentCard {
                FeedbackView(cardId: card.cardId, cardContent: card.frontContent)
            }
        }
        .onAppear {
            currentCardIndex = currentIndex
            updateProgress()
        }
    }
    
    private func goToPrev() {
        guard currentCardIndex > 0 else {
            dismiss()
            return
        }

        currentCardIndex -= 1
        isFlipped = false
        updateProgress()
    }
    
    private func goToNext() {
        guard currentCardIndex < cardList.count - 1 else {
            // 已完成所有卡片
            dismiss()
            return
        }
        
        currentCardIndex += 1
        isFlipped = false
        updateProgress()
    }
    
    private func handleStatus(_ status: Int) {
        guard let card = currentCard else { return }

        Task {
            do {
                let userId = appState.userInfo?.userId

                // 同时调用两个接口：更新进度 + 提交SM-2复习（创建复习计划）
                async let progressResult = apiService.updateProgress(
                    cardId: card.cardId,
                    appUserId: userId,
                    status: status,
                    token: appState.token
                )

                // 映射status到SM-2 quality: 0->0(忘记), 1->3(困难), 2->5(完美)
                let quality: Int
                switch status {
                case 1: quality = 3
                case 2: quality = 5
                default: quality = 0
                }

                // 获取当前SM-2状态，计算下次复习参数
                let sm2State: SM2Result
                do {
                    let progress = try await apiService.getSM2Progress(
                        cardId: card.cardId,
                        appUserId: userId
                    )
                    sm2State = SM2Result(
                        interval: progress.interval ?? 1,
                        easeFactor: progress.easeFactor ?? 2.5,
                        repetitions: progress.repetitions ?? 0,
                        nextReviewDate: Date()
                    )
                } catch {
                    sm2State = .initial
                }

                let reviewResult = SM2Algorithm.shared.calculate(
                    quality: ReviewQuality(rawValue: quality) ?? .blackout,
                    previous: sm2State
                )

                let isoFormatter = ISO8601DateFormatter()
                isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                let nextReviewTime = isoFormatter.string(from: reviewResult.nextReviewDate)

                let request = ReviewSubmitRequest(
                    cardId: card.cardId,
                    userId: userId ?? 0,
                    quality: quality,
                    easeFactor: reviewResult.easeFactor,
                    repetitions: reviewResult.repetitions,
                    interval: reviewResult.interval,
                    nextReviewTime: nextReviewTime
                )

                async let reviewSubmit = apiService.submitSM2Review(
                    request: request,
                    token: appState.token
                )

                let _ = try await progressResult
                let _ = try await reviewSubmit

                // 更新本地统计
                updateLocalStats(status)

                // 自动跳转到下一张
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    goToNext()
                }
            } catch {
                updateLocalStats(status)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    goToNext()
                }
            }
        }
    }
    
    private func updateLocalStats(_ status: Int) {
        let prevStatus = currentCard?.status ?? 0
        
        if prevStatus == 0 && status >= 1 {
            appState.stats.learned += 1
        }
        if prevStatus == 1 && status == 2 {
            appState.stats.mastered += 1
            appState.stats.review -= 1
        }
        if prevStatus == 0 && status == 1 {
            appState.stats.review += 1
        }
        if prevStatus == 2 && status == 1 {
            appState.stats.mastered -= 1
            appState.stats.review += 1
        }
        
        // 确保数值不为负
        appState.stats.learned = max(0, appState.stats.learned)
        appState.stats.mastered = max(0, appState.stats.mastered)
        appState.stats.review = max(0, appState.stats.review)
        
        appState.saveStats()
    }
    
    
    private func updateProgress() {
        progress = Int(Double(currentCardIndex + 1) / Double(totalCount) * 100)
    }
}

// 3D翻转卡片视图
struct FlipCardView: View {
    let frontContent: String
    let backContent: String
    let difficulty: Int
    let isFlipped: Bool
    let onTap: () -> Void
    let onFeedbackTap: () -> Void
    
    var body: some View {
        ZStack {
            // 卡片正面
            CardFrontView(
                content: frontContent,
                difficulty: difficulty,
                onTap: onTap
            )
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )
            
            // 卡片反面
            CardBackView(
                content: backContent,
                difficulty: difficulty,
                onTap: onTap,
                onFeedbackTap: onFeedbackTap
            )
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(
                    .degrees(isFlipped ? 0 : -180),
                    axis: (x: 0, y: 1, z: 0)
                )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

struct CardFrontView: View {
    let content: String
    let difficulty: Int
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                BadgeView(text: "问题", color: AppColor.info)
                
                Spacer()
                
                HStack(spacing: 2) {
                    ForEach(1..<6, id: \.self) { index in
                        Text("★")
                            .font(.system(size: 12))
                            .foregroundColor(index <= difficulty ? AppColor.gold : AppColor.divider)
                    }
                }
                
                Text("难度")
                    .font(.system(size: 12))
                    .foregroundColor(AppColor.textSecondary)
            }
            
            ScrollView {
                MarkdownText(content, fontSize: 16)
                    .lineSpacing(6)
            }
            .frame(maxHeight: .infinity)
            
            HStack {
                Spacer()
                
                VStack(spacing: 4) {
                    Text("👆")
                        .font(.system(size: 20))
                    
                    Text("点击翻转查看答案")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.info)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .onTapGesture(perform: onTap)
    }
}

struct CardBackView: View {
    let content: String
    let difficulty: Int
    let onTap: () -> Void
    let onFeedbackTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                BadgeView(text: "答案", color: AppColor.success)
                
                Spacer()
                
                HStack(spacing: 2) {
                    ForEach(1..<6, id: \.self) { index in
                        Text("★")
                            .font(.system(size: 12))
                            .foregroundColor(index <= difficulty ? AppColor.gold : AppColor.divider)
                    }
                }
                
                Text("难度")
                    .font(.system(size: 12))
                    .foregroundColor(AppColor.textSecondary)
            }
            
            ScrollView {
                MarkdownText(content, fontSize: 16)
                    .lineSpacing(6)
            }
            .frame(maxHeight: .infinity)
            
            HStack {
                VStack(spacing: 4) {
                    Text("👆")
                        .font(.system(size: 20))
                    
                    Text("点击返回问题")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.info)
                }
                
                Spacer()
                
                Button(action: onFeedbackTap) {
                    HStack(spacing: 4) {
                        Text("📝")
                            .font(.system(size: 14))
                        
                        Text("纠错反馈")
                            .font(.system(size: 12))
                            .foregroundColor(AppColor.info)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .onTapGesture(perform: onTap)
    }
}

struct BadgeView: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color)
            .cornerRadius(4)
    }
}

// 学习状态按钮
struct StatusButtons: View {
    let onSelect: (Int) -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            StatusButton(
                icon: "✗",
                label: "不熟",
                color: AppColor.error,
                bgColor: AppColor.errorLight
            ) {
                onSelect(0)
            }
            
            StatusButton(
                icon: "~",
                label: "模糊",
                color: AppColor.warning,
                bgColor: AppColor.warningLight
            ) {
                onSelect(1)
            }
            
            StatusButton(
                icon: "✓",
                label: "掌握",
                color: AppColor.success,
                bgColor: AppColor.successLight
            ) {
                onSelect(2)
            }
        }
        .padding(16)
    }
}

struct StatusButton: View {
    let icon: String
    let label: String
    let color: Color
    let bgColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(bgColor)
                        .frame(width: 50, height: 50)

                    Text(icon)
                        .font(.system(size: 20))
                        .foregroundColor(color)
                }

                Text(label)
                    .font(.system(size: 14))
                    .foregroundColor(color)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct MarkdownText: View {
    let content: String
    let fontSize: CGFloat
    let textColor: Color

    init(_ content: String, fontSize: CGFloat = 16, textColor: Color = AppColor.textPrimary) {
        self.content = content
        self.fontSize = fontSize
        self.textColor = textColor
    }

    var body: some View {
        if let attributedString = parseMarkdown(content) {
            Text(attributedString)
                .font(.system(size: fontSize))
        } else {
            Text(content)
                .font(.system(size: fontSize))
                .foregroundColor(textColor)
        }
    }

    private func parseMarkdown(_ text: String) -> AttributedString? {
        do {
            var result = try AttributedString(markdown: text, options: AttributedString.MarkdownParsingOptions(
                interpretedSyntax: .inlineOnlyPreservingWhitespace
            ))
            result.foregroundColor = textColor
            return result
        } catch {
            return nil
        }
    }
}