import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var email: String = ""
    @State private var code: String = ""
    @State private var codeKey: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var showPassword: Bool = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""
    @State private var successMessage: String = ""
    @State private var emailCodeCountdown: Int = 0
    @State private var emailCodeTimer: Timer?

    private let emailApiService = EmailAuthApiService.shared

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.backgroundLight
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // 标题
                        VStack(spacing: 8) {
                            Text("🔑")
                                .font(.system(size: 48))

                            Text("忘记密码")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(AppColor.textPrimary)

                            Text("通过邮箱验证码重置密码")
                                .font(.system(size: 14))
                                .foregroundColor(AppColor.textSecondary)
                        }
                        .padding(.top, 40)

                        // 表单
                        VStack(spacing: 16) {
                            // 邮箱
                            InputField(
                                icon: "📧",
                                placeholder: "请输入注册邮箱",
                                text: email,
                                isSecure: false
                            ) {
                                email = $0
                                errorMessage = ""
                            }

                            // 验证码 + 获取按钮
                            HStack(spacing: 12) {
                                InputField(
                                    icon: "number.square",
                                    placeholder: "请输入验证码",
                                    text: code,
                                    isSecure: false
                                ) {
                                    code = $0
                                    errorMessage = ""
                                }

                                Button(action: sendResetCode) {
                                    Text(emailCodeCountdown > 0 ? "\(emailCodeCountdown)s" : "获取验证码")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.white)
                                        .frame(width: 100, height: 44)
                                        .background(emailCodeCountdown > 0 ? AppColor.disabledText : AppColor.primary)
                                        .cornerRadius(10)
                                }
                                .disabled(emailCodeCountdown > 0 || email.trimmingCharacters(in: .whitespaces).isEmpty)
                            }

                            // 新密码
                            InputField(
                                icon: "🔑",
                                placeholder: "6-20位，需包含字母和数字",
                                text: newPassword,
                                isSecure: !showPassword
                            ) {
                                newPassword = $0
                                errorMessage = ""
                            }

                            // 确认密码
                            InputField(
                                icon: "🔒",
                                placeholder: "请再次输入新密码",
                                text: confirmPassword,
                                isSecure: !showPassword
                            ) {
                                confirmPassword = $0
                                errorMessage = ""
                            }

                            // 显示/隐藏密码
                            HStack {
                                Spacer()
                                Button(action: { showPassword.toggle() }) {
                                    Text(showPassword ? "🙈 隐藏密码" : "👁️ 显示密码")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppColor.primary)
                                }
                            }

                            // 成功/错误消息
                            if !successMessage.isEmpty {
                                Text(successMessage)
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColor.success)
                                    .padding(.horizontal, 16)
                            }
                            if !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColor.error)
                                    .padding(.horizontal, 16)
                            }

                            // 重置按钮
                            Button(action: doReset) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    }
                                    Text(isLoading ? "重置中..." : "重置密码")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(16)
                                .background(
                                    LinearGradient(
                                        colors: isFormValid ?
                                            [AppColor.primary, AppColor.primaryGradientEnd] :
                                            [AppColor.disabledText, AppColor.disabledText],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(12)
                            }
                            .disabled(!isFormValid || isLoading)

                            // 返回登录
                            Button(action: { dismiss() }) {
                                Text("返回登录")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColor.primary)
                            }
                            .padding(.top, 4)
                        }
                        .padding(.horizontal, 24)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("返回") {
                        dismiss()
                    }
                    .foregroundColor(AppColor.textSecondary)
                }
            }
        }
        .onDisappear {
            emailCodeTimer?.invalidate()
        }
    }

    private var isFormValid: Bool {
        let emailValid = email.contains("@") && email.contains(".")
        let codeValid = code.trimmingCharacters(in: .whitespaces).count >= 4
        let passwordValid = newPassword.count >= 6 && newPassword.count <= 20
        let confirmValid = newPassword == confirmPassword
        return emailValid && codeValid && passwordValid && confirmValid
    }

    private func sendResetCode() {
        let emailStr = email.trimmingCharacters(in: .whitespaces)
        guard !emailStr.isEmpty else { return }

        errorMessage = ""
        successMessage = ""

        Task {
            do {
                let response = try await emailApiService.sendResetCode(email: emailStr)
                codeKey = response.codeKey
                successMessage = "验证码已发送，请查收邮件"
                emailCodeCountdown = 60
                emailCodeTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    DispatchQueue.main.async {
                        if emailCodeCountdown > 0 {
                            emailCodeCountdown -= 1
                        } else {
                            emailCodeTimer?.invalidate()
                        }
                    }
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func doReset() {
        guard isFormValid else { return }

        isLoading = true
        errorMessage = ""
        successMessage = ""

        Task {
            do {
                try await emailApiService.resetPassword(
                    email: email,
                    code: code,
                    codeKey: codeKey,
                    newPassword: newPassword
                )
                isLoading = false
                successMessage = "密码重置成功，请使用新密码登录"
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    dismiss()
                }
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}
