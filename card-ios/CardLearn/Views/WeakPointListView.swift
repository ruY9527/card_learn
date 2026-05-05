import SwiftUI

/// 薄弱点列表页面
struct WeakPointListView: View {
    @EnvironmentObject var appState: AppState
    @State private var weakPoints: [WeakPoint] = []
    @State private var isLoading = true
    @State private var total = 0

    private let apiService = ReportApiService.shared

    var body: some View {
        List {
            if isLoading {
                HStack {
                    Spacer()
                    ProgressView("加载中...")
                    Spacer()
                }
                .padding(.vertical, 40)
            } else if weakPoints.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: "4CAF50"))
                    Text("暂无薄弱点")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("继续保持良好的学习状态！")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .listRowBackground(Color.clear)
            } else {
                Section(header: Text("共 \(total) 个薄弱点")) {
                    ForEach(weakPoints) { wp in
                        WeakPointRow(weakPoint: wp)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("薄弱点")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadWeakPoints() }
    }

    private func loadWeakPoints() async {
        isLoading = true
        do {
            let response = try await apiService.getWeakPoints(userId: appState.userInfo?.userId)
            await MainActor.run {
                self.weakPoints = response.records
                self.total = response.total
                self.isLoading = false
            }
        } catch {
            await MainActor.run { self.isLoading = false }
        }
    }
}

/// 薄弱点行
struct WeakPointRow: View {
    let weakPoint: WeakPoint

    var body: some View {
        HStack(spacing: 12) {
            // 错误次数标记
            ZStack {
                Circle()
                    .fill(errorColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                Text("\(weakPoint.errorCount)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(errorColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(weakPoint.frontContent ?? "未知卡片")
                    .font(.subheadline)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    if let subject = weakPoint.subjectName {
                        Text(subject)
                            .font(.caption2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(hex: "667eea"))
                            .cornerRadius(4)
                    }

                    if let time = weakPoint.lastErrorTime {
                        Text(formatTime(time))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }

    private var errorColor: Color {
        if weakPoint.errorCount >= 3 {
            return Color(hex: "FF6B6B")
        } else if weakPoint.errorCount >= 2 {
            return Color(hex: "FFD700")
        } else {
            return Color(hex: "FF9800")
        }
    }

    private func formatTime(_ timeStr: String) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let date = fmt.date(from: timeStr) else { return timeStr }
        fmt.dateFormat = "M月d日 HH:mm"
        return fmt.string(from: date)
    }
}
