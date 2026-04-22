<template>
  <div class="user-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>用户管理</span>
          <el-button type="primary" @click="handleAdd">新增</el-button>
        </div>
      </template>
      <el-form :inline="true" class="search-form">
        <el-form-item label="用户名">
          <el-input v-model="queryParams.username" placeholder="请输入用户名" clearable />
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
          <el-button type="primary" @click="fetchData">查询</el-button>
        </el-form-item>
      </el-form>
      <el-table :data="tableData" border stripe v-loading="loading">
        <el-table-column prop="userId" label="用户ID" width="80" />
        <el-table-column prop="username" label="用户名">
          <template #default="{ row }">
            <div class="username-cell">
              <span>{{ row.username }}</span>
              <el-tag
                :type="row.status === '0' ? 'success' : 'danger'"
                size="small"
                class="mobile-status-tag"
              >
                {{ row.status === '0' ? '正常' : '停用' }}
              </el-tag>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="nickname" label="昵称" />
        <el-table-column prop="status" label="状态" width="80" class-name="status-column">
          <template #default="{ row }">
            <el-tag :type="row.status === '0' ? 'success' : 'danger'">
              {{ row.status === '0' ? '正常' : '停用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180" />
        <el-table-column label="操作" width="200">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" size="small" @click="handleDelete(row)">删除</el-button>
            <el-dropdown trigger="click" @command="(command: string) => handleCommand(command, row)">
              <el-button size="small">
                更多<el-icon class="el-icon--right"><arrow-down /></el-icon>
              </el-button>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item command="resetPwd">重置密码</el-dropdown-item>
                  <el-dropdown-item command="assignRole">分配角色</el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </template>
        </el-table-column>
      </el-table>
      <el-pagination
        v-model:current-page="queryParams.pageNum"
        v-model:page-size="queryParams.pageSize"
        :total="total"
        :page-sizes="[10, 20, 50]"
        layout="total, sizes, prev, pager, next"
        @size-change="fetchData"
        @current-change="fetchData"
      />
    </el-card>

    <!-- 新增/编辑对话框 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="500px">
      <el-form ref="formRef" :model="formData" :rules="rules" label-width="100px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="formData.username" placeholder="请输入用户名" :disabled="editMode" />
        </el-form-item>
        <el-form-item label="密码" prop="password" v-if="!editMode">
          <el-input v-model="formData.password" type="password" placeholder="请输入密码" show-password />
        </el-form-item>
        <el-form-item label="昵称" prop="nickname">
          <el-input v-model="formData.nickname" placeholder="请输入昵称" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <!-- 大屏幕：使用单选按钮组 -->
          <el-radio-group v-model="formData.status" class="status-radio-group">
            <el-radio value="0">正常</el-radio>
            <el-radio value="1">停用</el-radio>
          </el-radio-group>
          <!-- 小屏幕：使用下拉框 -->
          <el-select v-model="formData.status" class="status-select-mobile">
            <el-option label="正常" value="0" />
            <el-option label="停用" value="1" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitLoading" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>

    <!-- 分配角色对话框 -->
    <el-dialog v-model="roleDialogVisible" title="分配角色" width="400px">
      <el-form label-width="80px">
        <el-form-item label="选择角色">
          <el-checkbox-group v-model="selectedRoles">
            <el-checkbox
              v-for="role in roleList"
              :key="role.roleId"
              :label="role.roleName"
              :value="role.roleId"
            />
          </el-checkbox-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="roleDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleAssignRoles">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import request from '@/api/request'

interface SysUser {
  userId?: number
  username: string
  password?: string
  nickname: string
  avatar?: string
  status: string
  createTime?: string
}

interface SysRole {
  roleId: number
  roleName: string
  roleKey: string
  status: string
}

const queryParams = reactive({
  username: '',
  status: '',
  pageNum: 1,
  pageSize: 10
})

const tableData = ref<SysUser[]>([])
const total = ref(0)
const loading = ref(false)
const dialogVisible = ref(false)
const dialogTitle = ref('新增用户')
const editMode = ref(false)
const formRef = ref<FormInstance>()

const formData = reactive<SysUser>({
  userId: undefined,
  username: '',
  password: '',
  nickname: '',
  status: '0'
})

const rules: FormRules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
  nickname: [{ required: true, message: '请输入昵称', trigger: 'blur' }]
}

const roleDialogVisible = ref(false)
const roleList = ref<SysRole[]>([])
const selectedRoles = ref<number[]>([])
const currentUserId = ref<number>(0)
const submitLoading = ref(false)

const fetchData = async () => {
  loading.value = true
  try {
    const res = await request.get('/system/user/page', { params: queryParams })
    tableData.value = res.data.records
    total.value = res.data.total
  } catch (error) {
    console.error(error)
  } finally {
    loading.value = false
  }
}

const fetchRoleList = async () => {
  try {
    const res = await request.get('/system/role/list')
    roleList.value = res.data
  } catch (error) {
    console.error(error)
  }
}

const handleAdd = () => {
  dialogTitle.value = '新增用户'
  editMode.value = false
  formData.userId = undefined
  formData.username = ''
  formData.password = ''
  formData.nickname = ''
  formData.status = '0'
  dialogVisible.value = true
}

const handleEdit = (row: SysUser) => {
  dialogTitle.value = '编辑用户'
  editMode.value = true
  formData.userId = row.userId
  formData.username = row.username
  formData.password = ''
  formData.nickname = row.nickname
  formData.status = row.status
  dialogVisible.value = true
}

const handleDelete = async (row: SysUser) => {
  await ElMessageBox.confirm('确定删除该用户？', '提示', { type: 'warning' })
  try {
    await request.delete(`/system/user/${row.userId}`)
    ElMessage.success('删除成功')
    fetchData()
  } catch (error) {
    console.error(error)
  }
}

const handleCommand = async (command: string, row: SysUser) => {
  if (command === 'resetPwd') {
    try {
      const { value } = await ElMessageBox.prompt('请输入新密码', '重置密码', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        inputPattern: /.+/
      })
      if (value) {
        await request.put('/system/user/resetPassword', null, {
          params: { userId: row.userId, password: value }
        })
        ElMessage.success('密码重置成功')
      }
    } catch (error) {
      console.error(error)
    }
  } else if (command === 'assignRole') {
    currentUserId.value = row.userId!
    selectedRoles.value = []
    roleDialogVisible.value = true
    fetchRoleList()
  }
}

