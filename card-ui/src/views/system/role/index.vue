<template>
  <div class="role-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>角色管理</span>
          <el-button type="primary" @click="handleAdd">新增</el-button>
        </div>
      </template>
      <el-form :inline="true" class="search-form">
        <el-form-item label="角色名称">
          <el-input v-model="queryParams.roleName" placeholder="请输入角色名称" clearable />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="fetchData">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>
      <el-table :data="tableData" border stripe v-loading="loading">
        <el-table-column prop="roleId" label="角色ID" width="80" />
        <el-table-column prop="roleName" label="角色名称" min-width="120" />
        <el-table-column prop="roleKey" label="权限字符" min-width="120" />
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
            <el-button type="primary" link size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" link size="small" @click="handleDelete(row)">删除</el-button>
            <el-dropdown trigger="click" @command="(command: string) => handleCommand(command, row)">
              <el-button type="warning" link size="small">
                更多<el-icon class="el-icon--right"><arrow-down /></el-icon>
              </el-button>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item command="assignMenu">分配权限</el-dropdown-item>
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
        <el-form-item label="角色名称" prop="roleName">
          <el-input v-model="formData.roleName" placeholder="请输入角色名称" />
        </el-form-item>
        <el-form-item label="权限字符" prop="roleKey">
          <el-input v-model="formData.roleKey" placeholder="请输入权限字符" />
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

    <!-- 分配权限对话框 -->
    <el-dialog v-model="menuDialogVisible" title="分配菜单权限" width="600px">
      <el-form label-width="100px">
        <el-form-item label="选择菜单">
          <el-tree
            ref="menuTreeRef"
            :data="menuList"
            show-checkbox
            node-key="menuId"
            :props="{ label: 'menuName', children: 'children' }"
            default-expand-all
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="menuDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitLoading" @click="saveMenuAssign">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import request from '@/api/request'

interface SysRole {
  roleId?: number
  roleName: string
  roleKey: string
  status: string
  createTime?: string
}

interface SysMenu {
  menuId: number
  menuName: string
  parentId: number
  orderNum: number
  path: string
  component: string
  perms: string
  menuType: string
  children?: SysMenu[]
}

const queryParams = reactive({
  roleName: '',
  pageNum: 1,
  pageSize: 10
})

const tableData = ref<SysRole[]>([])
const total = ref(0)
const loading = ref(false)
const submitLoading = ref(false)
const dialogVisible = ref(false)
const dialogTitle = ref('新增角色')
const formRef = ref<FormInstance>()

const formData = reactive<SysRole>({
  roleId: undefined,
  roleName: '',
  roleKey: '',
  status: '0'
})

const rules: FormRules = {
  roleName: [{ required: true, message: '请输入角色名称', trigger: 'blur' }],
  roleKey: [{ required: true, message: '请输入权限字符', trigger: 'blur' }]
}

const menuDialogVisible = ref(false)
const menuList = ref<SysMenu[]>([])
const menuTreeRef = ref()
const currentRoleId = ref<number>(0)

const fetchData = async () => {
  loading.value = true
  try {
    const res = await request.get('/system/role/page', { params: queryParams })
    tableData.value = res.data.records
    total.value = res.data.total
  } catch (error) {
    console.error(error)
  } finally {
    loading.value = false
  }
}

const resetQuery = () => {
  queryParams.roleName = ''
  queryParams.pageNum = 1
  fetchData()
}

const fetchMenuList = async () => {
  try {
    const res = await request.get('/system/menu/list')
    menuList.value = buildMenuTree(res.data)
  } catch (error) {
    console.error(error)
  }
}

const buildMenuTree = (menus: SysMenu[]): SysMenu[] => {
  const result: SysMenu[] = []
  const map = new Map<number, SysMenu>()

  menus.forEach(menu => {
    map.set(menu.menuId, menu)
    menu.children = []
  })

  menus.forEach(menu => {
    if (menu.parentId === 0) {
      result.push(menu)
    } else {
      const parent = map.get(menu.parentId)
      if (parent) {
        parent.children!.push(menu)
      }
    }
  })

  return result
}

const handleAdd = () => {
  dialogTitle.value = '新增角色'
  formData.roleId = undefined
  formData.roleName = ''
  formData.roleKey = ''
  formData.status = '0'
  dialogVisible.value = true
}

const handleEdit = (row: SysRole) => {
  dialogTitle.value = '编辑角色'
  formData.roleId = row.roleId
  formData.roleName = row.roleName
  formData.roleKey = row.roleKey
  formData.status = row.status
  dialogVisible.value = true
}

const handleDelete = async (row: SysRole) => {
  await ElMessageBox.confirm('确定删除该角色？', '提示', { type: 'warning' })
  try {
    await request.delete(`/system/role/${row.roleId}`)
    ElMessage.success('删除成功')
    fetchData()
  } catch (error) {
    console.error(error)
  }
}

const handleCommand = (command: string, row: SysRole) => {
  if (command === 'assignMenu') {
    currentRoleId.value = row.roleId!
    menuDialogVisible.value = true
    fetchMenuList()
  }
}

const openMenuDialog = async (row: SysRole) => {
  currentRoleId.value = row.roleId!
  menuDialogVisible.value = true
  await fetchMenuList()
}

const saveMenuAssign = async () => {
  submitLoading.value = true
  try {
    const checkedKeys = menuTreeRef.value?.getCheckedKeys() || []
    await request.put('/system/role/assignMenus', checkedKeys, {
      params: { roleId: currentRoleId.value }
    })
    ElMessage.success('权限分配成功')
    menuDialogVisible.value = false
    fetchData()
  } catch (error) {
    console.error(error)
  } finally {
    submitLoading.value = false
  }
}

const handleSubmit = async () => {
  await formRef.value?.validate()
  submitLoading.value = true
  try {
    if (formData.roleId) {
      await request.put('/system/role', formData)
      ElMessage.success('更新成功')
    } else {
      await request.post('/system/role', formData)
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
.role-page {
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
}
</style>