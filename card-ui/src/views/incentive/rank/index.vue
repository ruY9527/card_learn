<template>
  <div class="rank-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>排行榜</span>
          <el-radio-group v-model="selectedTab" @change="fetchData">
            <el-radio-button value="total">总榜</el-radio-button>
            <el-radio-button value="week">周榜</el-radio-button>
            <el-radio-button value="streak">连击榜</el-radio-button>
          </el-radio-group>
        </div>
      </template>

      <el-table :data="rankData" border stripe v-loading="loading">
        <el-table-column label="排名" width="80">
          <template #default="{ row }">
            <el-tag :type="row.rank <= 3 ? 'warning' : 'info'" effect="dark" round>
              {{ row.rank }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="nickname" label="用户" width="150" />
        <el-table-column prop="level" label="等级" width="80" />
        <el-table-column label="等级名称" width="120">
          <template #default="{ row }">
            {{ row.levelName || '-' }}
          </template>
        </el-table-column>
        <el-table-column :label="metricLabel">
          <template #default="{ row }">
            <span class="metric-value">
              {{ selectedTab === 'total' ? row.totalExp : selectedTab === 'week' ? row.weekLearnCount : row.currentStreak }}
            </span>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        v-model:current-page="pageNum"
        v-model:page-size="pageSize"
        :total="total"
        layout="total, prev, pager, next"
        style="margin-top: 16px; justify-content: flex-end"
        @current-change="fetchData"
      />
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { getTotalRank, getWeekRank, getStreakRank } from '@/api/incentive'
import type { RankItem } from '@/api/types'

const selectedTab = ref('total')
const loading = ref(false)
const rankData = ref<RankItem[]>([])
const pageNum = ref(1)
const pageSize = ref(20)
const total = ref(0)

const metricLabel = computed(() => {
  switch (selectedTab.value) {
    case 'total': return '总经验'
    case 'week': return '本周学习数'
    case 'streak': return '连续天数'
    default: return ''
  }
})

const fetchData = async () => {
  loading.value = true
  try {
    const params = { pageNum: pageNum.value, pageSize: pageSize.value }
    let res
    if (selectedTab.value === 'total') {
      res = await getTotalRank(params)
    } else if (selectedTab.value === 'week') {
      res = await getWeekRank(params)
    } else {
      res = await getStreakRank(params)
    }
    rankData.value = res.data?.records || []
    total.value = res.data?.total || 0
  } catch (e) {
    console.error('获取排行榜失败:', e)
  } finally {
    loading.value = false
  }
}

onMounted(() => fetchData())
</script>

<style scoped lang="scss">
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.metric-value {
  font-size: 16px;
  font-weight: bold;
  color: #409eff;
}
</style>
