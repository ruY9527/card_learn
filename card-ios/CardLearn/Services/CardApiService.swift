import Foundation

/// 卡片、科目、专业、冲刺配置等核心学习资源API
final class CardApiService: BaseApiService {
    static let shared = CardApiService()

    // MARK: - Cache

    private var cachedSprintConfig: SprintConfig?
    private var sprintConfigFetchTime: Date?
    private let sprintConfigCacheTTL: TimeInterval = 300

    // MARK: - 专业与科目

    func getMajorList() async throws -> [Major] {
        return try await retry {
            let url = URL(string: self.config.getApiUrl(path: "/api/miniprogram/majors"))!
            let response: APIResponse<[Major]> = try await self.get(url: url)
            if response.code == 200, let data = response.data {
                return data
            }
            throw APIError.serverError(response.message ?? "获取专业失败")
        }
    }

    func getSubjectList(majorId: Int?) async throws -> [Subject] {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/miniprogram/subjects"))!
        if let majorId = majorId {
            urlComponents.queryItems = [URLQueryItem(name: "majorId", value: String(majorId))]
        }
        let response: APIResponse<[Subject]> = try await get(url: urlComponents.url!)
        if response.code == 200, let data = response.data {
            return data
        }
        throw APIError.serverError(response.message ?? "获取科目失败")
    }

    // MARK: - 卡片

    func getCardPage(subjectId: Int?, frontContent: String?, appUserId: Int?, status: String?, startDate: String? = nil, endDate: String? = nil, pageNum: Int = 1, pageSize: Int = AppPageSize.cards) async throws -> PageResponse<Card> {
        return try await retry {
            var urlComponents = URLComponents(string: self.config.getApiUrl(path: "/api/miniprogram/cards"))!
            var queryItems: [URLQueryItem] = [
                URLQueryItem(name: "pageNum", value: String(pageNum)),
                URLQueryItem(name: "pageSize", value: String(pageSize))
            ]
            if let subjectId = subjectId {
                queryItems.append(URLQueryItem(name: "subjectId", value: String(subjectId)))
            }
            if let frontContent = frontContent, !frontContent.isEmpty {
                queryItems.append(URLQueryItem(name: "frontContent", value: frontContent))
            }
            if let appUserId = appUserId {
                queryItems.append(URLQueryItem(name: "userId", value: String(appUserId)))
            }
            if let status = status {
                queryItems.append(URLQueryItem(name: "status", value: status))
            }
            if let startDate = startDate {
                queryItems.append(URLQueryItem(name: "startDate", value: startDate))
            }
            if let endDate = endDate {
                queryItems.append(URLQueryItem(name: "endDate", value: endDate))
            }
            urlComponents.queryItems = queryItems

            let response: APIResponse<PageResponse<Card>> = try await self.get(url: urlComponents.url!)
            if response.code == 200, let pageData = response.data {
                return pageData
            }
            throw APIError.serverError(response.message ?? "获取卡片失败")
        }
    }

    func getCardById(cardId: Int, appUserId: Int?) async throws -> Card {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/miniprogram/cards/\(cardId)"))!
        if let appUserId = appUserId {
            urlComponents.queryItems = [URLQueryItem(name: "userId", value: String(appUserId))]
        }
        let response: APIResponse<Card> = try await get(url: urlComponents.url!)
        if response.code == 200, let card = response.data {
            return card
        }
        throw APIError.serverError(response.message ?? "获取卡片详情失败")
    }

    // MARK: - 学习进度

    func updateProgress(cardId: Int, appUserId: Int?, status: Int, token: String?) async throws {
        let url = URL(string: config.getApiUrl(path: "/api/miniprogram/progress"))!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let body = ProgressUpdate(cardId: cardId, appUserId: appUserId, status: status)
        request.httpBody = try JSONEncoder().encode(body)

        let response: APIResponse<String> = try await post(url: request)
        if response.code != 200 {
            throw APIError.serverError(response.message ?? "更新进度失败")
        }
    }

    // MARK: - 统计

    func getSubjectStats(subjectId: Int, appUserId: Int?) async throws -> SubjectStats {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/miniprogram/subjects/\(subjectId)/stats"))!
        if let appUserId = appUserId {
            urlComponents.queryItems = [URLQueryItem(name: "userId", value: String(appUserId))]
        }
        let response: APIResponse<SubjectStats> = try await get(url: urlComponents.url!)
        if response.code == 200, let stats = response.data {
            return stats
        }
        throw APIError.serverError(response.message ?? "获取统计失败")
    }

    func getProgressStats(appUserId: Int?) async throws -> StudyStats {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/miniprogram/stats"))!
        if let appUserId = appUserId {
            urlComponents.queryItems = [URLQueryItem(name: "userId", value: String(appUserId))]
        }
        let response: APIResponse<StudyStats> = try await get(url: urlComponents.url!)
        if response.code == 200, let stats = response.data {
            return stats
        }
        throw APIError.serverError(response.message ?? "获取学习统计失败")
    }

    // MARK: - 冲刺配置

    func getSprintConfig() async throws -> SprintConfig {
        if let cached = cachedSprintConfig,
           let fetchTime = sprintConfigFetchTime,
           Date().timeIntervalSince(fetchTime) < sprintConfigCacheTTL {
            return cached
        }

        let result: SprintConfig = try await retry {
            let url = URL(string: self.config.getApiUrl(path: "/api/miniprogram/sprint-config"))!
            let response: APIResponse<SprintConfig> = try await self.get(url: url)
            if response.code == 200, let data = response.data {
                return data
            }
            throw APIError.serverError(response.message ?? "获取冲刺配置失败")
        }

        cachedSprintConfig = result
        sprintConfigFetchTime = Date()
        return result
    }

    func invalidateSprintConfigCache() {
        cachedSprintConfig = nil
        sprintConfigFetchTime = nil
    }

    // MARK: - 推荐

    func getRecommendCards(majorId: Int?) async throws -> [Card] {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/miniprogram/recommend"))!
        if let majorId = majorId {
            urlComponents.queryItems = [URLQueryItem(name: "majorId", value: String(majorId))]
        }
        let response: APIResponse<[Card]> = try await get(url: urlComponents.url!)
        if response.code == 200, let cards = response.data {
            return cards
        }
        throw APIError.serverError(response.message ?? "获取推荐卡片失败")
    }
}
