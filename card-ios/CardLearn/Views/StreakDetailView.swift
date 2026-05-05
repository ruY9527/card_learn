import SwiftUI

/// 学习趋势详情页 - 按季度展示的 GitHub 风格热力图
struct StreakDetailView: View {
    let streakType: StreakType
    let streakValue: Int

    @EnvironmentObject var appState: AppState
    @State private var trendData: [String: Int] = [:]
    @State private var trendList: [DailyLearnTrend] = []
    @State private var isLoading = true
    /// 季度偏移：0=当前季度，-1=上一个季度，-2=再上一个...
    @State private var quarterOffset = 0

    private let apiService = CardApiService.shared
    private let calendar = Calendar.current

    // MARK: - 类型定义

    enum StreakType {
        case current, longest, total

        var title: String {
            switch self {
            case .current: return "当前连续学习"
            case .longest: return "最长连续记录"
            case .total: return "累计学习天数"
            }
        }

        var days: Int {
            switch self {
            case .current: return 90
            case .longest: return 365
            case .total: return 730
            }
        }

        var color: Color {
            switch self {
            case .current: return Color(hex: "FF6B6B")
            case .longest: return Color(hex: "FFD700")
            case .total: return Color(hex: "667eea")
            }
        }

        var icon: String {
            switch self {
            case .current: return "flame.fill"
            case .longest: return "trophy.fill"
            case .total: return "calendar"
            }
        }
    }

    struct MonthRange {
        let label: String
        let startWeekIndex: Int
        let weekCount: Int
    }

    // MARK: - 常量

    private let cellSpacing: CGFloat = 2
    private let cellRadius: CGFloat = 3

    // MARK: - 季度计算

    /// 当前季度的 (year, quarterIndex)，quarterIndex 0-3
    private var currentQuarterTuple: (year: Int, q: Int) {
        let now = Date()
        let y = calendar.component(.year, from: now)
        let m = calendar.component(.month, from: now)
        return (y, (m - 1) / 3)
    }

    /// 选中季度的 (year, quarterIndex)
    private var selectedQuarterTuple: (year: Int, q: Int) {
        let cur = currentQuarterTuple
        // 将偏移转换为绝对季度数
        let absQuarter = cur.year * 4 + cur.q + quarterOffset
        let year = absQuarter / 4
        let q = ((absQuarter % 4) + 4) % 4
        return (year, q)
    }

    /// 是否是当前季度（不能再往前）
    private var isCurrentQuarter: Bool {
        quarterOffset >= 0
    }

    /// 季度标题
    private var quarterTitle: String {
        let sq = selectedQuarterTuple
        let qName = ["一季度", "二季度", "三季度", "四季度"][sq.q]
        let months = ["1-3月", "4-6月", "7-9月", "10-12月"][sq.q]
        return "\(sq.year)年 \(qName) (\(months))"
    }

    // MARK: - 统计数据

    private var activeDays: Int {
        trendList.filter { $0.count > 0 }.count
    }

