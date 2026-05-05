import SwiftUI

/// 成就页面
struct AchievementView: View {
    @EnvironmentObject var appState: AppState
    @State private var achievements: [Achievement] = []
    @State private var selectedCategory: AchievementCategory = .all
    @State private var isLoading = true
    @State private var selectedAchievement: Achievement?

    private let apiService = IncentiveApiService.shared

    private var filteredAchievements: [Achievement] {
        switch selectedCategory {
        case .all: return achievements
        default: return achievements.filter { $0.category == selectedCategory.rawValue }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // 分类选择
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(AchievementCategory.allCases, id: \.self) { category in
                        Button(action: { selectedCategory = category }) {
                            Text(category.label)
                                .font(.subheadline)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedCategory == category ? Color(hex: "667eea") : Color(.systemGray6))
                                .foregroundColor(selectedCategory == category ? .white : .primary)
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }

            if isLoading {
                Spacer()
                ProgressView("加载中...")
                Spacer()
            } else {
                // 成就统计
                let unlocked = achievements.filter { $0.unlocked == true }.count
                Text("已解锁 \(unlocked)/\(achievements.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 4)

                // 成就网格
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(filteredAchievements) { achievement in
                            achievementItem(achievement)
                                .onTapGesture { selectedAchievement = achievement }
                        }
                    }
                    .padding()
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("我的成就")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedAchievement) { achievement in
            achievementDetailSheet(achievement)
        }
        .task { await loadData() }
    }

    // MARK: - 成就项

    private func achievementItem(_ achievement: Achievement) -> some View {
        let isUnlocked = achievement.unlocked == true
        return VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color(hex: achievement.tierColor).opacity(0.2) : Color(.systemGray5))
                    .frame(width: 60, height: 60)
                Image(systemName: achievement.icon ?? "star.fill")
                    .font(.title2)
                    .foregroundColor(isUnlocked ? Color(hex: achievement.tierColor) : .gray)
            }
            Text(achievement.name)
                .font(.caption)
                .lineLimit(1)
                .foregroundColor(isUnlocked ? .primary : .secondary)
            Text(achievement.tierName)
                .font(.caption2)
                .foregroundColor(isUnlocked ? Color(hex: achievement.tierColor) : .gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .opacity(isUnlocked ? 1.0 : 0.6)
    }

    // MARK: - 成就详情弹窗

    private func achievementDetailSheet(_ achievement: Achievement) -> some View {
        VStack(spacing: 20) {
            // 顶部拖拽指示器
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(.systemGray4))
                .frame(width: 40, height: 5)
                .padding(.top, 8)

            // 成就图标
            ZStack {
                Circle()
                    .fill(Color(hex: achievement.tierColor).opacity(0.2))
                    .frame(width: 100, height: 100)
                Image(systemName: achievement.icon ?? "star.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Color(hex: achievement.tierColor))
            }

            // 成就信息
            Text(achievement.name)
                .font(.title2.bold())
            Text(achievement.tierName)
                .font(.subheadline)
                .foregroundColor(Color(hex: achievement.tierColor))
            Text(achievement.description ?? "")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            if (achievement.expReward ?? 0) > 0 {
                Text("奖励: +\(achievement.expReward!) 经验")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "667eea"))
            }

            if achievement.unlocked == true, let achievedAt = achievement.achievedAt {
                Text("获得时间: \(achievedAt)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .presentationDetents([.medium])
    }

    // MARK: - 数据加载

    private func loadData() async {
        guard let userId = appState.userInfo?.userId else {
            isLoading = false
            return
        }
        do {
            let list = try await apiService.getAchievementList(userId: userId)
            await MainActor.run {
                self.achievements = list
                self.isLoading = false
            }
        } catch {
            await MainActor.run { self.isLoading = false }
        }
    }
}
