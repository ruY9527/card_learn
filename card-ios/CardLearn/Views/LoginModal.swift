import SwiftUI

struct LoginModal: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0 // 0=登录, 1=注册

    // 登录字段
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var captcha: String = ""
    @State private var captchaKey: String = ""
    @State private var captchaImage: String = ""
    @State private var showPassword: Bool = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""

    // 注册字段
    @State private var regEmail: String = ""
    @State private var regCode: String = ""
    @State private var regCodeKey: String = ""
    @State private var regPassword: String = ""
    @State private var regConfirmPassword: String = ""
    @State private var regShowPassword: Bool = false
    @State private var regIsLoading: Bool = false
    @State private var regErrorMessage: String = ""
    @State private var regSuccessMessage: String = ""
    @State private var emailCodeCountdown: Int = 0
    @State private var emailCodeTimer: Timer?

    // 忘记密码
    @State private var showForgotPassword: Bool = false

    let onSuccess: () -> Void

    private let apiService = AuthApiService.shared
    private let emailApiService = EmailAuthApiService.shared

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.backgroundLight
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // 标题区域
                        VStack(spacing: 8) {
                            Text("🔐")
                                .font(.system(size: 48))

                            Text(selectedTab == 0 ? "欢迎登录" : "注册账号")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(AppColor.textPrimary)

                            Text(selectedTab == 0 ? "登录后可保存学习进度并提交反馈" : "使用邮箱注册新账号")
                                .font(.system(size: 14))
                                .foregroundColor(AppColor.textSecondary)
                        }
                        .padding(.top, 40)

                        // Tab 切换
                        HStack(spacing: 0) {
                            TabButton(title: "登录", isSelected: selectedTab == 0) {
                                selectedTab = 0
                                errorMessage = ""
                                regErrorMessage = ""
                            }
                            TabButton(title: "注册", isSelected: selectedTab == 1) {
                                selectedTab = 1
                                errorMessage = ""
                                regErrorMessage = ""
                            }
                        }
                        .padding(.horizontal, 24)

                        if selectedTab == 0 {
                            // 登录表单
                            loginForm
                        } else {
                            // 注册表单
                            registerForm
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("✕") {
                        onSuccess()
                    }
                    .foregroundColor(AppColor.textSecondary)
                }
            }
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
        .onAppear {
            refreshCaptcha()
        }
        .onDisappear {
            emailCodeTimer?.invalidate()
        }
    }

    // MARK: - 登录表单
    private var loginForm: some View {
        VStack(spacing: 16) {
            // 账号输入
            InputField(
                icon: "👤",
                placeholder: "请输入用户名或邮箱",
                text: username,
                isSecure: false
            ) {
                username = $0
                errorMessage = ""
            }

            // 密码输入
            InputField(
                icon: "🔑",
                placeholder: "请输入密码",
                text: password,
                isSecure: !showPassword
            ) {
                password = $0
                errorMessage = ""
            }

            // 显示/隐藏密码按钮
            HStack {
                Spacer()
                Button(action: { showPassword.toggle() }) {
                    Text(showPassword ? "🙈 隐藏密码" : "👁️ 显示密码")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.primary)
                }
            }

            // 验证码
            HStack(spacing: 12) {
                InputField(
                    icon: "number.square",
                    placeholder: "请输入验证码",
                    text: captcha,
                    isSecure: false
                ) {
                    captcha = $0
                    errorMessage = ""
                }

                Button(action: refreshCaptcha) {
                    if captchaImage.isEmpty {
                        VStack(spacing: 4) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: AppColor.primary))
                            Text("加载中")
                                .font(.system(size: 10))
                                .foregroundColor(AppColor.textSecondary)
                        }
                        .frame(width: 100, height: 40)
                        .background(Color.white)
                        .cornerRadius(8)
                    } else {
                        let base64String = captchaImage.replacingOccurrences(of: "data:image/png;base64,", with: "")
                        if let data = Data(base64Encoded: base64String),
                           let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 40)
                                .background(Color.white)
                                .cornerRadius(8)
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(AppColor.divider)
                                .frame(width: 100, height: 40)
                                .overlay(
                                    Text("点击刷新")
                                        .font(.system(size: 10))
                                        .foregroundColor(AppColor.textSecondary)
                                )
                        }
                    }
                }
            }

            // 刷新验证码提示
            HStack {
                Spacer()
                Button(action: refreshCaptcha) {
                    HStack(spacing: 4) {
                        Text("🔄")
                            .font(.system(size: 12))
                        Text("点击刷新验证码")
                            .font(.system(size: 12))
                            .foregroundColor(AppColor.primary)
                    }
                }
            }

            // 错误消息
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.system(size: 14))
                    .foregroundColor(AppColor.error)
                    .padding(.horizontal, 16)
            }

            // 登录按钮
            Button(action: doLogin) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    Text(isLoading ? "登录中..." : "立即登录")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(
                    LinearGradient(
                        colors: isLoginFormValid ?
                            [AppColor.primary, AppColor.primaryGradientEnd] :
                            [AppColor.disabledText, AppColor.disabledText],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(12)
            }
            .disabled(!isLoginFormValid || isLoading)

            // 忘记密码
            Button(action: { showForgotPassword = true }) {
                Text("忘记密码？")
                    .font(.system(size: 14))
                    .foregroundColor(AppColor.primary)
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - 注册表单
    private var registerForm: some View {
        VStack(spacing: 16) {
            // 邮箱
            InputField(
                icon: "📧",
                placeholder: "请输入邮箱",
                text: regEmail,
                isSecure: false
            ) {
                regEmail = $0
                regErrorMessage = ""
            }

            // 验证码 + 获取按钮
            HStack(spacing: 12) {
                InputField(
                    icon: "number.square",
                    placeholder: "请输入验证码",
                    text: regCode,
                    isSecure: false
                ) {
                    regCode = $0
                    regErrorMessage = ""
                }

                Button(action: sendEmailCode) {
                    Text(emailCodeCountdown > 0 ? "\(emailCodeCountdown)s" : "获取验证码")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 100, height: 44)
                        .background(emailCodeCountdown > 0 ? AppColor.disabledText : AppColor.primary)
                        .cornerRadius(10)
                }
                .disabled(emailCodeCountdown > 0 || regEmail.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            // 密码
            InputField(
                icon: "🔑",
                placeholder: "6-20位，需包含字母和数字",
                text: regPassword,
                isSecure: !regShowPassword
            ) {
                regPassword = $0
                regErrorMessage = ""
            }

            // 确认密码
            InputField(
                icon: "🔒",
                placeholder: "请再次输入密码",
                text: regConfirmPassword,
                isSecure: !regShowPassword
            ) {
                regConfirmPassword = $0
                regErrorMessage = ""
            }

            // 显示/隐藏密码
            HStack {
                Spacer()
                Button(action: { regShowPassword.toggle() }) {
                    Text(regShowPassword ? "🙈 隐藏密码" : "👁️ 显示密码")
                        .font(.system(size: 12))
                        .foregroundColor(AppColor.primary)
                }
            }

            // 成功/错误消息
            if !regSuccessMessage.isEmpty {
                Text(regSuccessMessage)
                    .font(.system(size: 14))
                    .foregroundColor(AppColor.success)
                    .padding(.horizontal, 16)
            }
            if !regErrorMessage.isEmpty {
                Text(regErrorMessage)
                    .font(.system(size: 14))
                    .foregroundColor(AppColor.error)
                    .padding(.horizontal, 16)
            }

            // 注册按钮
            Button(action: doRegister) {
                HStack {
                    if regIsLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    Text(regIsLoading ? "注册中..." : "注册")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(
                    LinearGradient(
                        colors: isRegisterFormValid ?
                            [AppColor.primary, AppColor.primaryGradientEnd] :
                            [AppColor.disabledText, AppColor.disabledText],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(12)
            }
            .disabled(!isRegisterFormValid || regIsLoading)

            // 已有账号
            Button(action: { selectedTab = 0 }) {
                HStack(spacing: 4) {
                    Text("已有账号？")
                        .foregroundColor(AppColor.textSecondary)
                    Text("立即登录")
                        .foregroundColor(AppColor.primary)
                }
                .font(.system(size: 14))
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - 表单校验
    private var isLoginFormValid: Bool {
        username.trimmingCharacters(in: .whitespaces).count >= 3 &&
        password.trimmingCharacters(in: .whitespaces).count >= 3 &&
        captcha.trimmingCharacters(in: .whitespaces).count >= 4
    }

    private var isRegisterFormValid: Bool {
        let emailValid = regEmail.contains("@") && regEmail.contains(".")
        let codeValid = regCode.trimmingCharacters(in: .whitespaces).count >= 4
        let passwordValid = regPassword.count >= 6 && regPassword.count <= 20
        let confirmValid = regPassword == regConfirmPassword
        return emailValid && codeValid && passwordValid && confirmValid
    }

    // MARK: - 登录
    private func refreshCaptcha() {
        Task {
            do {
                let captchaData = try await apiService.getCaptcha()
                captchaKey = captchaData.key
                captchaImage = captchaData.image
            } catch {
                errorMessage = "获取验证码失败"
            }
        }
    }

    private func doLogin() {
        guard isLoginFormValid else { return }

        isLoading = true
        errorMessage = ""

        Task {
            do {
                let loginResponse = try await apiService.login(
                    username: username,
                    password: password,
                    captcha: captcha,
                    captchaKey: captchaKey
                )
                appState.login(user: loginResponse.user, token: loginResponse.token)
                isLoading = false
                onSuccess()
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
                refreshCaptcha()
            }
        }
    }

    // MARK: - 注册
    private func sendEmailCode() {
        let email = regEmail.trimmingCharacters(in: .whitespaces)
        guard !email.isEmpty else { return }

        regErrorMessage = ""
        regSuccessMessage = ""

        Task {
            do {
                let response = try await emailApiService.sendEmailCode(email: email, type: "register")
                regCodeKey = response.codeKey
                regSuccessMessage = "验证码已发送，请查收邮件"
                // 开始倒计时
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
                regErrorMessage = error.localizedDescription
            }
        }
    }

    private func doRegister() {
        guard isRegisterFormValid else { return }

        regIsLoading = true
        regErrorMessage = ""
        regSuccessMessage = ""

        Task {
            do {
                let result = try await emailApiService.emailRegister(
                    email: regEmail,
                    code: regCode,
                    codeKey: regCodeKey,
                    password: regPassword
                )
                regIsLoading = false

                if result.isAutoLogin, let token = result.token, let user = result.user {
                    // 不需要激活，直接登录
                    appState.login(user: user, token: token)
                    onSuccess()
                } else {
                    // 需要激活
                    regSuccessMessage = "注册成功，请查收激活邮件并在24小时内完成激活"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        selectedTab = 0
                        regEmail = ""
                        regCode = ""
                        regCodeKey = ""
                        regPassword = ""
                        regConfirmPassword = ""
                        regSuccessMessage = ""
                    }
                }
            } catch {
                regErrorMessage = error.localizedDescription
                regIsLoading = false
            }
        }
    }
}

// MARK: - Tab按钮
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? AppColor.primary : AppColor.textSecondary)

                Rectangle()
                    .fill(isSelected ? AppColor.primary : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

// 输入框组件
struct InputField: View {
    let icon: String
    let placeholder: String
    let text: String
    let isSecure: Bool
    var maxWidth: CGFloat? = nil
    let onChange: (String) -> Void

    var body: some View {
        HStack(spacing: 12) {
            if icon.contains(".") {
                Image(systemName: icon)
                    .font(.system(size: 20))
            } else {
                Text(icon)
                    .font(.system(size: 20))
            }

            if isSecure {
                SecureField(placeholder, text: Binding(
                    get: { text },
                    set: { onChange($0) }
                ))
                .font(.system(size: 14))
            } else {
                TextField(placeholder, text: Binding(
                    get: { text },
                    set: { onChange($0) }
                ))
                .font(.system(size: 14))
            }

            if !text.isEmpty && !isSecure {
                Button(action: { onChange("") }) {
                    Text("✕")
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.disabledText)
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(10)
        .frame(maxWidth: maxWidth ?? .infinity)
    }
}
