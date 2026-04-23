import SwiftUI

@main
struct CardLearnApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(appState)
                .onAppear {
                    // 检查本地存储的登录状态
                    appState.checkLoginStatus()
                }
        }
    }
}

// 全局应用状态管理
class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var userInfo: UserInfo?
    @Published var token: String = ""
    @Published var stats: StudyStats = StudyStats()
    
    /// 当前环境信息（用于显示）
    var environmentName: String {
        EnvConfig.config.environmentName
    }
    
    /// 当前 baseURL（用于显示）
    var baseURL: String {
        EnvConfig.config.baseURL
    }
    
    init() {
        checkLoginStatus()
    }
    
    func checkLoginStatus() {
        if let savedUser = UserDefaults.standard.string(forKey: "userInfo"),
           let savedToken = UserDefaults.standard.string(forKey: "token"),
           !savedToken.isEmpty {
            let decoder = JSONDecoder()
            if let data = savedUser.data(using: .utf8),
               let user = try? decoder.decode(UserInfo.self, from: data) {
                self.isLoggedIn = true
                self.userInfo = user
                self.token = savedToken
                loadStats()
            }
        }
    }
    
    func login(user: UserInfo, token: String) {
        self.isLoggedIn = true
        self.userInfo = user
        self.token = token
        
        // 保存到本地
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(user),
           let userString = String(data: data, encoding: .utf8) {
            UserDefaults.standard.set(userString, forKey: "userInfo")
        }
        UserDefaults.standard.set(token, forKey: "token")
    }
    
    func logout() {
        self.isLoggedIn = false
        self.userInfo = nil
        self.token = ""
        self.stats = StudyStats()
        
        UserDefaults.standard.removeObject(forKey: "userInfo")
        UserDefaults.standard.removeObject(forKey: "token")
    }
    
    func loadStats() {
        if let savedStats = UserDefaults.standard.string(forKey: "stats"),
           let data = savedStats.data(using: .utf8) {
            let decoder = JSONDecoder()
            if let stats = try? decoder.decode(StudyStats.self, from: data) {
                self.stats = stats
            }
        }
    }
    
    func saveStats() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(stats),
           let statsString = String(data: data, encoding: .utf8) {
            UserDefaults.standard.set(statsString, forKey: "stats")
        }
    }
}

// 用户信息模型
struct UserInfo: Codable {
    let userId: Int
    let nickname: String
    let avatar: String?
    let username: String?
}

// 学习统计模型
struct StudyStats: Codable {
    var learned: Int = 0
    var mastered: Int = 0
    var review: Int = 0
}