<template>
  <div class="study-history">
    <!-- 顶部筛选 -->
    <el-card class="filter-card">
      <el-row :gutter="16" align="middle">
        <el-col :span="6">
          <el-select
            v-model="selectedUserId"
            placeholder="选择用户"
            clearable
            filterable
            @change="handleSearch"
          >
            <el-option
              v-for="user in userList"
              :key="user.userId"
              :label="user.nickname"
              :value="user.userId!"
            />
          </el-select>
        </el-col>
        <el-col :span="6">
          <el-input
            v-model="searchKeyword"
            placeholder="搜索卡片内容"
            clearable
            @keyup.enter="handleSearch"
            @clear="handleSearch"
          >
            <template #prefix>
              <el-icon><Search /></el-icon>
            </template>
          </el-input>
        </el-col>
        <el-col :span="4">
          <el-button type="primary" @click="handleSearch">
            <el-icon><Search /></el-icon> 查询
          </el-button>
        </el-col>
      </el-row>
    </el-card>

    <!-- 卡片列表 -->
    <el-card class="table-card">
      <el-table
        :data="cardList"
        v-loading="loading"
        stripe
        style="width: 100%"
        :row-key="(row: any) => `${row.userId}_${row.cardId}`"
        @expand-change="handleExpandChange"
      >
        <el-table-column type="expand">
          <template #default="{ row }">
            <div class="history-expand" v-loading="row._loadingHistory">
              <el-timeline v-if="row._history && row._history.length > 0">
                <el-timeline-item
                  v-for="record in row._history"
                  :key="record.id"
                  :timestamp="formatTime(record.createTime)"
                  placement="top"
                  :type="getStatusType(record.status)"
                >
                  <span v-if="record.nickname" class="history-nickname">{{ record.nickname }}</span>
                  <el-tag :type="getStatusType(record.status)" size="small">
                    {{ getStatusText(record.status) }}
                  </el-tag>
                </el-timeline-item>
              </el-timeline>
              <el-empty v-else description="暂无学习记录" :image-size="60" />
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="nickname" label="学习用户" width="100">
          <template #default="{ row }">
            {{ row.nickname || '未知用户' }}
          </template>
        </el-table-column>
        <el-table-column prop="cardId" label="卡片ID" width="80" />
        <el-table-column prop="subjectName" label="科目" width="120">
          <template #default="{ row }">
            <el-tag size="small">{{ row.subjectName || '未分类' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="frontContent" label="卡片内容" min-width="200" show-overflow-tooltip />
        <el-table-column prop="difficultyLevel" label="难度" width="80" align="center">
          <template #default="{ row }">
            <el-rate :model-value="row.difficultyLevel || 1" disabled :max="5" />
          </template>
        </el-table-column>
        <el-table-column prop="studyCount" label="学习次数" width="90" align="center">
          <template #default="{ row }">
            <el-tag type="info">{{ row.studyCount }}次</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="lastStatus" label="最近状态" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.lastStatus)" size="small">
              {{ getStatusText(row.lastStatus) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="lastStudyTime" label="最近学习时间" width="170">
          <template #default="{ row }">
            {{ formatTime(row.lastStudyTime) }}
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination">
        <el-pagination
          v-model:current-page="pageNum"
          v-model:page-size="pageSize"
          :total="total"
          :page-sizes="[20, 50, 100]"
          layout="total, sizes, prev, pager, next"
          @size-change="handleSearch"
          @current-change="fetchData"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { getStudiedCards, getCardStudyHistory, getUserList } from '@/api/content'
import type { StudiedCard, StudyHistoryRecord, SysUser } from '@/api/types'
import { ElMessage } from 'element-plus'

const loading = ref(false)
const cardList = ref<(StudiedCard & { _history?: StudyHistoryRecord[]; _loadingHistory?: boolean })[]>([])
const userList = ref<SysUser[]>([])
const selectedUserId = ref<number | undefined>(undefined)
const searchKeyword = ref('')
const pageNum = ref(1)
const pageSize = ref(20)
const total = ref(0)

const fetchUsers = async () => {
  try {
    userList.value = await getUserList()
  } catch {
    // ignore
  }
}

const fetchData = async () => {
  loading.value = true
  try {
    const res = await getStudiedCards({
      userId: selectedUserId.value,
      pageNum: pageNum.value,
      pageSize: pageSize.value
    })
    const data = res.data
    cardList.value = (data.records || []).map(item => ({
      ...item,
      _history: undefined,
      _loadingHistory: false
    }))
    total.value = data.total || 0
  } catch (err: any) {
    ElMessage.error(err.message || '获取数据失败')
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  pageNum.value = 1
  fetchData()
}

const handleExpandChange = async (row: any, expandedRows: any[]) => {
  const isExpanded = expandedRows.some((r: any) => r.cardId === row.cardId && r.userId === row.userId)
  if (isExpanded && !row._history) {
    row._loadingHistory = true
    try {
      const res = await getCardStudyHistory({
        cardId: row.cardId,
        userId: row.userId,
        pageNum: 1,
        pageSize: 100
      })
      row._history = res.data.records || []
    } catch (err: any) {
      ElMessage.error(err.message || '获取历史记录失败')
      row._history = []
    } finally {
      row._loadingHistory = false
    }
  }
}

const getStatusText = (status: number) => {
  switch (status) {
    case 0: return '未学'
    case 1: return '模糊'
    case 2: return '掌握'
    default: return '未知'
  }
}

const getStatusType = (status: number): '' | 'success' | 'warning' | 'info' | 'danger' => {
  switch (status) {
    case 0: return 'info'
    case 1: return 'warning'
    case 2: return 'success'
    default: return 'info'
  }
}

const formatTime = (time: string | null) => {
  if (!time) return '-'
  const date = new Date(time)
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  const hours = String(date.getHours()).padStart(2, '0')
  const minutes = String(date.getMinutes()).padStart(2, '0')
  const seconds = String(date.getSeconds()).padStart(2, '0')
  return `${month}-${day} ${hours}:${minutes}:${seconds}`
}

onMounted(() => {
  fetchUsers()
  fetchData()
})
</script>

<style scoped lang="scss">
.study-history {
  .filter-card {
    margin-bottom: 16px;
  }

  .table-card {
    .history-expand {
      padding: 16px 40px;
      max-height: 400px;
      overflow-y: auto;

      .history-nickname {
        margin-right: 8px;
        font-size: 13px;
        color: #606266;
        font-weight: 500;
      }
    }

    .pagination {
      margin-top: 16px;
      display: flex;
      justify-content: flex-end;
    }
  }
}
</style>
