<template>
  <div class="email-config-container">
    <el-card shadow="never" class="config-card">
      <template #header>
        <div class="card-header">
          <span>邮箱配置</span>
          <el-tag :type="activationEnabled ? 'success' : 'info'" size="small">
            {{ activationEnabled ? '需要激活' : '无需激活' }}
          </el-tag>
        </div>
      </template>

      <el-form label-width="140px" v-loading="loading">
        <el-form-item label="邮箱激活开关">
          <div class="switch-row">
            <el-switch v-model="activationEnabled" />
            <span class="switch-label" :class="{ active: activationEnabled }">
              {{ activationEnabled ? '需要邮件激活' : '注册后直接激活' }}
            </span>
          </div>
          <div class="form-tip">
            开启后，用户注册需点击邮件中的激活链接才能登录；关闭后，注册即自动激活。
          </div>
        </el-form-item>

        <el-form-item label="激活链接地址">
          <el-input
            v-model="activateUrl"
            placeholder="如 https://yourdomain.com/auth/activate"
          />
          <div class="form-tip">
            激活邮件中点击的链接地址，需包含完整域名和路径。例如：https://card.example.com/auth/activate
          </div>
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="handleSave" :loading="saving">
            保存配置
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card shadow="never" class="tip-card">
      <template #header>
        <span>配置说明</span>
      </template>
      <el-alert type="info" :closable="false">
        <template #title>
          <div class="alert-content">
            <p>1. 开启「邮箱激活开关」后，用户注册会收到激活邮件，需在24小时内点击链接激活账号</p>
            <p>2. 关闭「邮箱激活开关」后，用户注册完成即可直接登录，无需邮件激活</p>
            <p>3. 「激活链接地址」决定激活邮件中的链接域名，部署到生产环境时需改为真实域名</p>
            <p>4. 此配置对重置密码功能无影响，重置密码始终需要邮箱验证码</p>
          </div>
        </template>
      </el-alert>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getConfigByKey, updateConfigValue } from '@/api/config'

const loading = ref(false)
const saving = ref(false)
const activationEnabled = ref(true)
const activateUrl = ref('')

const fetchConfig = async () => {
  loading.value = true
  try {
    const [activationRes, urlRes] = await Promise.all([
      getConfigByKey('email_activation_required'),
      getConfigByKey('email_activate_url')
    ])
    activationEnabled.value = activationRes.data.configValue !== 'false'
    activateUrl.value = urlRes.data.configValue || ''
  } catch {
    activationEnabled.value = true
    activateUrl.value = ''
  } finally {
    loading.value = false
  }
}

const handleSave = async () => {
  saving.value = true
  try {
    await Promise.all([
      updateConfigValue('email_activation_required', activationEnabled.value ? 'true' : 'false'),
      updateConfigValue('email_activate_url', activateUrl.value)
    ])
    ElMessage.success('配置保存成功')
  } catch {
    ElMessage.error('保存失败')
  } finally {
    saving.value = false
  }
}

onMounted(() => {
  fetchConfig()
})
</script>

<style scoped lang="scss">
.email-config-container {
  padding: 20px;

  .config-card {
    margin-bottom: 20px;

    .card-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    .switch-row {
      display: flex;
      align-items: center;
      gap: 12px;

      .switch-label {
        font-size: 14px;
        color: #909399;
        transition: color 0.3s;

        &.active {
          color: #409eff;
        }
      }
    }

    .form-tip {
      font-size: 12px;
      color: #909399;
      margin-top: 2px;
      padding-left: 8px;
      line-height: 1.5;
    }
  }

  .tip-card {
    .alert-content {
      p {
        margin: 4px 0;
        line-height: 1.6;
      }
    }
  }
}
</style>
