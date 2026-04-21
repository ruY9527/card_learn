<template>
  <div class="card-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>知识点卡片管理</span>
          <el-button type="primary" @click="handleAdd">新增</el-button>
        </div>
      </template>
      <el-form :inline="true" class="search-form">
        <el-form-item label="科目">
          <el-select
            v-model="queryParams.subjectId"
            placeholder="请选择科目"
            clearable
            style="width: 200px"
            popper-class="subject-select-popper"
          >
            <el-option
              v-for="item in subjectList"
              :key="item.subjectId"
              :label="item.subjectName"
              :value="item.subjectId"
            />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="fetchData">查询</el-button>
        </el-form-item>
      </el-form>
      <el-table :data="tableData" border stripe>
        <el-table-column prop="cardId" label="ID" width="80" />
        <el-table-column prop="subjectName" label="科目名称" width="120" />
        <el-table-column prop="frontContent" label="正面内容" show-overflow-tooltip />
        <el-table-column label="标签" width="150">
          <template #default="{ row }">
            <div class="tag-cell">
              <el-tag
                v-for="tag in row.tags"
                :key="tag.tagId"
                size="small"
                class="tag-item"
              >
                {{ tag.tagName }}
              </el-tag>
              <el-button
                type="primary"
                size="small"
                link
                @click="handleEditTags(row)"
              >
                配置
              </el-button>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="difficultyLevel" label="难度" width="80">
          <template #default="{ row }">
            <el-tag :type="getDifficultyType(row.difficultyLevel)">
              {{ row.difficultyLevel }}级
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180" />
        <el-table-column label="操作" width="150">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" size="small" @click="handleDelete(row)">删除</el-button>
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

    <!-- 新增/编辑卡片对话框 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="800px">
      <el-form ref="formRef" :model="formData" :rules="rules" label-width="100px">
        <el-form-item label="科目" prop="subjectId">
          <el-select
            v-model="formData.subjectId"
            placeholder="请选择科目"
            style="width: 100%"
            popper-class="subject-select-popper"
          >
            <el-option
              v-for="item in subjectList"
              :key="item.subjectId"
              :label="item.subjectName"
              :value="item.subjectId"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="正面内容" prop="frontContent">
          <el-input
            v-model="formData.frontContent"
            type="textarea"
            :rows="5"
            placeholder="支持Markdown/LaTeX格式"
          />
        </el-form-item>
        <el-form-item label="反面内容" prop="backContent">
          <el-input
            v-model="formData.backContent"
            type="textarea"
            :rows="5"
            placeholder="答案/解析，支持Markdown/LaTeX格式"
          />
        </el-form-item>
        <el-form-item label="难度等级" prop="difficultyLevel">
          <el-rate v-model="formData.difficultyLevel" :max="5" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="loading" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>

    <!-- 配置标签对话框 -->
    <el-dialog v-model="tagDialogVisible" title="配置标签" width="500px">
      <el-form label-width="80px">
        <el-form-item label="当前卡片">
          <el-text>{{ currentCard?.frontContent }}</el-text>
        </el-form-item>
        <el-form-item label="选择标签">
          <el-select
            v-model="selectedTagIds"
            multiple
            placeholder="请选择标签"
            style="width: 100%"
            popper-class="tag-select-popper"
          >
            <el-option
              v-for="item in allTagList"
              :key="item.tagId"
              :label="item.tagName"
              :value="item.tagId"
            />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="tagDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="tagLoading" @click="handleSaveTags">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import {
  getCardPage,
  getCardById,
  getCardTags,
  createCard,
  updateCard,
  setCardTags,
  deleteCard,
  getSubjectList,
  getTagList
} from '@/api/content'
import type { Card, Subject, Tag } from '@/api/types'

interface CardWithTags extends Card {
  tags: Tag[]
}

const formRef = ref<FormInstance>()
const loading = ref(false)
const dialogVisible = ref(false)
const dialogTitle = ref('新增卡片')
const tableData = ref<CardWithTags[]>([])
const subjectList = ref<Subject[]>([])
const allTagList = ref<Tag[]>([])
const total = ref(0)

// 标签配置相关
const tagDialogVisible = ref(false)
const tagLoading = ref(false)
const currentCard = ref<Card | null>(null)
const selectedTagIds = ref<number[]>([])

const queryParams = reactive({
  subjectId: undefined as number | undefined,
  pageNum: 1,
  pageSize: 10
})

const formData = reactive<Card>({
  cardId: undefined,
  subjectId: undefined as unknown as number,
  frontContent: '',
  backContent: '',
  difficultyLevel: 1
})

const rules: FormRules = {
  subjectId: [{ required: true, message: '请选择科目', trigger: 'change' }],
  frontContent: [{ required: true, message: '请输入正面内容', trigger: 'blur' }],
  backContent: [{ required: true, message: '请输入反面内容', trigger: 'blur' }]
}

const getDifficultyType = (level: number) => {
  if (level <= 2) return 'success'
  if (level === 3) return 'warning'
  return 'danger'
}

const fetchData = async () => {
  try {
    const res = await getCardPage(queryParams)
    // 为每张卡片加载标签
    const cards = res.data.records
    const cardsWithTags: CardWithTags[] = await Promise.all(
      cards.map(async (card) => {
        try {
          const tagRes = await getCardTags(card.cardId!)
          return { ...card, tags: tagRes.data || [] }
        } catch {
          return { ...card, tags: [] }
        }
      })
    )
    tableData.value = cardsWithTags
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

const fetchTagList = async () => {
  try {
    const res = await getTagList()
    allTagList.value = res.data
  } catch (error) {
    console.error(error)
  }
}

const handleAdd = () => {
  dialogTitle.value = '新增卡片'
  formData.cardId = undefined
  formData.subjectId = undefined as unknown as number
  formData.frontContent = ''
  formData.backContent = ''
  formData.difficultyLevel = 1
  dialogVisible.value = true
}

const handleEdit = async (row: Card) => {
  dialogTitle.value = '编辑卡片'
  try {
    const res = await getCardById(row.cardId!)
    formData.cardId = res.data.cardId
    formData.subjectId = res.data.subjectId
    formData.frontContent = res.data.frontContent
    formData.backContent = res.data.backContent
    formData.difficultyLevel = res.data.difficultyLevel || 1
    dialogVisible.value = true
  } catch (error) {
    console.error(error)
  }
}

const handleEditTags = async (row: Card) => {
  currentCard.value = row
  try {
    const res = await getCardTags(row.cardId!)
    selectedTagIds.value = res.data.map((tag: Tag) => tag.tagId!)
  } catch {
    selectedTagIds.value = []
  }
  tagDialogVisible.value = true
}

const handleSaveTags = async () => {
  if (!currentCard.value?.cardId) return
  tagLoading.value = true
  try {
    await setCardTags(currentCard.value.cardId, selectedTagIds.value)
    ElMessage.success('标签配置成功')
    tagDialogVisible.value = false
    fetchData()
  } catch (error) {
    console.error(error)
  } finally {
    tagLoading.value = false
  }
}

const handleDelete = async (row: Card) => {
  await ElMessageBox.confirm('确定删除该卡片？', '提示', { type: 'warning' })
  try {
    await deleteCard(row.cardId!)
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
    if (formData.cardId) {
      await updateCard(formData)
      ElMessage.success('更新成功')
    } else {
      await createCard(formData)
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
  fetchTagList()
})
</script>

<style scoped lang="scss">
.card-page {
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

  .tag-cell {
    display: flex;
    flex-wrap: wrap;
    gap: 4px;
    align-items: center;

    .tag-item {
      margin: 2px;
    }
  }
}
</style>