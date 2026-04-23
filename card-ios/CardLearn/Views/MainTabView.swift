import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: Tab = .home
    
    enum Tab {
        case home
        case profile
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 主内容区域
            Group {
                if selectedTab == .home {
                    HomeView()
                } else {
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
        .background(Color(hex: "F5F5F5"))
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
                    .foregroundColor(isSelected ? Color(hex: "409EFF") : Color(hex: "999999"))
                
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? Color(hex: "409EFF") : Color(hex: "999999"))
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// Color extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
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