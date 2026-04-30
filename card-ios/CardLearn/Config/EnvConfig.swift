import Foundation

/// 环境类型（重命名以避免与 SwiftUI.Environment 冲突）
enum AppEnvironment {
    case development
    case production
}

/// 环境配置
struct EnvConfig {
    /// 当前环境（修改此值切换环境）
    static let current: AppEnvironment = .development
    
    /// 获取当前环境的配置
    static var config: Config {
        switch current {
        case .development:
            return developmentConfig
        case .production:
            return productionConfig
        }
    }
    
    /// 开发环境配置
    private static let developmentConfig = Config(
        baseURL: "http://localhost:8080",
        apiPrefix: "/api",
        environmentName: "开发环境"
    )
    
    /// 生产环境配置
    private static let productionConfig = Config(
        baseURL: "http://learn.thisforyou.cn:180",
        apiPrefix: "/api",
        environmentName: "生产环境"
    )
    
    /// 配置项结构
    struct Config {
        let baseURL: String
        let apiPrefix: String
        let environmentName: String
        
        /// 获取完整的 API URL
        func getApiUrl(path: String) -> String {
            // 如果路径已经包含 /api，直接拼接
            if path.hasPrefix("/api") {
                return baseURL + path
            }
            return baseURL + apiPrefix + path
        }
        
        /// 获取不带 api prefix 的 URL（用于 captcha、auth 等）
        func getBaseUrl(path: String) -> String {
            return baseURL + path
        }
    }
}