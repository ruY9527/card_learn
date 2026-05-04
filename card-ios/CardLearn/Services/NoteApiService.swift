import Foundation

/// 笔记相关API
final class NoteApiService: BaseApiService {
    static let shared = NoteApiService()

    func getMyNotes(userId: Int, subjectId: Int? = nil, keyword: String? = nil, pageNum: Int = 1, pageSize: Int = AppPageSize.comments) async throws -> PageResponse<Note> {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/miniprogram/note/my"))!
        var queryItems = [
            URLQueryItem(name: "userId", value: String(userId)),
            URLQueryItem(name: "pageNum", value: String(pageNum)),
            URLQueryItem(name: "pageSize", value: String(pageSize))
        ]
        if let subjectId = subjectId, subjectId > 0 {
            queryItems.append(URLQueryItem(name: "subjectId", value: String(subjectId)))
        }
        if let keyword = keyword, !keyword.isEmpty {
            queryItems.append(URLQueryItem(name: "keyword", value: keyword))
        }
        urlComponents.queryItems = queryItems

        let response: APIResponse<PageResponse<Note>> = try await get(url: urlComponents.url!)
        if response.code == 200, let pageData = response.data {
            return pageData
        }
        throw APIError.serverError(response.message ?? "获取笔记失败")
    }

    func editNote(noteId: Int, userId: Int, content: String) async throws {
        let url = URL(string: config.getApiUrl(path: "/api/miniprogram/note/\(noteId)"))!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.url = URL(string: request.url!.absoluteString + "?userId=\(userId)")!
        request.httpBody = content.data(using: .utf8)

        let response: APIResponse<String> = try await post(url: request)
        if response.code != 200 {
            throw APIError.serverError(response.message ?? "编辑笔记失败")
        }
    }

    func deleteNote(noteId: Int, userId: Int) async throws {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/miniprogram/note/\(noteId)"))!
        urlComponents.queryItems = [URLQueryItem(name: "userId", value: String(userId))]

        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "DELETE"

        let response: APIResponse<String> = try await post(url: request)
        if response.code != 200 {
            throw APIError.serverError(response.message ?? "删除笔记失败")
        }
    }

    func exportNotes(userId: Int, subjectId: Int? = nil) async throws -> String {
        var urlComponents = URLComponents(string: config.getApiUrl(path: "/api/miniprogram/note/export"))!
        var queryItems = [URLQueryItem(name: "userId", value: String(userId))]
        if let subjectId = subjectId, subjectId > 0 {
            queryItems.append(URLQueryItem(name: "subjectId", value: String(subjectId)))
        }
        urlComponents.queryItems = queryItems

        let response: APIResponse<String> = try await get(url: urlComponents.url!)
        if response.code == 200, let content = response.data {
            return content
        }
        throw APIError.serverError(response.message ?? "导出笔记失败")
    }
}
