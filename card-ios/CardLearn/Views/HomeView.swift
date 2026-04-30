import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var majorList: [Major] = []
    @State private var subjectList: [Subject] = []
    @State private var recommendCards: [Card] = []
    @State private var sprintConfig: SprintConfig?
    @State private var countdownDays: Int = 0
    @State private var countdownText: String = ""
    @State private var isLoading: Bool = false
    @State private var isLoadingSubjects: Bool = false
    @State private var initialized: Bool = false // 是否已初始化

    @State private var showStudy: Bool = false
    @State private var selectedSubject: Subject?
    @State private var showCardDetail: Bool = false
    @State private var selectedCard: Card?

    private let apiService = APIService.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // 考研倒计时
                    if countdownDays > 0 || (sprintConfig?.enabled ?? false) {
                        CountdownBar(
                            days: countdownDays,
                            text: countdownText,
                            examName: sprintConfig?.examName ?? "距离考研还有"
                        )
                    }

                    // 专业分类下拉选择
                    VStack(alignment: .leading, spacing: 12) {
                        Text("专业分类")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "303133"))
                            .padding(.horizontal, 16)

                        Menu {
                            ForEach(majorList) { major in
                                Button(action: {
                                    selectMajor(major)
                                }) {
                                    HStack {
                                        Text(major.majorName)
                                        if appState.selectedMajorId == major.majorId {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                if let selectedMajor = majorList.first(where: { $0.majorId == appState.selectedMajorId }) {
                                    Text(selectedMajor.majorName)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color(hex: "303133"))
                                } else if let firstMajor = majorList.first {
                                    Text(firstMajor.majorName)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color(hex: "303133"))
                                } else {
                                    Text("请选择专业")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(hex: "909399"))
                                }

                                Spacer()

                                Image(systemName: "chevron.down")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "909399"))
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        .padding(.horizontal, 16)
                    }

                    // 科目列表（联动加载）
                    if appState.selectedMajorId != nil {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("科目列表")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(Color(hex: "303133"))

                                if isLoadingSubjects {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                }

                                Spacer()
                            }
                            .padding(.horizontal, 16)

                            if isLoadingSubjects {
                                HStack {
                                    Spacer()
                                    Text("加载科目中...")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(hex: "909399"))
                                        .padding(.vertical, 32)
                                    Spacer()
                                }
                            } else if subjectList.isEmpty {
                                HStack {
                                    Spacer()
                                    Text("该专业暂无科目数据")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(hex: "909399"))
                                        .padding(.vertical, 32)
                                    Spacer()
                                }
                            } else {
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 16) {
                                    ForEach(subjectList) { subject in
                                        SubjectItem(subject: subject)
                                            .onTapGesture {
                                                selectedSubject = subject
                                                showStudy = true
                                            }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                    }

                    // 推荐卡片
                    VStack(alignment: .leading, spacing: 12) {
                        Text("今日推荐")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "303133"))
                            .padding(.horizontal, 16)

                        if !recommendCards.isEmpty {
                            LazyVStack(spacing: 12) {
                                ForEach(recommendCards) { card in
                                    RecommendCardItem(card: card)
                                        .onTapGesture {
                                            selectedCard = card
                                            showCardDetail = true
                                        }
                                }
                            }
                            .padding(.horizontal, 16)
                        } else {
                            VStack {
                                Text("暂无推荐卡片")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "909399"))
                                    .padding(.vertical, 32)
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.top, 16)
            }
            .navigationTitle("考研知识点学习卡片")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                refreshData()
            }
            .navigationDestination(isPresented: $showStudy) {
                if let subject = selectedSubject {
                    StudyView(subjectId: subject.subjectId, subjectName: subject.subjectName)
                }
            }
            .navigationDestination(isPresented: $showCardDetail) {
                if let card = selectedCard {
                    CardDetailView(
                        cardList: [card],
                        currentIndex: 0,
                        subjectId: card.subjectId,
                        subjectName: card.subjectName ?? "知识点卡片"
                    )
                }
            }
        }
        .onAppear {
            if !initialized {
                initializePage()
            } else {
                // 已初始化，恢复用户之前选择的专业
                restoreSelectedMajor()
            }
        }
    }

    // 初始化页面（只在第一次onAppear时调用）
    private func initializePage() {
        Task {
            isLoading = true
            initialized = true

            // 获取冲刺配置
            do {
                sprintConfig = try await apiService.getSprintConfig()
                if let config = sprintConfig, config.enabled, !(config.isExpired ?? true) {
                    countdownDays = config.daysRemaining ?? 0
                    countdownText = getCountdownText(days: countdownDays)
                } else {
                    calculateDefaultCountdown()
                }
            } catch {
                calculateDefaultCountdown()
            }

            // 获取专业列表
            do {
                majorList = try await apiService.getMajorList()
                
                // 尝试恢复用户之前选择的专业
                if let savedMajorId = appState.selectedMajorId {
                    // 检查保存的专业是否在列表中
                    let majorExists = majorList.contains { $0.majorId == savedMajorId }
                    if majorExists {
                        await fetchSubjects(majorId: savedMajorId)
                        await fetchRecommendCards(majorId: savedMajorId)
                    } else {
                        // 如果保存的专业不存在，加载第一个专业并保存
                        loadFirstMajor()
                    }
                } else {
                    // 没有保存的专业，加载第一个专业并保存
                    loadFirstMajor()
                }
            } catch {
                majorList = []
            }

            isLoading = false
        }
    }

    // 加载第一个专业
    private func loadFirstMajor() {
        if let firstMajor = majorList.first {
            appState.saveSelectedMajor(majorId: firstMajor.majorId, majorName: firstMajor.majorName)
            Task {
                await fetchSubjects(majorId: firstMajor.majorId)
                await fetchRecommendCards(majorId: firstMajor.majorId)
            }
        }
    }

    // 恢复用户选择的专业
    private func restoreSelectedMajor() {
        // 更新冲刺配置
        Task {
            do {
                sprintConfig = try await apiService.getSprintConfig()
                if let config = sprintConfig, config.enabled, !(config.isExpired ?? true) {
                    countdownDays = config.daysRemaining ?? 0
                    countdownText = getCountdownText(days: countdownDays)
                } else {
                    calculateDefaultCountdown()
                }
            } catch {
                calculateDefaultCountdown()
            }
        }
        
        // 如果有保存的专业且与当前显示不同，重新加载
        if let savedMajorId = appState.selectedMajorId {
            let needsReload = subjectList.isEmpty || 
                majorList.first(where: { $0.majorId == savedMajorId })?.majorId != savedMajorId
            
            if needsReload {
                Task {
                    await fetchSubjects(majorId: savedMajorId)
                    await fetchRecommendCards(majorId: savedMajorId)
                }
            }
        }
    }

    // 刷新数据（下拉刷新时调用）
    private func refreshData() {
        Task {
            // 更新冲刺配置
            do {
                sprintConfig = try await apiService.getSprintConfig()
                if let config = sprintConfig, config.enabled, !(config.isExpired ?? true) {
                    countdownDays = config.daysRemaining ?? 0
                    countdownText = getCountdownText(days: countdownDays)
                } else {
                    calculateDefaultCountdown()
                }
            } catch {
                calculateDefaultCountdown()
            }

            // 重新获取专业列表
            do {
                majorList = try await apiService.getMajorList()
                
                // 恢复之前选择的专业
                if let savedMajorId = appState.selectedMajorId {
                    let majorExists = majorList.contains { $0.majorId == savedMajorId }
                    if majorExists {
                        await fetchSubjects(majorId: savedMajorId)
                        await fetchRecommendCards(majorId: savedMajorId)
                    } else {
                        loadFirstMajor()
                    }
                } else if majorList.first != nil {
                    loadFirstMajor()
                }
            } catch {
                majorList = []
            }
        }
    }

    private func fetchSubjects(majorId: Int) async {
        isLoadingSubjects = true
        do {
            subjectList = try await apiService.getSubjectList(majorId: majorId)
        } catch {
            subjectList = []
        }
        isLoadingSubjects = false
    }

    private func fetchRecommendCards(majorId: Int) async {
        do {
            recommendCards = try await apiService.getRecommendCards(majorId: majorId)
        } catch {
            recommendCards = []
        }
    }

    private func selectMajor(_ major: Major) {
        // 保存用户选择的专业
        appState.saveSelectedMajor(majorId: major.majorId, majorName: major.majorName)
        
        subjectList = []
        recommendCards = []
        
        Task {
            await fetchSubjects(majorId: major.majorId)
            await fetchRecommendCards(majorId: major.majorId)
        }
    }

    private func calculateDefaultCountdown() {
        let now = Date()
        let currentYear = Calendar.current.component(.year, from: now)
        let examDate = Calendar.current.date(from: DateComponents(year: currentYear, month: 12, day: 21))!
        let diffDays = Calendar.current.dateComponents([.day], from: now, to: examDate).day ?? 0

        countdownDays = max(diffDays, 0)
        countdownText = getCountdownText(days: countdownDays)

        sprintConfig = SprintConfig(
            enabled: false,
            examName: nil,
            examDate: nil,
            daysRemaining: nil,
            isExpired: true
        )
    }

    private func getCountdownText(days: Int) -> String {
        if days > 365 { return "备战考研" }
        if days > 100 { return "冲刺阶段" }
        if days > 30 { return "考前冲刺" }
        if days > 7 { return "最后冲刺" }
        if days > 0 { return "考前一周" }
        return "考试进行中"
    }
}

