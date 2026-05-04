import Foundation

/// 认证相关API（验证码、登录）
final class AuthApiService: BaseApiService {
    static let shared = AuthApiService()

    func getCaptcha() async throws -> CaptchaResponse {
        let url = URL(string: config.getBaseUrl(path: "/captcha/generate"))!
        let response: APIResponse<CaptchaResponse> = try await get(url: url)
        if response.code == 200, let captcha = response.data {
            return captcha
        }
        throw APIError.serverError(response.message ?? "获取验证码失败")
    }

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

        let response: APIResponse<LoginResponse> = try await post(url: request)
        if response.code == 200, let loginData = response.data {
            return loginData
        }
        throw APIError.serverError(response.message ?? "登录失败")
    }
}
