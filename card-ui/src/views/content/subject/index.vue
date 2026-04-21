<template>
  <div class="subject-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>科目管理</span>
          <el-button type="primary" @click="handleAdd">新增</el-button>
        </div>
      </template>
      <el-table :data="tableData" border stripe>
        <el-table-column prop="subjectId" label="ID" width="80" />
        <el-table-column prop="majorId" label="所属专业" width="100" />
        <el-table-column prop="subjectName" label="科目名称" />
        <el-table-column prop="orderNum" label="排序" width="80" />
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
        <el-form-item label="所属专业" prop="majorId">
          <el-select v-model="formData.majorId" placeholder="请选择专业">
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
        <el-form-item label="排序" prop="orderNum">
          <el-input-number v-model="formData.orderNum" :min="0" />
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
import { getSubjectList, createSubject, updateSubject, deleteSubject, getMajorList } from '@/api/content'
import type { Subject, Major } from '@/api/types'

const formRef = ref<FormInstance>()
const loading = ref(false)
const dialogVisible = ref(false)
const dialogTitle = ref('新增科目')
const tableData = ref<Subject[]>([])
const majorList = ref<Major[]>([])

const formData = reactive<Subject>({
  subjectId: undefined,
  majorId: undefined as unknown as number,
  subjectName: '',
  orderNum: 0
})

const rules: FormRules = {
  majorId: [{ required: true, message: '请选择专业', trigger: 'change' }],
  subjectName: [{ required: true, message: '请输入科目名称', trigger: 'blur' }]
}

const fetchData = async () => {
  try {
    const res = await getSubjectList()
    tableData.value = res.data
  } catch (error) {
    console.error(error)
  }
}

const fetchMajorList = async () => {
  try {
    const res = await getMajorList()
    majorList.value = res.data
  } catch (error) {
    console.error(error)
  }
}

const handleAdd = () => {
  dialogTitle.value = '新增科目'
  formData.subjectId = undefined
  formData.majorId = undefined as unknown as number
  formData.subjectName = ''
  formData.orderNum = 0
  dialogVisible.value = true
}

const handleEdit = (row: Subject) => {
  dialogTitle.value = '编辑科目'
  formData.subjectId = row.subjectId
  formData.majorId = row.majorId
  formData.subjectName = row.subjectName
  formData.orderNum = row.orderNum || 0
  dialogVisible.value = true
}

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

const handleSubmit = async () => {
  await formRef.value?.validate()
  loading.value = true
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
    loading.value = false
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
}
</style>