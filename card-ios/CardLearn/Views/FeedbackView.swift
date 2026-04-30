import SwiftUI

struct FeedbackView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    let cardId: Int?
    let cardContent: String?

    @State private var feedbackType: FeedbackType = .suggestion
    @State private var rating: Int = 0
    @State private var content: String = ""
    @State private var contact: String = ""
    @State private var images: [UIImage] = []
    @State private var isSubmitting: Bool = false
    @State private var showImagePicker: Bool = false

    // 专业和科目选择
    @State private var majorList: [Major] = []
    @State private var selectedMajor: Major?
    @State private var subjectList: [Subject] = []
    @State private var selectedSubject: Subject?
    @State private var isLoadingMajors: Bool = false
    @State private var isLoadingSubjects: Bool = false

    private let apiService = APIService.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 登录提示
                    if !appState.isLoggedIn {
                        LoginPrompt()
                            .padding(.top, 40)
                    }

                    // 反馈表单
                    if appState.isLoggedIn {
                        VStack(spacing: 20) {
                            // 卡片纠错信息
                            if let cardId = cardId {
                                CardInfoSection(cardId: cardId, content: cardContent ?? "")
                            }

                            // 专业选择
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 4) {
                                    Text("选择专业")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(Color(hex: "303133"))
                                    Text("*")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(hex: "F56C6C"))
                                }

                                if isLoadingMajors {
                                    HStack {
                                        Spacer()
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(Color(hex: "F5F7FA"))
                                    .cornerRadius(8)
                                } else if majorList.isEmpty {
                                    Text("暂无专业数据")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(hex: "909399"))
                                        .padding(12)
                                        .frame(maxWidth: .infinity)
                                        .background(Color(hex: "F5F7FA"))
                                        .cornerRadius(8)
                                } else {
                                    Menu {
                                        ForEach(majorList) { major in
                                            Button(action: {
                                                selectedMajor = major
                                                loadSubjects(for: major.majorId)
                                            }) {
                                                HStack {
                                                    Text(major.majorName)
                                                    if selectedMajor?.majorId == major.majorId {
                                                        Text("✓")
                                                    }
                                                }
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Text(selectedMajor?.majorName ?? "请选择专业")
                                                .font(.system(size: 14))
                                                .foregroundColor(selectedMajor != nil ? Color(hex: "303133") : Color(hex: "909399"))
                                            Spacer()
                                            Text("▼")
                                                .font(.system(size: 12))
                                                .foregroundColor(Color(hex: "909399"))
                                        }
                                        .padding(12)
                                        .background(Color(hex: "F5F7FA"))
                                        .cornerRadius(8)
                                    }
                                }
                            }

                            // 科目选择
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 4) {
                                    Text("选择科目")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(Color(hex: "303133"))
                                    Text("*")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(hex: "F56C6C"))
                                }

                                if isLoadingSubjects {
                                    HStack {
                                        Spacer()
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(Color(hex: "F5F7FA"))
                                    .cornerRadius(8)
                                } else if selectedMajor == nil {
                                    Text("请先选择专业")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(hex: "909399"))
                                        .padding(12)
                                        .frame(maxWidth: .infinity)
                                        .background(Color(hex: "F5F7FA"))
                                        .cornerRadius(8)
                                } else if subjectList.isEmpty {
                                    Text("该专业暂无科目")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(hex: "909399"))
                                        .padding(12)
                                        .frame(maxWidth: .infinity)
                                        .background(Color(hex: "F5F7FA"))
                                        .cornerRadius(8)
                                } else {
                                    Menu {
                                        ForEach(subjectList) { subject in
                                            Button(action: {
                                                selectedSubject = subject
                                            }) {
                                                HStack {
                                                    Text(subject.subjectName)
                                                    if selectedSubject?.subjectId == subject.subjectId {
                                                        Text("✓")
                                                    }
                                                }
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Text(selectedSubject?.subjectName ?? "请选择科目")
                                                .font(.system(size: 14))
                                                .foregroundColor(selectedSubject != nil ? Color(hex: "303133") : Color(hex: "909399"))
                                            Spacer()
                                            Text("▼")
                                                .font(.system(size: 12))
                                                .foregroundColor(Color(hex: "909399"))
                                        }
                                        .padding(12)
                                        .background(Color(hex: "F5F7FA"))
                                        .cornerRadius(8)
                                    }
                                }
                            }

                            // 反馈类型
                            VStack(alignment: .leading, spacing: 12) {
                                Text("反馈类型")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(hex: "303133"))

                                HStack(spacing: 12) {
                                    ForEach(FeedbackType.allCases, id: \.self) { type in
                                        TypeButton(
                                            type: type,
                                            isSelected: feedbackType == type
                                        ) {
                                            feedbackType = type
                                        }
                                    }
                                }
                            }

                            // 评分
                            VStack(alignment: .leading, spacing: 12) {
                                Text("评分（可选）")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(hex: "303133"))

                                HStack(spacing: 8) {
                                    ForEach(1..<6, id: \.self) { index in
                                        Button(action: { rating = index }) {
                                            Text("★")
                                                .font(.system(size: 24))
                                                .foregroundColor(index <= rating ? Color(hex: "FFD700") : Color(hex: "E0E0E0"))
                                        }
                                    }

                                    if rating > 0 {
                                        Text("\(rating)星")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color(hex: "909399"))
                                    }
                                }
                            }

                            // 反馈内容
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 4) {
                                    Text("反馈内容")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(Color(hex: "303133"))
                                    Text("*")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(hex: "F56C6C"))
                                }

                                TextEditor(text: $content)
                                    .font(.system(size: 14))
                                    .padding(12)
                                    .background(Color(hex: "F5F7FA"))
                                    .cornerRadius(8)
                                    .frame(height: 120)

                                HStack {
                                    Spacer()
                                    Text("\(content.count)/500")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(hex: "909399"))
                                }
                            }

                            // 联系方式
                            VStack(alignment: .leading, spacing: 12) {
                                Text("联系方式（可选）")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(hex: "303133"))

                                TextField("留下您的联系方式，方便我们回复", text: $contact)
                                    .font(.system(size: 14))
                                    .padding(12)
                                    .background(Color(hex: "F5F7FA"))
                                    .cornerRadius(8)
                            }

                            // 图片上传
                            VStack(alignment: .leading, spacing: 12) {
                                Text("图片附件（可选）")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(hex: "303133"))

                                HStack(spacing: 12) {
                                    ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                                        ImagePreview(
                                            image: image,
                                            index: index
                                        ) {
                                            images.remove(at: index)
                                        }
                                    }

                                    if images.count < 3 {
                                        UploadButton {
                                            showImagePicker = true
                                        }
                                    }
                                }

                                Text("最多上传3张图片")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: "909399"))
                            }

                            // 提交按钮
                            Button(action: submitFeedback) {
                                Text(isSubmitting ? "提交中..." : "提交反馈")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(16)
                                    .background(
                                        LinearGradient(
                                            colors: canSubmit ?
                                                [Color(hex: "667eea"), Color(hex: "764ba2")] :
                                                [Color(hex: "C0C4CC"), Color(hex: "C0C4CC")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .cornerRadius(12)
                            }
                            .disabled(!canSubmit || isSubmitting)
                        }
                        .padding(.top, 20)
                    }

                    // 历史反馈入口
                    if appState.isLoggedIn {
                        Button(action: { }) {
                            HStack {
                                Text("📋")
                                    .font(.system(size: 20))

                                Text("查看我的反馈记录")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "303133"))

                                Spacer()

                                Text("→")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "667eea"))
                            }
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        .padding(.bottom, 20)
                    }
                }
                .padding(.horizontal, 16)
            }
            .navigationTitle(cardId != nil ? "卡片纠错" : "提交反馈")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(images: images, maxCount: 3 - images.count) { selectedImages in
                    images.append(contentsOf: selectedImages)
                }
            }
        }
        .onAppear {
            if cardId != nil {
                feedbackType = .error
            }
            loadMajors()
        }
    }

    // 是否可以提交
    private var canSubmit: Bool {
        !content.trimmingCharacters(in: .whitespaces).isEmpty &&
        selectedMajor != nil &&
        selectedSubject != nil
    }

    // 加载专业列表
    private func loadMajors() {
        isLoadingMajors = true
        Task {
            do {
                let majors = try await apiService.getMajorList()
                await MainActor.run {
                    majorList = majors
                    isLoadingMajors = false
                    // 默认选择第一个专业
                    if let firstMajor = majors.first {
                        selectedMajor = firstMajor
                        loadSubjects(for: firstMajor.majorId)
                    }
                }
            } catch {
                await MainActor.run {
                    isLoadingMajors = false
                }
            }
        }
    }

    // 加载科目列表
    private func loadSubjects(for majorId: Int) {
        isLoadingSubjects = true
        selectedSubject = nil // 清空已选科目
        Task {
            do {
                let subjects = try await apiService.getSubjectList(majorId: majorId)
                await MainActor.run {
                    subjectList = subjects
                    isLoadingSubjects = false
                    // 默认选择第一个科目
                    if let firstSubject = subjects.first {
                        selectedSubject = firstSubject
                    }
                }
            } catch {
                await MainActor.run {
                    isLoadingSubjects = false
                }
            }
        }
    }

    private func submitFeedback() {
        guard let userId = appState.userInfo?.userId,
              let majorId = selectedMajor?.majorId,
              let subjectId = selectedSubject?.subjectId else { return }

        isSubmitting = true

        Task {
            do {
                let _ = try await apiService.submitFeedback(
                    appUserId: userId,
                    cardId: cardId,
                    majorId: majorId,
                    subjectId: subjectId,
                    type: feedbackType.rawValue,
                    rating: rating > 0 ? rating : nil,
                    content: content.trimmingCharacters(in: .whitespaces),
                    contact: contact.isEmpty ? nil : contact,
                    images: nil,
                    token: appState.token
                )

                isSubmitting = false

                // 返回上一页
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss()
                }
            } catch {
                isSubmitting = false
            }
        }
    }
}

