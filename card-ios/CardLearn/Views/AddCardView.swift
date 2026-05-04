import SwiftUI

struct AddCardView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var majorList: [Major] = []
    @State private var subjectList: [Subject] = []
    @State private var selectedMajorId: Int?
    @State private var selectedSubjectId: Int?
    @State private var frontContent: String = ""
    @State private var backContent: String = ""
    @State private var difficultyLevel: Int = 2
    @State private var isSubmitting: Bool = false
    @State private var isLoadingSubjects: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showSuccess: Bool = false

    private let cardApi = CardApiService.shared
    private let userCardApi = UserCardApiService.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 提示信息
                    TipSection()

                    // 专业选择
                    MajorSelectSection(
                        majorList: majorList,
                        selectedMajorId: selectedMajorId,
                        onSelect: { majorId in
                            selectedMajorId = majorId
                            selectedSubjectId = nil
                            fetchSubjects(majorId: majorId)
                        }
                    )

                    // 科目选择
                    SubjectSelectSection(
                        subjectList: subjectList,
                        selectedSubjectId: selectedSubjectId,
                        isLoading: isLoadingSubjects,
                        onSelect: { subjectId in
                            selectedSubjectId = subjectId
                        }
                    )

                    // 正面内容
                    ContentInputSection(
                        title: "卡片正面（问题/知识点）",
                        placeholder: "请输入卡片正面内容...",
                        content: $frontContent
                    )

                    // 背面内容
                    ContentInputSection(
                        title: "卡片背面（答案/解析）",
                        placeholder: "请输入卡片背面内容...",
                        content: $backContent
                    )

                    // 难度选择
                    DifficultySection(
                        level: $difficultyLevel
                    )

                    // 提交按钮
                    SubmitButton(
                        isEnabled: canSubmit,
                        isSubmitting: isSubmitting,
                        action: submitCard
                    )
                }
                .padding(20)
            }
            .navigationTitle("添加卡片")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                fetchMajors()
            }
            .alert("提交成功", isPresented: $showSuccess) {
                Button("确定") {
                    dismiss()
                }
            } message: {
                Text("卡片已提交，等待管理员审核")
            }
            .alert("提交失败", isPresented: $showError) {
                Button("确定") {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private var canSubmit: Bool {
        selectedSubjectId != nil &&
        !frontContent.trimmingCharacters(in: .whitespaces).isEmpty &&
        !backContent.trimmingCharacters(in: .whitespaces).isEmpty &&
        !isSubmitting
    }

    private func fetchMajors() {
        Task {
            do {
                let majors = try await cardApi.getMajorList()
                await MainActor.run {
                    majorList = majors
                    // 默认选择第一个专业
                    if let firstMajor = majors.first {
                        selectedMajorId = firstMajor.majorId
                        fetchSubjects(majorId: firstMajor.majorId)
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "获取专业列表失败"
                    showError = true
                }
            }
        }
    }

    private func fetchSubjects(majorId: Int) {
        isLoadingSubjects = true
        selectedSubjectId = nil
        Task {
            do {
                let subjects = try await cardApi.getSubjectList(majorId: majorId)
                await MainActor.run {
                    subjectList = subjects
                    isLoadingSubjects = false
                    // 默认选择第一个科目
                    if let firstSubject = subjects.first {
                        selectedSubjectId = firstSubject.subjectId
                    }
                }
            } catch {
                await MainActor.run {
                    isLoadingSubjects = false
                    errorMessage = "获取科目列表失败"
                    showError = true
                }
            }
        }
    }

    private func submitCard() {
        let token = appState.token
        guard !token.isEmpty else {
            errorMessage = "请先登录后再提交卡片"
            showError = true
            return
        }

        guard let subjectId = selectedSubjectId else { return }

        isSubmitting = true

        Task {
            do {
                let _ = try await userCardApi.createCard(
                    subjectId: subjectId,
                    frontContent: frontContent.trimmingCharacters(in: .whitespaces),
                    backContent: backContent.trimmingCharacters(in: .whitespaces),
                    difficultyLevel: difficultyLevel,
                    tagIds: nil,
                    token: token
                )
                showSuccess = true
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isSubmitting = false
        }
    }
}

// 提示信息
struct TipSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("💡")
                    .font(.system(size: 16))
                Text("添加知识点卡片")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColor.textPrimary)
            }

            Text("贡献您的知识卡片，帮助更多考生复习。提交后需要管理员审核通过才会显示。")
                .font(.system(size: 13))
                .foregroundColor(AppColor.textMedium)

            Text("支持Markdown格式编写答案")
                .font(.system(size: 12))
                .foregroundColor(AppColor.textSecondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.backgroundLight)
        .cornerRadius(12)
    }
}

