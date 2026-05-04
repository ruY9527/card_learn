import Foundation

class APIService {
    static let shared = APIService()
    
    private let session = URLSession.shared
    
    /// 获取当前环境配置
    private var config: EnvConfig.Config {
        EnvConfig.config
    }

    // MARK: - Cache

    private var cachedSprintConfig: SprintConfig?
    private var sprintConfigFetchTime: Date?
    private let sprintConfigCacheTTL: TimeInterval = 300

    // MARK: - Retry

    private func retry<T>(maxRetries: Int = 2, delay: TimeInterval = 1.0, operation: @escaping () async throws -> T) async throws -> T {
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

    // MARK: - 小程序 API
    
    // 获取专业列表
    func getMajorList() async throws -> [Major] {
        return try await retry {
            let url = URL(string: self.config.getApiUrl(path: "/api/miniprogram/majors"))!
            let (data, _) = try await self.session.data(from: url)
            let response = try JSONDecoder().decode(APIResponse<[Major]>.self, from: data)
            if response.code == 200, let majors = response.data {
                return majors
            }
            throw APIError.serverError(response.message ?? "获取专业失败")
        }
    }

    // 获取科目列表
    func getSubjectList(majorId: Int?) async throws -> [Subject] {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/miniprogram/subjects"))!
        if let majorId = majorId {
            urlComponents.queryItems = [URLQueryItem(name: "majorId", value: String(majorId))]
        }
        let (data, _) = try await session.data(from: urlComponents.url!)
        let response = try JSONDecoder().decode(APIResponse<[Subject]>.self, from: data)
        if response.code == 200, let subjects = response.data {
            return subjects
        }
        throw APIError.serverError(response.message ?? "获取科目失败")
    }

    // 分页获取卡片列表
    func getCardPage(subjectId: Int?, frontContent: String?, appUserId: Int?, status: String?, pageNum: Int = 1, pageSize: Int = AppPageSize.cards) async throws -> PageResponse<Card> {
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
            urlComponents.queryItems = queryItems

            let (data, _) = try await self.session.data(from: urlComponents.url!)
            let response = try JSONDecoder().decode(APIResponse<PageResponse<Card>>.self, from: data)
            if response.code == 200, let pageData = response.data {
                return pageData
            }
            throw APIError.serverError(response.message ?? "获取卡片失败")
        }
    }

    // 获取卡片详情
    func getCardById(cardId: Int, appUserId: Int?) async throws -> Card {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/miniprogram/cards/\(cardId)"))!
        if let appUserId = appUserId {
            urlComponents.queryItems = [URLQueryItem(name: "userId", value: String(appUserId))]
        }
        let (data, _) = try await session.data(from: urlComponents.url!)
        let response = try JSONDecoder().decode(APIResponse<Card>.self, from: data)
        if response.code == 200, let card = response.data {
            return card
        }
        throw APIError.serverError(response.message ?? "获取卡片详情失败")
    }

    // 更新学习进度
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

