import Foundation

/// 激励系统API服务
final class IncentiveApiService: BaseApiService {
    static let shared = IncentiveApiService()

    private override init() {
        super.init()
    }

    /// 构建带认证的URLRequest
    private func makeRequest(url: URL, method: String = "GET") -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        if let token = UserDefaults.standard.string(forKey: AppKey.token), !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    /// 带认证的GET请求
    private func authGet<T: Decodable>(url: URL) async throws -> T {
        let request = makeRequest(url: url)
        let (data, _) = try await session.data(for: request)
        return try JSONDecoder().decode(T.self, from: data)
    }

    // MARK: - 成就API

    /// 获取成就列表
    func getAchievementList(userId: Int, category: String? = nil) async throws -> [Achievement] {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/incentive/achievement/list"))!
        urlComponents.queryItems = [
            URLQueryItem(name: "userId", value: String(userId))
        ]
        if let category = category, !category.isEmpty {
            urlComponents.queryItems?.append(URLQueryItem(name: "category", value: category))
        }
        let response: APIResponse<[Achievement]> = try await authGet(url: urlComponents.url!)
        guard response.code == 200, let data = response.data else {
            throw APIError.serverError(response.message ?? "获取成就列表失败")
        }
        return data
    }

    /// 获取用户成就统计
    func getUserAchievements(userId: Int) async throws -> AchievementListResponse {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/incentive/achievement/user"))!
        urlComponents.queryItems = [URLQueryItem(name: "userId", value: String(userId))]
        let response: APIResponse<AchievementListResponse> = try await authGet(url: urlComponents.url!)
        guard response.code == 200, let data = response.data else {
            throw APIError.serverError(response.message ?? "获取用户成就失败")
        }
        return data
    }

    /// 检查并解锁成就
    func checkAchievement(userId: Int, actionType: String, sourceId: String? = nil) async throws -> AchievementCheckResponse {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/incentive/achievement/check"))!
        urlComponents.queryItems = [
            URLQueryItem(name: "userId", value: String(userId)),
            URLQueryItem(name: "actionType", value: actionType)
        ]
        if let sourceId = sourceId {
            urlComponents.queryItems?.append(URLQueryItem(name: "sourceId", value: sourceId))
        }
        let response: APIResponse<AchievementCheckResponse> = try await authGet(url: urlComponents.url!)
        guard response.code == 200, let data = response.data else {
            throw APIError.serverError(response.message ?? "检查成就失败")
        }
        return data
    }

    // MARK: - 等级API

    /// 获取用户等级信息
    func getLevelInfo(userId: Int) async throws -> UserLevel {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/incentive/level/info"))!
        urlComponents.queryItems = [URLQueryItem(name: "userId", value: String(userId))]
        let response: APIResponse<UserLevel> = try await authGet(url: urlComponents.url!)
        guard response.code == 200, let data = response.data else {
            throw APIError.serverError(response.message ?? "获取等级信息失败")
        }
        return data
    }

    /// 获取经验值日志
    func getExpLog(userId: Int, sourceType: String? = nil, pageNum: Int = 1, pageSize: Int = 20) async throws -> PageResponse<ExpLog> {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/incentive/level/exp-log"))!
        var queryItems = [
            URLQueryItem(name: "userId", value: String(userId)),
            URLQueryItem(name: "pageNum", value: String(pageNum)),
            URLQueryItem(name: "pageSize", value: String(pageSize))
        ]
        if let sourceType = sourceType, !sourceType.isEmpty {
            queryItems.append(URLQueryItem(name: "sourceType", value: sourceType))
        }
        urlComponents.queryItems = queryItems
        let response: APIResponse<PageResponse<ExpLog>> = try await authGet(url: urlComponents.url!)
        guard response.code == 200, let data = response.data else {
            throw APIError.serverError(response.message ?? "获取经验日志失败")
        }
        return data
    }

    // MARK: - 目标API