// 专业选择
struct MajorSelectSection: View {
    let majorList: [Major]
    let selectedMajorId: Int?
    let onSelect: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("选择专业")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppColor.textPrimary)

            if majorList.isEmpty {
                Text("加载中...")
                    .font(.system(size: 14))
                    .foregroundColor(AppColor.textSecondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(majorList) { major in
                            AddCardMajorItem(
                                major: major,
                                isSelected: selectedMajorId == major.majorId,
                                onSelect: { onSelect(major.majorId) }
                            )
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

fileprivate struct AddCardMajorItem: View {
    let major: Major
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            Text(major.majorName)
                .font(.system(size: 13, weight: isSelected ? .medium : .regular))
                .foregroundColor(isSelected ? .white : AppColor.textMedium)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ?
                              AppColor.primary :
                              AppColor.backgroundLight)
                )
        }
    }
}

// 科目选择
struct SubjectSelectSection: View {
    let subjectList: [Subject]
    let selectedSubjectId: Int?
    let isLoading: Bool
    let onSelect: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("选择科目")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppColor.textPrimary)

            if isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                }
                .padding(12)
            } else if subjectList.isEmpty {
                Text("请先选择专业")
                    .font(.system(size: 14))
                    .foregroundColor(AppColor.textSecondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(subjectList) { subject in
                            AddCardSubjectItem(
                                subject: subject,
                                isSelected: selectedSubjectId == subject.subjectId,
                                onSelect: { onSelect(subject.subjectId) }
                            )
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

fileprivate struct AddCardSubjectItem: View {
    let subject: Subject
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            Text(subject.subjectName)
                .font(.system(size: 13, weight: isSelected ? .medium : .regular))
                .foregroundColor(isSelected ? .white : AppColor.textMedium)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ?
                              AppColor.primary :
                              AppColor.backgroundLight)
                )
        }
    }
}

// 内容输入
struct ContentInputSection: View {
    let title: String
    let placeholder: String
    @Binding var content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppColor.textPrimary)

            TextEditor(text: $content)
                .font(.system(size: 14))
                .foregroundColor(AppColor.textPrimary)
                .frame(height: 120)
                .padding(12)
                .background(AppColor.backgroundLight)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppColor.border, lineWidth: 1)
                )

            if content.isEmpty {
                Text(placeholder)
                    .font(.system(size: 14))
                    .foregroundColor(AppColor.disabledText)
                    .padding(.top, -100)
                    .padding(.leading, 16)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// 难度选择
struct DifficultySection: View {
    @Binding var level: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("难度等级")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppColor.textPrimary)

            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { i in
                    DifficultyItem(
                        level: i,
                        isSelected: level == i,
                        onSelect: { level = i }
                    )
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct DifficultyItem: View {
    let level: Int
    let isSelected: Bool
    let onSelect: () -> Void

    var color: String {
        switch level {
        case 1, 2: return "4CAF50"  // 绿色
        case 3: return "FF9800"     // 橙色
        case 4, 5: return "F44336"  // 红色
        default: return "9E9E9E"
        }
    }

    var label: String {
        switch level {
        case 1: return "简单"
        case 2: return "较易"
        case 3: return "中等"
        case 4: return "较难"
        case 5: return "困难"
        default: return ""
        }
    }

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 4) {
                Text("\(level)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? .white : Color(hex: color))

                Text(label)
                    .font(.system(size: 11))
                    .foregroundColor(isSelected ? .white : AppColor.textSecondary)
            }
            .frame(width: 50, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ?
                          Color(hex: color) :
                          AppColor.backgroundLight)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(hex: color), lineWidth: isSelected ? 0 : 1)
            )
        }
    }
}

// 提交按钮
struct SubmitButton: View {
    let isEnabled: Bool
    let isSubmitting: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }

                Text(isSubmitting ? "提交中..." : "提交卡片")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isEnabled ? .white : AppColor.disabledText)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(
                LinearGradient(
                    colors: isEnabled ?
                        [AppColor.primary, AppColor.primaryGradientEnd] :
                        [AppColor.border, AppColor.border],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
        }
        .disabled(!isEnabled || isSubmitting)
    }
}

#Preview {
    AddCardView()
        .environmentObject(AppState())
}