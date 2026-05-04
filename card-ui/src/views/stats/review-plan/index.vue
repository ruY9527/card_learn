<template>
  <div class="review-plan">
    <!-- 筛选栏 -->
    <el-card class="filter-card" shadow="never">
      <el-form :inline="true" :model="filterForm">
        <el-form-item label="用户">
          <el-select
            v-model="filterForm.userId"
            placeholder="全部用户"
            clearable
            filterable
            style="width: 180px"
          >
            <el-option
              v-for="user in userList"
              :key="user.userId"
              :label="user.nickname"
              :value="user.userId!"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="filterForm.status" placeholder="全部状态" clearable style="width: 120px">
            <el-option label="待复习" value="0" />
            <el-option label="已完成" value="1" />
          </el-select>
        </el-form-item>
        <el-form-item label="计划日期">
          <el-date-picker
            v-model="filterForm.dateRange"
            type="datetimerange"
            range-separator="至"
            start-placeholder="开始时间"
            end-placeholder="结束时间"
            value-format="YYYY-MM-DD HH:mm:ss"
            :default-time="[new Date(2000, 1, 1, 0, 0, 0), new Date(2000, 1, 1, 23, 59, 59)]"
            style="width: 380px"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 统计卡片 -->
    <el-row :gutter="16" class="stats-row">
      <el-col :span="6">
        <el-card shadow="never" class="stat-card">
          <div class="stat-value">{{ totalRecords }}</div>
          <div class="stat-label">总记录数</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never" class="stat-card stat-pending">
          <div class="stat-value">{{ pendingCount }}</div>
          <div class="stat-label">待复习</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never" class="stat-card stat-done">
          <div class="stat-value">{{ doneCount }}</div>
          <div class="stat-label">已完成</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never" class="stat-card stat-user">
          <div class="stat-value">{{ userCount }}</div>
          <div class="stat-label">涉及用户</div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 数据表格 -->
    <el-card shadow="never">
      <el-table :data="tableData" v-loading="loading" stripe style="width: 100%">
        <el-table-column prop="nickname" label="用户" width="120">
          <template #default="{ row }">
            <div class="user-cell">
              <el-avatar :size="28" :src="row.avatar || ''">
                {{ (row.nickname || '?').charAt(0) }}
              </el-avatar>
              <span>{{ row.nickname || '未知' }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="scheduledDate" label="计划日期" width="120" />
        <el-table-column prop="subjectName" label="科目" width="140">
          <template #default="{ row }">
            <el-tag size="small" type="info">{{ row.subjectName || '-' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="frontContent" label="卡片内容" min-width="250" show-overflow-tooltip />
        <el-table-column prop="difficultyLevel" label="难度" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="difficultyType(row.difficultyLevel)" size="small">
              {{ difficultyLabel(row.difficultyLevel) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="studyCount" label="学习次数" width="100" align="center">
          <template #default="{ row }">
            <el-link v-if="row.studyCount > 0" type="primary" @click="openHistory(row)">
              {{ row.studyCount }}次
            </el-link>
            <span v-else class="text-muted">0次</span>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === '0' ? 'warning' : 'success'" size="small">
              {{ row.status === '0' ? '待复习' : '已完成' }}
            </el-tag>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-wrapper">
        <el-pagination
          v-model:current-page="pagination.pageNum"
          v-model:page-size="pagination.pageSize"
          :page-sizes="[10, 20, 50, 100]"
          :total="totalRecords"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSearch"
          @current-change="handleSearch"
        />
      </div>
    </el-card>

    <!-- 学习历史抽屉 -->
    <el-drawer v-model="historyDrawerVisible" title="学习记录" size="400px">
      <div v-loading="historyLoading">
        <el-empty v-if="!historyLoading && historyRecords.length === 0" description="暂无学习记录" />
        <el-timeline v-else>
          <el-timeline-item
            v-for="record in historyRecords"
            :key="record.id"
            :timestamp="record.createTime"
            placement="top"
            :type="record.status === 2 ? 'success' : record.status === 1 ? 'warning' : 'info'"
          >
            <el-tag :type="record.status === 2 ? 'success' : record.status === 1 ? 'warning' : 'info'" size="small">
              {{ statusText(record.status) }}
            </el-tag>
          </el-timeline-item>
        </el-timeline>
      </div>
    </el-drawer>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed } from 'vue'
import { getAdminReviewPlan, getUserList, getCardStudyHistory } from '@/api/content'
import type { AdminReviewPlan, SysUser, StudyHistoryRecord } from '@/api/types'

const loading = ref(false)
const tableData = ref<AdminReviewPlan[]>([])
const userList = ref<SysUser[]>([])
const totalRecords = ref(0)

// 学习历史抽屉
const historyDrawerVisible = ref(false)
const historyLoading = ref(false)
const historyRecords = ref<StudyHistoryRecord[]>([])

const filterForm = reactive({
  userId: undefined as number | undefined,
  status: '' as string,
  dateRange: null as [string, string] | null
})

const pagination = reactive({
  pageNum: 1,
  pageSize: 20
})

// 统计
const pendingCount = computed(() => tableData.value.filter(r => r.status === '0').length)
const doneCount = computed(() => tableData.value.filter(r => r.status === '1').length)
const userCount = computed(() => new Set(tableData.value.map(r => r.userId)).size)

// 难度标签
function difficultyLabel(level?: number) {
  const map: Record<number, string> = { 1: '简单', 2: '中等', 3: '困难', 4: '很难' }
  return map[level || 0] || '-'
}

function difficultyType(level?: number) {
  const map: Record<number, string> = { 1: 'success', 2: 'info', 3: 'warning', 4: 'danger' }
  return (map[level || 0] || 'info') as any
}

// 查询
async function handleSearch() {
  loading.value = true
  try {
    const res = await getAdminReviewPlan({
      userId: filterForm.userId,
      status: filterForm.status || undefined,
      scheduledDateStart: filterForm.dateRange?.[0] || undefined,
      scheduledDateEnd: filterForm.dateRange?.[1] || undefined,
      pageNum: pagination.pageNum,
      pageSize: pagination.pageSize
    })
    tableData.value = res.data.records
    totalRecords.value = res.data.total
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}

// 重置
function handleReset() {
  filterForm.userId = undefined
  filterForm.status = ''
  filterForm.dateRange = null
  pagination.pageNum = 1
  handleSearch()
}

// 加载用户列表
async function loadUsers() {
  try {
    userList.value = await getUserList()
  } catch (e) {
    console.error(e)
  }
}

// 打开学习历史
async function openHistory(row: AdminReviewPlan) {
  historyDrawerVisible.value = true
  historyLoading.value = true
  historyRecords.value = []
  try {
    const res = await getCardStudyHistory({ cardId: row.cardId, userId: row.userId })
    historyRecords.value = res.data.records || []
  } catch (e) {
    console.error(e)
  } finally {
    historyLoading.value = false
  }
}

// 状态文本
function statusText(status: number) {
  const map: Record<number, string> = { 0: '未学', 1: '模糊', 2: '掌握' }
  return map[status] || '未知'
}

onMounted(() => {
  loadUsers()
  handleSearch()
})
</script>

<style scoped lang="scss">
.review-plan {
  .filter-card {
    margin-bottom: 16px;

    .el-form-item {
      margin-bottom: 0;
    }
  }

  .stats-row {
    margin-bottom: 16px;

    .stat-card {
      text-align: center;
      padding: 8px 0;

      .stat-value {
        font-size: 28px;
        font-weight: bold;
        color: #409eff;
      }

      .stat-label {
        font-size: 13px;
        color: #909399;
        margin-top: 4px;
      }

      &.stat-pending .stat-value { color: #e6a23c; }
      &.stat-done .stat-value { color: #67c23a; }
      &.stat-user .stat-value { color: #909399; }
    }
  }

  .user-cell {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .pagination-wrapper {
    display: flex;
    justify-content: flex-end;
    margin-top: 16px;
  }

  .text-muted {
    color: #909399;
    font-size: 13px;
  }
}
</style>
