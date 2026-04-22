<template>
  <div class="sprint-container">
    <!-- 当前配置展示 -->
    <el-card shadow="never" class="preview-card">
      <template #header>
        <div class="card-header">
          <span>当前冲刺配置预览</span>
          <el-tag :type="config.enabled ? 'success' : 'info'" size="small">
            {{ config.enabled ? '已启用' : '已禁用' }}
          </el-tag>
        </div>
      </template>

      <div class="preview-content">
        <div class="exam-info">
          <h3>{{ config.examName || '未设置考试名称' }}</h3>
          <p class="exam-date">考试日期：{{ config.examDate || '未设置' }}</p>
        </div>

        <div class="countdown-box" v-if="config.enabled && config.examDate && !config.isExpired">
          <div class="countdown-number">{{ config.daysRemaining }}</div>
          <div class="countdown-label">天</div>
        </div>

        <div class="expired-box" v-if="config.enabled && config.examDate && config.isExpired">
          <el-icon><WarningFilled /></el-icon>
          <span>考试已结束</span>
        </div>

        <div class="disabled-tip" v-if="!config.enabled">
          <el-icon><WarningFilled /></el-icon>
          <span>冲刺模式已禁用，小程序将不显示倒计时</span>
        </div>
      </div>
    </el-card>

    <!-- 配置表单 -->
    <el-card shadow="never" class="form-card">
      <template #header>
        <span>冲刺配置设置</span>
      </template>

      <el-form :model="formData" label-width="100px" v-loading="loading">
        <el-form-item label="考试名称">
          <el-input v-model="formData.examName" placeholder="请输入考试名称，如：2025年全国硕士研究生招生考试" />
        </el-form-item>

        <el-form-item label="考试日期">
          <el-date-picker
            v-model="formData.examDate"
            type="date"
            placeholder="请选择考试日期"
            value-format="YYYY-MM-DD"
            :disabled-date="disabledDate"
            style="width: 100%"
          />
        </el-form-item>

        <el-form-item label="启用状态">
          <el-switch
            v-model="formData.enabledBool"
            active-text="启用"
            inactive-text="禁用"
          />
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="handleSave" :loading="saving">
            <el-icon><Check /></el-icon>
            保存配置
          </el-button>
          <el-button @click="handleReset">
            <el-icon><Refresh /></el-icon>
            重置
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 配置说明 -->
    <el-card shadow="never" class="tip-card">
      <template #header>
        <span>配置说明</span>
      </template>

      <el-alert type="info" :closable="false">
        <template #title>
          <div class="alert-content">
            <p>1. 设置考试日期后，小程序首页将显示倒计时天数</p>
            <p>2. 考试名称将作为倒计时的标题显示</p>
            <p>3. 禁用冲刺模式后，小程序将隐藏倒计时模块</p>
            <p>4. 建议设置真实的考试日期，如考研初试日期（每年12月倒数第二个周末）</p>
          </div>
        </template>
      </el-alert>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getSprintConfig, updateSprintConfig } from '@/api/config'
import type { SprintConfig } from '@/api/types'

// 当前配置
const config = reactive<SprintConfig>({
  examName: '',
  examDate: '',
  daysRemaining: 0,
  isExpired: false,
  enabled: false
})

// 表单数据
const formData = reactive({
  examName: '',
  examDate: '',
  enabledBool: true
})

// 状态
const loading = ref(false)
const saving = ref(false)

// 禁用过去的日期
const disabledDate = (date: Date) => {
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  return date < today
}

// 获取配置
const fetchConfig = async () => {
  loading.value = true
  try {
    const res = await getSprintConfig()
    Object.assign(config, res.data)
    // 同步到表单
    formData.examName = config.examName || ''
    formData.examDate = config.examDate || ''
    formData.enabledBool = config.enabled
  } catch (error) {
    console.error('获取配置失败:', error)
  } finally {
    loading.value = false
  }
}

// 保存配置
const handleSave = async () => {
  if (!formData.examDate) {
    ElMessage.warning('请选择考试日期')
    return
  }
  if (!formData.examName) {
    ElMessage.warning('请输入考试名称')
    return
  }

  saving.value = true
  try {
    await updateSprintConfig({
      examDate: formData.examDate,
      examName: formData.examName,
      enabled: formData.enabledBool ? 'true' : 'false'
    })
    ElMessage.success('配置保存成功')
    // 更新预览
    await fetchConfig()
  } catch (error) {
    console.error('保存配置失败:', error)
    ElMessage.error('保存失败')
  } finally {
    saving.value = false
  }
}

// 重置表单
const handleReset = () => {
  formData.examName = config.examName || ''
  formData.examDate = config.examDate || ''
  formData.enabledBool = config.enabled
}

// 初始化
onMounted(() => {
  fetchConfig()
})
</script>

<style scoped lang="scss">
.sprint-container {
  padding: 20px;

  .preview-card {
    margin-bottom: 20px;

    .card-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    .preview-content {
      display: flex;
      align-items: center;
      gap: 40px;
      padding: 20px 0;

      .exam-info {
        h3 {
          font-size: 18px;
          margin-bottom: 8px;
          color: #303133;
        }

        .exam-date {
          color: #909399;
          font-size: 14px;
        }
      }

      .countdown-box {
        text-align: center;
        padding: 20px 30px;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        border-radius: 12px;
        color: #fff;

        .countdown-number {
          font-size: 48px;
          font-weight: bold;
          line-height: 1;
        }

        .countdown-label {
          font-size: 16px;
          margin-top: 8px;
        }
      }

      .expired-box {
        display: flex;
        align-items: center;
        gap: 8px;
        color: #f56c6c;
        font-size: 18px;
      }

      .disabled-tip {
        color: #909399;
        display: flex;
        align-items: center;
        gap: 8px;
      }
    }
  }

  .form-card {
    margin-bottom: 20px;
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