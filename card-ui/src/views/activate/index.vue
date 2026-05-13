<template>
  <div class="activate-container">
    <div class="brand-side">
      <div class="brand-content">
        <div class="brand-icon">
          <span>📧</span>
        </div>
        <h1 class="brand-title">邮箱激活</h1>
        <p class="brand-subtitle">验证您的邮箱以完成注册</p>
      </div>
      <div class="brand-bg-decor"></div>
    </div>

    <div class="form-side">
      <div class="form-card">
        <!-- 加载中 -->
        <div v-if="loading" class="state-card">
          <div class="state-icon spinning">
            <span>⏳</span>
          </div>
          <h3>正在激活账号...</h3>
          <p>请稍候，正在验证您的邮箱</p>
        </div>

        <!-- 激活成功 -->
        <div v-else-if="success" class="state-card success">
          <div class="state-icon">
            <span>✅</span>
          </div>
          <h3>激活成功</h3>
          <p>您的账号已激活，{{ countdown }}秒后自动跳转到首页...</p>
          <el-button type="primary" size="large" class="action-btn" @click="goHome">
            立即前往
          </el-button>
        </div>

        <!-- 激活失败 -->
        <div v-else class="state-card error">
          <div class="state-icon">
            <span>❌</span>
          </div>
          <h3>激活失败</h3>
          <p class="error-msg">{{ errorMsg }}</p>
          <el-button size="large" class="action-btn" @click="goLogin">
            返回登录
          </el-button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { activateAccount } from '@/api/email-auth'
import { useUserStore } from '@/store/user'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const loading = ref(true)
const success = ref(false)
const errorMsg = ref('')
const countdown = ref(3)

const goLogin = () => router.push('/login')
const goHome = () => {
  const roles = userStore.userInfo?.roles || []
  router.push(roles.includes('admin') ? '/admin/dashboard' : '/learn')
}

onMounted(async () => {
  const code = route.query.code as string
  const key = route.query.key as string

  if (!code || !key) {
    loading.value = false
    errorMsg.value = '激活链接参数不完整'
    return
  }

  try {
    const res = await activateAccount(code, key)
    success.value = true
    loading.value = false
    userStore.setToken(res.data.token)
    userStore.setUserInfo(res.data.user)
    if (res.data.user?.menus) {
      userStore.setMenus(res.data.user.menus)
    }
    // 倒计时跳转
    const timer = setInterval(() => {
      countdown.value--
      if (countdown.value <= 0) {
        clearInterval(timer)
        goHome()
      }
    }, 1000)
  } catch (error: any) {
    loading.value = false
    errorMsg.value = error?.message || '激活失败，请重新注册或联系管理员'
  }
})
</script>

<style scoped lang="scss">
.activate-container {
  width: 100%;
  height: 100vh;
  display: flex;
  overflow: hidden;
}

.brand-side {
  flex: 1;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;

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
    top: -15%;
    right: -8%;
    width: 350px;
    height: 350px;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.06);
    z-index: 1;
  }
}

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

.state-card {
  text-align: center;
  padding: 40px 0;

  .state-icon {
    font-size: 64px;
    margin-bottom: 20px;
    display: inline-block;

    &.spinning {
      animation: spin 1.5s linear infinite;
    }
  }

  h3 {
    font-size: 22px;
    font-weight: 600;
    color: #1a1a2e;
    margin: 0 0 12px;
  }

  p {
    font-size: 14px;
    color: #8c8c8c;
    margin: 0 0 28px;
    line-height: 1.6;
  }

  .error-msg {
    color: #f56c6c;
  }

  &.success h3 {
    color: #67c23a;
  }

  &.error h3 {
    color: #f56c6c;
  }
}

.action-btn {
  min-width: 160px;
  height: 44px;
  border-radius: 10px;
  font-size: 15px;
  font-weight: 500;
  letter-spacing: 2px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;

  &:hover {
    opacity: 0.9;
  }
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

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
