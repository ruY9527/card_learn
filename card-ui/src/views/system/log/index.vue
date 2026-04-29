<template>
  <div class="log-container">
    <!-- 统计卡片 -->
    <el-row :gutter="20" class="stats-row">
      <el-col :span="6">
        <el-card shadow="hover" class="stats-card">
          <div class="stats-content">
            <div class="stats-icon" style="background: #409eff">
              <el-icon><Document /></el-icon>
            </div>
            <div class="stats-info">
              <div class="stats-value">{{ stats.total }}</div>
              <div class="stats-label">总日志数</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stats-card">
          <div class="stats-content">
            <div class="stats-icon" style="background: #67c23a">
              <el-icon><SuccessFilled /></el-icon>
            </div>
            <div class="stats-info">
              <div class="stats-value">{{ stats.success }}</div>
              <div class="stats-label">成功请求</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stats-card">
          <div class="stats-content">
            <div class="stats-icon" style="background: #f56c6c">
              <el-icon><CircleCloseFilled /></el-icon>
            </div>
            <div class="stats-info">
              <div class="stats-value">{{ stats.fail }}</div>
              <div class="stats-label">失败请求</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stats-card">
          <div class="stats-content">
            <div class="stats-icon" style="background: #e6a23c">
              <el-icon><Clock /></el-icon>
            </div>
            <div class="stats-info">
              <div class="stats-value">{{ stats.today }}</div>
              <div class="stats-label">今日日志</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 搜索表单 -->
    <el-card shadow="never" class="search-card">
      <el-form :model="queryParams" inline>
        <el-form-item label="请求方法">
          <el-select v-model="queryParams.requestMethod" placeholder="请选择" clearable style="width: 120px">
            <el-option label="GET" value="GET" />
            <el-option label="POST" value="POST" />
            <el-option label="PUT" value="PUT" />
            <el-option label="DELETE" value="DELETE" />
          </el-select>
        </el-form-item>
        <el-form-item label="请求URL">
          <el-input v-model="queryParams.requestUrl" placeholder="请输入URL" clearable style="width: 200px" />
        </el-form-item>
        <el-form-item label="执行状态">
          <el-select v-model="queryParams.status" placeholder="请选择" clearable style="width: 120px">
            <el-option label="成功" value="1" />
            <el-option label="失败" value="0" />
          </el-select>
        </el-form-item>
        <el-form-item label="时间范围">
          <el-date-picker
            v-model="timeRange"
            type="datetimerange"
            range-separator="至"
            start-placeholder="开始时间"
            end-placeholder="结束时间"
            value-format="YYYY-MM-DD HH:mm:ss"
            style="width: 360px"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">
            <el-icon><Search /></el-icon>
            搜索
          </el-button>
          <el-button @click="resetQuery">
            <el-icon><Refresh /></el-icon>
            重置
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 日志列表 -->
    <el-card shadow="never" class="table-card">
      <el-table v-loading="loading" :data="logList" stripe border>
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="requestMethod" label="请求方法" width="100">
          <template #default="{ row }">
            <el-tag :type="getMethodTagType(row.requestMethod)" size="small">
              {{ row.requestMethod }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="requestUrl" label="请求URL" min-width="200" show-overflow-tooltip />
        <el-table-column prop="className" label="类名" min-width="180" show-overflow-tooltip />
        <el-table-column prop="methodName" label="方法名" width="120" />
        <el-table-column prop="executionTime" label="耗时(ms)" width="100">
          <template #default="{ row }">
            <el-tag :type="row.executionTime > 1000 ? 'danger' : row.executionTime > 500 ? 'warning' : 'success'" size="small">
              {{ row.executionTime }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="row.status === '1' ? 'success' : 'danger'" size="small">
              {{ row.status === '1' ? '成功' : '失败' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="ipAddress" label="IP地址" width="130" />
        <el-table-column prop="userName" label="操作用户" width="120" />
        <el-table-column prop="createTime" label="创建时间" width="180" />
        <el-table-column label="操作" width="100" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click="handleDetail(row)">
              <el-icon><View /></el-icon>
              详情
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <el-pagination
        v-model:current-page="queryParams.pageNum"
        v-model:page-size="queryParams.pageSize"
        :page-sizes="[10, 20, 50, 100]"
        :total="total"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="handleQuery"
        @current-change="handleQuery"
        class="pagination"
      />
    </el-card>

    <!-- 详情弹窗 -->
    <el-dialog v-model="detailVisible" title="日志详情" width="800px" destroy-on-close>
      <el-descriptions :column="2" border>
        <el-descriptions-item label="请求方法">
          <el-tag :type="getMethodTagType(currentLog?.requestMethod)" size="small">
            {{ currentLog?.requestMethod }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="执行状态">
          <el-tag :type="currentLog?.status === '1' ? 'success' : 'danger'" size="small">
            {{ currentLog?.status === '1' ? '成功' : '失败' }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="请求URL" :span="2">{{ currentLog?.requestUrl }}</el-descriptions-item>
        <el-descriptions-item label="类名">{{ currentLog?.className }}</el-descriptions-item>
        <el-descriptions-item label="方法名">{{ currentLog?.methodName }}</el-descriptions-item>
        <el-descriptions-item label="执行耗时">{{ currentLog?.executionTime }} ms</el-descriptions-item>
        <el-descriptions-item label="IP地址">{{ currentLog?.ipAddress }}</el-descriptions-item>
        <el-descriptions-item label="操作用户">{{ currentLog?.userName || '匿名用户' }}</el-descriptions-item>
        <el-descriptions-item label="创建时间">{{ currentLog?.createTime }}</el-descriptions-item>
      </el-descriptions>

      <el-divider content-position="left">请求参数</el-divider>
      <el-input
        :model-value="currentLog?.requestParams || ''"
        type="textarea"
        :rows="4"
        readonly
        placeholder="无请求参数"
      />

      <el-divider content-position="left">响应结果</el-divider>
      <el-input
        :model-value="currentLog?.responseResult || ''"
        type="textarea"
        :rows="4"
        readonly
        placeholder="无响应结果"
      />

      <el-divider v-if="currentLog?.errorMsg" content-position="left">错误信息</el-divider>
      <el-input
        v-if="currentLog?.errorMsg"
        :model-value="currentLog?.errorMsg"
        type="textarea"
        :rows="3"
        readonly
        style="color: #f56c6c"
      />
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { getLogList, getLogStats } from '@/api/log'
import type { RequestLog, LogStats } from '@/api/types'

// 统计数据
const stats = reactive<LogStats>({
  total: 0,
  success: 0,
  fail: 0,
  today: 0
})

// 查询参数
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  requestMethod: '',
  requestUrl: '',
  status: ''
})

// 时间范围
const timeRange = ref<[string, string] | null>(null)

// 日志列表
const logList = ref<RequestLog[]>([])
const total = ref(0)
const loading = ref(false)

// 详情弹窗
const detailVisible = ref(false)
const currentLog = ref<RequestLog | null>(null)

// 获取方法标签类型
const getMethodTagType = (method: string | undefined) => {
  if (!method) return ''
  const types: Record<string, string> = {
    GET: '',
    POST: 'success',
    PUT: 'warning',
    DELETE: 'danger'
  }
  return types[method] || ''
}

// 获取统计数据
const fetchStats = async () => {
  try {
    const res = await getLogStats()
    Object.assign(stats, res.data)
  } catch (error) {
    console.error('获取统计失败:', error)
  }
}

// 获取日志列表
const fetchLogList = async () => {
  loading.value = true
  try {
    const params: any = { ...queryParams }

    // 处理时间范围
    if (timeRange.value && timeRange.value.length === 2) {
      params.startTime = timeRange.value[0]
      params.endTime = timeRange.value[1]
    }

    const res = await getLogList(params)
    logList.value = res.data.records
    total.value = res.data.total
  } catch (error) {
    console.error('获取日志列表失败:', error)
  } finally {
    loading.value = false
  }
}

// 搜索
const handleQuery = () => {
  queryParams.pageNum = 1
  fetchLogList()
}

// 重置
const resetQuery = () => {
  queryParams.requestMethod = ''
  queryParams.requestUrl = ''
  queryParams.status = ''
  timeRange.value = null
  handleQuery()
}

// 查看详情
const handleDetail = (row: RequestLog) => {
  currentLog.value = row
  detailVisible.value = true
}

// 初始化
onMounted(() => {
  fetchStats()
  fetchLogList()
})
</script>

<style scoped lang="scss">
.log-container {
  padding: 20px;

  .stats-row {
    margin-bottom: 20px;
  }

  .stats-card {
    .stats-content {
      display: flex;
      align-items: center;
      gap: 16px;
    }

    .stats-icon {
      width: 48px;
      height: 48px;
      border-radius: 8px;
      display: flex;
      align-items: center;
      justify-content: center;
      color: #fff;
      font-size: 24px;
    }

    .stats-info {
      .stats-value {
        font-size: 24px;
        font-weight: 600;
        color: #303133;
      }

      .stats-label {
        font-size: 14px;
        color: #909399;
      }
    }
  }

  .search-card {
    margin-bottom: 20px;
  }

  .table-card {
    .pagination {
      margin-top: 20px;
      justify-content: flex-end;
    }
  }
}
</style>