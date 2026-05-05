import SwiftUI

/// 经验明细页面
struct ExpLogView: View {
    @EnvironmentObject var appState: AppState
    @State private var logs: [ExpLog] = []
    @State private var isLoading = true
    @State private var pageNum = 1
    @State private var hasMore = true

    private let apiService = IncentiveApiService.shared

    var body: some View {
        List {
            if isLoading && logs.isEmpty {
                ProgressView("加载中...")
                    .frame(maxWidth: .infinity)
            } else if logs.isEmpty {
                Text("暂无经验记录")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ForEach(logs) { log in
                    HStack(spacing: 12) {
                        Image(systemName: log.sourceIcon)
                            .font(.title3)
                            .foregroundColor(Color(hex: "667eea"))
                            .frame(width: 32)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(log.description ?? log.sourceType)
                                .font(.subheadline)
                            Text(log.createTime)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Text("+\(log.expChange)")
                            .font(.subheadline.bold())
                            .foregroundColor(.green)
                    }
                    .padding(.vertical, 4)
                    .onAppear {
                        if log.id == logs.last?.id && hasMore && !isLoading {
                            Task { await loadMore() }
                        }
                    }
                }

                if isLoading && !logs.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("经验明细")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadData() }
    }

    private func loadData() async {
        guard let userId = appState.userInfo?.userId else {
            isLoading = false
            return
        }
        isLoading = true
        pageNum = 1
        do {
            let result = try await apiService.getExpLog(userId: userId, pageNum: pageNum, pageSize: 20)
            await MainActor.run {
                self.logs = result.records
                self.hasMore = logs.count < result.total
                self.isLoading = false
            }
        } catch {
            await MainActor.run { self.isLoading = false }
        }
    }

    private func loadMore() async {
        guard let userId = appState.userInfo?.userId, !isLoading else { return }
        isLoading = true
        pageNum += 1
        do {
            let result = try await apiService.getExpLog(userId: userId, pageNum: pageNum, pageSize: 20)
            await MainActor.run {
                self.logs.append(contentsOf: result.records)
                self.hasMore = logs.count < result.total
                self.isLoading = false
            }
        } catch {
            await MainActor.run { self.isLoading = false }
        }
    }
}
