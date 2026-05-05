<template>
  <div class="achievement-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>成就管理</span>
          <el-select v-model="selectedCategory" placeholder="分类筛选" clearable style="width: 120px" @change="fetchData">
            <el-option label="全部" value="" />
            <el-option label="连续" value="streak" />
            <el-option label="数量" value="count" />
            <el-option label="科目" value="subject" />
            <el-option label="社交" value="social" />
          </el-select>
        </div>
      </template>

      <el-table :data="achievements" border stripe v-loading="loading">
        <el-table-column label="图标" width="80" align="center">
          <template #default="{ row }">
            <div class="icon-cell" :style="{ background: tierBg(row.tier) }">
              <el-icon :size="22" :color="tierColor(row.tier)">
                <component :is="iconMap[row.icon] || 'Star'" />
              </el-icon>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="code" label="代码" width="160" />
        <el-table-column prop="name" label="名称" width="120" />
        <el-table-column prop="description" label="描述" show-overflow-tooltip />
        <el-table-column label="等级" width="80">
          <template #default="{ row }">
            <el-tag :type="tierType(row.tier)" size="small">{{ tierName(row.tier) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="category" label="分类" width="80">
          <template #default="{ row }">
            {{ categoryLabel(row.category) }}
          </template>
        </el-table-column>
        <el-table-column prop="conditionValue" label="条件值" width="80" align="center" />
        <el-table-column prop="expReward" label="奖励经验" width="100" align="center">
          <template #default="{ row }">
            <span v-if="row.expReward" class="exp-reward">+{{ row.expReward }}</span>
            <span v-else class="exp-zero">-</span>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import {
  Reading, Star, StarFilled, RefreshRight, ChatDotRound, Trophy, TrophyBase,
  Medal, GoldMedal, Lightning, Suitcase, Flag, Mouse, Edit, DataLine
} from '@element-plus/icons-vue'
import { getAchievementList } from '@/api/incentive'
import type { Achievement } from '@/api/types'

const loading = ref(false)
const achievements = ref<Achievement[]>([])
const selectedCategory = ref('')

// SF Symbol → Element Plus icon 映射
const iconMap: Record<string, any> = {
  'book.fill': Reading,
  'book': Reading,
  'star.fill': StarFilled,
  'star': Star,
  'arrow.clockwise': RefreshRight,
  'bubble.left.fill': ChatDotRound,
  'bubble.left': ChatDotRound,
  'flame': Lightning,
  'flame.fill': Lightning,
  'bolt.fill': Lightning,
  'bolt': Lightning,
  'flame.circle.fill': Lightning,
  'crown.fill': GoldMedal,
  'crown': GoldMedal,
  'crown.circle.fill': GoldMedal,
  'trophy.fill': Trophy,
  'trophy': Trophy,
  'trophy.circle.fill': TrophyBase,
  'medal.fill': Medal,
  'medal': Medal,
  'target': DataLine,
  'square.and.pencil': Edit,
  'cursor': Mouse,
  'case': Suitcase,
  'flag.fill': Flag,
  'flag': Flag,
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

const categoryLabel = (category: string) => {
  const labels: Record<string, string> = { streak: '连续', count: '数量', subject: '科目', social: '社交' }
  return labels[category] || category
}

const fetchData = async () => {
  loading.value = true
  try {
    const params = selectedCategory.value ? { category: selectedCategory.value } : undefined
    const res = await getAchievementList(params)
    achievements.value = Array.isArray(res) ? res : (res as any).data || []
  } catch (e) {
    console.error('获取成就列表失败:', e)
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

.icon-cell {
  width: 40px;
  height: 40px;
  border-radius: 10px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.exp-reward {
  color: #67C23A;
  font-weight: 600;
}

.exp-zero {
  color: #C0C4CC;
}
</style>
