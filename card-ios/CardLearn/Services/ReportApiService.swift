import Foundation

/// 学习报告API服务
final class ReportApiService: BaseApiService {
    static let shared = ReportApiService()

    // MARK: - 获取当前周期报告

    func getCurrentReport(userId: Int?, type: String = "weekly") async throws -> ReportDetail {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/learning/report/current"))!
        var queryItems = [URLQueryItem(name: "type", value: type)]
        if let userId = userId {
            queryItems.append(URLQueryItem(name: "userId", value: String(userId)))
        }
        urlComponents.queryItems = queryItems
        let response: APIResponse<ReportDetail> = try await get(url: urlComponents.url!)
        if response.code == 200, let data = response.data {
            return data
        }
        throw APIError.serverError(response.message ?? "获取报告失败")
    }

    // MARK: - 获取历史报告列表

    func getHistoryReports(userId: Int?, type: String = "weekly", page: Int = 1, size: Int = 4) async throws -> ReportHistoryResponse {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/learning/report/history"))!
        var queryItems = [
            URLQueryItem(name: "type", value: type),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "size", value: String(size))
        ]
        if let userId = userId {
            queryItems.append(URLQueryItem(name: "userId", value: String(userId)))
        }
        urlComponents.queryItems = queryItems
        let response: APIResponse<ReportHistoryResponse> = try await get(url: urlComponents.url!)
        if response.code == 200, let data = response.data {
            return data
        }
        throw APIError.serverError(response.message ?? "获取历史报告失败")
    }

    // MARK: - 获取指定报告详情

    func getReportById(reportId: Int, userId: Int?) async throws -> ReportDetail {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/learning/report/\(reportId)"))!
        if let userId = userId {
            urlComponents.queryItems = [URLQueryItem(name: "userId", value: String(userId))]
        }
        let response: APIResponse<ReportDetail> = try await get(url: urlComponents.url!)
        if response.code == 200, let data = response.data {
            return data
        }
        throw APIError.serverError(response.message ?? "获取报告详情失败")
    }

    // MARK: - 获取薄弱点列表

    func getWeakPoints(userId: Int?, page: Int = 1, size: Int = 20) async throws -> WeakPointResponse {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/learning/weak-points"))!
        var queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "size", value: String(size))
        ]
        if let userId = userId {
            queryItems.append(URLQueryItem(name: "userId", value: String(userId)))
        }
        urlComponents.queryItems = queryItems
        let response: APIResponse<WeakPointResponse> = try await get(url: urlComponents.url!)
        if response.code == 200, let data = response.data {
            return data
        }
        throw APIError.serverError(response.message ?? "获取薄弱点失败")
    }

    // MARK: - 标记薄弱点已复习

    func markWeakPointReviewed(cardId: Int, userId: Int?) async throws {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/learning/weak-points/\(cardId)/review"))!
        if let userId = userId {
            urlComponents.queryItems = [URLQueryItem(name: "userId", value: String(userId))]
        }
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let response: APIResponse<String> = try await post(url: urlRequest)
        if response.code != 200 {
            throw APIError.serverError(response.message ?? "标记失败")
        }
    }
}
