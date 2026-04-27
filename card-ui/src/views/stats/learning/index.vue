<template>
  <div class="learning-stats">
    <!-- 用户选择器 -->
    <el-card shadow="hover" class="user-selector-card">
      <div class="user-selector-row">
        <span class="selector-label">查看用户：</span>
        <el-select
          v-model="selectedUserId"
          filterable
          clearable
          placeholder="全部用户（全局统计）"
          style="width: 280px"
          @change="onUserChange"
        >
          <el-option
            v-for="u in userList"
            :key="u.userId"
            :label="u.nickname || '用户' + u.userId"
            :value="u.userId"
          />
        </el-select>
        <span v-if="selectedUserId" class="user-tag">
          <el-tag type="primary" closable @close="clearUser">当前查看：{{ selectedUserName }}</el-tag>
        </span>
      </div>
    </el-card>

    <!-- 顶部统计卡片 -->
    <el-row :gutter="20" class="stat-cards">
      <el-col :span="selectedUserId ? 8 : 6">
        <el-card shadow="hover">
          <div class="stat-card-item">
            <div class="stat-icon" style="background-color: #409eff">
              <el-icon :size="28"><User /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.learnDays }}</div>
              <div class="stat-label">学习天数</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="selectedUserId ? 8 : 6">
        <el-card shadow="hover">
          <div class="stat-card-item">
            <div class="stat-icon" style="background-color: #67c23a">
              <el-icon :size="28"><Document /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.masteredCount }}</div>
              <div class="stat-label">已掌握卡片</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="selectedUserId ? 8 : 6">
        <el-card shadow="hover">
          <div class="stat-card-item">
            <div class="stat-icon" style="background-color: #e6a23c">
              <el-icon :size="28"><TrendCharts /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.learnedRate }}%</div>
              <div class="stat-label">学习完成率</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col v-if="!selectedUserId" :span="6">
        <el-card shadow="hover">
          <div class="stat-card-item">
            <div class="stat-icon" style="background-color: #f56c6c">
              <el-icon :size="28"><DataLine /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.totalLearnRecords }}</div>
              <div class="stat-label">学习记录总数</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 第二行：趋势图 + 科目统计 -->
    <el-row :gutter="20" class="chart-row">
      <el-col :span="14">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>每日学习趋势（近30天）</span>
            </div>
          </template>
          <div ref="trendChartRef" class="chart-container"></div>
        </el-card>
      </el-col>
      <el-col :span="10">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>科目学习进度</span>
            </div>
          </template>
          <div ref="subjectChartRef" class="chart-container"></div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 第三行：用户排行 + 状态分布 -->
    <el-row :gutter="20" class="chart-row">
      <el-col :span="selectedUserId ? 24 : 14">
        <el-card v-if="!selectedUserId" shadow="hover">
          <template #header>
            <div class="card-header">
              <span>用户学习排行榜（TOP 10）</span>
            </div>
          </template>
          <el-table :data="userRanking" stripe style="width: 100%">
            <el-table-column type="index" label="排名" width="70" align="center">
              <template #default="{ $index }">
                <span class="rank-badge" :class="{ 'top-3': $index < 3 }">{{ $index + 1 }}</span>
              </template>
            </el-table-column>
            <el-table-column label="用户" min-width="150">
              <template #default="{ row }">
                <div class="user-cell">
                  <el-avatar :size="28" :src="row.avatar || ''">
                    <el-icon><UserFilled /></el-icon>
                  </el-avatar>
                  <span>{{ row.nickname }}</span>
                </div>
              </template>
            </el-table-column>
            <el-table-column prop="totalCards" label="学习卡片" align="center" />
            <el-table-column prop="masteredCount" label="已掌握" align="center">
              <template #default="{ row }">
                <el-tag type="success" size="small">{{ row.masteredCount }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="fuzzyCount" label="模糊" align="center">
              <template #default="{ row }">
                <el-tag type="warning" size="small">{{ row.fuzzyCount }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="掌握率" align="center" width="100">
              <template #default="{ row }">
                <span>{{ row.totalCards > 0 ? ((row.masteredCount / row.totalCards) * 100).toFixed(0) : 0 }}%</span>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
      <el-col :span="selectedUserId ? 24 : 10">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>学习状态分布</span>
            </div>
          </template>
          <div ref="pieChartRef" class="chart-container"></div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted, onUnmounted, nextTick } from 'vue'
import * as echarts from 'echarts'
import { getLearningStats, getLearnTrend, getUserRanking, getSubjectStats, getUserList } from '@/api/content'
import type { LearningStats, DailyLearnTrend, UserLearnRank, SubjectLearnStats, SysUser } from '@/api/types'

const stats = reactive<LearningStats>({
  totalCards: 0,
  learnDays: 0,
  totalLearnRecords: 0,
  unlearnedCount: 0,
  fuzzyCount: 0,
  masteredCount: 0,
  learnedRate: 0
})

const trendData = ref<DailyLearnTrend[]>([])
const userRanking = ref<UserLearnRank[]>([])
const subjectData = ref<SubjectLearnStats[]>([])

// 用户选择
const userList = ref<SysUser[]>([])
const selectedUserId = ref<number | undefined>(undefined)

const selectedUserName = computed(() => {
  if (!selectedUserId.value) return ''
  const user = userList.value.find(u => u.userId === selectedUserId.value)
  return user?.nickname || `用户${selectedUserId.value}`
})

const trendChartRef = ref<HTMLDivElement>()
const subjectChartRef = ref<HTMLDivElement>()
const pieChartRef = ref<HTMLDivElement>()

let trendChart: echarts.ECharts | null = null
let subjectChart: echarts.ECharts | null = null
let pieChart: echarts.ECharts | null = null

const fetchUsers = async () => {
  try {
    userList.value = await getUserList()
  } catch (e) {
    console.error('获取用户列表失败', e)
  }
}

const fetchStats = async () => {
  try {
    const res = await getLearningStats(selectedUserId.value)
    Object.assign(stats, res.data)
  } catch (e) {
    console.error('获取学习统计失败', e)
  }
}

const fetchTrend = async () => {
  try {
    const res = await getLearnTrend(30, selectedUserId.value)
    trendData.value = res.data
    renderTrendChart()
  } catch (e) {
    console.error('获取趋势数据失败', e)
  }
}

const fetchUserRanking = async () => {
  try {
    const res = await getUserRanking(10)
    userRanking.value = res.data
  } catch (e) {
    console.error('获取用户排行失败', e)
  }
}

const fetchSubjectStats = async () => {
  try {
    const res = await getSubjectStats(selectedUserId.value)
    subjectData.value = res.data
    renderSubjectChart()
    renderPieChart()
  } catch (e) {
    console.error('获取科目统计失败', e)
  }
}

const onUserChange = async () => {
  await fetchStats()
  await nextTick()
  fetchTrend()
  fetchSubjectStats()
}

const clearUser = () => {
  selectedUserId.value = undefined
  onUserChange()
}

const renderTrendChart = () => {
  if (!trendChartRef.value || trendData.value.length === 0) return
  if (!trendChart) {
    trendChart = echarts.init(trendChartRef.value)
  }
  trendChart.setOption({
    tooltip: { trigger: 'axis' },
    grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
    xAxis: {
      type: 'category',
      data: trendData.value.map(d => d.date),
      axisLabel: { rotate: 45, fontSize: 11 }
    },
    yAxis: { type: 'value', name: '学习记录数' },
    series: [{
      name: '学习记录',
      type: 'line',
      smooth: true,
      data: trendData.value.map(d => d.count),
      areaStyle: { opacity: 0.3 },
      itemStyle: { color: '#409eff' }
    }]
  })
}

const renderSubjectChart = () => {
  if (!subjectChartRef.value || subjectData.value.length === 0) return
  if (!subjectChart) {
    subjectChart = echarts.init(subjectChartRef.value)
  }
  subjectChart.setOption({
    tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
    legend: { data: ['未学', '模糊', '掌握'], bottom: 0 },
    grid: { left: '3%', right: '4%', bottom: '15%', containLabel: true },
    xAxis: {
      type: 'category',
      data: subjectData.value.map(d => d.subjectName),
      axisLabel: { rotate: 30, fontSize: 11 }
    },
    yAxis: { type: 'value', name: '卡片数' },
    series: [
      { name: '未学', type: 'bar', stack: 'total', data: subjectData.value.map(d => d.unlearnedCount), itemStyle: { color: '#909399' } },
      { name: '模糊', type: 'bar', stack: 'total', data: subjectData.value.map(d => d.fuzzyCount), itemStyle: { color: '#e6a23c' } },
      { name: '掌握', type: 'bar', stack: 'total', data: subjectData.value.map(d => d.masteredCount), itemStyle: { color: '#67c23a' } }
    ]
  })
}

const renderPieChart = () => {
  if (!pieChartRef.value) return
  if (!pieChart) {
    pieChart = echarts.init(pieChartRef.value)
  }
  pieChart.setOption({
    tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
    legend: { bottom: 0 },
    series: [{
      type: 'pie',
      radius: ['40%', '65%'],
      center: ['50%', '45%'],
      avoidLabelOverlap: false,
      label: { show: true, formatter: '{b}\n{d}%' },
      data: [
        { value: stats.unlearnedCount, name: '未学', itemStyle: { color: '#909399' } },
        { value: stats.fuzzyCount, name: '模糊', itemStyle: { color: '#e6a23c' } },
        { value: stats.masteredCount, name: '掌握', itemStyle: { color: '#67c23a' } }
      ]
    }]
  })
}

const handleResize = () => {
  trendChart?.resize()
  subjectChart?.resize()
  pieChart?.resize()
}

onMounted(async () => {
  fetchUsers()
  await fetchStats()
  await nextTick()
  fetchTrend()
  fetchUserRanking()
  fetchSubjectStats()
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
  trendChart?.dispose()
  subjectChart?.dispose()
  pieChart?.dispose()
})
</script>

<style scoped lang="scss">
.learning-stats {
  .user-selector-card {
    margin-bottom: 20px;

    .user-selector-row {
      display: flex;
      align-items: center;
      gap: 12px;
    }

    .selector-label {
      font-size: 14px;
      font-weight: bold;
      color: #303133;
      white-space: nowrap;
    }

    .user-tag {
      margin-left: 8px;
    }
  }

  .stat-cards {
    margin-bottom: 20px;
  }

  .stat-card-item {
    display: flex;
    align-items: center;
    gap: 16px;
    padding: 8px 0;
  }

  .stat-icon {
    width: 56px;
    height: 56px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #fff;
  }

  .stat-info {
    .stat-value {
      font-size: 28px;
      font-weight: bold;
      color: #303133;
      line-height: 1.2;
    }
    .stat-label {
      font-size: 13px;
      color: #909399;
      margin-top: 4px;
    }
  }

  .chart-row {
    margin-bottom: 20px;
  }

  .card-header {
    font-weight: bold;
    font-size: 15px;
  }

  .chart-container {
    height: 320px;
    width: 100%;
  }

  .user-cell {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .rank-badge {
    display: inline-block;
    width: 24px;
    height: 24px;
    line-height: 24px;
    text-align: center;
    border-radius: 50%;
    font-size: 13px;
    font-weight: bold;
    background-color: #f0f0f0;
    color: #606266;

    &.top-3 {
      background-color: #409eff;
      color: #fff;
    }
  }
}
</style>
