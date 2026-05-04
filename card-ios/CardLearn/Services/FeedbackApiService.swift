import Foundation

/// 反馈相关API
final class FeedbackApiService: BaseApiService {
    static let shared = FeedbackApiService()

    func submitFeedback(appUserId: Int, cardId: Int?, majorId: Int?, subjectId: Int?, type: String, rating: Int?, content: String, contact: String?, images: [String]?, token: String) async throws {
        let url = URL(string: config.getApiUrl(path: "/api/miniprogram/feedback"))!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        var body: [String: Any] = [
            "userId": appUserId,
            "type": type,
            "content": content
        ]
        if let cardId = cardId { body["cardId"] = cardId }
        if let majorId = majorId { body["majorId"] = majorId }
        if let subjectId = subjectId { body["subjectId"] = subjectId }
        if let rating = rating { body["rating"] = rating }
        if let contact = contact { body["contact"] = contact }
        if let images = images, !images.isEmpty { body["images"] = images }

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, urlResponse) = try await session.data(for: request)
        if let httpResponse = urlResponse as? HTTPURLResponse {
            if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                throw APIError.serverError("登录已过期，请重新登录")
            }
        }
        let response = try JSONDecoder().decode(APIResponse<String>.self, from: data)
        if response.code != 200 {
            throw APIError.serverError(response.message ?? "提交反馈失败")
        }
    }

    func getUserFeedbackList(appUserId: Int, pageNum: Int = 1, pageSize: Int = AppPageSize.feedback, token: String) async throws -> PageResponse<Feedback> {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/miniprogram/feedback/list"))!
        urlComponents.queryItems = [
            URLQueryItem(name: "userId", value: String(appUserId)),
            URLQueryItem(name: "pageNum", value: String(pageNum)),
            URLQueryItem(name: "pageSize", value: String(pageSize))
        ]

        var request = URLRequest(url: urlComponents.url!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, urlResponse) = try await session.data(for: request)
        if let httpResponse = urlResponse as? HTTPURLResponse {
            if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                throw APIError.serverError("登录已过期，请重新登录")
            }
        }
        let response = try JSONDecoder().decode(APIResponse<PageResponse<Feedback>>.self, from: data)
        if response.code == 200, let pageData = response.data {
            return pageData
        }
        throw APIError.serverError(response.message ?? "获取反馈列表失败")
    }
}