        let (data, _) = try await session.data(for: request)
        let response = try JSONDecoder().decode(APIResponse<String>.self, from: data)
        if response.code != 200 {
            throw APIError.serverError(response.message ?? "更新进度失败")
        }
    }

    // 获取科目统计
    func getSubjectStats(subjectId: Int, appUserId: Int?) async throws -> SubjectStats {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/miniprogram/subjects/\(subjectId)/stats"))!
        if let appUserId = appUserId {
            urlComponents.queryItems = [URLQueryItem(name: "userId", value: String(appUserId))]
        }
        let (data, _) = try await session.data(from: urlComponents.url!)
        let response = try JSONDecoder().decode(APIResponse<SubjectStats>.self, from: data)
        if response.code == 200, let stats = response.data {
            return stats
        }
        throw APIError.serverError(response.message ?? "获取统计失败")
    }

    // 获取冲刺配置
    func getSprintConfig() async throws -> SprintConfig {
        if let cached = cachedSprintConfig,
           let fetchTime = sprintConfigFetchTime,
           Date().timeIntervalSince(fetchTime) < sprintConfigCacheTTL {
            return cached
        }

        let config = try await retry {
            let url = URL(string: self.config.getApiUrl(path: "/api/miniprogram/sprint-config"))!
            let (data, _) = try await self.session.data(from: url)
            let response = try JSONDecoder().decode(APIResponse<SprintConfig>.self, from: data)
            if response.code == 200, let sprintConfig = response.data {
                return sprintConfig
            }
            throw APIError.serverError(response.message ?? "获取冲刺配置失败")
        }

        cachedSprintConfig = config
        sprintConfigFetchTime = Date()
        return config
    }

    func invalidateSprintConfigCache() {
        cachedSprintConfig = nil
        sprintConfigFetchTime = nil
    }

    // 获取推荐卡片
    func getRecommendCards(majorId: Int?) async throws -> [Card] {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/miniprogram/recommend"))!
        if let majorId = majorId {
            urlComponents.queryItems = [URLQueryItem(name: "majorId", value: String(majorId))]
        }
        let (data, _) = try await session.data(from: urlComponents.url!)
        let response = try JSONDecoder().decode(APIResponse<[Card]>.self, from: data)
        if response.code == 200, let cards = response.data {
            return cards
        }
        throw APIError.serverError(response.message ?? "获取推荐卡片失败")
    }

    // 获取学习统计（用户总体统计）
    func getProgressStats(appUserId: Int?) async throws -> StudyStats {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/miniprogram/stats"))!
        if let appUserId = appUserId {
            urlComponents.queryItems = [URLQueryItem(name: "userId", value: String(appUserId))]
        }
        let (data, _) = try await session.data(from: urlComponents.url!)
        let response = try JSONDecoder().decode(APIResponse<StudyStats>.self, from: data)
        if response.code == 200, let stats = response.data {
            return stats
        }
        throw APIError.serverError(response.message ?? "获取学习统计失败")
    }

    // MARK: - 认证相关 API
    
    // 获取验证码
    func getCaptcha() async throws -> CaptchaResponse {
        let url = URL(string: config.getBaseUrl(path: "/captcha/generate"))!
        let (data, _) = try await session.data(from: url)
        let response = try JSONDecoder().decode(APIResponse<CaptchaResponse>.self, from: data)
        if response.code == 200, let captcha = response.data {
            return captcha
        }
        throw APIError.serverError(response.message ?? "获取验证码失败")
    }

    // 登录
    func login(username: String, password: String, captcha: String, captchaKey: String) async throws -> LoginResponse {
        let url = URL(string: config.getBaseUrl(path: "/auth/login"))!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "username": username.trimmingCharacters(in: .whitespaces),
            "password": password.trimmingCharacters(in: .whitespaces),
            "captcha": captcha,
            "captchaKey": captchaKey
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await session.data(for: request)
        let response = try JSONDecoder().decode(APIResponse<LoginResponse>.self, from: data)
        if response.code == 200, let loginData = response.data {
            return loginData
        }
        throw APIError.serverError(response.message ?? "登录失败")
    }

    // MARK: - 反馈相关 API
    
    // 提交反馈
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

    // 获取用户反馈列表
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

    // MARK: - 进度卡片 API
    
    // 获取进度卡片列表（已学习、已掌握、待复习）
    func getProgressCards(appUserId: Int, status: String, pageNum: Int = 1, pageSize: Int = AppPageSize.cards) async throws -> PageResponse<Card> {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/miniprogram/cards"))!
        urlComponents.queryItems = [
            URLQueryItem(name: "userId", value: String(appUserId)),
            URLQueryItem(name: "status", value: status),
            URLQueryItem(name: "pageNum", value: String(pageNum)),
            URLQueryItem(name: "pageSize", value: String(pageSize))
        ]

        let (data, _) = try await session.data(from: urlComponents.url!)
        let response = try JSONDecoder().decode(APIResponse<PageResponse<Card>>.self, from: data)
        if response.code == 200, let pageData = response.data {
            return pageData
        }
        throw APIError.serverError(response.message ?? "获取进度卡片失败")
    }

    // MARK: - 用户卡片贡献 API

    // 创建卡片（提交待审批）
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

        let (data, _) = try await session.data(for: request)
        let response = try JSONDecoder().decode(APIResponse<Int>.self, from: data)
        if response.code == 200, let draftId = response.data {
            return draftId
        }
        throw APIError.serverError(response.message ?? "创建卡片失败")
    }

    // 获取我的卡片列表
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

        let (data, _) = try await session.data(for: request)
        let response = try JSONDecoder().decode(APIResponse<PageResponse<MyCard>>.self, from: data)
        if response.code == 200, let pageData = response.data {
            return pageData
        }
        throw APIError.serverError(response.message ?? "获取我的卡片失败")
    }

    // 获取我的卡片统计
    func getMyCardStats(token: String) async throws -> MyCardStats {
        let url = URL(string: config.getApiUrl(path: "/api/miniprogram/card/my/stats"))!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await session.data(for: request)
        let response = try JSONDecoder().decode(APIResponse<MyCardStats>.self, from: data)
        if response.code == 200, let stats = response.data {
            return stats
        }
        throw APIError.serverError(response.message ?? "获取我的卡片统计失败")
    }

    // 删除我的卡片
    func deleteMyCard(draftId: Int, token: String) async throws {
        let url = URL(string: config.getApiUrl(path: "/api/miniprogram/card/my/\(draftId)"))!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await session.data(for: request)
        let response = try JSONDecoder().decode(APIResponse<String>.self, from: data)
        if response.code != 200 {
            throw APIError.serverError(response.message ?? "删除卡片失败")
        }
    }

    // MARK: - 评论 API

    // 提交评论
    func submitComment(cardId: Int, appUserId: Int, content: String, rating: Int, commentType: String) async throws -> Int {
        let url = URL(string: config.getApiUrl(path: "/api/miniprogram/comment/submit"))!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "cardId": cardId,
            "userId": appUserId,
            "content": content,
            "rating": rating,
            "commentType": commentType
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await session.data(for: request)
        let response = try JSONDecoder().decode(APIResponse<Int>.self, from: data)
        if response.code == 200, let commentId = response.data {
            return commentId
        }
        throw APIError.serverError(response.message ?? "提交评论失败")
    }

    // 获取卡片评论列表
    func getCardComments(cardId: Int, pageNum: Int = 1, pageSize: Int = AppPageSize.comments) async throws -> PageResponse<Comment> {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/miniprogram/comment/list/\(cardId)"))!
        urlComponents.queryItems = [
            URLQueryItem(name: "pageNum", value: String(pageNum)),
            URLQueryItem(name: "pageSize", value: String(pageSize))
        ]

        let (data, _) = try await session.data(from: urlComponents.url!)
        let response = try JSONDecoder().decode(APIResponse<PageResponse<Comment>>.self, from: data)
        if response.code == 200, let pageData = response.data {
            return pageData
        }
        throw APIError.serverError(response.message ?? "获取评论失败")
    }

    // 获取卡片评论统计
    func getCommentStats(cardId: Int) async throws -> CommentStats {
        let url = URL(string: config.getApiUrl(path: "/api/miniprogram/comment/stats/\(cardId)"))!
        let (data, _) = try await session.data(from: url)
        let response = try JSONDecoder().decode(APIResponse<CommentStats>.self, from: data)
        if response.code == 200, let stats = response.data {
            return stats
        }
        throw APIError.serverError(response.message ?? "获取评论统计失败")
    }

    // MARK: - SM-2 学习进度相关 API

    // 获取用户SM-2进度
    func getSM2Progress(cardId: Int, appUserId: Int?) async throws -> SM2Progress {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/learning/sm2/progress"))!
        var queryItems = [URLQueryItem(name: "cardId", value: String(cardId))]
        if let appUserId = appUserId {
            queryItems.append(URLQueryItem(name: "userId", value: String(appUserId)))
        }
        urlComponents.queryItems = queryItems
        let (data, _) = try await session.data(from: urlComponents.url!)
        let response = try JSONDecoder().decode(APIResponse<SM2Progress>.self, from: data)
        if response.code == 200, let progress = response.data {
            return progress
        }
        throw APIError.serverError(response.message ?? "获取SM2进度失败")
    }

    // 提交复习结果（SM-2）
    func submitSM2Review(request: ReviewSubmitRequest, token: String?) async throws {
        let url = URL(string: config.getApiUrl(path: "/api/learning/review"))!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = token {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, _) = try await session.data(for: urlRequest)
        let response = try JSONDecoder().decode(APIResponse<String>.self, from: data)
        if response.code != 200 {
            throw APIError.serverError(response.message ?? "提交复习失败")
        }
    }

    // 简化复习提交（服务端自动计算SM-2）
    func submitSimpleReview(cardId: Int, userId: Int?, status: Int) async throws -> ReviewResultVO {
        let url = URL(string: config.getApiUrl(path: "/api/learning/review/simple"))!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody = SimpleReviewRequest(cardId: cardId, userId: userId ?? 0, status: status)
        urlRequest.httpBody = try JSONEncoder().encode(requestBody)

        let (data, _) = try await session.data(for: urlRequest)
        let response = try JSONDecoder().decode(APIResponse<ReviewResultVO>.self, from: data)
        if response.code == 200, let result = response.data {
            return result
        }
        throw APIError.serverError(response.message ?? "提交复习失败")
    }

    // 获取复习计划
    func getReviewPlan(appUserId: Int?) async throws -> [ReviewPlanResponse] {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/learning/plan"))!
        if let appUserId = appUserId {
            urlComponents.queryItems = [URLQueryItem(name: "userId", value: String(appUserId))]
        }
        let (data, _) = try await session.data(from: urlComponents.url!)
        let response = try JSONDecoder().decode(APIResponse<[ReviewPlanResponse]>.self, from: data)
        if response.code == 200, let plans = response.data {
            return plans
        }
        throw APIError.serverError(response.message ?? "获取复习计划失败")
    }

    // 获取卡片学习历史
    func getCardStudyHistory(cardId: Int, userId: Int) async throws -> CardStudyHistoryResponse {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/miniprogram/study-history/card/\(cardId)"))!
        urlComponents.queryItems = [URLQueryItem(name: "userId", value: String(userId))]
        let (data, _) = try await session.data(from: urlComponents.url!)
        let response = try JSONDecoder().decode(APIResponse<CardStudyHistoryResponse>.self, from: data)
        if response.code == 200, let history = response.data {
            return history
        }
        throw APIError.serverError(response.message ?? "获取学习历史失败")
    }

    // 获取科目进度
    func getSubjectProgress(appUserId: Int?) async throws -> [SubjectProgressResponse] {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/learning/subject-progress"))!
        if let appUserId = appUserId {
            urlComponents.queryItems = [URLQueryItem(name: "userId", value: String(appUserId))]
        }
        let (data, _) = try await session.data(from: urlComponents.url!)
        let response = try JSONDecoder().decode(APIResponse<[SubjectProgressResponse]>.self, from: data)
        if response.code == 200, let progress = response.data {
            return progress
        }
        throw APIError.serverError(response.message ?? "获取科目进度失败")
    }

    // 获取学习统计（Streak等）
    func getLearningStats(appUserId: Int?) async throws -> LearningStatsResponse {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/learning/stats"))!
        if let appUserId = appUserId {
            urlComponents.queryItems = [URLQueryItem(name: "userId", value: String(appUserId))]
        }
        let (data, _) = try await session.data(from: urlComponents.url!)
        let response = try JSONDecoder().decode(APIResponse<LearningStatsResponse>.self, from: data)
        if response.code == 200, let stats = response.data {
            return stats
        }
        throw APIError.serverError(response.message ?? "获取学习统计失败")
    }

    // 注册设备（推送）
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
        let (data, _) = try await session.data(for: urlRequest)
        let response = try JSONDecoder().decode(APIResponse<String>.self, from: data)
        if response.code != 200 {
            throw APIError.serverError(response.message ?? "注册设备失败")
        }
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