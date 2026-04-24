<template>
  <div class="major-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>专业管理</span>
          <el-button type="primary" @click="handleAdd">新增</el-button>
        </div>
      </template>
      
      <!-- 搜索表单 -->
      <el-form :inline="true" class="search-form">
        <el-form-item label="专业名称">
          <el-input
            v-model="queryParams.majorName"
            placeholder="请输入专业名称"
            clearable
            class="search-input"
            @keyup.enter="handleSearch"
          />
        </el-form-item>
        <el-form-item label="状态">
          <el-select
            v-model="queryParams.status"
            placeholder="请选择状态"
            clearable
            class="status-select"
          >
            <el-option label="正常" value="0" />
            <el-option label="停用" value="1" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="tableData" border stripe v-loading="loading">
        <el-table-column prop="majorId" label="ID" width="80" />
        <el-table-column prop="majorName" label="专业名称" />
        <el-table-column prop="description" label="描述" show-overflow-tooltip />
        <el-table-column prop="status" label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="row.status === '0' ? 'success' : 'danger'">
              {{ row.status === '0' ? '正常' : '停用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180" />
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
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
      />
    </el-card>

    <!-- 新增/编辑弹窗 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="500px">
      <el-form ref="formRef" :model="formData" :rules="rules" label-width="100px">
        <el-form-item label="专业名称" prop="majorName">
          <el-input v-model="formData.majorName" placeholder="请输入专业名称" />
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input v-model="formData.description" type="textarea" :rows="3" placeholder="请输入描述" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="formData.status">
            <el-radio value="0">正常</el-radio>
            <el-radio value="1">停用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitLoading" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import { getMajorPage, createMajor, updateMajor, deleteMajor } from '@/api/content'
import type { Major } from '@/api/types'

const formRef = ref<FormInstance>()
const loading = ref(false)
const submitLoading = ref(false)
const dialogVisible = ref(false)
const dialogTitle = ref('新增专业')
const tableData = ref<Major[]>([])
const total = ref(0)

// 查询参数
const queryParams = reactive({
  majorName: '',
  status: '',
  pageNum: 1,
  pageSize: 10
})

// 表单数据
const formData = reactive<Major>({
  majorId: undefined,
  majorName: '',
  description: '',
  status: '0'
})

const rules: FormRules = {
  majorName: [{ required: true, message: '请输入专业名称', trigger: 'blur' }]
}

// 获取数据
const fetchData = async () => {
  loading.value = true
  try {
    const res = await getMajorPage(queryParams)
    tableData.value = res.data.records
    total.value = res.data.total
  } catch (error) {
    console.error(error)
  } finally {
    loading.value = false
  }
}

// 查询
const handleSearch = () => {
  queryParams.pageNum = 1
  fetchData()
}

// 重置查询
const handleReset = () => {
  queryParams.majorName = ''
  queryParams.status = ''
  queryParams.pageNum = 1
  fetchData()
}

// 新增
const handleAdd = () => {
  dialogTitle.value = '新增专业'
  formData.majorId = undefined
  formData.majorName = ''
  formData.description = ''
  formData.status = '0'
  dialogVisible.value = true
}

// 编辑
const handleEdit = (row: Major) => {
  dialogTitle.value = '编辑专业'
  formData.majorId = row.majorId
  formData.majorName = row.majorName
  formData.description = row.description || ''
  formData.status = row.status || '0'
  dialogVisible.value = true
}

// 删除
const handleDelete = async (row: Major) => {
  await ElMessageBox.confirm('确定删除该专业？', '提示', { type: 'warning' })
  try {
    await deleteMajor(row.majorId!)
    ElMessage.success('删除成功')
    fetchData()
  } catch (error) {
    console.error(error)
  }
}

// 提交
const handleSubmit = async () => {
  await formRef.value?.validate()
  submitLoading.value = true
  try {
    if (formData.majorId) {
      await updateMajor(formData)
      ElMessage.success('更新成功')
    } else {
      await createMajor(formData)
      ElMessage.success('创建成功')
    }
    dialogVisible.value = false
    fetchData()
  } catch (error) {
    console.error(error)
  } finally {
    submitLoading.value = false
  }
}

onMounted(() => {
  fetchData()
})
</script>

<style scoped lang="scss">
.major-page {
  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .search-form {
    margin-bottom: 16px;

    .search-input {
      width: 200px;
    }

    .status-select {
      width: 120px;
    }
  }

  .el-pagination {
    margin-top: 16px;
    justify-content: flex-end;
  }
}
</style>
