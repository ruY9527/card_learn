<template>
  <div class="login-container">
    <!-- 左侧品牌区域 -->
    <div class="brand-side">
      <div class="brand-content">
        <div class="brand-icon">
          <span>📚</span>
        </div>
        <h1 class="brand-title">考研知识点学习卡片</h1>
        <p class="brand-subtitle">高效记忆 · 科学复习 · 轻松备考</p>
        <div class="brand-features">
          <div class="feature-item">
            <span class="feature-icon">🎯</span>
            <span>智能间隔重复算法</span>
          </div>
          <div class="feature-item">
            <span class="feature-icon">📊</span>
            <span>学习数据可视化</span>
          </div>
          <div class="feature-item">
            <span class="feature-icon">🏆</span>
            <span>成就激励系统</span>
          </div>
        </div>
      </div>
      <div class="brand-bg-decor"></div>
    </div>

    <!-- 右侧表单区域 -->
    <div class="form-side">
      <div class="form-card">
        <div class="form-header">
          <h2>{{ activeTab === 'login' ? '欢迎回来' : '创建账号' }}</h2>
          <p>{{ activeTab === 'login' ? '登录您的账号继续学习' : '注册新账号开始学习之旅' }}</p>
        </div>

        <!-- Tab 切换 -->
        <div class="tab-switcher">
          <div
            class="tab-item"
            :class="{ active: activeTab === 'login' }"
            @click="activeTab = 'login'"
          >
            登录
          </div>
          <div
            class="tab-item"
            :class="{ active: activeTab === 'register' }"
            @click="activeTab = 'register'"
          >
            注册
          </div>
          <div class="tab-indicator" :class="{ right: activeTab === 'register' }"></div>
        </div>

        <!-- 登录表单 -->
        <transition name="fade" mode="out-in">
          <div v-if="activeTab === 'login'" key="login" class="form-body">
            <el-form ref="loginFormRef" :model="loginForm" :rules="loginRules" @submit.prevent="handleLogin">
              <div class="input-group">
                <label class="input-label">用户名 / 邮箱</label>
                <el-input
                  v-model="loginForm.username"
                  placeholder="请输入用户名或邮箱"
                  size="large"
                  :prefix-icon="User"
                />
              </div>
              <div class="input-group">
                <label class="input-label">密码</label>
                <el-input
                  v-model="loginForm.password"
                  type="password"
                  placeholder="请输入密码"
                  size="large"
                  show-password
                  :prefix-icon="Lock"
                />
              </div>
              <div class="input-group">
                <label class="input-label">验证码</label>
                <div class="captcha-row">
                  <el-input
                    v-model="loginForm.captcha"
                    placeholder="请输入验证码"
                    size="large"
                    :prefix-icon="Key"
                    @keyup.enter="handleLogin"
                  />
                  <div class="captcha-img" @click="refreshCaptcha">
                    <img v-if="captchaImage" :src="captchaImage" alt="验证码" />
                    <span v-else class="captcha-loading">加载中</span>
                  </div>
                </div>
              </div>
              <div class="form-options">
                <span></span>
                <el-link type="primary" :underline="false" @click="goForgotPassword">忘记密码？</el-link>
              </div>
              <el-button
                type="primary"
                size="large"
                :loading="loginLoading"
                class="submit-btn"
                @click="handleLogin"
              >
                {{ loginLoading ? '登录中...' : '登 录' }}
              </el-button>
            </el-form>
          </div>

          <!-- 注册表单 -->
          <div v-else key="register" class="form-body">
            <el-form ref="registerFormRef" :model="registerForm" :rules="registerRules" @submit.prevent="handleRegister">
              <div class="input-group">
                <label class="input-label">邮箱</label>
                <el-input
                  v-model="registerForm.email"
                  placeholder="请输入邮箱地址"
                  size="large"
                  :prefix-icon="Message"
                />
              </div>
              <div class="input-group">
                <label class="input-label">邮箱验证码</label>
                <div class="captcha-row">
                  <el-input
                    v-model="registerForm.code"
                    placeholder="请输入验证码"
                    size="large"
                    :prefix-icon="Key"
                  />
                  <el-button
                    size="large"
                    class="code-btn"
                    :disabled="emailCodeCountdown > 0"
                    @click="handleSendEmailCode"
                  >
                    {{ emailCodeCountdown > 0 ? `${emailCodeCountdown}s` : '获取验证码' }}
                  </el-button>
                </div>
              </div>
              <div class="input-group">
                <label class="input-label">密码</label>
                <el-input
                  v-model="registerForm.password"
                  type="password"
                  placeholder="6-20位，需包含字母和数字"
                  size="large"
                  show-password
                  :prefix-icon="Lock"
                />
              </div>
              <div class="input-group">
                <label class="input-label">确认密码</label>
                <el-input
                  v-model="registerForm.confirmPassword"
                  type="password"
                  placeholder="请再次输入密码"
                  size="large"
                  show-password
                  :prefix-icon="Lock"
                  @keyup.enter="handleRegister"
                />
              </div>
              <el-button
                type="primary"
                size="large"
                :loading="registerLoading"
                class="submit-btn"
                @click="handleRegister"
              >
                {{ registerLoading ? '注册中...' : '注册' }}
              </el-button>
            </el-form>
          </div>
        </transition>

        <div class="form-footer">
          <template v-if="activeTab === 'login'">
            还没有账号？
            <el-link type="primary" :underline="false" @click="activeTab = 'register'">立即注册</el-link>
          </template>
          <template v-else>
            已有账号？
            <el-link type="primary" :underline="false" @click="activeTab = 'login'">立即登录</el-link>
          </template>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { User, Lock, Key, Message } from '@element-plus/icons-vue'
