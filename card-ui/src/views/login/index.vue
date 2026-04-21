<template>
  <div class="login-container">
    <el-card class="login-card">
      <template #header>
        <h2>408知识点学习卡片管理系统</h2>
      </template>
      <el-form ref="formRef" :model="loginForm" :rules="rules" label-width="80px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="loginForm.username" placeholder="请输入用户名" />
        </el-form-item>
        <el-form-item label="密码" prop="password">
          <el-input
            v-model="loginForm.password"
            type="password"
            placeholder="请输入密码"
            show-password
          />
        </el-form-item>
        <el-form-item label="验证码" prop="captcha">
          <div class="captcha-wrapper">
            <el-input
              v-model="loginForm.captcha"
              placeholder="请输入验证码"
              class="captcha-input"
            />
            <div class="captcha-image" @click="refreshCaptcha">
              <img v-if="captchaImage" :src="captchaImage" alt="验证码" />
              <span v-else class="loading-text">加载中...</span>
            </div>
          </div>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="loading" @click="handleLogin">
            登录
          </el-button>
          <el-button @click="refreshCaptcha">刷新验证码</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import { login, getCaptcha } from '@/api/auth'
import { useUserStore } from '@/store/user'

const router = useRouter()
const userStore = useUserStore()

const formRef = ref<FormInstance>()
const loading = ref(false)
const captchaImage = ref<string>('')
const captchaKey = ref<string>('')

const loginForm = reactive({
  username: 'admin',
  password: 'admin123',
  captcha: '',
  captchaKey: ''
})

const rules: FormRules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
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
  } catch (error) {
    console.error(error)
    ElMessage.error('获取验证码失败')
  }
}

const handleLogin = async () => {
  await formRef.value?.validate()
  loading.value = true
  try {
    const res = await login(loginForm)
    userStore.setToken(res.data.token)
    userStore.setUserInfo(res.data.user)
    ElMessage.success('登录成功')
    router.push('/')
  } catch (error) {
    console.error(error)
    // 登录失败后刷新验证码
    refreshCaptcha()
  } finally {
    loading.value = false
  }
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
  justify-content: center;
  align-items: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);

  .login-card {
    width: 450px;

    h2 {
      text-align: center;
      margin: 0;
      color: #409eff;
    }
  }
}

.captcha-wrapper {
  display: flex;
  align-items: center;
  width: 100%;

  .captcha-input {
    width: 150px;
    margin-right: 10px;
  }

  .captcha-image {
    width: 120px;
    height: 40px;
    border: 1px solid #dcdfe6;
    border-radius: 4px;
    cursor: pointer;
    overflow: hidden;
    display: flex;
    align-items: center;
    justify-content: center;
    background-color: #f5f5f5;

    img {
      width: 100%;
      height: 100%;
      object-fit: fill;
    }

    .loading-text {
      color: #909399;
      font-size: 12px;
    }
  }
}
</style>