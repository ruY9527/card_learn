import Foundation

/// API服务基类，提供共享的网络请求、重试逻辑和环境配置
class BaseApiService {
    let session = URLSession.shared

    /// 获取当前环境配置
    var config: EnvConfig.Config {
        EnvConfig.config
    }

    /// 通用重试逻辑
    func retry<T>(maxRetries: Int = 2, delay: TimeInterval = 1.0, operation: @escaping () async throws -> T) async throws -> T {
        var lastError: Error?
        for attempt in 0...maxRetries {
            do {
                return try await operation()
            } catch {
                lastError = error
                if attempt < maxRetries {
                    try? await Task.sleep(nanoseconds: UInt64(delay * Double(attempt + 1) * 1_000_000_000))
                }
            }
        }
        throw lastError ?? APIError.networkError
    }

    /// 通用GET请求
    func get<T: Decodable>(url: URL) async throws -> T {
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(T.self, from: data)
    }

    /// 通用POST请求
    func post<T: Decodable>(url: URLRequest) async throws -> T {
        let (data, _) = try await session.data(for: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
}

enum APIError: Error, LocalizedError {
    case serverError(String)
    case networkError
    case decodingError

    var errorDescription: String? {
        switch self {
        case .serverError(let message): return message
        case .networkError: return "网络连接失败"
        case .decodingError: return "数据解析失败"
        }
    }
}
