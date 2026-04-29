<template>
  <div class="tag-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>标签管理</span>
          <el-button type="primary" @click="handleAdd">新增</el-button>
        </div>
      </template>

      <!-- 搜索表单 -->
      <el-form :inline="true" class="search-form">
        <el-form-item label="标签名称">
          <el-input
            v-model="queryParams.tagName"
            placeholder="请输入标签名称"
            clearable
            style="width: 200px"
            @keyup.enter="fetchData"
          />
        </el-form-item>
        <el-form-item label="科目">
          <el-select
            v-model="queryParams.subjectId"
            placeholder="全部科目"
            clearable
            style="width: 180px"
          >
            <el-option label="通用标签" value="null" />
            <el-option
              v-for="subject in subjectList"
              :key="subject.subjectId"
              :label="subject.subjectName"
              :value="subject.subjectId"
            />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="fetchData">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 标签列表 -->
      <el-table :data="tableData" border stripe>
        <el-table-column prop="tagId" label="ID" width="80" />
        <el-table-column prop="tagName" label="标签名称" />
        <el-table-column prop="subjectName" label="所属科目" width="150">
          <template #default="{ row }">
            <span :class="{ 'common-tag': !row.subjectId }">
              {{ row.subjectId ? row.subjectName : '通用标签' }}
            </span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150">
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

    <!-- 新增/编辑对话框 -->
    <el-dialog v-model="dialogVisible" :title="isEdit ? '编辑标签' : '新增标签'" width="400px">
      <el-form ref="formRef" :model="formData" :rules="rules" label-width="100px">
        <el-form-item label="所属科目" prop="subjectId">
          <el-select v-model="formData.subjectId" placeholder="选择科目（不选为通用标签）" clearable style="width: 100%">
            <el-option
              v-for="subject in subjectList"
              :key="subject.subjectId"
              :label="subject.subjectName"
              :value="subject.subjectId"
            />
          </el-select>
          <div class="form-tip">不选择科目则为通用标签，可在任意科目卡片中使用</div>
        </el-form-item>
        <el-form-item label="标签名称" prop="tagName">
          <el-input v-model="formData.tagName" placeholder="请输入标签名称" />
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
import { getTagPage, createTag, updateTag, deleteTag, getSubjectList } from '@/api/content'
import type { Tag, Subject } from '@/api/types'

const formRef = ref<FormInstance>()
const loading = ref(false)
const dialogVisible = ref(false)
const isEdit = ref(false)
const tableData = ref<Tag[]>([])
const subjectList = ref<Subject[]>([])
const total = ref(0)

const queryParams = reactive({
  tagName: '' as string,
  subjectId: undefined as number | undefined,
  pageNum: 1,
  pageSize: 10
})

const formData = reactive<Tag>({
  tagId: undefined,
  tagName: '',
  subjectId: undefined
})

const rules: FormRules = {
  tagName: [{ required: true, message: '请输入标签名称', trigger: 'blur' }]
}

const fetchData = async () => {
  try {
    const params = {
      tagName: queryParams.tagName || undefined,
      subjectId: queryParams.subjectId,
      pageNum: queryParams.pageNum,
      pageSize: queryParams.pageSize
    }
    const res = await getTagPage(params)
    tableData.value = res.data.records
    total.value = res.data.total
  } catch (error) {
    console.error(error)
  }
}

const fetchSubjectList = async () => {
  try {
    const res = await getSubjectList()
    subjectList.value = res.data
  } catch (error) {
    console.error(error)
  }
}

const handleReset = () => {
  queryParams.tagName = ''
  queryParams.subjectId = undefined
  queryParams.pageNum = 1
  fetchData()
}

const handleAdd = () => {
  isEdit.value = false
  formData.tagId = undefined
  formData.tagName = ''
  formData.subjectId = undefined
  dialogVisible.value = true
}

const handleEdit = (row: Tag) => {
  isEdit.value = true
  formData.tagId = row.tagId
  formData.tagName = row.tagName
  formData.subjectId = row.subjectId
  dialogVisible.value = true
}

const handleDelete = async (row: Tag) => {
  await ElMessageBox.confirm('确定删除该标签？删除后关联该标签的卡片将失去此标签关联。', '提示', { type: 'warning' })
  try {
    await deleteTag(row.tagId!)
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
    if (isEdit.value) {
      await updateTag(formData)
      ElMessage.success('更新成功')
    } else {
      await createTag(formData)
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
  fetchSubjectList()
})
</script>

<style scoped lang="scss">
.tag-page {
  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .search-form {
    margin-bottom: 16px;
  }

  .el-pagination {
    margin-top: 16px;
    justify-content: flex-end;
  }

  .common-tag {
    color: #409eff;
    font-weight: 500;
  }

  .form-tip {
    font-size: 12px;
    color: #909399;
    margin-top: 4px;
  }
}
</style>