import type { FormInstance, FormRules } from 'element-plus'
import { login, getCaptcha } from '@/api/auth'
import { sendEmailCode, emailRegister } from '@/api/email-auth'
import { useUserStore } from '@/store/user'
import { registerDynamicRoutes } from '@/router/dynamicRouteHelper'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const activeTab = ref((route.query.tab as string) === 'register' ? 'register' : 'login')

// ========== 登录 ==========
const loginFormRef = ref<FormInstance>()
const loginLoading = ref(false)
const captchaImage = ref('')
const captchaKey = ref('')

const loginForm = reactive({
  username: '',
  password: '',
  captcha: '',
  captchaKey: ''
})

const loginRules: FormRules = {
  username: [{ required: true, message: '请输入用户名或邮箱', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
  captcha: [{ required: true, message: '请输入验证码', trigger: 'blur' }]
}

const refreshCaptcha = async () => {
  try {
    const res = await getCaptcha()
    captchaImage.value = res.data.image
    captchaKey.value = res.data.key
    loginForm.captchaKey = res.data.key
    loginForm.captcha = ''
  } catch {
    ElMessage.error('获取验证码失败')
  }
}

const handleLogin = async () => {
  await loginFormRef.value?.validate()
  loginLoading.value = true
  try {
    const res = await login(loginForm)
    userStore.setToken(res.data.token)
    userStore.setUserInfo(res.data.user)
    // 保存菜单数据
    if (res.data.user?.menus) {
      userStore.setMenus(res.data.user.menus)
    }
    ElMessage.success('登录成功')
    const roles = res.data.user?.roles || []
    const isAdmin = roles.includes('admin')
    // 管理员需要先注册动态路由再跳转
    if (isAdmin) {
      await registerDynamicRoutes(userStore)
    }
    router.push(isAdmin ? '/admin/dashboard' : '/learn')
  } catch {
    refreshCaptcha()
  } finally {
    loginLoading.value = false
  }
}

// ========== 注册 ==========
const registerFormRef = ref<FormInstance>()
const registerLoading = ref(false)
const emailCodeCountdown = ref(0)
let countdownTimer: ReturnType<typeof setInterval> | null = null

const registerForm = reactive({
  email: '',
  code: '',
  codeKey: '',
  password: '',
  confirmPassword: ''
})

const validateConfirmPassword = (_rule: any, value: string, callback: any) => {
  if (value !== registerForm.password) {
    callback(new Error('两次输入的密码不一致'))
  } else {
    callback()
  }
}

const registerRules: FormRules = {
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
  ],
  code: [{ required: true, message: '请输入验证码', trigger: 'blur' }],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, max: 20, message: '密码长度需6-20位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请再次输入密码', trigger: 'blur' },
    { validator: validateConfirmPassword, trigger: 'blur' }
  ]
}

