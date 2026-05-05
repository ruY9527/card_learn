import Foundation

/// 邮箱认证相关API（发送验证码、注册、激活、重置密码）
final class EmailAuthApiService: BaseApiService {
    static let shared = EmailAuthApiService()

    /// 发送邮箱验证码
    func sendEmailCode(email: String, type: String) async throws -> EmailCodeResponse {
        let url = URL(string: config.getBaseUrl(path: "/auth/email-code/send"))!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "email": email.trimmingCharacters(in: .whitespaces),
            "type": type
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let response: APIResponse<EmailCodeResponse> = try await post(url: request)
        if response.code == 200, let data = response.data {
            return data
        }
        throw APIError.serverError(response.message ?? "发送验证码失败")
    }

    /// 邮箱注册
    func emailRegister(email: String, code: String, codeKey: String, password: String) async throws -> EmailRegisterResponse {
        let url = URL(string: config.getBaseUrl(path: "/auth/email/register"))!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "email": email.trimmingCharacters(in: .whitespaces),
            "code": code.trimmingCharacters(in: .whitespaces),
            "codeKey": codeKey,
            "password": password
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let response: APIResponse<EmailRegisterResponse> = try await post(url: request)
        if response.code == 200, let data = response.data {
            return data
        }
        throw APIError.serverError(response.message ?? "注册失败")
    }

    /// 激活账号
    func activateAccount(code: String, key: String) async throws -> LoginResponse {
        var components = URLComponents(string: config.getBaseUrl(path: "/auth/activate"))!
        components.queryItems = [
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "key", value: key)
        ]
        let url = components.url!
        let response: APIResponse<LoginResponse> = try await get(url: url)
        if response.code == 200, let data = response.data {
            return data
        }
        throw APIError.serverError(response.message ?? "激活失败")
    }

    /// 发送重置密码验证码
    func sendResetCode(email: String) async throws -> EmailCodeResponse {
        let url = URL(string: config.getBaseUrl(path: "/auth/password/reset-code/send"))!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "email": email.trimmingCharacters(in: .whitespaces)
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let response: APIResponse<EmailCodeResponse> = try await post(url: request)
        if response.code == 200, let data = response.data {
            return data
        }
        throw APIError.serverError(response.message ?? "发送验证码失败")
    }

    /// 重置密码
    func resetPassword(email: String, code: String, codeKey: String, newPassword: String) async throws {
        let url = URL(string: config.getBaseUrl(path: "/auth/password/reset"))!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "email": email.trimmingCharacters(in: .whitespaces),
            "code": code.trimmingCharacters(in: .whitespaces),
            "codeKey": codeKey,
            "newPassword": newPassword
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let response: APIResponse<EmptyResponse> = try await post(url: request)
        if response.code != 200 {
            throw APIError.serverError(response.message ?? "重置密码失败")
        }
    }
}

/// 空响应体（用于不需要返回数据的接口）
struct EmptyResponse: Codable {}
