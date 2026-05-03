import SwiftUI
import PhotosUI

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
                                        .foregroundColor(AppColor.textPrimary)
                                    Text("*")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppColor.error)
                                }

                                if isLoadingMajors {
                                    HStack {
                                        Spacer()
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(AppColor.backgroundLight)
                                    .cornerRadius(8)
                                } else if majorList.isEmpty {
                                    Text("暂无专业数据")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppColor.textSecondary)
                                        .padding(12)
                                        .frame(maxWidth: .infinity)
                                        .background(AppColor.backgroundLight)
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
                                                .foregroundColor(selectedMajor != nil ? AppColor.textPrimary : AppColor.textSecondary)
                                            Spacer()
                                            Text("▼")
                                                .font(.system(size: 12))
                                                .foregroundColor(AppColor.textSecondary)
                                        }
                                        .padding(12)
                                        .background(AppColor.backgroundLight)
                                        .cornerRadius(8)
                                    }
                                }
                            }

                            // 科目选择
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 4) {
                                    Text("选择科目")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(AppColor.textPrimary)
                                    Text("*")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppColor.error)
                                }

                                if isLoadingSubjects {
                                    HStack {
                                        Spacer()
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(AppColor.backgroundLight)
                                    .cornerRadius(8)
                                } else if selectedMajor == nil {
                                    Text("请先选择专业")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppColor.textSecondary)
                                        .padding(12)
                                        .frame(maxWidth: .infinity)
                                        .background(AppColor.backgroundLight)
                                        .cornerRadius(8)
                                } else if subjectList.isEmpty {
                                    Text("该专业暂无科目")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppColor.textSecondary)
                                        .padding(12)
                                        .frame(maxWidth: .infinity)
                                        .background(AppColor.backgroundLight)
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
                                                .foregroundColor(selectedSubject != nil ? AppColor.textPrimary : AppColor.textSecondary)
                                            Spacer()
                                            Text("▼")
                                                .font(.system(size: 12))
                                                .foregroundColor(AppColor.textSecondary)
                                        }
                                        .padding(12)
                                        .background(AppColor.backgroundLight)
                                        .cornerRadius(8)
                                    }
                                }
                            }

                            // 反馈类型
                            VStack(alignment: .leading, spacing: 12) {
                                Text("反馈类型")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(AppColor.textPrimary)

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
                                    .foregroundColor(AppColor.textPrimary)

                                HStack(spacing: 8) {
                                    ForEach(1..<6, id: \.self) { index in
                                        Button(action: { rating = index }) {
                                            Text("★")
                                                .font(.system(size: 24))
                                                .foregroundColor(index <= rating ? AppColor.gold : AppColor.divider)
                                        }
                                    }

                                    if rating > 0 {
                                        Text("\(rating)星")
                                            .font(.system(size: 14))
                                            .foregroundColor(AppColor.textSecondary)
                                    }
                                }
                            }

                            // 反馈内容
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 4) {
                                    Text("反馈内容")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(AppColor.textPrimary)
                                    Text("*")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppColor.error)
                                }

                                TextEditor(text: $content)
                                    .font(.system(size: 14))
                                    .padding(12)
                                    .background(AppColor.backgroundLight)
                                    .cornerRadius(8)
                                    .frame(height: 120)

                                HStack {
                                    Spacer()
                                    Text("\(content.count)/500")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppColor.textSecondary)
                                }
                            }

                            // 联系方式
                            VStack(alignment: .leading, spacing: 12) {
                                Text("联系方式（可选）")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(AppColor.textPrimary)

                                TextField("留下您的联系方式，方便我们回复", text: $contact)
                                    .font(.system(size: 14))
                                    .padding(12)
                                    .background(AppColor.backgroundLight)
                                    .cornerRadius(8)
                            }

                            // 图片上传
                            VStack(alignment: .leading, spacing: 12) {
                                Text("图片附件（可选）")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(AppColor.textPrimary)

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
                                    .foregroundColor(AppColor.textSecondary)
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
                                                [AppColor.primary, AppColor.primaryGradientEnd] :
                                                [AppColor.disabledText, AppColor.disabledText],
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
                .foregroundColor(AppColor.textPrimary)

            Text("登录后可以更好地追踪反馈处理进度")
                .font(.system(size: 14))
                .foregroundColor(AppColor.textSecondary)
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
                .foregroundColor(AppColor.textPrimary)

            HStack(spacing: 8) {
                Text("#\(cardId)")
                    .font(.system(size: 12))
                    .foregroundColor(AppColor.primary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AppColor.infoLight)
                    .cornerRadius(4)

                Text(content.isEmpty ? "卡片\(cardId)" : content)
                    .font(.system(size: 14))
                    .foregroundColor(AppColor.textPrimary)
                    .lineLimit(1)

                Spacer()

                Text("✓")
                    .font(.system(size: 14))
                    .foregroundColor(AppColor.primary)
            }
            .padding(12)
            .background(AppColor.backgroundLight)
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
                .foregroundColor(isSelected ? .white : AppColor.textMedium)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ?
                              LinearGradient(colors: [AppColor.primary, AppColor.primaryGradientEnd], startPoint: .topLeading, endPoint: .bottomTrailing) :
                              LinearGradient(colors: [AppColor.backgroundLight, AppColor.backgroundLight], startPoint: .topLeading, endPoint: .bottomTrailing)
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
                    .background(AppColor.error)
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
                    .foregroundColor(AppColor.textSecondary)

                Text("上传图片")
                    .font(.system(size: 12))
                    .foregroundColor(AppColor.textSecondary)
            }
            .frame(width: 80, height: 80)
            .background(AppColor.backgroundLight)
            .cornerRadius(8)
        }
    }
}

// 图片选择器（支持多选，最多 maxCount 张）
struct ImagePicker: UIViewControllerRepresentable {
    let images: [UIImage]
    let maxCount: Int
    let onSelect: ([UIImage]) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = maxCount
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var onSelect: ([UIImage]) -> Void

        init(onSelect: @escaping ([UIImage]) -> Void) {
            self.onSelect = onSelect
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard !results.isEmpty else {
                picker.dismiss(animated: true)
                return
            }
            var images: [UIImage] = []
            let group = DispatchGroup()
            for result in results {
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                    if let image = object as? UIImage {
                        images.append(image)
                    }
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                picker.dismiss(animated: true)
                self.onSelect(images)
            }
        }
    }
}