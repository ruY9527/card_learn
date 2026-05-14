import Foundation

/// SM-2学习进度、复习计划、学习统计、设备注册等API
final class LearningApiService: BaseApiService {
    static let shared = LearningApiService()

    // MARK: - SM-2 进度

    func getSM2Progress(cardId: Int, appUserId: Int?) async throws -> SM2Progress {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/learning/sm2/progress"))!
        var queryItems = [URLQueryItem(name: "cardId", value: String(cardId))]
        if let appUserId = appUserId {
            queryItems.append(URLQueryItem(name: "userId", value: String(appUserId)))
        }
        urlComponents.queryItems = queryItems
        let response: APIResponse<SM2Progress> = try await get(url: urlComponents.url!)
        if response.code == 200, let progress = response.data {
            return progress
        }
        throw APIError.serverError(response.message ?? "获取SM2进度失败")
    }

    // MARK: - 复习

    func submitSM2Review(request: ReviewSubmitRequest, token: String?) async throws {
        let url = URL(string: config.getApiUrl(path: "/api/learning/review"))!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = token {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let response: APIResponse<String> = try await post(url: urlRequest)
        if response.code != 200 {
            throw APIError.serverError(response.message ?? "提交复习失败")
        }
    }

    func submitSimpleReview(cardId: Int, userId: Int?, status: Int, source: String = "ios") async throws -> ReviewResultVO {
        let url = URL(string: config.getApiUrl(path: "/api/learning/review/simple"))!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody = SimpleReviewRequest(cardId: cardId, userId: userId ?? 0, status: status, source: source)
        urlRequest.httpBody = try JSONEncoder().encode(requestBody)

        let response: APIResponse<ReviewResultVO> = try await post(url: urlRequest)
        if response.code == 200, let result = response.data {
            return result
        }
        throw APIError.serverError(response.message ?? "提交复习失败")
    }

    // MARK: - 复习计划

    func getReviewPlan(appUserId: Int?) async throws -> [ReviewPlanResponse] {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/learning/plan"))!
        if let appUserId = appUserId {
            urlComponents.queryItems = [URLQueryItem(name: "userId", value: String(appUserId))]
        }
        let response: APIResponse<[ReviewPlanResponse]> = try await get(url: urlComponents.url!)
        if response.code == 200, let plans = response.data {
            return plans
        }
        throw APIError.serverError(response.message ?? "获取复习计划失败")
    }

    // MARK: - 学习历史

    func getCardStudyHistory(cardId: Int, userId: Int) async throws -> CardStudyHistoryResponse {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/miniprogram/study-history/card/\(cardId)"))!
        urlComponents.queryItems = [URLQueryItem(name: "userId", value: String(userId))]
        let response: APIResponse<CardStudyHistoryResponse> = try await get(url: urlComponents.url!)
        if response.code == 200, let history = response.data {
            return history
        }
        throw APIError.serverError(response.message ?? "获取学习历史失败")
    }

    // MARK: - 科目进度与学习统计

    func getSubjectProgress(appUserId: Int?) async throws -> [SubjectProgressResponse] {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/learning/subject-progress"))!
        if let appUserId = appUserId {
            urlComponents.queryItems = [URLQueryItem(name: "userId", value: String(appUserId))]
        }
        let response: APIResponse<[SubjectProgressResponse]> = try await get(url: urlComponents.url!)
        if response.code == 200, let progress = response.data {
            return progress
        }
        throw APIError.serverError(response.message ?? "获取科目进度失败")
    }

    func getLearningStats(appUserId: Int?) async throws -> LearningStatsResponse {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/learning/stats"))!
        if let appUserId = appUserId {
            urlComponents.queryItems = [URLQueryItem(name: "userId", value: String(appUserId))]
        }
        let response: APIResponse<LearningStatsResponse> = try await get(url: urlComponents.url!)
        if response.code == 200, let stats = response.data {
            return stats
        }
        throw APIError.serverError(response.message ?? "获取学习统计失败")
    }

    // MARK: - 设备注册

    func registerDevice(userId: Int, deviceToken: String, deviceType: String) async throws {
        let url = URL(string: config.getApiUrl(path: "/api/learning/device/register"))!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "userId": userId,
            "deviceToken": deviceToken,
            "deviceType": deviceType
        ]
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body)
        let response: APIResponse<String> = try await post(url: urlRequest)
        if response.code != 200 {
            throw APIError.serverError(response.message ?? "注册设备失败")
        }
    }
}