// 登录提示
struct LoginPrompt: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("🔒")
                .font(.system(size: 48))

            Text("提交反馈需要先登录")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(hex: "303133"))

            Text("登录后可以更好地追踪反馈处理进度")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "909399"))
        }
    }
}

// 卡片信息区域
struct CardInfoSection: View {
    let cardId: Int
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("关联卡片")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "303133"))

            HStack(spacing: 8) {
                Text("#\(cardId)")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "667eea"))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(hex: "F0F5FF"))
                    .cornerRadius(4)

                Text(content.isEmpty ? "卡片\(cardId)" : content)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "303133"))
                    .lineLimit(1)

                Spacer()

                Text("✓")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "667eea"))
            }
            .padding(12)
            .background(Color(hex: "F5F7FA"))
            .cornerRadius(8)
        }
    }
}

// 类型按钮
struct TypeButton: View {
    let type: FeedbackType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(type.label)
                .font(.system(size: 14, weight: isSelected ? .medium : .regular))
                .foregroundColor(isSelected ? .white : Color(hex: "606266"))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ?
                              LinearGradient(colors: [Color(hex: "667eea"), Color(hex: "764ba2")], startPoint: .topLeading, endPoint: .bottomTrailing) :
                              LinearGradient(colors: [Color(hex: "F5F7FA"), Color(hex: "F5F7FA")], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                )
        }
    }
}

// 图片预览
struct ImagePreview: View {
    let image: UIImage
    let index: Int
    let onRemove: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .cornerRadius(8)
                .clipped()

            Button(action: onRemove) {
                Text("×")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(4)
                    .background(Color(hex: "F56C6C"))
                    .cornerRadius(10)
            }
            .offset(x: 4, y: -4)
        }
    }
}

// 上传按钮
struct UploadButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text("+")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "909399"))

                Text("上传图片")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "909399"))
            }
            .frame(width: 80, height: 80)
            .background(Color(hex: "F5F7FA"))
            .cornerRadius(8)
        }
    }
}

// 图片选择器（简化版）
struct ImagePicker: UIViewControllerRepresentable {
    let images: [UIImage]
    let maxCount: Int
    let onSelect: ([UIImage]) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.image"]
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var onSelect: ([UIImage]) -> Void

        init(onSelect: @escaping ([UIImage]) -> Void) {
            self.onSelect = onSelect
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                onSelect([image])
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}