    /// 获取当前目标设置
    func getCurrentGoal(userId: Int) async throws -> LearningGoal {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/incentive/goal/current"))!
        urlComponents.queryItems = [URLQueryItem(name: "userId", value: String(userId))]
        let response: APIResponse<LearningGoal> = try await authGet(url: urlComponents.url!)
        guard response.code == 200, let data = response.data else {
            throw APIError.serverError(response.message ?? "获取目标失败")
        }
        return data
    }

    /// 设置学习目标
    func setGoal(userId: Int, request: GoalSetRequest) async throws -> LearningGoal {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/incentive/goal/set"))!
        urlComponents.queryItems = [URLQueryItem(name: "userId", value: String(userId))]

        var urlRequest = makeRequest(url: urlComponents.url!, method: "POST")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let response: APIResponse<LearningGoal> = try await post(url: urlRequest)
        guard response.code == 200, let data = response.data else {
            throw APIError.serverError(response.message ?? "设置目标失败")
        }
        return data
    }

    /// 获取今日目标进度
    func getGoalProgress(userId: Int) async throws -> GoalProgress {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/incentive/goal/progress"))!
        urlComponents.queryItems = [URLQueryItem(name: "userId", value: String(userId))]
        let response: APIResponse<GoalProgress> = try await authGet(url: urlComponents.url!)
        guard response.code == 200, let data = response.data else {
            throw APIError.serverError(response.message ?? "获取目标进度失败")
        }
        return data
    }

    /// 获取本周目标完成情况
    func getWeekGoalProgress(userId: Int) async throws -> [WeekGoalRecord] {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/incentive/goal/week"))!
        urlComponents.queryItems = [URLQueryItem(name: "userId", value: String(userId))]
        let response: APIResponse<[WeekGoalRecord]> = try await authGet(url: urlComponents.url!)
        guard response.code == 200, let data = response.data else {
            throw APIError.serverError(response.message ?? "获取周目标失败")
        }
        return data
    }

    // MARK: - 排行榜API

    /// 获取总排行榜
    func getTotalRank(pageNum: Int = 1, pageSize: Int = 20) async throws -> PageResponse<RankItem> {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/incentive/rank/total"))!
        urlComponents.queryItems = [
            URLQueryItem(name: "pageNum", value: String(pageNum)),
            URLQueryItem(name: "pageSize", value: String(pageSize))
        ]
        let response: APIResponse<PageResponse<RankItem>> = try await authGet(url: urlComponents.url!)
        guard response.code == 200, let data = response.data else {
            throw APIError.serverError(response.message ?? "获取排行榜失败")
        }
        return data
    }

    /// 获取周排行榜
    func getWeekRank(pageNum: Int = 1, pageSize: Int = 20) async throws -> PageResponse<RankItem> {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/incentive/rank/week"))!
        urlComponents.queryItems = [
            URLQueryItem(name: "pageNum", value: String(pageNum)),
            URLQueryItem(name: "pageSize", value: String(pageSize))
        ]
        let response: APIResponse<PageResponse<RankItem>> = try await authGet(url: urlComponents.url!)
        guard response.code == 200, let data = response.data else {
            throw APIError.serverError(response.message ?? "获取周榜失败")
        }
        return data
    }

    /// 获取连击排行榜
    func getStreakRank(pageNum: Int = 1, pageSize: Int = 20) async throws -> PageResponse<RankItem> {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/incentive/rank/streak"))!
        urlComponents.queryItems = [
            URLQueryItem(name: "pageNum", value: String(pageNum)),
            URLQueryItem(name: "pageSize", value: String(pageSize))
        ]
        let response: APIResponse<PageResponse<RankItem>> = try await authGet(url: urlComponents.url!)
        guard response.code == 200, let data = response.data else {
            throw APIError.serverError(response.message ?? "获取连击榜失败")
        }
        return data
    }

    /// 获取用户排名
    func getUserRank(userId: Int) async throws -> RankPosition {
        let url = URL(string: config.getApiUrl(path: "/api/incentive/rank/user/\(userId)"))!
        let response: APIResponse<RankPosition> = try await authGet(url: url)
        guard response.code == 200, let data = response.data else {
            throw APIError.serverError(response.message ?? "获取用户排名失败")
        }
        return data
    }
}
