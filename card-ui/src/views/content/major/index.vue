<template>
  <div class="major-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>专业管理</span>
          <el-button type="primary" @click="handleAdd">新增</el-button>
        </div>
      </template>
      <el-table :data="tableData" border stripe>
        <el-table-column prop="majorId" label="ID" width="80" />
        <el-table-column prop="majorName" label="专业名称" />
        <el-table-column prop="description" label="描述" />
        <el-table-column prop="status" label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="row.status === '0' ? 'success' : 'danger'">
              {{ row.status === '0' ? '正常' : '停用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="500px">
      <el-form ref="formRef" :model="formData" :rules="rules" label-width="100px">
        <el-form-item label="专业名称" prop="majorName">
          <el-input v-model="formData.majorName" placeholder="请输入专业名称" />
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input v-model="formData.description" type="textarea" placeholder="请输入描述" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="loading" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import { getMajorList, createMajor, updateMajor, deleteMajor } from '@/api/content'
import type { Major } from '@/api/types'

const formRef = ref<FormInstance>()
const loading = ref(false)
const dialogVisible = ref(false)
const dialogTitle = ref('新增专业')
const tableData = ref<Major[]>([])

const formData = reactive<Major>({
  majorId: undefined,
  majorName: '',
  description: ''
})

const rules: FormRules = {
  majorName: [{ required: true, message: '请输入专业名称', trigger: 'blur' }]
}

const fetchData = async () => {
  try {
    const res = await getMajorList()
    tableData.value = res.data
  } catch (error) {
    console.error(error)
  }
}

const handleAdd = () => {
  dialogTitle.value = '新增专业'
  formData.majorId = undefined
  formData.majorName = ''
  formData.description = ''
  dialogVisible.value = true
}

const handleEdit = (row: Major) => {
  dialogTitle.value = '编辑专业'
  formData.majorId = row.majorId
  formData.majorName = row.majorName
  formData.description = row.description || ''
  dialogVisible.value = true
}

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

const handleSubmit = async () => {
  await formRef.value?.validate()
  loading.value = true
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
    loading.value = false
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
}
</style>