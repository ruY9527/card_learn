<template>
  <div class="comment-container">
    <!-- 搜索区域 -->
    <el-form :inline="true" class="search-form">
      <el-form-item label="评论类型">
        <el-select v-model="queryParams.commentType" placeholder="全部类型" clearable style="width: 150px">
          <el-option label="优质内容" value="QUALITY" />
          <el-option label="劣质内容" value="POOR" />
          <el-option label="中性评价" value="NEUTRAL" />
        </el-select>
      </el-form-item>
      <el-form-item label="状态">
        <el-select v-model="queryParams.status" placeholder="全部状态" clearable style="width: 150px">
          <el-option label="正常" value="0" />
          <el-option label="已处理" value="1" />
          <el-option label="已隐藏" value="2" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="fetchData">查询</el-button>
      </el-form-item>
    </el-form>

    <!-- 表格 -->
    <el-table :data="commentList" v-loading="loading" stripe>
      <el-table-column prop="commentId" label="ID" width="80" />
      <el-table-column prop="cardFrontContent" label="卡片内容" min-width="200">
        <template #default="{ row }">
          <el-text line-clamp="2">{{ row.cardFrontContent }}</el-text>
        </template>
      </el-table-column>
      <el-table-column prop="subjectName" label="科目" width="120" />
      <el-table-column prop="userNickname" label="用户" width="100" />
      <el-table-column prop="content" label="评论内容" min-width="150">
        <template #default="{ row }">
          <el-text line-clamp="2">{{ row.content }}</el-text>
        </template>
      </el-table-column>
      <el-table-column prop="rating" label="评分" width="80">
        <template #default="{ row }">
          <el-rate v-model="row.rating" disabled :max="5" size="small" />
        </template>
      </el-table-column>
      <el-table-column prop="commentTypeText" label="类型" width="100">
        <template #default="{ row }">
          <el-tag
            :type="row.commentType === 'QUALITY' ? 'success' : row.commentType === 'POOR' ? 'danger' : 'info'"
          >
            {{ row.commentTypeText }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="statusText" label="状态" width="80">
        <template #default="{ row }">
          <el-tag :type="row.status === '0' ? 'success' : row.status === '1' ? 'warning' : 'info'">
            {{ row.statusText }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="createTime" label="时间" width="160" />
      <el-table-column label="操作" width="180" fixed="right">
        <template #default="{ row }">
          <el-button type="primary" size="small" @click="handleReply(row)">回复</el-button>
          <el-button
            v-if="row.commentType === 'POOR' && row.feedbackId"
            type="warning"
            size="small"
            @click="handleFeedback(row)"
          >
            处理反馈
          </el-button>
          <el-button type="danger" size="small" @click="handleDelete(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 分页 -->
    <el-pagination
      v-model:current-page="queryParams.pageNum"
      v-model:page-size="queryParams.pageSize"
      :total="total"
      :page-sizes="[10, 20, 50, 100]"
      layout="total, sizes, prev, pager, next, jumper"
      @size-change="fetchData"
      @current-change="fetchData"
      style="margin-top: 20px; justify-content: flex-end"
    />

    <!-- 回复弹窗 -->
    <el-dialog v-model="replyDialogVisible" title="回复评论" width="500">
      <el-form>
        <el-form-item label="回复内容">
          <el-input v-model="replyContent" type="textarea" :rows="4" placeholder="请输入回复内容" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="replyDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitReply">确定</el-button>
      </template>
    </el-dialog>

    <!-- 反馈处理弹窗 -->
    <el-dialog v-model="feedbackDialogVisible" title="处理劣质内容反馈" width="600">
      <el-form>
        <el-form-item label="处理结果">
          <el-radio-group v-model="feedbackStatus">
            <el-radio value="1">采纳（修正卡片）</el-radio>
            <el-radio value="2">忽略（内容无误）</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="处理说明">
          <el-input v-model="feedbackReply" type="textarea" :rows="4" placeholder="请输入处理说明" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="feedbackDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitFeedback">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import request from '@/api/request'

interface Comment {
  commentId: number
  cardId: number
  cardFrontContent: string
  subjectName: string
  userId: number
  userNickname: string
  content: string
  rating: number
  commentType: string
  commentTypeText: string
  status: string
  statusText: string
  adminReply: string
  feedbackId: number
  createTime: string
}

const queryParams = reactive({
  commentType: undefined as string | undefined,
  status: undefined as string | undefined,
  pageNum: 1,
  pageSize: 10
})

const commentList = ref<Comment[]>([])
const total = ref(0)
const loading = ref(false)

const replyDialogVisible = ref(false)
const replyContent = ref('')
const currentComment = ref<Comment | null>(null)

const feedbackDialogVisible = ref(false)
const feedbackStatus = ref('1')
const feedbackReply = ref('')
const currentFeedbackComment = ref<Comment | null>(null)

const fetchData = async () => {
  loading.value = true
  try {
    const res = await request.get('/admin/comment/page', { params: queryParams })
    commentList.value = res.data.records
    total.value = res.data.total
  } catch (error) {
    ElMessage.error('获取数据失败')
  }
  loading.value = false
}

const handleReply = (row: Comment) => {
  currentComment.value = row
  replyContent.value = row.adminReply || ''
  replyDialogVisible.value = true
}

const submitReply = async () => {
  if (!replyContent.value.trim()) {
    ElMessage.warning('请输入回复内容')
    return
  }
  try {
    await request.post(`/admin/comment/reply/${currentComment.value?.commentId}`, replyContent.value)
    ElMessage.success('回复成功')
    replyDialogVisible.value = false
    fetchData()
  } catch (error) {
    ElMessage.error('回复失败')
  }
}

const handleFeedback = (row: Comment) => {
  currentFeedbackComment.value = row
  feedbackStatus.value = '1'
  feedbackReply.value = ''
  feedbackDialogVisible.value = true
}

const submitFeedback = async () => {
  if (!feedbackReply.value.trim()) {
    ElMessage.warning('请输入处理说明')
    return
  }
  try {
    await request.post(`/admin/comment/handle/${currentFeedbackComment.value?.commentId}`, null, {
      params: { status: feedbackStatus.value }
    })
    // 同时更新反馈
    if (currentFeedbackComment.value?.feedbackId) {
      await request.post(`/admin/feedback/process/${currentFeedbackComment.value.feedbackId}`, {
        status: feedbackStatus.value,
        adminReply: feedbackReply.value
      })
    }
    ElMessage.success('处理成功')
    feedbackDialogVisible.value = false
    fetchData()
  } catch (error) {
    ElMessage.error('处理失败')
  }
}

const handleDelete = (row: Comment) => {
  ElMessageBox.confirm('确认删除该评论？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      await request.delete(`/admin/comment/${row.commentId}`)
      ElMessage.success('删除成功')
      fetchData()
    } catch (error) {
      ElMessage.error('删除失败')
    }
  })
}

onMounted(() => {
  fetchData()
})
</script>

<style scoped>
.comment-container {
  padding: 20px;
}

.search-form {
  margin-bottom: 20px;
}
</style>