    private var totalStudyCount: Int {
        trendList.reduce(0) { $0 + $1.count }
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                summaryCard
                heatmapCard
                recentList
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(streakType.title)
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadData() }
    }

    // MARK: - 顶部统计卡片

    private var summaryCard: some View {
        HStack(spacing: 0) {
            statItem(value: "\(streakValue)", label: streakType == .total ? "累计天数" : "连续天数", icon: streakType.icon, color: streakType.color)
            Divider().frame(height: 40)
            statItem(value: "\(activeDays)", label: "活跃天数", icon: "checkmark.circle.fill", color: Color(hex: "4CAF50"))
            Divider().frame(height: 40)
            statItem(value: "\(totalStudyCount)", label: "学习次数", icon: "number.circle.fill", color: Color(hex: "667eea"))
        }
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    private func statItem(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - 热力图卡片

    private var heatmapCard: some View {
        VStack(spacing: 10) {
            quarterNavHeader

            if isLoading {
                ProgressView("加载中...")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                HeatmapQuarterGrid(
                    weeks: quarterWeeks(),
                    monthRanges: quarterMonthRanges(),
                    streakColor: streakType.color,
                    cellSpacing: cellSpacing,
                    cellRadius: cellRadius,
                    leftLabelW: 16,
                    spacingH: 3,
                    heatColor: heatColor
                )

                legendBar
            }
        }
        .padding(14)
        .padding(.bottom, 4)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    // MARK: - 季度导航头部

    private var quarterNavHeader: some View {
        HStack {
            // 左箭头：往前一个季度
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    quarterOffset -= 1
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(streakType.color)
                    .frame(width: 32, height: 32)
                    .background(streakType.color.opacity(0.1))
                    .cornerRadius(8)
            }

            Spacer()

            // 季度标题
            Text(quarterTitle)
                .font(.system(size: 15, weight: .semibold))
                .animation(.none, value: quarterOffset)

            Spacer()

            // 右箭头：往后一个季度（不能超过当前季度）
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    quarterOffset += 1
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isCurrentQuarter ? .gray.opacity(0.3) : streakType.color)
                    .frame(width: 32, height: 32)
                    .background(isCurrentQuarter ? Color(.systemGray5) : streakType.color.opacity(0.1))
                    .cornerRadius(8)
            }
            .disabled(isCurrentQuarter)
        }
    }

    // MARK: - 图例

    private var legendBar: some View {
        HStack(spacing: 3) {
            Text("少")
                .font(.system(size: 9))
                .foregroundColor(.secondary)
            ForEach(0..<5, id: \.self) { level in
                RoundedRectangle(cornerRadius: cellRadius)
                    .fill(heatColor(count: level == 0 ? 0 : level * 2))
                    .frame(width: 11, height: 11)
            }
            Text("多")
                .font(.system(size: 9))
                .foregroundColor(.secondary)

            Spacer()

            Text(String(format: "周均 %.1f 天", weeklyAverage))
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .padding(.top, 6)
        .padding(.bottom, 2)
    }

    private var weeklyAverage: Double {
        let startDate = quarterStartDate()
        guard let endDate = calendar.date(byAdding: .day, value: 13 * 7, to: startDate) else { return 0 }
        let activeInQuarter = trendList.filter { item in
            guard item.count > 0, let date = parseDate(item.date) else { return false }
            return date >= startDate && date < endDate
        }.count
        return Double(activeInQuarter) / 13.0 * 7.0
    }

    // MARK: - 季度数据构建

    /// 该季度的起始日期（第一个月的第1天对齐到周一）
    private func quarterStartDate() -> Date {
        let sq = selectedQuarterTuple
        let firstMonth = sq.q * 3 + 1
        var comp = DateComponents()
        comp.year = sq.year
        comp.month = firstMonth
        comp.day = 1
        let firstOfMonth = calendar.date(from: comp)!
        let weekday = calendar.component(.weekday, from: firstOfMonth)
        let mondayOffset = weekday == 1 ? -6 : (2 - weekday)
        return calendar.date(byAdding: .day, value: mondayOffset, to: firstOfMonth)!
    }

    /// 构建该季度的13周数据
    private func quarterWeeks() -> [[DayCell]] {
        let today = Date()
        let startDate = quarterStartDate()
        let weekCount = 13
        let dataMinDate = calendar.date(byAdding: .day, value: -(streakType.days - 1), to: today)!

        var weeks: [[DayCell]] = []
        for weekIndex in 0..<weekCount {
            let monday = calendar.date(byAdding: .day, value: weekIndex * 7, to: startDate)!
            var week: [DayCell] = []
            for dayOffset in 0..<7 {
                let date = calendar.date(byAdding: .day, value: dayOffset, to: monday)!
                if date > today || date < dataMinDate {
                    week.append(.empty)
                } else {
                    let dateStr = formatDate(date)
                    week.append(DayCell(
                        date: date, dateStr: dateStr,
                        count: trendData[dateStr] ?? 0,
                        isToday: calendar.isDateInToday(date),
                        isFuture: false, isInDataRange: true
                    ))
                }
            }
            weeks.append(week)
        }
        return weeks
    }

    /// 计算每个月在13周中的位置和宽度
    private func quarterMonthRanges() -> [MonthRange] {
        let startDate = quarterStartDate()
        let sq = selectedQuarterTuple
        let firstMonth = sq.q * 3 + 1
        let zhFmt = DateFormatter()
        zhFmt.locale = Locale(identifier: "zh_CN")
        zhFmt.dateFormat = "M月"

        var ranges: [MonthRange] = []
        for m in 0..<3 {
            var comp = DateComponents()
            comp.year = sq.year
            comp.month = firstMonth + m
            comp.day = 1
            let monthStart = calendar.date(from: comp)!
            let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart)!

            var startWeek = -1
            var endWeek = -1
            for w in 0..<13 {
                let weekStart = calendar.date(byAdding: .day, value: w * 7, to: startDate)!
                let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
                if weekStart < monthEnd && weekEnd > monthStart {
                    if startWeek < 0 { startWeek = w }
                    endWeek = w
                }
            }
            if startWeek >= 0 {
                ranges.append(MonthRange(
                    label: zhFmt.string(from: monthStart),
                    startWeekIndex: startWeek,
                    weekCount: endWeek - startWeek + 1
                ))
            }
        }
        return ranges
    }

    // MARK: - 颜色

    private func heatColor(count: Int) -> Color {
        switch count {
        case 0: return Color(.systemGray5)
        case 1: return streakType.color.opacity(0.2)
        case 2...3: return streakType.color.opacity(0.4)
        case 4...6: return streakType.color.opacity(0.6)
        default: return streakType.color.opacity(0.85)
        }
    }

    // MARK: - 最近学习记录

    private var recentList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("学习记录")
                .font(.headline)

            let recentItems = trendList.filter { $0.count > 0 }.suffix(20).reversed()
            if recentItems.isEmpty {
                Text("暂无学习记录")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                ForEach(Array(recentItems), id: \.date) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(formatDisplayDate(item.date))
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            Text(formatWeekday(item.date))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        HStack(spacing: 4) {
                            ForEach(0..<min(item.count, 6), id: \.self) { _ in
                                Circle().fill(streakType.color).frame(width: 6, height: 6)
                            }
                            if item.count > 6 {
                                Text("+\(item.count - 6)")
                                    .font(.caption2).foregroundColor(.secondary)
                            }
                        }

                        Text("\(item.count) 次")
                            .font(.subheadline.bold())
                            .foregroundColor(streakType.color)
                            .frame(width: 45, alignment: .trailing)
                    }
                    .padding(.vertical, 6)

                    if item.date != recentItems.last?.date {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    // MARK: - 辅助方法

    private func formatDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: date)
    }

    private func parseDate(_ str: String) -> Date? {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.date(from: str)
    }

    private func formatDisplayDate(_ dateStr: String) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        guard let date = fmt.date(from: dateStr) else { return dateStr }
        fmt.dateFormat = "M月d日"
        return fmt.string(from: date)
    }

    private func formatWeekday(_ dateStr: String) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        guard let date = fmt.date(from: dateStr) else { return "" }
        fmt.locale = Locale(identifier: "zh_CN")
        fmt.dateFormat = "EEEE"
        return fmt.string(from: date)
    }

    // MARK: - 数据加载

    private func loadData() async {
        isLoading = true
        do {
            let data = try await apiService.getLearnTrend(
                userId: appState.userInfo?.userId,
                days: streakType.days
            )
            await MainActor.run {
                var map: [String: Int] = [:]
                for item in data { map[item.date] = item.count }
                self.trendData = map
                self.trendList = data.sorted { $0.date < $1.date }
                self.isLoading = false
            }
        } catch {
            await MainActor.run { self.isLoading = false }
        }
    }
}

