<template>
  <div class="heatmap-page">
    <!-- 顶部导航 -->
    <header class="heatmap-nav">
      <div class="nav-inner">
        <div class="nav-left">
          <el-button text class="back-btn" @click="$router.push('/learn')">
            <el-icon><ArrowLeft /></el-icon>
            <span>返回</span>
          </el-button>
          <h1 class="page-title">学习天数</h1>
        </div>
      </div>
    </header>

    <!-- 统计摘要 -->
    <section class="summary-section">
      <div class="summary-grid">
        <div class="summary-card">
          <div class="summary-value">{{ yearDays }}</div>
          <div class="summary-label">学习天数</div>
        </div>
        <div class="summary-card">
          <div class="summary-value">{{ totalCount }}</div>
          <div class="summary-label">总学习次数</div>
        </div>
        <div class="summary-card">
          <div class="summary-value">{{ maxDaily }}</div>
          <div class="summary-label">单日最高</div>
        </div>
        <div class="summary-card">
          <div class="summary-value">{{ streakDays }}</div>
          <div class="summary-label">连续天数</div>
        </div>
      </div>
    </section>

    <!-- 热力图 -->
    <section class="chart-section">
      <div class="chart-container" ref="chartRef"></div>
    </section>

    <!-- 日期详情抽屉 -->
    <el-drawer
      v-model="drawerVisible"
      :title="drawerTitle"
      direction="btt"
      size="60%"
    >
      <div class="drawer-content" v-if="dayDetail">
        <!-- 当日统计 -->
        <div class="day-stats">
          <div class="day-stat-item">
            <span class="day-stat-value">{{ dayDetail.totalCount }}</span>
            <span class="day-stat-label">总学习次数</span>
          </div>
          <div class="day-stat-item mastered">
            <span class="day-stat-value">{{ dayDetail.masteredCount }}</span>
            <span class="day-stat-label">掌握</span>
          </div>
          <div class="day-stat-item fuzzy">
            <span class="day-stat-value">{{ dayDetail.fuzzyCount }}</span>
            <span class="day-stat-label">模糊</span>
          </div>
          <div class="day-stat-item again">
            <span class="day-stat-value">{{ dayDetail.againCount }}</span>
            <span class="day-stat-label">不熟</span>
          </div>
        </div>

        <!-- 卡片列表 -->
        <div class="day-cards" v-if="dayDetail.cards && dayDetail.cards.length > 0">
          <div
            v-for="(card, idx) in dayDetail.cards"
            :key="idx"
            class="day-card-item"
          >
            <div class="day-card-top">
              <span class="day-card-subject">{{ card.subjectName }}</span>
              <span class="day-card-time">{{ card.studyTime }}</span>
            </div>
            <div class="day-card-content">{{ card.frontContent }}</div>
            <div class="day-card-bottom">
              <span
                class="day-card-status"
                :class="`status-${card.status}`"
              >
                {{ card.status === 2 ? '✓ 掌握' : card.status === 1 ? '~ 模糊' : '✗ 不熟' }}
              </span>
              <span v-if="card.source" class="day-card-source">{{ sourceLabel(card.source) }}</span>
            </div>
          </div>
        </div>
        <div class="empty-hint" v-else>
          <p>当日暂无学习记录</p>
        </div>
      </div>
      <div class="drawer-loading" v-else-if="dayLoading">
        <div class="loading-spinner"></div>
        <p>加载中...</p>
      </div>
    </el-drawer>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, nextTick } from 'vue'
import { ArrowLeft } from '@element-plus/icons-vue'
import * as echarts from 'echarts'
import { getLearnTrend } from '@/api/content'
import { getDayLearnDetail } from '@/api/learn'
import { useUserStore } from '@/store/user'

const userStore = useUserStore()
const chartRef = ref<HTMLElement | null>(null)
let chart: echarts.ECharts | null = null

const trendData = ref<{ date: string; count: number }[]>([])
const drawerVisible = ref(false)
const drawerTitle = ref('')
const dayDetail = ref<any>(null)
const dayLoading = ref(false)

