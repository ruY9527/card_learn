import Foundation

/// 评论相关API
final class CommentApiService: BaseApiService {
    static let shared = CommentApiService()

    // MARK: - 评论

    func submitComment(cardId: Int, appUserId: Int, content: String, rating: Int, commentType: String, isNote: Int = 0) async throws -> Int {
        let url = URL(string: config.getApiUrl(path: "/api/miniprogram/comment/submit"))!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "cardId": cardId,
            "userId": appUserId,
            "content": content,
            "rating": rating,
            "commentType": commentType,
            "isNote": isNote
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let response: APIResponse<Int> = try await post(url: request)
        if response.code == 200, let commentId = response.data {
            return commentId
        }
        throw APIError.serverError(response.message ?? "提交评论失败")
    }

    func getCardComments(cardId: Int, pageNum: Int = 1, pageSize: Int = AppPageSize.comments, userId: Int? = nil) async throws -> PageResponse<Comment> {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/miniprogram/comment/list/\(cardId)"))!
        var queryItems = [
            URLQueryItem(name: "pageNum", value: String(pageNum)),
            URLQueryItem(name: "pageSize", value: String(pageSize))
        ]
        if let userId = userId {
            queryItems.append(URLQueryItem(name: "userId", value: String(userId)))
        }
        urlComponents.queryItems = queryItems

        let response: APIResponse<PageResponse<Comment>> = try await get(url: urlComponents.url!)
        if response.code == 200, let pageData = response.data {
            return pageData
        }
        throw APIError.serverError(response.message ?? "获取评论失败")
    }

    func getCommentStats(cardId: Int) async throws -> CommentStats {
        let url = URL(string: config.getApiUrl(path: "/api/miniprogram/comment/stats/\(cardId)"))!
        let response: APIResponse<CommentStats> = try await get(url: url)
        if response.code == 200, let stats = response.data {
            return stats
        }
        throw APIError.serverError(response.message ?? "获取评论统计失败")
    }

    // MARK: - 点赞

    func toggleCommentLike(commentId: Int, userId: Int, likeType: Int) async throws -> Int {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/miniprogram/like/comment/\(commentId)"))!
        urlComponents.queryItems = [
            URLQueryItem(name: "userId", value: String(userId)),
            URLQueryItem(name: "likeType", value: String(likeType))
        ]

        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"

        let response: APIResponse<Int> = try await post(url: request)
        if response.code == 200, let result = response.data {
            return result
        }
        throw APIError.serverError(response.message ?? "点赞失败")
    }

    // MARK: - 回复

    func getReplies(commentId: Int, pageNum: Int = 1, pageSize: Int = 20, userId: Int? = nil) async throws -> PageResponse<Reply> {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/miniprogram/reply/list/\(commentId)"))!
        var queryItems = [
            URLQueryItem(name: "pageNum", value: String(pageNum)),
            URLQueryItem(name: "pageSize", value: String(pageSize))
        ]
        if let userId = userId {
            queryItems.append(URLQueryItem(name: "userId", value: String(userId)))
        }
        urlComponents.queryItems = queryItems

        let response: APIResponse<PageResponse<Reply>> = try await get(url: urlComponents.url!)
        if response.code == 200, let pageData = response.data {
            return pageData
        }
        throw APIError.serverError(response.message ?? "获取回复失败")
    }

    func submitReply(commentId: Int, userId: Int, content: String) async throws -> Int {
        let url = URL(string: config.getApiUrl(path: "/api/miniprogram/reply/\(commentId)"))!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "commentId": commentId,
            "userId": userId,
            "content": content
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let response: APIResponse<Int> = try await post(url: request)
        if response.code == 200, let replyId = response.data {
            return replyId
        }
        throw APIError.serverError(response.message ?? "回复失败")
    }

    func toggleReplyLike(replyId: Int, userId: Int, likeType: Int) async throws -> Int {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/miniprogram/like/reply/\(replyId)"))!
        urlComponents.queryItems = [
            URLQueryItem(name: "userId", value: String(userId)),
            URLQueryItem(name: "likeType", value: String(likeType))
        ]

        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"

        let response: APIResponse<Int> = try await post(url: request)
        if response.code == 200, let result = response.data {
            return result
        }
        throw APIError.serverError(response.message ?? "点赞失败")
    }
}