const handleAssignRoles = async () => {
  try {
    await request.put('/system/user/assignRoles', null, {
      params: { userId: currentUserId.value },
      data: selectedRoles.value
    })
    ElMessage.success('角色分配成功')
    roleDialogVisible.value = false
    fetchData()
  } catch (error) {
    console.error(error)
  }
}

const handleSubmit = async () => {
  await formRef.value?.validate()
  submitLoading.value = true
  try {
    if (formData.userId) {
      await request.put('/system/user', formData)
      ElMessage.success('更新成功')
    } else {
      await request.post('/system/user', formData)
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
.user-page {
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

  .username-cell {
    display: flex;
    align-items: center;
    gap: 8px;

    .mobile-status-tag {
      display: none;
    }
  }

  // 搜索表单状态下拉框固定宽度
  .status-select {
    width: 120px;
  }
}

// 对话框中的状态组件响应式
.status-radio-group {
  display: inline-flex;
}

.status-select-mobile {
  display: none;
  width: 100%;
}

@media screen and (max-width: 576px) {
  // 小屏幕下对话框：隐藏单选按钮，显示下拉框
  .status-radio-group {
    display: none;
  }

  .status-select-mobile {
    display: inline-flex;
  }
}

// 响应式布局：小屏幕隐藏状态列，显示用户名旁的状态标签
@media screen and (max-width: 768px) {
  .user-page {
    // 隐藏状态列（td 单元格）
    :deep(.status-column) {
      display: none;
    }

    // 隐藏状态列的表头（第4列：状态）
    :deep(.el-table__header-wrapper th:nth-child(4)) {
      display: none;
    }

    // 显示用户名旁的移动端状态标签
    .username-cell .mobile-status-tag {
      display: inline-flex;
    }

    // 搜索表单响应式
    .search-form .el-form-item {
      margin-bottom: 12px;
    }
  }
}

// 超小屏幕优化
@media screen and (max-width: 576px) {
  .user-page {
    .card-header {
      flex-direction: column;
      gap: 12px;
      align-items: flex-start;
    }

    .search-form {
      .el-form-item {
        width: 100%;
        .el-input, .el-select {
          width: 100%;
        }
      }

      // 状态下拉框自适应
      .status-select {
        width: 100%;
      }
    }
  }
}
</style>