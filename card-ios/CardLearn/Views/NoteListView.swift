import SwiftUI

struct NoteListView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var notes: [Note] = []
    @State private var subjects: [Subject] = []
    @State private var selectedSubjectId: Int? = nil
    @State private var keyword: String = ""
    @State private var isLoading = false
    @State private var pageNum = 1
    @State private var hasMore = true
    @State private var showError = false
    @State private var errorMessage = ""

    // Navigation to card detail
    @State private var showCardDetail = false
    @State private var selectedCard: Card? = nil
    @State private var cardList: [Card] = []

    private let cardApi = CardApiService.shared
    private let noteApi = NoteApiService.shared

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack(spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.textSecondary)
                    TextField("搜索笔记内容...", text: $keyword)
                        .font(.system(size: 14))
                        .onSubmit { loadNotes(refresh: true) }
                }
                .padding(10)
                .background(AppColor.backgroundLight)
                .cornerRadius(10)

                if !keyword.isEmpty {
                    Button("取消") {
                        keyword = ""
                        loadNotes(refresh: true)
                    }
                    .font(.system(size: 14))
                    .foregroundColor(AppColor.primary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            // Subject filter
            if !subjects.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        subjectChip(nil, label: "全部")
                        ForEach(subjects) { subject in
                            subjectChip(subject.subjectId, label: subject.subjectName)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)
                }
            }

            Divider()

            // Note list
            if isLoading && notes.isEmpty {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppColor.primary))
                Spacer()
            } else if notes.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "note.text")
                        .font(.system(size: 40))
                        .foregroundColor(AppColor.divider)
                    Text("暂无笔记")
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.textSecondary)
                    Text("在卡片评论时勾选\"保存为笔记\"即可创建")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.textSecondary)
                }
                Spacer()
            } else {
                List {
                    ForEach(notes) { note in
                        noteRow(note)
                            .onAppear {
                                if note.id == notes.last?.id && hasMore && !isLoading {
                                    loadMore()
                                }
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    }
                    .onDelete { indexSet in
                        if let index = indexSet.first {
                            deleteNote(notes[index])
                        }
                    }

                    if isLoading && !notes.isEmpty {
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
                .refreshable {
                    loadNotes(refresh: true)
                }
            }
        }
        .navigationTitle("我的笔记")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showCardDetail) {
            if let card = selectedCard {
                CardDetailView(
                    cardList: cardList,
                    currentIndex: 0,
                    subjectId: card.subjectId,
                    subjectName: card.subjectName ?? "知识点卡片"
                )
            }
        }
        .onAppear {
            loadSubjects()
            loadNotes(refresh: true)
        }
        .alert("错误", isPresented: $showError) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Subject Chip

    private func subjectChip(_ subjectId: Int?, label: String) -> some View {
        let isSelected = subjectId == selectedSubjectId
        return Text(label)
            .font(.system(size: 12))
            .foregroundColor(isSelected ? .white : AppColor.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? AppColor.primary : AppColor.backgroundLight)
            .cornerRadius(14)
            .onTapGesture {
                selectedSubjectId = subjectId
                loadNotes(refresh: true)
            }
    }

    // MARK: - Note Row

    private func noteRow(_ note: Note) -> some View {
        Button(action: { navigateToCard(note) }) {
            VStack(alignment: .leading, spacing: 8) {
                // Header: subject + time
                HStack {
                    if let subject = note.subjectName {
                        Text(subject)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(AppColor.primary)
                            .cornerRadius(4)
                    }

                    Spacer()

                    Text(note.createTime ?? "")
                        .font(.system(size: 11))
                        .foregroundColor(AppColor.textSecondary)
                }

                // Card title (front content)
                if let cardTitle = note.cardFrontContent {
                    Text(cardTitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppColor.textSecondary)
                        .lineLimit(1)
                }

                // Note content
                Text(note.content)
                    .font(.system(size: 14))
                    .foregroundColor(AppColor.textPrimary)
                    .lineSpacing(4)
                    .lineLimit(3)

                // Footer: stats
                HStack(spacing: 12) {
                    if let likes = note.likeCount, likes > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "heart")
                                .font(.system(size: 11))
                            Text("\(likes)")
                                .font(.system(size: 11))
                        }
                        .foregroundColor(AppColor.textSecondary)
                    }

                    if let replies = note.replyCount, replies > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "bubble.right")
                                .font(.system(size: 11))
                            Text("\(replies)")
                                .font(.system(size: 11))
                        }
                        .foregroundColor(AppColor.textSecondary)
                    }

                    Spacer()

                    HStack(spacing: 2) {
                        Text("查看卡片")
                            .font(.system(size: 11))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(AppColor.primary)
                }
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Data Loading

    private func loadSubjects() {
        Task {
            do {
                let result = try await cardApi.getSubjectList(majorId: nil)
                await MainActor.run {
                    subjects = result
                }
            } catch {
                // Silent fail
            }
        }
    }

    private func loadNotes(refresh: Bool) {
        guard !isLoading else { return }
        guard let userId = appState.userInfo?.userId else { return }

        if refresh {
            pageNum = 1
        }

        isLoading = true

        Task {
            do {
                let pageData = try await noteApi.getMyNotes(
                    userId: userId,
                    subjectId: selectedSubjectId,
                    keyword: keyword.isEmpty ? nil : keyword,
                    pageNum: pageNum
                )
                await MainActor.run {
                    if refresh {
                        notes = pageData.records
                    } else {
                        notes.append(contentsOf: pageData.records)
                    }
                    hasMore = notes.count < (pageData.total ?? 0)
                    pageNum += 1
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }

    private func loadMore() {
        loadNotes(refresh: false)
    }

    private func deleteNote(_ note: Note) {
        guard let userId = appState.userInfo?.userId else { return }

        Task {
            do {
                try await noteApi.deleteNote(noteId: note.commentId, userId: userId)
                await MainActor.run {
                    notes.removeAll { $0.commentId == note.commentId }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "删除失败"
                    showError = true
                }
            }
        }
    }

    private func navigateToCard(_ note: Note) {
        Task {
            do {
                let card = try await cardApi.getCardById(cardId: note.cardId, appUserId: appState.userInfo?.userId)
                await MainActor.run {
                    selectedCard = card
                    cardList = [card]
                    showCardDetail = true
                }
            } catch {
                await MainActor.run {
                    errorMessage = "加载卡片失败"
                    showError = true
                }
            }
        }
    }
}
