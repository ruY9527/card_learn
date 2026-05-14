import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: Tab = .home
    @State private var showCardFromNotification = false
    @State private var notificationCardId: Int?

    enum Tab {
        case home
        case review
        case stats
        case profile
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // 主内容区域
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .review:
                    ReviewListView()
                case .stats:
                    StatsView()
                case .profile:
                    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 80)
            }

            // 自定义 TabBar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
        .background(AppColor.backgroundGray)
        .onChange(of: appState.pendingNavigationCardId) { cardId in
            if let cardId = cardId {
                notificationCardId = cardId
                showCardFromNotification = true
                appState.pendingNavigationCardId = nil
            }
        }
        .sheet(isPresented: $showCardFromNotification) {
            if let cardId = notificationCardId {
                NotificationCardNavigationView(cardId: cardId)
            }
        }
    }
}

/// 通知点击后的卡片导航中间层
struct NotificationCardNavigationView: View {
    let cardId: Int
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("加载卡片...")
                } else {
                    Text("卡片ID: \(cardId)")
                        .foregroundColor(AppColor.textSecondary)
                }
            }
            .navigationTitle("复习卡片")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") { dismiss() }
                }
            }
        }
        .task {
            // 模拟加载，实际需要根据cardId获取卡片数据
            try? await Task.sleep(nanoseconds: 500_000_000)
            isLoading = false
        }
    }
}

// 自定义 TabBar
struct CustomTabBar: View {
    @Binding var selectedTab: MainTabView.Tab

    var body: some View {
        HStack(spacing: 0) {
            TabBarItem(
                icon: "house.fill",
                title: "首页",
                isSelected: selectedTab == .home
            ) {
                selectedTab = .home
            }

            TabBarItem(
                icon: "clock.arrow.circlepath",
                title: "复习",
                isSelected: selectedTab == .review
            ) {
                selectedTab = .review
            }

            TabBarItem(
                icon: "chart.bar.fill",
                title: "统计",
                isSelected: selectedTab == .stats
            ) {
                selectedTab = .stats
            }

            TabBarItem(
                icon: "person.fill",
                title: "我的",
                isSelected: selectedTab == .profile
            ) {
                selectedTab = .profile
            }
        }
        .frame(height: 60)
        .background(Color.white)
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -2)
    }
}

struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? AppColor.info : AppColor.inactive)
                
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? AppColor.info : AppColor.inactive)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// View extension for corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let p1 = CGPoint(x: rect.minX, y: rect.minY + radius)
        let p2 = CGPoint(x: rect.minX + radius, y: rect.minY)
        let p3 = CGPoint(x: rect.maxX - radius, y: rect.minY)
        let p4 = CGPoint(x: rect.maxX, y: rect.minY + radius)
        let p5 = CGPoint(x: rect.maxX, y: rect.maxY - radius)
        let p6 = CGPoint(x: rect.maxX - radius, y: rect.maxY)
        let p7 = CGPoint(x: rect.minX + radius, y: rect.maxY)
        let p8 = CGPoint(x: rect.minX, y: rect.maxY - radius)
        
        if corners.contains(.topLeft) {
            path.move(to: p1)
            path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.minY), tangent2End: p2, radius: radius)
        } else {
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        }
        
        if corners.contains(.topRight) {
            path.addLine(to: p3)
            path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.minY), tangent2End: p4, radius: radius)
        } else {
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        }
        
        if corners.contains(.bottomRight) {
            path.addLine(to: p5)
            path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.maxY), tangent2End: p6, radius: radius)
        } else {
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        }
        
        if corners.contains(.bottomLeft) {
            path.addLine(to: p7)
            path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.maxY), tangent2End: p8, radius: radius)
        } else {
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        }
        
        path.closeSubpath()
        
        return path
    }
}
