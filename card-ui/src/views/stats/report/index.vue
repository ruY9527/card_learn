<template>
  <div class="report-container">
    <el-card class="report-card">
      <template #header>
        <div class="card-header">
          <span>学习报告</span>
          <div class="header-actions">
            <el-radio-group v-model="reportType" @change="loadReport">
              <el-radio-button value="weekly">周报</el-radio-button>
              <el-radio-button value="monthly">月报</el-radio-button>
            </el-radio-group>
          </div>
        </div>
      </template>

      <div v-if="loading" class="loading-container">
        <el-icon class="is-loading" :size="32"><Loading /></el-icon>
        <p>加载中...</p>
      </div>

      <div v-else-if="report" class="report-content">
        <!-- 报告头部 -->
        <div class="report-header">
          <h2>{{ report.reportType === 'weekly' ? '学习周报' : '学习月报' }}</h2>
          <p class="period">{{ report.periodStart }} ~ {{ report.periodEnd }}</p>
        </div>

        <!-- 学习概览 -->
        <el-row :gutter="16" class="overview-row">
          <el-col :span="6">
            <el-statistic title="学习卡片" :value="report.overview.totalCards">
              <template #prefix><el-icon><Document /></el-icon></template>
            </el-statistic>
          </el-col>
          <el-col :span="6">
            <el-statistic title="新掌握" :value="report.overview.newMastered">
              <template #prefix><el-icon><CircleCheck /></el-icon></template>
            </el-statistic>
          </el-col>
          <el-col :span="6">
            <el-statistic title="遗忘" :value="report.overview.forgotten">
              <template #prefix><el-icon><Warning /></el-icon></template>
            </el-statistic>
          </el-col>
          <el-col :span="6">
            <el-statistic title="连续天数" :value="report.overview.streakDays">
              <template #prefix><el-icon><Trophy /></el-icon></template>
            </el-statistic>
          </el-col>
        </el-row>

        <!-- 掌握率趋势 -->
        <div v-if="report.masteryTrend" class="section">
          <h3>掌握率趋势</h3>
          <el-row :gutter="20" align="middle">
            <el-col :span="8">
              <div class="trend-item">
                <span class="trend-label">期初</span>
                <span class="trend-value">{{ report.masteryTrend.startRate }}%</span>
              </div>
            </el-col>
            <el-col :span="4" style="text-align: center">
              <el-icon :size="24"><ArrowRight /></el-icon>
            </el-col>
            <el-col :span="8">
              <div class="trend-item">
                <span class="trend-label">期末</span>
                <span class="trend-value success">{{ report.masteryTrend.endRate }}%</span>
              </div>
            </el-col>
            <el-col :span="4">
              <div class="trend-item">
                <span class="trend-label">变化</span>
                <span :class="['trend-value', report.masteryTrend.changeRate >= 0 ? 'success' : 'danger']">
                  {{ report.masteryTrend.changeRate >= 0 ? '+' : '' }}{{ report.masteryTrend.changeRate }}%
                </span>
              </div>
            </el-col>
          </el-row>
        </div>

        <!-- 科目分析 -->
        <div v-if="report.subjectAnalysis?.length" class="section">
          <h3>科目进度</h3>
          <el-table :data="report.subjectAnalysis" stripe>
            <el-table-column prop="subjectName" label="科目" width="150" />
            <el-table-column prop="totalCards" label="总卡片" width="100" align="center" />
            <el-table-column prop="mastered" label="已掌握" width="100" align="center" />
            <el-table-column label="掌握率" align="center">
              <template #default="{ row }">
                <el-progress
                  :percentage="row.masteryRate"
                  :color="row.masteryRate < 40 ? '#FF6B6B' : '#667eea'"
                  :stroke-width="8"
                />
              </template>
            </el-table-column>
          </el-table>
        </div>

        <!-- 学习习惯 -->
        <div v-if="report.learningHabits" class="section">
          <h3>学习习惯</h3>
          <el-row :gutter="16">
            <el-col :span="8">
              <el-card shadow="never">
                <div class="habit-item">
                  <span class="habit-label">上午</span>
                  <el-progress :percentage="report.learningHabits.morning" :stroke-width="10" color="#FFD700" />
                </div>
              </el-card>
            </el-col>
            <el-col :span="8">
              <el-card shadow="never">
                <div class="habit-item">
                  <span class="habit-label">下午</span>
                  <el-progress :percentage="report.learningHabits.afternoon" :stroke-width="10" color="#667eea" />
                </div>
              </el-card>
            </el-col>
            <el-col :span="8">
              <el-card shadow="never">
                <div class="habit-item">
                  <span class="habit-label">晚上</span>
                  <el-progress :percentage="report.learningHabits.evening" :stroke-width="10" color="#9C27B0" />
                </div>
              </el-card>
            </el-col>
          </el-row>
          <div class="habit-info">
            <p>高峰时段: {{ report.learningHabits.peakHour }}</p>
            <p>最活跃学习日: {{ report.learningHabits.mostActiveDay }}</p>
            <p>平均每日学习: {{ report.learningHabits.avgDailyDuration }}分钟</p>
          </div>
        </div>

        <!-- 薄弱点 -->
        <div v-if="report.weakPoints?.length" class="section">
          <h3>薄弱点预警</h3>
          <el-table :data="report.weakPoints" stripe>
            <el-table-column prop="subjectName" label="科目" width="120" />
            <el-table-column prop="frontContent" label="卡片内容" show-overflow-tooltip />
            <el-table-column prop="errorCount" label="错误次数" width="100" align="center">
              <template #default="{ row }">
                <el-tag :type="row.errorCount >= 3 ? 'danger' : 'warning'">
                  {{ row.errorCount }}次
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="lastErrorTime" label="最后错误" width="160" />
          </el-table>
        </div>

        <!-- 改进建议 -->
        <div v-if="report.suggestions?.length" class="section">
          <h3>改进建议</h3>
          <el-timeline>
            <el-timeline-item
              v-for="(suggestion, index) in report.suggestions"
              :key="index"
              :type="suggestion.priority === 'high' ? 'danger' : suggestion.priority === 'medium' ? 'warning' : 'info'"
              :hollow="suggestion.priority !== 'high'"
            >
              {{ suggestion.content }}
              <el-tag v-if="suggestion.priority === 'high'" type="danger" size="small" style="margin-left: 8px">
                重要
              </el-tag>
            </el-timeline-item>
          </el-timeline>
        </div>
      </div>

      <el-empty v-else description="暂无报告数据" />
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { Loading, Document, CircleCheck, Warning, Trophy, ArrowRight } from '@element-plus/icons-vue'
import { getCurrentReport, type ReportDetail } from '@/api/report'

