<template>
  <div class="subject-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>科目管理</span>
          <el-button type="primary" @click="handleAdd">新增</el-button>
        </div>
      </template>

      <!-- 搜索表单 -->
      <el-form :inline="true" class="search-form">
        <el-form-item label="所属专业">
          <el-select
            v-model="queryParams.majorId"
            placeholder="请选择专业"
            clearable
            class="major-select"
          >
            <el-option
              v-for="item in majorList"
              :key="item.majorId"
              :label="item.majorName"
              :value="item.majorId"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="科目名称">
          <el-input
            v-model="queryParams.subjectName"
            placeholder="请输入科目名称"
            clearable
            class="search-input"
            @keyup.enter="handleSearch"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="tableData" border stripe v-loading="loading">
        <el-table-column prop="subjectId" label="ID" width="80" />
        <el-table-column prop="majorName" label="所属专业" width="120" />
        <el-table-column prop="subjectName" label="科目名称" />
        <el-table-column prop="icon" label="图标" width="80">
          <template #default="{ row }">
            <el-image v-if="row.icon" :src="row.icon" style="width: 40px; height: 40px" fit="contain" />
            <span v-else class="text-muted">无</span>
          </template>
        </el-table-column>
        <el-table-column prop="orderNum" label="排序" width="80" />
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
        <el-form-item label="所属专业" prop="majorId">
          <el-select
            v-model="formData.majorId"
            placeholder="请选择专业"
            style="width: 100%"
          >
            <el-option
              v-for="item in majorList"
              :key="item.majorId"
              :label="item.majorName"
              :value="item.majorId"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="科目名称" prop="subjectName">
          <el-input v-model="formData.subjectName" placeholder="请输入科目名称" />
        </el-form-item>
        <el-form-item label="图标" prop="icon">
          <el-input v-model="formData.icon" placeholder="请输入图标URL（可选）" />
        </el-form-item>
        <el-form-item label="排序" prop="orderNum">
          <el-input-number v-model="formData.orderNum" :min="0" :max="100" />
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
import { getSubjectPage, createSubject, updateSubject, deleteSubject, getMajorList } from '@/api/content'
import type { Subject, Major } from '@/api/types'

const formRef = ref<FormInstance>()
const loading = ref(false)
const submitLoading = ref(false)
const dialogVisible = ref(false)
const dialogTitle = ref('新增科目')
const tableData = ref<Subject[]>([])
const majorList = ref<Major[]>([])
const total = ref(0)

// 查询参数
const queryParams = reactive({
  majorId: undefined as number | undefined,
  subjectName: '',
  pageNum: 1,
  pageSize: 10
})

// 表单数据
const formData = reactive<Subject>({
  subjectId: undefined,
  majorId: undefined as number | undefined,
  subjectName: '',
  icon: '',
  orderNum: 0
})

const rules: FormRules = {
  majorId: [{ required: true, message: '请选择专业', trigger: 'change' }],
  subjectName: [{ required: true, message: '请输入科目名称', trigger: 'blur' }]
}

// 获取数据
const fetchData = async () => {
  loading.value = true
  try {
    const res = await getSubjectPage(queryParams)
    tableData.value = res.data.records
    total.value = res.data.total
  } catch (error) {
    console.error(error)
  } finally {
    loading.value = false
  }
}

// 获取专业列表（用于下拉选择）
const fetchMajorList = async () => {
  try {
    const res = await getMajorList()
    majorList.value = res.data
  } catch (error) {
    console.error(error)
  }
}

// 查询
const handleSearch = () => {
  queryParams.pageNum = 1
  fetchData()
}

// 重置查询
const handleReset = () => {
  queryParams.majorId = undefined
  queryParams.subjectName = ''
  queryParams.pageNum = 1
  fetchData()
}

// 新增
const handleAdd = () => {
  dialogTitle.value = '新增科目'
  formData.subjectId = undefined
  formData.majorId = undefined
  formData.subjectName = ''
  formData.icon = ''
  formData.orderNum = 0
  dialogVisible.value = true
}

// 编辑
const handleEdit = (row: Subject) => {
  dialogTitle.value = '编辑科目'
  formData.subjectId = row.subjectId
  formData.majorId = row.majorId
  formData.subjectName = row.subjectName
  formData.icon = row.icon || ''
  formData.orderNum = row.orderNum || 0
  dialogVisible.value = true
}

// 删除
const handleDelete = async (row: Subject) => {
  await ElMessageBox.confirm('确定删除该科目？', '提示', { type: 'warning' })
  try {
    await deleteSubject(row.subjectId!)
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
    if (formData.subjectId) {
      await updateSubject(formData)
      ElMessage.success('更新成功')
    } else {
      await createSubject(formData)
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
  fetchMajorList()
})
</script>

<style scoped lang="scss">
.subject-page {
  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .search-form {
    margin-bottom: 16px;

    .major-select {
      width: 150px;
    }

    .search-input {
      width: 200px;
    }
  }

  .el-pagination {
    margin-top: 16px;
    justify-content: flex-end;
  }

  .text-muted {
    color: #909399;
  }
}
</style>
