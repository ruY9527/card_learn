<template>
  <div class="note-container">
    <!-- 搜索区域 -->
    <el-form :inline="true" class="search-form">
      <el-form-item label="用户名">
        <el-input v-model="queryParams.username" placeholder="用户名" clearable style="width: 150px" />
      </el-form-item>
      <el-form-item label="科目">
        <el-select v-model="queryParams.subjectId" placeholder="全部科目" clearable style="width: 150px">
          <el-option v-for="s in subjectList" :key="s.subjectId" :label="s.subjectName" :value="s.subjectId" />
        </el-select>
      </el-form-item>
      <el-form-item label="关键词">
        <el-input v-model="queryParams.keyword" placeholder="搜索笔记内容" clearable style="width: 180px" />
      </el-form-item>
      <el-form-item label="日期范围">
        <el-date-picker
          v-model="dateRange"
          type="daterange"
          range-separator="至"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
          value-format="YYYY-MM-DD"
          style="width: 260px"
        />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="fetchData">查询</el-button>
        <el-button @click="handleExport">导出</el-button>
      </el-form-item>
    </el-form>

    <!-- 表格 -->
    <el-table :data="noteList" v-loading="loading" stripe>
      <el-table-column prop="commentId" label="ID" width="80" />
      <el-table-column prop="cardFrontContent" label="关联卡片" min-width="200">
        <template #default="{ row }">
          <el-text line-clamp="2">{{ row.cardFrontContent }}</el-text>
        </template>
      </el-table-column>
      <el-table-column prop="subjectName" label="科目" width="120" />
      <el-table-column prop="userNickname" label="用户" width="100" />
      <el-table-column prop="content" label="笔记内容" min-width="200">
        <template #default="{ row }">
          <el-text line-clamp="3">{{ row.content }}</el-text>
        </template>
      </el-table-column>
      <el-table-column prop="rating" label="评分" width="80">
        <template #default="{ row }">
          <el-rate v-model="row.rating" disabled :max="5" size="small" />
        </template>
      </el-table-column>
      <el-table-column prop="likeCount" label="点赞" width="70" />
      <el-table-column prop="replyCount" label="回复" width="70" />
      <el-table-column prop="createTime" label="创建时间" width="160" />
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
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage } from 'element-plus'
import request from '@/api/request'

interface Note {
  commentId: number
  cardId: number
  cardFrontContent: string
  subjectName: string
  userId: number
  userNickname: string
  content: string
  rating: number
  likeCount: number
  replyCount: number
  createTime: string
  updateTime: string
}

interface Subject {
  subjectId: number
  subjectName: string
}

const dateRange = ref<[string, string] | null>(null)

const queryParams = reactive({
  username: undefined as string | undefined,
  subjectId: undefined as number | undefined,
  keyword: undefined as string | undefined,
  startDate: undefined as string | undefined,
  endDate: undefined as string | undefined,
  pageNum: 1,
  pageSize: 10
})

const noteList = ref<Note[]>([])
const total = ref(0)
const loading = ref(false)
const subjectList = ref<Subject[]>([])

const fetchData = async () => {
  loading.value = true
  // 同步日期范围
  if (dateRange.value) {
    queryParams.startDate = dateRange.value[0]
    queryParams.endDate = dateRange.value[1]
  } else {
    queryParams.startDate = undefined
    queryParams.endDate = undefined
  }

  try {
    const res = await request.get<any, { data: { records: Note[]; total: number } }>('/admin/comment/notes', { params: queryParams })
    noteList.value = res.data.records
    total.value = res.data.total
  } catch (error) {
    ElMessage.error('获取数据失败')
  }
  loading.value = false
}

const fetchSubjects = async () => {
  try {
    const res = await request.get<any, { data: Subject[] }>('/api/miniprogram/subjects')
    subjectList.value = res.data || []
  } catch (error) {
    console.error('获取科目列表失败:', error)
  }
}

const handleExport = async () => {
  if (dateRange.value) {
    queryParams.startDate = dateRange.value[0]
    queryParams.endDate = dateRange.value[1]
  }

  try {
    const res = await request.get<any, { data: string }>('/api/miniprogram/note/export', {
      params: { ...queryParams, pageSize: 1000 }
    })
    const content = res.data || ''
    if (!content) {
      ElMessage.warning('没有可导出的笔记')
      return
    }

    // 创建下载
    const blob = new Blob([content], { type: 'text/plain;charset=utf-8' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `notes_${new Date().toISOString().slice(0, 10)}.txt`
    a.click()
    URL.revokeObjectURL(url)
    ElMessage.success('导出成功')
  } catch (error) {
    ElMessage.error('导出失败')
  }
}

onMounted(() => {
  fetchSubjects()
  fetchData()
})
</script>

<style scoped>
.note-container {
  padding: 20px;
}

.search-form {
  margin-bottom: 20px;
}
</style>
