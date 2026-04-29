<template>
  <div class="card-audit-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>用户录入卡片审批</span>
          <el-badge :value="pendingCount" :hidden="pendingCount === 0" class="pending-badge">
            <el-button type="warning" size="small" @click="filterPending">待审批</el-button>
          </el-badge>
        </div>
      </template>
      
      <el-form :inline="true" class="search-form">
        <el-form-item label="审批状态">
          <el-select
            v-model="queryParams.auditStatus"
            placeholder="请选择状态"
            clearable
            class="status-select"
          >
            <el-option label="待审批" value="0" />
            <el-option label="已通过" value="1" />
            <el-option label="已拒绝" value="2" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="fetchData">查询</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="tableData" border stripe v-loading="loading">
        <el-table-column prop="cardId" label="ID" width="80" />
        <el-table-column prop="subjectName" label="所属科目" width="120" />
        <el-table-column prop="frontContent" label="卡片正面" show-overflow-tooltip>
          <template #default="{ row }">
            <div class="content-preview" v-html="renderMarkdown(row.frontContent)"></div>
          </template>
        </el-table-column>
        <el-table-column prop="backContent" label="卡片反面" show-overflow-tooltip>
          <template #default="{ row }">
            <div class="content-preview" v-html="renderMarkdown(row.backContent)"></div>
          </template>
        </el-table-column>
        <el-table-column prop="difficultyLevel" label="难度" width="80">
          <template #default="{ row }">
            <el-tag :type="getDifficultyType(row.difficultyLevel)">
              {{ getDifficultyLabel(row.difficultyLevel) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createUserNickname" label="提交用户" width="100">
          <template #default="{ row }">
            <span>{{ row.createUserNickname || '未知用户' }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="auditStatus" label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="getStatusTagType(row.auditStatus)">
              {{ row.auditStatusText || getStatusLabel(row.auditStatus) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="提交时间" width="160" />
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button 
              v-if="row.auditStatus === '0'" 
              type="success" 
              size="small" 
              @click="handleApprove(row)"
            >通过</el-button>
            <el-button 
              v-if="row.auditStatus === '0'" 
              type="danger" 
              size="small" 
              @click="handleReject(row)"
            >拒绝</el-button>
            <el-button type="primary" size="small" @click="handleView(row)">详情</el-button>
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

    <!-- 详情弹窗 -->
    <el-dialog v-model="dialogVisible" title="卡片详情" width="800px">
      <el-descriptions :column="2" border>
        <el-descriptions-item label="卡片ID">{{ currentCard?.cardId }}</el-descriptions-item>
        <el-descriptions-item label="所属科目">{{ currentCard?.subjectName }}</el-descriptions-item>
        <el-descriptions-item label="难度系数">
          <el-tag :type="getDifficultyType(currentCard?.difficultyLevel)">
            {{ getDifficultyLabel(currentCard?.difficultyLevel) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="审批状态">
          <el-tag :type="getStatusTagType(currentCard?.auditStatus)">
            {{ currentCard?.auditStatusText || getStatusLabel(currentCard?.auditStatus) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="提交用户">{{ currentCard?.createUserNickname || '未知用户' }}</el-descriptions-item>
        <el-descriptions-item label="提交时间">{{ currentCard?.createTime }}</el-descriptions-item>
        <el-descriptions-item label="审批人" v-if="currentCard?.auditUserNickname">
          {{ currentCard?.auditUserNickname }}
        </el-descriptions-item>
        <el-descriptions-item label="审批时间" v-if="currentCard?.auditTime">
          {{ currentCard?.auditTime }}
        </el-descriptions-item>
        <el-descriptions-item label="卡片正面" :span="2">
          <div class="content-detail" v-html="renderMarkdown(currentCard?.frontContent || '')"></div>
        </el-descriptions-item>
        <el-descriptions-item label="卡片反面" :span="2">
          <div class="content-detail" v-html="renderMarkdown(currentCard?.backContent || '')"></div>
        </el-descriptions-item>
        <el-descriptions-item label="审批备注" :span="2" v-if="currentCard?.auditRemark">
          {{ currentCard?.auditRemark }}
        </el-descriptions-item>
      </el-descriptions>

      <!-- 审批操作（待审批状态） -->
      <el-divider v-if="currentCard?.auditStatus === '0'" />
      <el-form v-if="currentCard?.auditStatus === '0'" :model="auditForm" label-width="100px">
        <el-form-item label="审批结果">
          <el-radio-group v-model="auditForm.auditStatus">
            <el-radio value="1">通过</el-radio>
            <el-radio value="2">拒绝</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="审批备注">
          <el-input
            v-model="auditForm.auditRemark"
            type="textarea"
            :rows="3"
            placeholder="填写审批备注（拒绝时建议填写原因）"
          />
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="dialogVisible = false">关闭</el-button>
        <el-button 
          v-if="currentCard?.auditStatus === '0'" 
          type="primary" 
          :loading="auditLoading" 
          @click="handleAudit"
        >提交审批</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { 
  getCardAuditPage, 
  auditCard, 
  getPendingCardCount 
} from '@/api/content'
import type { CardAuditVO } from '@/api/types'
import { useUserStore } from '@/store/user'

const userStore = useUserStore()

// 查询参数
const queryParams = reactive({
  auditStatus: '',
  pageNum: 1,
  pageSize: 10
})

const tableData = ref<CardAuditVO[]>([])
const total = ref(0)
const loading = ref(false)
const pendingCount = ref(0)
const dialogVisible = ref(false)
const currentCard = ref<CardAuditVO | null>(null)
const auditLoading = ref(false)

const auditForm = reactive({
  auditStatus: '1',
  auditRemark: ''
})

// 难度标签类型
const getDifficultyType = (level: number | undefined) => {
  const map: Record<number, string> = {
    1: 'success',
    2: 'info',
    3: 'warning',
    4: 'danger',
    5: 'danger'
  }
  return map[level || 2] || 'info'
}

// 难度标签文本
const getDifficultyLabel = (level: number | undefined) => {
  const map: Record<number, string> = {
    1: '简单',
    2: '中等',
    3: '较难',
    4: '困难',
    5: '极难'
  }
  return map[level || 2] || '中等'
}

// 状态标签类型
const getStatusTagType = (status: string | undefined) => {
  const map: Record<string, string> = {
    '0': 'warning',
    '1': 'success',
    '2': 'danger'
  }
  return map[status || '0'] || 'info'
}

// 状态标签文本
const getStatusLabel = (status: string | undefined) => {
  const map: Record<string, string> = {
    '0': '待审批',
    '1': '已通过',
    '2': '已拒绝'
  }
  return map[status || '0'] || '未知'
}

// Markdown渲染函数
const renderMarkdown = (text: string): string => {
  if (!text) return ''
  
  let html = text
  
  // 加粗 **text**
  html = html.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
  
  // 斜体 *text* 或 _text_
  html = html.replace(/\*(.+?)\*/g, '<em>$1</em>')
  html = html.replace(/_(.+?)_/g, '<em>$1</em>')
  
  // 代码 `code`
  html = html.replace(/`(.+?)`/g, '<code>$1</code>')
  
  // 标题
  html = html.replace(/^### (.+)$/gm, '<h3>$1</h3>')
  html = html.replace(/^## (.+)$/gm, '<h2>$1</h2>')
  html = html.replace(/^# (.+)$/gm, '<h1>$1</h1>')
  
  // 换行
  html = html.replace(/\n/g, '<br/>')
  
  return html
}

// 获取数据
const fetchData = async () => {
  loading.value = true
  try {
    const res = await getCardAuditPage(queryParams)
    tableData.value = res.data.records
    total.value = res.data.total
  } catch (error) {
    console.error(error)
    ElMessage.error('获取数据失败')
  } finally {
    loading.value = false
  }
}

// 获取待审批数量
const fetchPendingCount = async () => {
  try {
    const res = await getPendingCardCount()
    pendingCount.value = res.data
  } catch (error) {
    console.error(error)
  }
}

// 筛选待审批
const filterPending = () => {
  queryParams.auditStatus = '0'
  fetchData()
}

// 查看详情
const handleView = (row: CardAuditVO) => {
  currentCard.value = { ...row }
  auditForm.auditStatus = '1'
  auditForm.auditRemark = ''
  dialogVisible.value = true
}

// 快捷通过
const handleApprove = async (row: CardAuditVO) => {
  await ElMessageBox.confirm('确定通过该卡片？通过后将添加到知识库中', '审批确认', { 
    type: 'success',
    confirmButtonText: '通过',
    cancelButtonText: '取消'
  })
  
  try {
    const userId = userStore.userInfo?.userId || 1
    await auditCard({ 
      cardId: row.cardId!, 
      auditStatus: '1', 
      auditUserId: userId 
    })
    ElMessage.success('审批通过，卡片已添加到知识库')
    fetchData()
    fetchPendingCount()
  } catch (error) {
    console.error(error)
    ElMessage.error('审批失败')
  }
}

// 快捷拒绝
const handleReject = async (row: CardAuditVO) => {
  const { value } = await ElMessageBox.prompt('请输入拒绝原因', '审批拒绝', {
    confirmButtonText: '拒绝',
    cancelButtonText: '取消',
    inputPattern: /.+/,
    inputErrorMessage: '请输入拒绝原因'
  })
  
  try {
    const userId = userStore.userInfo?.userId || 1
    await auditCard({ 
      cardId: row.cardId!, 
      auditStatus: '2', 
      auditUserId: userId,
      auditRemark: value 
    })
    ElMessage.warning('已拒绝该卡片')
    fetchData()
    fetchPendingCount()
  } catch (error) {
    console.error(error)
    ElMessage.error('审批失败')
  }
}

// 弹窗内提交审批
const handleAudit = async () => {
  if (!currentCard.value?.cardId) return
  
  auditLoading.value = true
  try {
    const userId = userStore.userInfo?.userId || 1
    await auditCard({ 
      cardId: currentCard.value.cardId, 
      auditStatus: auditForm.auditStatus, 
      auditUserId: userId,
      auditRemark: auditForm.auditRemark 
    })
    
    const msg = auditForm.auditStatus === '1' ? '审批通过，卡片已添加到知识库' : '已拒绝该卡片'
    ElMessage.success(msg)
    dialogVisible.value = false
    fetchData()
    fetchPendingCount()
  } catch (error) {
    console.error(error)
    ElMessage.error('审批失败')
  } finally {
    auditLoading.value = false
  }
}

onMounted(() => {
  fetchData()
  fetchPendingCount()
})
</script>

<style scoped lang="scss">
.card-audit-page {
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

    .status-select {
      width: 120px;
    }
  }

  .el-pagination {
    margin-top: 16px;
    justify-content: flex-end;
  }

  .content-preview {
    max-height: 60px;
    overflow: hidden;
    line-height: 1.5;
    
    strong {
      font-weight: bold;
      color: #409eff;
    }
    
    em {
      font-style: italic;
    }
    
    code {
      background-color: #f5f5f5;
      padding: 2px 4px;
      border-radius: 2px;
      font-family: monospace;
    }
  }

  .content-detail {
    line-height: 1.8;
    
    strong {
      font-weight: bold;
      color: #409eff;
    }
    
    em {
      font-style: italic;
    }
    
    code {
      background-color: #f5f5f5;
      padding: 2px 6px;
      border-radius: 4px;
      font-family: monospace;
      color: #e96900;
    }
    
    h1, h2, h3 {
      margin: 8px 0;
      color: #303133;
    }
    
    br {
      display: block;
      content: '';
      margin-top: 8px;
    }
  }
}

@media screen and (max-width: 768px) {
  .card-audit-page {
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