// 计算统计摘要
const yearDays = computed(() => trendData.value.filter(d => d.count > 0).length)
const totalCount = computed(() => trendData.value.reduce((sum, d) => sum + d.count, 0))
const maxDaily = computed(() => {
  if (trendData.value.length === 0) return 0
  return Math.max(...trendData.value.map(d => d.count))
})
const streakDays = computed(() => {
  // 计算当前连续学习天数（从今天往回数）
  const dateSet = new Set(trendData.value.filter(d => d.count > 0).map(d => d.date))
  let streak = 0
  const today = new Date()
  for (let i = 0; i < 400; i++) {
    const d = new Date(today)
    d.setDate(d.getDate() - i)
    const dateStr = d.toISOString().slice(0, 10)
    if (dateSet.has(dateStr)) {
      streak++
    } else {
      break
    }
  }
  return streak
})

const sourceLabel = (source: string) => {
  const map: Record<string, string> = { web: '网页端', ios: 'iOS', mini: '小程序' }
  return map[source] || source
}

const handleResize = () => {
  chart?.resize()
}

const initChart = () => {
  if (!chartRef.value) return

  chart = echarts.init(chartRef.value)

  // 构建近12个月的日期范围
  const endDate = new Date()
  const startDate = new Date()
  startDate.setFullYear(startDate.getFullYear() - 1)
  startDate.setDate(startDate.getDate() + 1)

  const startStr = startDate.toISOString().slice(0, 10)
  const endStr = endDate.toISOString().slice(0, 10)

  // 构建数据映射
  const dataMap = new Map<string, number>()
  trendData.value.forEach(d => {
    dataMap.set(d.date, d.count)
  })

  // 生成完整日期范围的数据
  const heatData: [string, number][] = []
  const current = new Date(startDate)
  while (current <= endDate) {
    const dateStr = current.toISOString().slice(0, 10)
    heatData.push([dateStr, dataMap.get(dateStr) || 0])
    current.setDate(current.getDate() + 1)
  }

  // 计算 visualMap 的 max
  const maxVal = Math.max(...heatData.map(d => d[1]), 1)

  const option: echarts.EChartsOption = {
    tooltip: {
      formatter: (params: any) => {
        const [date, count] = params.data
        return `<div style="font-weight:600">${date}</div><div>${count} 次学习</div>`
      }
    },
    visualMap: {
      min: 0,
      max: maxVal,
      type: 'piecewise',
      orient: 'horizontal',
      left: 'center',
      bottom: 0,
      pieces: [
        { min: 0, max: 0, label: '0', color: '#ebedf0' },
        { min: 1, max: 3, label: '1-3', color: '#9be9a8' },
        { min: 4, max: 9, label: '4-9', color: '#40c463' },
        { min: 10, max: 19, label: '10-19', color: '#30a14e' },
        { min: 20, label: '20+', color: '#216e39' }
      ],
      textStyle: { color: '#666' }
    },
    calendar: {
      range: [startStr, endStr],
      cellSize: ['auto', 16],
      left: 40,
      right: 20,
      top: 20,
      bottom: 40,
      yearLabel: { show: false },
      monthLabel: {
        nameMap: 'ZH',
        color: '#666',
        fontSize: 12
      },
      dayLabel: {
        nameMap: 'ZH',
        color: '#999',
        fontSize: 11
      },
      itemStyle: {
        borderWidth: 3,
        borderColor: '#fff'
      },
      splitLine: { show: false }
    },
    series: [{
      type: 'heatmap',
      coordinateSystem: 'calendar',
      data: heatData,
      emphasis: {
        itemStyle: {
          borderColor: '#667eea',
          borderWidth: 1
        }
      }
    }]
  }

  chart.setOption(option)

  // 点击事件
  chart.on('click', (params: any) => {
    if (params.data) {
      const [date, count] = params.data
      if (count > 0) {
        openDayDetail(date)
      }
    }
  })
}

const openDayDetail = async (date: string) => {
  drawerTitle.value = `${date} 学习详情`
  drawerVisible.value = true
  dayDetail.value = null
  dayLoading.value = true

  try {
    const userId = userStore.userInfo?.userId
    const res = await getDayLearnDetail(date, userId)
    dayDetail.value = res.data
  } catch {
    dayDetail.value = { date, totalCount: 0, masteredCount: 0, fuzzyCount: 0, againCount: 0, cards: [] }
  } finally {
    dayLoading.value = false
  }
}

