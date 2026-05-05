import SwiftUI

/// 目标设置页面
struct GoalSettingView: View {
    @EnvironmentObject var appState: AppState
    @State private var learnTarget: Double = 20
    @State private var masterTarget: Double = 10
    @State private var isEnabled = true
    @State private var isLoading = true
    @State private var isSaving = false
    @State private var showSuccess = false

    private let apiService = IncentiveApiService.shared

    var body: some View {
        Form {
            if isLoading {
                ProgressView("加载中...")
            } else {
                Section(header: Text("每日学习目标")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("学习卡片数")
                            Spacer()
                            Text("\(Int(learnTarget)) 张")
                                .foregroundColor(Color(hex: "667eea"))
                                .bold()
                        }
                        Slider(value: $learnTarget, in: 5...100, step: 5)
                            .accentColor(Color(hex: "667eea"))
                    }
                }

                Section(header: Text("每日掌握目标")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("掌握卡片数")
                            Spacer()
                            Text("\(Int(masterTarget)) 张")
                                .foregroundColor(Color(hex: "f093fb"))
                                .bold()
                        }
                        Slider(value: $masterTarget, in: 5...50, step: 5)
                            .accentColor(Color(hex: "f093fb"))
                    }
                }

                Section {
                    Toggle("启用目标提醒", isOn: $isEnabled)
                }

                Section {
                    Button(action: { Task { await saveGoal() } }) {
                        HStack {
                            Spacer()
                            if isSaving {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("保存设置")
                                    .bold()
                            }
                            Spacer()
                        }
                    }
                    .listRowBackground(Color(hex: "667eea"))
                    .foregroundColor(.white)
                    .disabled(isSaving)
                }
            }
        }
        .navigationTitle("目标设置")
        .navigationBarTitleDisplayMode(.inline)
        .alert("保存成功", isPresented: $showSuccess) {
            Button("确定", role: .cancel) {}
        }
        .task { await loadGoal() }
    }

    private func loadGoal() async {
        guard let userId = appState.userInfo?.userId else {
            isLoading = false
            return
        }
        do {
            let goal = try await apiService.getCurrentGoal(userId: userId)
            await MainActor.run {
                self.learnTarget = Double(goal.dailyLearnTarget)
                self.masterTarget = Double(goal.dailyMasterTarget)
                self.isEnabled = goal.enabled
                self.isLoading = false
            }
        } catch {
            await MainActor.run { self.isLoading = false }
        }
    }

    private func saveGoal() async {
        guard let userId = appState.userInfo?.userId else { return }
        await MainActor.run { isSaving = true }
        do {
            let request = GoalSetRequest(
                dailyLearnTarget: Int(learnTarget),
                dailyMasterTarget: Int(masterTarget),
                enabled: isEnabled
            )
            _ = try await apiService.setGoal(userId: userId, request: request)
            await MainActor.run {
                isSaving = false
                showSuccess = true
            }
        } catch {
            await MainActor.run { isSaving = false }
        }
    }
}
