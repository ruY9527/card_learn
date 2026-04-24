<template>
  <div class="dashboard">
    <el-row :gutter="20">
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-card">
            <el-icon :size="40" color="#409eff"><Folder /></el-icon>
            <div class="stat-info">
              <span class="stat-value">{{ stats.majorCount || '--' }}</span>
              <span class="stat-label">专业总数</span>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-card">
            <el-icon :size="40" color="#67c23a"><Document /></el-icon>
            <div class="stat-info">
              <span class="stat-value">{{ stats.subjectCount || '--' }}</span>
              <span class="stat-label">科目总数</span>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-card">
            <el-icon :size="40" color="#e6a23c"><Tickets /></el-icon>
            <div class="stat-info">
              <span class="stat-value">{{ stats.cardCount || '--' }}</span>
              <span class="stat-label">卡片总数</span>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-card">
            <el-icon :size="40" color="#f56c6c"><PriceTag /></el-icon>
            <div class="stat-info">
              <span class="stat-value">{{ stats.tagCount || '--' }}</span>
              <span class="stat-label">标签总数</span>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
    <el-card class="welcome-card" style="margin-top: 20px">
      <h3>欢迎使用考研知识点学习卡片管理系统</h3>
      <p>系统功能：</p>
      <ul>
        <li>专业管理：管理考研专业分类</li>
        <li>科目管理：管理各专业下的考试科目</li>
        <li>卡片管理：管理知识点卡片，支持Markdown/LaTeX格式</li>
        <li>标签管理：管理知识点标签分类</li>
      </ul>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import request from '@/api/request'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/store/user'
import { ref } from 'vue'

const stats = ref({
  majorCount: 0,
  subjectCount: 0,
  cardCount: 0,
  tagCount: 0
})
const loading = ref(true)
const userStore = useUserStore()

const fetchStats = async () => {
  try {
    const res = await request.get('/dashboard/stats')
    stats.value = res.data
    loading.value = false
  } catch (error) {
    console.error(error)
    ElMessage.error('获取统计数据失败')
  }
}

onMounted(() => {
  fetchStats()
})
</script>

<style scoped lang="scss">
.dashboard {
  .stat-card {
    display: flex;
    align-items: center;
    gap: 16px;

    .stat-info {
      .stat-value {
        font-size: 24px;
        font-weight: bold;
      }

      .stat-label {
        color: #999;
        font-size: 14px;
      }
    }
  }

  .welcome-card {
    h3 {
      margin-bottom: 16px;
    }

    ul {
      padding-left: 20px;
      li {
        margin: 8px 0;
      }
    }
  }
}
</style>