const reportType = ref('weekly')
const loading = ref(false)
const report = ref<ReportDetail | null>(null)

const loadReport = async () => {
  loading.value = true
  try {
    const res = await getCurrentReport(reportType.value)
    report.value = res.data || null
  } catch (error) {
    console.error('Failed to load report:', error)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadReport()
})
</script>

<style scoped>
.report-container {
  padding: 20px;
}

.report-card {
  max-width: 1200px;
  margin: 0 auto;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 80px 0;
  color: var(--el-text-color-secondary);
}

.report-header {
  text-align: center;
  margin-bottom: 30px;
}

.report-header h2 {
  font-size: 24px;
  margin-bottom: 8px;
}

.report-header .period {
  color: var(--el-text-color-secondary);
}

.overview-row {
  margin-bottom: 30px;
}

.section {
  margin-bottom: 30px;
  padding-top: 20px;
  border-top: 1px solid var(--el-border-color-lighter);
}

.section h3 {
  margin-bottom: 16px;
  font-size: 18px;
}

.trend-item {
  text-align: center;
}

.trend-label {
  display: block;
  font-size: 14px;
  color: var(--el-text-color-secondary);
  margin-bottom: 4px;
}

.trend-value {
  font-size: 24px;
  font-weight: bold;
}

.trend-value.success {
  color: var(--el-color-success);
}

.trend-value.danger {
  color: var(--el-color-danger);
}

.habit-item {
  text-align: center;
}

.habit-label {
  display: block;
  margin-bottom: 8px;
  font-size: 14px;
  color: var(--el-text-color-secondary);
}

.habit-info {
  margin-top: 16px;
  padding: 12px;
  background: var(--el-fill-color-lighter);
  border-radius: 4px;
}

.habit-info p {
  margin: 4px 0;
  font-size: 14px;
  color: var(--el-text-color-regular);
}
</style>