// 倒计时组件
struct CountdownBar: View {
    let days: Int
    let text: String
    let examName: String

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(text)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)

                    Text(examName)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(days)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)

                    Text("天")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
            )
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// 专业项目组件
struct MajorItem: View {
    let major: Major
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(major.majorName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(isSelected ? .white : Color(hex: "303133"))

                    Text(major.description ?? "点击查看科目")
                        .font(.system(size: 12))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : Color(hex: "909399"))
                }

                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ?
                          LinearGradient(colors: [Color(hex: "667eea"), Color(hex: "764ba2")], startPoint: .topLeading, endPoint: .bottomTrailing) :
                          LinearGradient(colors: [.white, .white], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            )
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

// 科目项目组件
struct SubjectItem: View {
    let subject: Subject

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(hex: "409EFF"))
                    .frame(width: 40, height: 40)

                Text(String(subject.subjectName.prefix(1)))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }

            Text(subject.subjectName)
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "303133"))
                .lineLimit(1)
        }
    }
}

// 推荐卡片组件
struct RecommendCardItem: View {
    let card: Card

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(card.subjectName ?? "")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "409EFF"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "ECF5FF"))
                    .cornerRadius(4)

                Spacer()
            }

            Text(card.frontContent)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "303133"))
                .lineLimit(3)

            HStack {
                Text("难度: \(card.difficultyLevel ?? 1)级")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "909399"))

                Spacer()

                Text("点击查看答案")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "409EFF"))
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