onMounted(async () => {
  try {
    const userId = userStore.userInfo?.userId
    const res = await getLearnTrend(365, userId)
    trendData.value = res.data || []
  } catch {
    trendData.value = []
  }

  await nextTick()
  initChart()
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  chart?.dispose()
  window.removeEventListener('resize', handleResize)
})
</script>

<style scoped lang="scss">
.heatmap-page {
  min-height: 100vh;
  background: #f5f7fb;
}

// ========== 顶部导航 ==========
.heatmap-nav {
  background: #fff;
  border-bottom: 1px solid #f0f0f0;
  position: sticky;
  top: 0;
  z-index: 50;
}

.nav-inner {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 32px;
  height: 64px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.nav-left {
  display: flex;
  align-items: center;
  gap: 16px;
}

.back-btn {
  color: #666;
  font-size: 14px;
  display: flex;
  align-items: center;
  gap: 4px;

  &:hover {
    color: #667eea;
  }
}

.page-title {
  font-size: 18px;
  font-weight: 600;
  color: #1a1a2e;
  margin: 0;
}

// ========== 统计摘要 ==========
.summary-section {
  max-width: 800px;
  margin: 0 auto;
  padding: 24px 32px 0;
}

.summary-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
}

.summary-card {
  background: #fff;
  border-radius: 16px;
  padding: 20px;
  text-align: center;
  border: 1px solid #f0f0f0;

  .summary-value {
    font-size: 32px;
    font-weight: 800;
    color: #1a1a2e;
    line-height: 1;
  }

  .summary-label {
    font-size: 13px;
    color: #999;
    margin-top: 8px;
  }
}

// ========== 热力图 ==========
.chart-section {
  max-width: 800px;
  margin: 0 auto;
  padding: 24px 32px;
}

.chart-container {
  background: #fff;
  border-radius: 20px;
  border: 1px solid #f0f0f0;
  width: 100%;
  height: 220px;
}

// ========== 抽屉内容 ==========
.drawer-content {
  padding: 0 4px;
}

.day-stats {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
  margin-bottom: 24px;
}

.day-stat-item {
  background: #f8f9fd;
  border-radius: 12px;
  padding: 16px;
  text-align: center;

  .day-stat-value {
    display: block;
    font-size: 24px;
    font-weight: 700;
    color: #1a1a2e;
  }

  .day-stat-label {
    display: block;
    font-size: 12px;
    color: #999;
    margin-top: 4px;
  }

  &.mastered .day-stat-value { color: #67c23a; }
  &.fuzzy .day-stat-value { color: #e6a23c; }
  &.again .day-stat-value { color: #f56c6c; }
}

.day-cards {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.day-card-item {
  background: #fff;
  border: 1px solid #f0f0f0;
  border-radius: 14px;
  padding: 16px;
}

.day-card-top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 10px;
}

.day-card-subject {
  font-size: 12px;
  font-weight: 600;
  color: #667eea;
  background: linear-gradient(135deg, #667eea15, #764ba215);
  padding: 3px 10px;
  border-radius: 8px;
}

.day-card-time {
  font-size: 12px;
  color: #bbb;
}

.day-card-content {
  font-size: 14px;
  color: #333;
  line-height: 1.6;
  margin-bottom: 10px;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.day-card-bottom {
  display: flex;
  align-items: center;
  gap: 10px;
}

.day-card-status {
  font-size: 11px;
  font-weight: 600;
  padding: 2px 8px;
  border-radius: 6px;

  &.status-0 { color: #9e9e9e; background: #9e9e9e15; }
  &.status-1 { color: #e6a23c; background: #e6a23c15; }
  &.status-2 { color: #67c23a; background: #67c23a15; }
}

.day-card-source {
  font-size: 11px;
  color: #bbb;
}

.empty-hint {
  text-align: center;
  padding: 40px 0;
  color: #999;
}

.drawer-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 0;

  p {
    font-size: 14px;
    color: #999;
    margin-top: 16px;
  }
}

.loading-spinner {
  width: 36px;
  height: 36px;
  border: 3px solid #f0f0f0;
  border-top-color: #667eea;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

// ========== 响应式 ==========
@media (max-width: 640px) {
  .summary-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .chart-container {
    height: 200px;
  }

  .day-stats {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>
