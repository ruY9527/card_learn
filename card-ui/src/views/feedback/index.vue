<template>
  <div class="feedback-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>用户反馈管理</span>
          <el-badge :value="pendingCount" :hidden="pendingCount === 0" class="pending-badge">
            <el-button type="warning" size="small" @click="filterPending">待处理</el-button>
          </el-badge>
        </div>
      </template>
      <el-form :inline="true" class="search-form">
        <el-form-item label="反馈类型">
          <el-select
            v-model="queryParams.type"
            placeholder="请选择类型"
            clearable
            class="type-select"
          >
            <el-option label="建议" value="SUGGESTION" />
            <el-option label="纠错" value="ERROR" />
            <el-option label="功能问题" value="FUNCTION" />
            <el-option label="其他" value="OTHER" />
          </el-select>
        </el-form-item>
        <el-form-item label="处理状态">
          <el-select
            v-model="queryParams.status"
            placeholder="请选择状态"
            clearable
            class="status-select"
          >
            <el-option label="待处理" value="0" />
            <el-option label="已采纳" value="1" />
            <el-option label="已忽略" value="2" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="fetchData">查询</el-button>
        </el-form-item>
      </el-form>
      <el-table :data="tableData" border stripe v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="userNickname" label="用户" width="100">
          <template #default="{ row }">
            <span>{{ row.userNickname || '未知用户' }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="type" label="类型" width="100">
          <template #default="{ row }">
            <el-tag :type="getTypeTagType(row.type)">
              {{ getTypeLabel(row.type) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="cardFrontContent" label="关联卡片" width="150">
          <template #default="{ row }">
            <el-text v-if="row.cardId" truncated>
              {{ row.cardFrontContent || `卡片#${row.cardId}` }}
            </el-text>
            <span v-else class="text-muted">无</span>
          </template>
        </el-table-column>
        <el-table-column prop="content" label="反馈内容" show-overflow-tooltip />
        <el-table-column prop="rating" label="评分" width="80">
          <template #default="{ row }">
            <el-rate v-if="row.rating" :model-value="row.rating" disabled :max="5" size="small" />
            <span v-else class="text-muted">无</span>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="getStatusTagType(row.status)">
              {{ getStatusLabel(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="提交时间" width="180" />
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleView(row)">查看</el-button>
            <el-button type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-pagination
        v-model:current-page="queryParams.pageNum"
        v-model:page-size="queryParams.pageSize"
        :total="total"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="fetchData"
        @current-change="fetchData"
      />
    </el-card>

    <!-- 详情处理弹窗 -->
    <el-dialog v-model="dialogVisible" title="反馈详情" width="700px">
      <el-descriptions :column="2" border>
        <el-descriptions-item label="反馈ID">{{ currentFeedback?.id }}</el-descriptions-item>
        <el-descriptions-item label="提交用户">
          {{ currentFeedback?.userNickname || '未知用户' }}
        </el-descriptions-item>
        <el-descriptions-item label="反馈类型">
          <el-tag :type="getTypeTagType(currentFeedback?.type || '')">
            {{ getTypeLabel(currentFeedback?.type || '') }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="评分">
          <el-rate v-if="currentFeedback?.rating" :model-value="currentFeedback.rating" disabled :max="5" />
          <span v-else>无评分</span>
        </el-descriptions-item>
        <el-descriptions-item label="联系方式">
          {{ currentFeedback?.contact || '未留下联系方式' }}
        </el-descriptions-item>
        <el-descriptions-item label="提交时间">
          {{ currentFeedback?.createTime }}
        </el-descriptions-item>
        <el-descriptions-item label="关联卡片" :span="2">
          <el-text v-if="currentFeedback?.cardId">
            {{ currentFeedback?.cardFrontContent || `卡片#${currentFeedback.cardId}` }}
          </el-text>
          <span v-else>无关联卡片</span>
        </el-descriptions-item>
        <el-descriptions-item label="反馈内容" :span="2">
          <div class="feedback-content">{{ currentFeedback?.content }}</div>
        </el-descriptions-item>
        <el-descriptions-item label="图片附件" :span="2">
          <div v-if="currentFeedback?.images" class="feedback-images">
            <el-image
              v-for="(img, index) in parseImages(currentFeedback?.images)"
              :key="index"
              :src="img"
              :preview-src-list="parseImages(currentFeedback?.images)"
              fit="cover"
              class="feedback-image"
            />
          </div>
          <span v-else>无图片</span>
        </el-descriptions-item>
      </el-descriptions>

      <el-divider />

      <el-form :model="processForm" label-width="100px">
        <el-form-item label="处理状态">
          <el-radio-group v-model="processForm.status">
            <el-radio value="1">已采纳</el-radio>
            <el-radio value="2">已忽略</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="回复内容">
          <el-input
            v-model="processForm.adminReply"
            type="textarea"
            :rows="3"
            placeholder="填写处理意见或回复内容"
          />
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="processLoading" @click="handleProcess">保存处理</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  getFeedbackPage,
  getFeedbackById,
  processFeedback,
  deleteFeedback,
  getPendingFeedbackCount
} from '@/api/content'
import type { FeedbackVO } from '@/api/types'

const queryParams = reactive({
  type: '',
  status: '',
  pageNum: 1,
  pageSize: 10
})

const tableData = ref<FeedbackVO[]>([])
const total = ref(0)
const loading = ref(false)
const pendingCount = ref(0)
const dialogVisible = ref(false)
const currentFeedback = ref<FeedbackVO | null>(null)
const processLoading = ref(false)

const processForm = reactive({
  status: '1',
  adminReply: ''
})

// 类型标签颜色
const getTypeTagType = (type: string) => {
  const map: Record<string, string> = {
    SUGGESTION: 'primary',
    ERROR: 'danger',
    FUNCTION: 'warning',
    OTHER: 'info'
  }
  return map[type] || 'info'
}

// 类型标签文本
const getTypeLabel = (type: string) => {
  const map: Record<string, string> = {
    SUGGESTION: '建议',
    ERROR: '纠错',
    FUNCTION: '功能问题',
    OTHER: '其他'
  }
  return map[type] || type
}

// 状态标签颜色
const getStatusTagType = (status: string) => {
  const map: Record<string, string> = {
    '0': 'warning',
    '1': 'success',
    '2': 'info'
  }
  return map[status] || 'info'
}

// 状态标签文本
const getStatusLabel = (status: string) => {
  const map: Record<string, string> = {
    '0': '待处理',
    '1': '已采纳',
    '2': '已忽略'
  }
  return map[status] || status
}

// 解析图片 JSON
const parseImages = (images: string | undefined) => {
  if (!images) return []
  try {
    return JSON.parse(images) as string[]
  } catch {
    return []
  }
}

// 获取数据
const fetchData = async () => {
  loading.value = true
  try {
    const res = await getFeedbackPage(queryParams)
    tableData.value = res.data.records
    total.value = res.data.total
  } catch (error) {
    console.error(error)
  } finally {
    loading.value = false
  }
}

// 获取待处理数量
const fetchPendingCount = async () => {
  try {
    const res = await getPendingFeedbackCount()
    pendingCount.value = res.data
  } catch (error) {
    console.error(error)
  }
}

// 筛选待处理
const filterPending = () => {
  queryParams.status = '0'
  fetchData()
}

// 查看详情
const handleView = async (row: FeedbackVO) => {
  try {
    const res = await getFeedbackById(row.id!)
    currentFeedback.value = { ...row, ...res.data }
    processForm.status = row.status === '0' ? '1' : (row.status || '1')
    processForm.adminReply = res.data.adminReply || ''
    dialogVisible.value = true
  } catch (error) {
    console.error(error)
  }
}

// 处理反馈
const handleProcess = async () => {
  if (!currentFeedback.value?.id) return
  processLoading.value = true
  try {
    await processFeedback(
      currentFeedback.value.id,
      processForm.status,
      processForm.adminReply
    )
    ElMessage.success('处理成功')
    dialogVisible.value = false
    fetchData()
    fetchPendingCount()
  } catch (error) {
    console.error(error)
  } finally {
    processLoading.value = false
  }
}

// 删除反馈
const handleDelete = async (row: FeedbackVO) => {
  await ElMessageBox.confirm('确定删除该反馈？', '提示', { type: 'warning' })
  try {
    await deleteFeedback(row.id!)
    ElMessage.success('删除成功')
    fetchData()
    fetchPendingCount()
  } catch (error) {
    console.error(error)
  }
}

onMounted(() => {
  fetchData()
  fetchPendingCount()
})
</script>

<style scoped lang="scss">
.feedback-page {
  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;

    .pending-badge {
      margin-left: 16px;
    }
  }

  .search-form {
    margin-bottom: 16px;

    .type-select,
    .status-select {
      width: 120px;
    }
  }

  .el-pagination {
    margin-top: 16px;
    justify-content: flex-end;
  }

  .text-muted {
    color: #909399;
  }

  .feedback-content {
    white-space: pre-wrap;
    word-break: break-all;
  }

  .feedback-images {
    display: flex;
    gap: 8px;

    .feedback-image {
      width: 100px;
      height: 100px;
      border-radius: 4px;
    }
  }
}

// 响应式布局
@media screen and (max-width: 768px) {
  .feedback-page {
    .card-header {
      flex-direction: column;
      gap: 12px;
      align-items: flex-start;
    }

    .search-form {
      .el-form-item {
        width: 100%;
        .el-select {
          width: 100%;
        }
      }
    }
  }
}
</style>