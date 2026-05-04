import Foundation

/// 用户卡片贡献相关API（创建、查询、删除我的卡片）
final class UserCardApiService: BaseApiService {
    static let shared = UserCardApiService()

    func createCard(subjectId: Int, frontContent: String, backContent: String, difficultyLevel: Int, tagIds: [Int]?, token: String) async throws -> Int {
        let url = URL(string: config.getApiUrl(path: "/api/miniprogram/card/create"))!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        var body: [String: Any] = [
            "subjectId": subjectId,
            "frontContent": frontContent,
            "backContent": backContent,
            "difficultyLevel": difficultyLevel
        ]
        if let tagIds = tagIds, !tagIds.isEmpty {
            body["tagIds"] = tagIds
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let response: APIResponse<Int> = try await post(url: request)
        if response.code == 200, let draftId = response.data {
            return draftId
        }
        throw APIError.serverError(response.message ?? "创建卡片失败")
    }

    func getMyCards(auditStatus: String?, pageNum: Int = 1, pageSize: Int = AppPageSize.myCards, token: String) async throws -> PageResponse<MyCard> {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/miniprogram/card/my"))!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "pageNum", value: String(pageNum)),
            URLQueryItem(name: "pageSize", value: String(pageSize))
        ]
        if let auditStatus = auditStatus {
            queryItems.append(URLQueryItem(name: "auditStatus", value: auditStatus))
        }
        urlComponents.queryItems = queryItems

        var request = URLRequest(url: urlComponents.url!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let response: APIResponse<PageResponse<MyCard>> = try await post(url: request)
        if response.code == 200, let pageData = response.data {
            return pageData
        }
        throw APIError.serverError(response.message ?? "获取我的卡片失败")
    }

    func getMyCardStats(token: String) async throws -> MyCardStats {
        let url = URL(string: config.getApiUrl(path: "/api/miniprogram/card/my/stats"))!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let response: APIResponse<MyCardStats> = try await post(url: request)
        if response.code == 200, let stats = response.data {
            return stats
        }
        throw APIError.serverError(response.message ?? "获取我的卡片统计失败")
    }

    func deleteMyCard(draftId: Int, token: String) async throws {
        let url = URL(string: config.getApiUrl(path: "/api/miniprogram/card/my/\(draftId)"))!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let response: APIResponse<String> = try await post(url: request)
        if response.code != 200 {
            throw APIError.serverError(response.message ?? "删除卡片失败")
        }
    }
}
