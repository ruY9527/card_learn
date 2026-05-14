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
    @State private var reminderHour: Int = 20
    @State private var reminderMinute: Int = 0
    @State private var showTimePicker = false

    private let apiService = IncentiveApiService.shared
    private let preferences = NotificationPreferences.shared

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

                Section(header: Text("提醒设置")) {
                    Toggle("启用每日学习提醒", isOn: $isEnabled)
                        .onChange(of: isEnabled) { newValue in
                            if newValue {
                                requestNotificationPermission()
                            }
                        }

                    if isEnabled {
                        HStack {
                            Text("提醒时间")
                            Spacer()
                            Button(action: { showTimePicker = true }) {
                                Text(String(format: "%02d:%02d", reminderHour, reminderMinute))
                                    .foregroundColor(Color(hex: "667eea"))
                                    .bold()
                            }
                        }

                        if !appState.notificationPermissionGranted {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(AppColor.warning)
                                Text("请在系统设置中允许通知权限")
                                    .font(.caption)
                                    .foregroundColor(AppColor.warning)
                            }
                        }
                    }
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
        .sheet(isPresented: $showTimePicker) {
            ReminderTimePickerSheet(hour: $reminderHour, minute: $reminderMinute)
        }
        .task {
            await loadGoal()
            loadReminderPreferences()
        }
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
                if let hour = goal.reminderHour {
                    self.reminderHour = hour
                }
                if let minute = goal.reminderMinute {
                    self.reminderMinute = minute
                }
                self.isLoading = false
            }
        } catch {
            await MainActor.run { self.isLoading = false }
        }
    }

    private func loadReminderPreferences() {
        reminderHour = preferences.reminderHour
        reminderMinute = preferences.reminderMinute
        if preferences.reminderEnabled != isEnabled {
            isEnabled = preferences.reminderEnabled
        }
    }

    private func requestNotificationPermission() {
        Task {
            let granted = await NotificationService.shared.requestAuthorization()
            await MainActor.run {
                appState.notificationPermissionGranted = granted
                if !granted {
                    isEnabled = false
                }
            }
        }
    }

    private func saveGoal() async {
        guard let userId = appState.userInfo?.userId else { return }
        await MainActor.run { isSaving = true }
        do {
            let request = GoalSetRequest(
                dailyLearnTarget: Int(learnTarget),
                dailyMasterTarget: Int(masterTarget),
                enabled: isEnabled,
                reminderHour: reminderHour,
                reminderMinute: reminderMinute
            )
            _ = try await apiService.setGoal(userId: userId, request: request)

            preferences.reminderEnabled = isEnabled
            preferences.reminderHour = reminderHour
            preferences.reminderMinute = reminderMinute
            preferences.syncLocalNotification()

            await MainActor.run {
                isSaving = false
                showSuccess = true
            }
        } catch {
            await MainActor.run { isSaving = false }
        }
    }
}

struct ReminderTimePickerSheet: View {
    @Binding var hour: Int
    @Binding var minute: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "选择提醒时间",
                    selection: Binding(
                        get: {
                            Calendar.current.date(from: DateComponents(hour: hour, minute: minute)) ?? Date()
                        },
                        set: { date in
                            let components = Calendar.current.dateComponents([.hour, .minute], from: date)
                            hour = components.hour ?? 20
                            minute = components.minute ?? 0
                        }
                    ),
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
            }
            .navigationTitle("提醒时间")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("确定") { dismiss() }
                        .foregroundColor(Color(hex: "667eea"))
                }
            }
        }
        .presentationDetents([.medium])
    }
}
