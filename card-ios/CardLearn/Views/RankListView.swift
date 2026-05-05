import SwiftUI

/// 排行榜页面
struct RankListView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    @State private var totalRankItems: [RankItem] = []
    @State private var weekRankItems: [RankItem] = []
    @State private var streakRankItems: [RankItem] = []
    @State private var userRank: RankPosition?
    @State private var isLoading = true

    private let apiService = IncentiveApiService.shared
    private let tabs = ["总榜", "周榜", "连击榜"]

    var body: some View {
        VStack(spacing: 0) {
            // Tab 选择
            Picker("排行榜类型", selection: $selectedTab) {
                ForEach(0..<tabs.count, id: \.self) { index in
                    Text(tabs[index]).tag(index)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            // 用户排名置顶
            if let rank = userRank {
                userRankCard(rank)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            }

            // 排行榜列表
            if isLoading {
                Spacer()
                ProgressView("加载中...")
                Spacer()
            } else {
                List {
                    ForEach(currentItems) { item in
                        rankRow(item)
                    }
                }
                .listStyle(.plain)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("排行榜")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadData() }
    }

    private var currentItems: [RankItem] {
        switch selectedTab {
        case 0: return totalRankItems
        case 1: return weekRankItems
        case 2: return streakRankItems
        default: return totalRankItems
        }
    }

    // MARK: - 用户排名卡片

    private func userRankCard(_ rank: RankPosition) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("我的排名")
                    .font(.caption)
                    .foregroundColor(.secondary)
                switch selectedTab {
                case 0:
                    Text("第 \(rank.rank ?? 0) 名")
                        .font(.title2.bold())
                    Text("经验: \(rank.totalExp ?? 0)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                case 1:
                    Text("第 \(rank.weekRank ?? 0) 名")
                        .font(.title2.bold())
                    Text("本周学习: \(rank.weekLearnCount ?? 0)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                default:
                    Text("第 \(rank.streakRank ?? 0) 名")
                        .font(.title2.bold())
                    Text("连续: \(rank.currentStreak ?? 0) 天")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Image(systemName: "person.fill")
                .font(.title)
                .foregroundColor(Color(hex: "667eea"))
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    // MARK: - 排行榜行

    private func rankRow(_ item: RankItem) -> some View {
        HStack(spacing: 12) {
            // 排名
            ZStack {
                if item.rank <= 3 {
                    Circle()
                        .fill(rankColor(item.rank))
                        .frame(width: 32, height: 32)
                    Text("\(item.rank)")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                } else {
                    Text("\(item.rank)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(width: 32, height: 32)
                }
            }

            // 用户信息
            VStack(alignment: .leading, spacing: 2) {
                Text(item.nickname)
                    .font(.subheadline.bold())
                Text("Lv.\(item.level)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // 指标
            VStack(alignment: .trailing, spacing: 2) {
                switch selectedTab {
                case 0:
                    Text("\(item.totalExp ?? 0)")
                        .font(.subheadline.bold())
                        .foregroundColor(Color(hex: "667eea"))
                    Text("经验")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                case 1:
                    Text("\(item.weekLearnCount ?? 0)")
                        .font(.subheadline.bold())
                        .foregroundColor(Color(hex: "667eea"))
                    Text("学习")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                default:
                    Text("\(item.currentStreak ?? 0)")
                        .font(.subheadline.bold())
                        .foregroundColor(Color(hex: "f093fb"))
                    Text("天")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return Color(hex: "FFD700")
        case 2: return Color(hex: "C0C0C0")
        case 3: return Color(hex: "CD7F32")
        default: return .gray
        }
    }

    // MARK: - 数据加载

    private func loadData() async {
        guard let userId = appState.userInfo?.userId else {
            isLoading = false
            return
        }
        isLoading = true
        do {
            async let totalTask = apiService.getTotalRank(pageNum: 1, pageSize: 50)
            async let weekTask = apiService.getWeekRank(pageNum: 1, pageSize: 50)
            async let streakTask = apiService.getStreakRank(pageNum: 1, pageSize: 50)
            async let userTask = apiService.getUserRank(userId: userId)

            let (total, week, streak, rank) = try await (totalTask, weekTask, streakTask, userTask)

            await MainActor.run {
                self.totalRankItems = total.records
                self.weekRankItems = week.records
                self.streakRankItems = streak.records
                self.userRank = rank
                self.isLoading = false
            }
        } catch {
            await MainActor.run { self.isLoading = false }
        }
    }
}
