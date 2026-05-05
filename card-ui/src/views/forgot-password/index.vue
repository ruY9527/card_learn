<template>
  <div class="forgot-container">
    <!-- 左侧品牌区域 -->
    <div class="brand-side">
      <div class="brand-content">
        <div class="brand-icon">
          <span>🔑</span>
        </div>
        <h1 class="brand-title">找回密码</h1>
        <p class="brand-subtitle">通过邮箱验证重置您的密码</p>
      </div>
      <div class="brand-bg-decor"></div>
    </div>

    <!-- 右侧表单区域 -->
    <div class="form-side">
      <div class="form-card">
        <div class="form-header">
          <h2>重置密码</h2>
          <p>输入您的邮箱，我们将发送验证码</p>
        </div>

        <el-form ref="formRef" :model="form" :rules="rules" @submit.prevent="handleReset">
          <div class="input-group">
            <label class="input-label">邮箱</label>
            <el-input
              v-model="form.email"
              placeholder="请输入注册邮箱"
              size="large"
              :prefix-icon="Message"
            />
          </div>
          <div class="input-group">
            <label class="input-label">邮箱验证码</label>
            <div class="captcha-row">
              <el-input
                v-model="form.code"
                placeholder="请输入验证码"
                size="large"
                :prefix-icon="Key"
              />
              <el-button
                size="large"
                class="code-btn"
                :disabled="countdown > 0"
                @click="handleSendCode"
              >
                {{ countdown > 0 ? `${countdown}s` : '获取验证码' }}
              </el-button>
            </div>
          </div>
          <div class="input-group">
            <label class="input-label">新密码</label>
            <el-input
              v-model="form.newPassword"
              type="password"
              placeholder="6-20位，需包含字母和数字"
              size="large"
              show-password
              :prefix-icon="Lock"
            />
          </div>
          <div class="input-group">
            <label class="input-label">确认新密码</label>
            <el-input
              v-model="form.confirmPassword"
              type="password"
              placeholder="请再次输入新密码"
              size="large"
              show-password
              :prefix-icon="Lock"
              @keyup.enter="handleReset"
            />
          </div>
          <el-button
            type="primary"
            size="large"
            :loading="loading"
            class="submit-btn"
            @click="handleReset"
          >
            {{ loading ? '重置中...' : '重置密码' }}
          </el-button>
        </el-form>

        <div class="form-footer">
          <el-link type="primary" :underline="false" @click="goLogin">
            ← 返回登录
          </el-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Lock, Key, Message } from '@element-plus/icons-vue'
import type { FormInstance, FormRules } from 'element-plus'
import { sendResetCode, resetPassword } from '@/api/email-auth'

const router = useRouter()

const formRef = ref<FormInstance>()
const loading = ref(false)
const countdown = ref(0)
let countdownTimer: ReturnType<typeof setInterval> | null = null

const form = reactive({
  email: '',
  code: '',
  codeKey: '',
  newPassword: '',
  confirmPassword: ''
})

const validateConfirmPassword = (_rule: any, value: string, callback: any) => {
  if (value !== form.newPassword) {
    callback(new Error('两次输入的密码不一致'))
  } else {
    callback()
  }
}

const rules: FormRules = {
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
  ],
  code: [{ required: true, message: '请输入验证码', trigger: 'blur' }],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, max: 20, message: '密码长度需6-20位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请再次输入新密码', trigger: 'blur' },
    { validator: validateConfirmPassword, trigger: 'blur' }
  ]
}

const handleSendCode = async () => {
  if (!form.email) {
    ElMessage.warning('请先输入邮箱')
    return
  }
  try {
    const res = await sendResetCode(form.email)
    form.codeKey = res.data.codeKey
    ElMessage.success('验证码已发送，请查收邮件')
    countdown.value = 60
    countdownTimer = setInterval(() => {
      countdown.value--
      if (countdown.value <= 0 && countdownTimer) {
        clearInterval(countdownTimer)
        countdownTimer = null
      }
    }, 1000)
  } catch {
    // 错误已由拦截器处理
  }
}

const handleReset = async () => {
  await formRef.value?.validate()
  loading.value = true
  try {
    await resetPassword({
      email: form.email,
      code: form.code,
      codeKey: form.codeKey,
      newPassword: form.newPassword
    })
    ElMessage.success('密码重置成功，请使用新密码登录')
    router.push('/login')
  } catch {
    // 错误已由拦截器处理
  } finally {
    loading.value = false
  }
}

const goLogin = () => {
  router.push('/login')
}
</script>

<style scoped lang="scss">
.forgot-container {
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
    text-align: center;
  }

  .brand-icon {
    font-size: 72px;
    margin-bottom: 24px;
    filter: drop-shadow(0 4px 12px rgba(0, 0, 0, 0.2));
  }

  .brand-title {
    font-size: 36px;
    font-weight: 700;
    margin: 0 0 12px;
    letter-spacing: 2px;
  }

  .brand-subtitle {
    font-size: 16px;
    opacity: 0.85;
    margin: 0;
    letter-spacing: 2px;
  }

  .brand-bg-decor {
    position: absolute;
    bottom: -20%;
    left: -10%;
    width: 400px;
    height: 400px;
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

.input-group {
  margin-bottom: 20px;

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

  .code-btn {
    width: 120px;
    flex-shrink: 0;
    border-radius: 10px;
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
  margin-top: 8px;
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

  .el-link {
    font-size: 14px;
    font-weight: 500;
  }
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
