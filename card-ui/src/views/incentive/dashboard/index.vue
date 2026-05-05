<template>
  <div class="incentive-dashboard">
    <el-row :gutter="20" class="stat-cards">
      <el-col :span="8">
        <el-card shadow="hover">
          <div class="stat-item">
            <div class="stat-icon" style="background: #e6f7ff">
              <el-icon size="28" color="#1890ff"><Trophy /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.totalAchievements }}</div>
              <div class="stat-label">成就总数</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="hover">
          <div class="stat-item">
            <div class="stat-icon" style="background: #fff7e6">
              <el-icon size="28" color="#fa8c16"><Trophy /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ rankData.length }}</div>
              <div class="stat-label">上榜用户</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="hover">
          <div class="stat-item">
            <div class="stat-icon" style="background: #f6ffed">
              <el-icon size="28" color="#52c41a"><DataAnalysis /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ selectedTab === 'total' ? '总榜' : selectedTab === 'week' ? '周榜' : '连击榜' }}</div>
              <div class="stat-label">当前排行榜</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" style="margin-top: 20px">
      <el-col :span="16">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>排行榜 TOP 10</span>
              <el-radio-group v-model="selectedTab" size="small" @change="fetchRank">
                <el-radio-button value="total">总榜</el-radio-button>
                <el-radio-button value="week">周榜</el-radio-button>
                <el-radio-button value="streak">连击榜</el-radio-button>
              </el-radio-group>
            </div>
          </template>
          <el-table :data="rankData" stripe v-loading="loading">
            <el-table-column label="排名" width="80">
              <template #default="{ row }">
                <el-tag :type="row.rank <= 3 ? 'warning' : 'info'" effect="dark" round>
                  {{ row.rank }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="nickname" label="用户" />
            <el-table-column prop="level" label="等级" width="80" />
            <el-table-column :label="selectedTab === 'total' ? '经验' : selectedTab === 'week' ? '学习数' : '连续天数'">
              <template #default="{ row }">
                {{ selectedTab === 'total' ? row.totalExp : selectedTab === 'week' ? row.weekLearnCount : row.currentStreak }}
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card>
          <template #header>
            <span>成就概览</span>
          </template>
          <div v-loading="achievementLoading">
            <div class="achievement-stat">
              <span>成就总数</span>
              <span class="value">{{ achievementStats.totalAchievements }}</span>
            </div>
            <el-divider />
            <div class="achievement-list">
              <div v-for="item in achievements.slice(0, 8)" :key="item.achievementId" class="achievement-item">
                <div class="ach-icon" :style="{ background: tierBg(item.tier) }">
                  <el-icon :size="14" :color="tierColor(item.tier)">
                    <component :is="iconMap[item.icon] || 'Star'" />
                  </el-icon>
                </div>
                <span class="name">{{ item.name }}</span>
                <el-tag :type="tierType(item.tier)" size="small" class="tier-tag">{{ tierName(item.tier) }}</el-tag>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import {
  DataAnalysis, Reading, Star, StarFilled, RefreshRight, ChatDotRound,
  Trophy, TrophyBase, Medal, GoldMedal, Lightning, Suitcase, Flag, Mouse, Edit, DataLine
} from '@element-plus/icons-vue'
import { getTotalRank, getWeekRank, getStreakRank, getAchievementList, getAchievementStats } from '@/api/incentive'
import type { Achievement, RankItem } from '@/api/types'

const selectedTab = ref('total')
const loading = ref(false)
const achievementLoading = ref(false)
const rankData = ref<RankItem[]>([])
const achievements = ref<Achievement[]>([])
const stats = ref({ totalAchievements: 0 })
const achievementStats = ref({ totalAchievements: 0 })

// SF Symbol → Element Plus icon 映射
const iconMap: Record<string, any> = {
  'book.fill': Reading, 'book': Reading,
  'star.fill': StarFilled, 'star': Star,
  'arrow.clockwise': RefreshRight,
  'bubble.left.fill': ChatDotRound, 'bubble.left': ChatDotRound,
  'flame': Lightning, 'flame.fill': Lightning,
  'bolt.fill': Lightning, 'bolt': Lightning, 'flame.circle.fill': Lightning,
  'crown.fill': GoldMedal, 'crown': GoldMedal, 'crown.circle.fill': GoldMedal,
  'trophy.fill': Trophy, 'trophy': Trophy, 'trophy.circle.fill': TrophyBase,
  'medal.fill': Medal, 'medal': Medal,
  'target': DataLine, 'square.and.pencil': Edit,
  'cursor': Mouse, 'case': Suitcase, 'flag.fill': Flag, 'flag': Flag,
}

const tierName = (tier: number) => {
  const names: Record<number, string> = { 1: '铜牌', 2: '银牌', 3: '金牌', 4: '钻石' }
  return names[tier] || '普通'
}

const tierType = (tier: number) => {
  const types: Record<number, string> = { 1: 'info', 2: '', 3: 'warning', 4: 'danger' }
  return types[tier] || 'info'
}

const tierColor = (tier: number) => {
  const colors: Record<number, string> = { 1: '#CD7F32', 2: '#909399', 3: '#E6A23C', 4: '#409EFF' }
  return colors[tier] || '#909399'
}

const tierBg = (tier: number) => {
  const bgs: Record<number, string> = { 1: '#FDF6EC', 2: '#F4F4F5', 3: '#FDF6EC', 4: '#ECF5FF' }
  return bgs[tier] || '#F4F4F5'
}

const fetchRank = async () => {
  loading.value = true
  try {
    const params = { pageNum: 1, pageSize: 10 }
    let res
    if (selectedTab.value === 'total') {
      res = await getTotalRank(params)
    } else if (selectedTab.value === 'week') {
      res = await getWeekRank(params)
    } else {
      res = await getStreakRank(params)
    }
    rankData.value = res.data?.records || []
  } catch (e) {
    console.error('获取排行榜失败:', e)
  } finally {
    loading.value = false
  }
}

const fetchAchievements = async () => {
  achievementLoading.value = true
  try {
    const [listRes, statsRes] = await Promise.all([
      getAchievementList(),
      getAchievementStats()
    ])
    achievements.value = Array.isArray(listRes) ? listRes : (listRes as any).data || []
    const statsData = (statsRes as any).data || statsRes || { totalAchievements: 0 }
    achievementStats.value = statsData
    stats.value = statsData
  } catch (e) {
    console.error('获取成就失败:', e)
  } finally {
    achievementLoading.value = false
  }
}

onMounted(() => {
  fetchRank()
  fetchAchievements()
})
</script>

<style scoped lang="scss">
.stat-cards {
  .stat-item {
    display: flex;
    align-items: center;
    gap: 16px;

    .stat-icon {
      width: 56px;
      height: 56px;
      border-radius: 12px;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    .stat-info {
      .stat-value {
        font-size: 28px;
        font-weight: bold;
        color: #303133;
      }
      .stat-label {
        font-size: 14px;
        color: #909399;
        margin-top: 4px;
      }
    }
  }
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.achievement-stat {
  display: flex;
  justify-content: space-between;
  align-items: center;

  .value {
    font-size: 24px;
    font-weight: bold;
    color: #409eff;
  }
}

.achievement-list {
  .achievement-item {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 8px 0;
    border-bottom: 1px solid #f0f0f0;

    &:last-child {
      border-bottom: none;
    }

    .ach-icon {
      width: 24px;
      height: 24px;
      border-radius: 6px;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      flex-shrink: 0;
    }

    .name {
      font-size: 14px;
      color: #606266;
      flex: 1;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    .tier-tag {
      flex-shrink: 0;
    }
  }
}
</style>