const handleSendEmailCode = async () => {
  if (!registerForm.email) {
    ElMessage.warning('请先输入邮箱')
    return
  }
  try {
    const res = await sendEmailCode({ email: registerForm.email, type: 'register' })
    registerForm.codeKey = res.data.codeKey
    ElMessage.success('验证码已发送，请查收邮件')
    emailCodeCountdown.value = 60
    countdownTimer = setInterval(() => {
      emailCodeCountdown.value--
      if (emailCodeCountdown.value <= 0 && countdownTimer) {
        clearInterval(countdownTimer)
        countdownTimer = null
      }
    }, 1000)
  } catch {
    // 错误已由拦截器处理
  }
}

const handleRegister = async () => {
  await registerFormRef.value?.validate()
  registerLoading.value = true
  try {
    const res = await emailRegister({
      email: registerForm.email,
      code: registerForm.code,
      codeKey: registerForm.codeKey,
      password: registerForm.password
    })
    if (res.data.token) {
      // 不需要激活，直接登录
      userStore.setToken(res.data.token)
      userStore.setUserInfo(res.data.user)
      if (res.data.user?.menus) {
        userStore.setMenus(res.data.user.menus)
      }
      ElMessage.success('注册成功，已自动登录')
      const roles = res.data.user?.roles || []
      const isAdmin = roles.includes('admin')
      // 管理员需要先注册动态路由再跳转
      if (isAdmin) {
        await registerDynamicRoutes(userStore)
      }
      router.push(isAdmin ? '/admin/dashboard' : '/learn')
    } else {
      // 需要激活
      ElMessage.success('注册成功，请查收激活邮件并在24小时内完成激活')
      activeTab.value = 'login'
    }
    registerForm.email = ''
    registerForm.code = ''
    registerForm.codeKey = ''
    registerForm.password = ''
    registerForm.confirmPassword = ''
  } catch {
    // 错误已由拦截器处理
  } finally {
    registerLoading.value = false
  }
}

const goForgotPassword = () => {
  router.push('/forgot-password')
}

onMounted(() => {
  refreshCaptcha()
})
</script>

<style scoped lang="scss">
.login-container {
  width: 100%;
  height: 100vh;
  display: flex;
  overflow: hidden;
}

// ========== 左侧品牌区域 ==========
.brand-side {
  flex: 1;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
  padding: 60px;

  .brand-content {
    position: relative;
    z-index: 2;
    color: #fff;
    max-width: 420px;
  }

  .brand-icon {
    font-size: 64px;
    margin-bottom: 24px;
    filter: drop-shadow(0 4px 12px rgba(0, 0, 0, 0.2));
  }

  .brand-title {
    font-size: 36px;
    font-weight: 700;
    margin: 0 0 12px;
    line-height: 1.3;
    letter-spacing: 2px;
  }

  .brand-subtitle {
    font-size: 16px;
    opacity: 0.85;
    margin: 0 0 40px;
    letter-spacing: 4px;
  }

  .brand-features {
    display: flex;
    flex-direction: column;
    gap: 16px;
  }

  .feature-item {
    display: flex;
    align-items: center;
    gap: 12px;
    font-size: 15px;
    opacity: 0.9;
    background: rgba(255, 255, 255, 0.12);
    padding: 12px 20px;
    border-radius: 12px;
    backdrop-filter: blur(8px);
    transition: background 0.3s;

    &:hover {
      background: rgba(255, 255, 255, 0.2);
    }

    .feature-icon {
      font-size: 20px;
    }
  }

  .brand-bg-decor {
    position: absolute;
    top: -20%;
    right: -10%;
    width: 500px;
    height: 500px;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.06);
    z-index: 1;
  }
}

