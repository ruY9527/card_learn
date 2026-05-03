import SwiftUI

struct LoginModal: View {
    @EnvironmentObject var appState: AppState
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var captcha: String = ""
    @State private var captchaKey: String = ""
    @State private var captchaImage: String = ""
    @State private var showPassword: Bool = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""
    
    let onSuccess: () -> Void
    
    private let apiService = APIService.shared
    
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
                            
                            Text("欢迎登录")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(AppColor.textPrimary)
                            
                            Text("登录后可保存学习进度并提交反馈")
                                .font(.system(size: 14))
                                .foregroundColor(AppColor.textSecondary)
                        }
                        .padding(.top, 40)
                        
                        // 表单区域
                        VStack(spacing: 16) {
                            // 账号输入
                            InputField(
                                icon: "👤",
                                placeholder: "请输入账号",
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
                                
                                // 验证码图片
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
                                        // 显示 base64 图片
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
                            
                            // 底部提示
                            Text("首次登录请联系管理员获取账号")
                                .font(.system(size: 12))
                                .foregroundColor(AppColor.textSecondary)
                                .padding(.top, 8)
                        }
                        .padding(.horizontal, 24)
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
        .onAppear {
            refreshCaptcha()
        }
    }
    
    private var isFormValid: Bool {
        username.trimmingCharacters(in: .whitespaces).count >= 3 &&
        password.trimmingCharacters(in: .whitespaces).count >= 3 &&
        captcha.trimmingCharacters(in: .whitespaces).count >= 4
    }
    
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
        guard isFormValid else { return }
        
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
                
                // 登录成功
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