// MARK: - 日历单元格

private struct DayCell {
    let date: Date
    let dateStr: String
    let count: Int
    let isToday: Bool
    let isFuture: Bool
    let isInDataRange: Bool

    var isEmpty: Bool { dateStr.isEmpty }

    static let empty = DayCell(
        date: Date(), dateStr: "", count: 0,
        isToday: false, isFuture: false, isInDataRange: false
    )
}

extension DayCell: Equatable {
    static func == (lhs: DayCell, rhs: DayCell) -> Bool { lhs.dateStr == rhs.dateStr }
}

// MARK: - 季度热力图网格组件

private struct HeatmapQuarterGrid: View {
    let weeks: [[DayCell]]
    let monthRanges: [StreakDetailView.MonthRange]
    let streakColor: Color
    let cellSpacing: CGFloat
    let cellRadius: CGFloat
    let leftLabelW: CGFloat
    let spacingH: CGFloat
    let heatColor: (Int) -> Color

    var body: some View {
        let weekCount = CGFloat(weeks.count)
        let gridHeight = 7 * 20 + 6 * cellSpacing

        VStack(alignment: .leading, spacing: 0) {
            GeometryReader { geo in
                let gridWidth = geo.size.width - leftLabelW - spacingH
                let cellSize = (gridWidth - (weekCount - 1) * cellSpacing) / weekCount

                VStack(alignment: .leading, spacing: 0) {
                    // 月份标签
                    monthLabelsRow(cellSize: cellSize)
                        .frame(height: 16)

                    // 热力图主体
                    HStack(alignment: .top, spacing: spacingH) {
                        // 左侧星期标签
                        VStack(spacing: cellSpacing) {
                            ForEach(Array(["一", "", "三", "", "五", "", "日"].enumerated()), id: \.offset) { _, label in
                                Text(label)
                                    .font(.system(size: 8))
                                    .foregroundColor(.secondary.opacity(0.6))
                                    .frame(height: cellSize, alignment: .trailing)
                            }
                        }
                        .frame(width: leftLabelW, alignment: .topTrailing)

                        // 格子网格
                        HStack(alignment: .top, spacing: cellSpacing) {
                            ForEach(Array(weeks.enumerated()), id: \.offset) { _, week in
                                VStack(spacing: cellSpacing) {
                                    ForEach(Array(week.enumerated()), id: \.offset) { _, day in
                                        if day.isEmpty {
                                            Color.clear.frame(width: cellSize, height: cellSize)
                                        } else {
                                            RoundedRectangle(cornerRadius: cellRadius)
                                                .fill(heatColor(day.count))
                                                .frame(width: cellSize, height: cellSize)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: cellRadius)
                                                        .stroke(day.isToday ? streakColor : Color.clear, lineWidth: 1.5)
                                                )
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .frame(height: 16 + gridHeight)
    }

    /// 月份标签行：用绝对定位精确对齐到对应周列
    private func monthLabelsRow(cellSize: CGFloat) -> some View {
        GeometryReader { geo in
            let weekColW = cellSize + cellSpacing
            let gridOffset = leftLabelW + spacingH

            ZStack(alignment: .topLeading) {
                ForEach(Array(monthRanges.enumerated()), id: \.offset) { _, range in
                    let centerWeek = CGFloat(range.startWeekIndex) + CGFloat(range.weekCount) / 2
                    let x = gridOffset + centerWeek * weekColW - weekColW / 2

                    Text(range.label)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                        .position(x: x, y: 8)
                }
            }
        }
        .frame(height: 16)
    }
}
