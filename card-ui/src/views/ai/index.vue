<template>
  <div class="ai-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>AI智能工作站</span>
        </div>
      </template>
      <el-form ref="formRef" :model="formData" :rules="rules" label-width="100px">
        <el-form-item label="选择科目" prop="subjectId">
          <el-select v-model="formData.subjectId" placeholder="请选择科目" style="width: 200px">
            <el-option
              v-for="subject in subjectList"
              :key="subject.subjectId"
              :label="subject.subjectName"
              :value="subject.subjectId"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="知识内容" prop="content">
          <el-input
            v-model="formData.content"
            type="textarea"
            :rows="10"
            placeholder="请粘贴知识点内容，AI将自动解析并拆分为卡片"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="loading" @click="handleConvert">解析</el-button>
          <el-button type="success" :disabled="previewData.length === 0" @click="handleBatchSave">批量保存</el-button>
        </el-form-item>
      </el-form>

      <el-divider content-position="left">解析结果</el-divider>

      <el-table :data="previewData" border stripe max-height="400px" v-if="previewData.length > 0">
        <el-table-column type="index" label="#" width="60" />
        <el-table-column prop="frontContent" label="正面内容" show-overflow-tooltip />
        <el-table-column prop="backContent" label="反面内容" show-overflow-tooltip />
        <el-table-column prop="difficultyLevel" label="难度" width="120">
          <template #default="{ row }">
            <el-rate v-model="row.difficultyLevel" :max="5" />
          </template>
        </el-table-column>
        <el-table-column prop="tags" label="标签" width="150">
          <template #default="{ row }">
            <el-tag v-for="tag in row.tags" :key="tag" size="small" style="margin-right: 4px">
              {{ tag }}
            </el-tag>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import request from '@/api/request'

interface Subject {
  subjectId: number
  subjectName: string
}

interface AiCardDTO {
  frontContent: string
  backContent: string
  difficultyLevel: number
  tags?: string[]
}

const formRef = ref<FormInstance>()
const loading = ref(false)
const subjectList = ref<Subject[]>([])

const formData = reactive({
  subjectId: undefined as number | undefined,
  content: ''
})

const rules: FormRules = {
  subjectId: [{ required: true, message: '请选择科目', trigger: 'change' }],
  content: [{ required: true, message: '请输入内容', trigger: 'blur' }]
}

const previewData = ref<AiCardDTO[]>([])

const fetchSubjectList = async () => {
  try {
    const res = await request.get('/subject/list')
    subjectList.value = res.data
  } catch (error) {
    console.error(error)
  }
}

const handleConvert = async () => {
  await formRef.value?.validate()
  loading.value = true
  try {
    const res = await request.post('/ai/convert', { content: formData.content })
    previewData.value = res.data
    ElMessage.success(`解析成功，生成 ${previewData.value.length} 张卡片`)
  } catch (error) {
    console.error(error)
    ElMessage.error('解析失败')
  } finally {
    loading.value = false
  }
}

const handleBatchSave = async () => {
  if (previewData.value.length === 0) {
    ElMessage.warning('请先解析内容')
    return
  }
  loading.value = true
  try {
    await request.post('/ai/batchSave', previewData.value, {
      params: { subjectId: formData.subjectId }
    })
    ElMessage.success('批量保存成功')
    previewData.value = []
    formData.content = ''
  } catch (error) {
    console.error(error)
    ElMessage.error('保存失败')
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchSubjectList()
})
</script>

<style scoped lang="scss">
.ai-page {
  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
}
</style>