// ========== 右侧表单区域 ==========
.form-side {
  width: 520px;
  min-width: 520px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f8f9fd;
  padding: 40px;
}

.form-card {
  width: 100%;
  max-width: 400px;
}

.form-header {
  margin-bottom: 32px;

  h2 {
    font-size: 28px;
    font-weight: 700;
    color: #1a1a2e;
    margin: 0 0 8px;
  }

  p {
    font-size: 14px;
    color: #8c8c8c;
    margin: 0;
  }
}

// ========== Tab 切换 ==========
.tab-switcher {
  display: flex;
  position: relative;
  background: #ebedf0;
  border-radius: 10px;
  padding: 4px;
  margin-bottom: 28px;

  .tab-item {
    flex: 1;
    text-align: center;
    padding: 10px 0;
    font-size: 14px;
    font-weight: 500;
    color: #666;
    cursor: pointer;
    position: relative;
    z-index: 2;
    transition: color 0.3s;

    &.active {
      color: #409eff;
    }
  }

  .tab-indicator {
    position: absolute;
    top: 4px;
    left: 4px;
    width: calc(50% - 4px);
    height: calc(100% - 8px);
    background: #fff;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
    transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    z-index: 1;

    &.right {
      transform: translateX(100%);
    }
  }
}

// ========== 表单主体 ==========
.form-body {
  .input-group {
    margin-bottom: 20px;
  }

  .input-label {
    display: block;
    font-size: 13px;
    font-weight: 500;
    color: #4a4a4a;
    margin-bottom: 6px;
  }

  :deep(.el-input__wrapper) {
    border-radius: 10px;
    box-shadow: 0 0 0 1px #dcdfe6 inset;
    padding: 4px 12px;
    transition: all 0.3s;

    &:hover {
      box-shadow: 0 0 0 1px #c0c4cc inset;
    }

    &.is-focus {
      box-shadow: 0 0 0 1px #409eff inset;
    }
  }

  :deep(.el-input__prefix) {
    color: #bfbfbf;
  }
}

.captcha-row {
  display: flex;
  gap: 12px;

  .el-input {
    flex: 1;
  }

  .captcha-img {
    width: 120px;
    height: 40px;
    border-radius: 10px;
    overflow: hidden;
    cursor: pointer;
    background: #fff;
    border: 1px solid #dcdfe6;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    transition: border-color 0.3s;

    &:hover {
      border-color: #409eff;
    }

    img {
      width: 100%;
      height: 100%;
      object-fit: fill;
    }

    .captcha-loading {
      font-size: 12px;
      color: #999;
    }
  }

  .code-btn {
    width: 120px;
    flex-shrink: 0;
    border-radius: 10px;
  }
}

.form-options {
  display: flex;
  justify-content: flex-end;
  margin-bottom: 20px;

  .el-link {
    font-size: 13px;
  }
}

.submit-btn {
  width: 100%;
  height: 46px;
  border-radius: 10px;
  font-size: 16px;
  font-weight: 600;
  letter-spacing: 4px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  transition: all 0.3s;

  &:hover {
    opacity: 0.9;
    transform: translateY(-1px);
    box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
  }

  &:active {
    transform: translateY(0);
  }
}

.form-footer {
  text-align: center;
  margin-top: 24px;
  font-size: 14px;
  color: #8c8c8c;

  .el-link {
    font-size: 14px;
    font-weight: 500;
  }
}

// ========== 过渡动画 ==========
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.25s ease, transform 0.25s ease;
}

.fade-enter-from {
  opacity: 0;
  transform: translateY(8px);
}

.fade-leave-to {
  opacity: 0;
  transform: translateY(-8px);
}

// ========== 响应式 ==========
@media (max-width: 900px) {
  .brand-side {
    display: none;
  }

  .form-side {
    width: 100%;
    min-width: auto;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);

    .form-card {
      background: #fff;
      border-radius: 16px;
      padding: 40px 32px;
      box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
    }
  }
}
</style>
