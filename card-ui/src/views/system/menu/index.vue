<template>
  <div class="menu-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>菜单管理</span>
          <el-button type="primary" @click="handleAdd">新增</el-button>
        </div>
      </template>
      <el-table :data="tableData" border stripe v-loading="loading" row-key="menuId" default-expand-all>
        <el-table-column prop="menuName" label="菜单名称" width="150" />
        <el-table-column prop="orderNum" label="排序" width="80" />
        <el-table-column prop="path" label="路由地址" />
        <el-table-column prop="component" label="组件路径" show-overflow-tooltip />
        <el-table-column prop="perms" label="权限标识" show-overflow-tooltip />
        <el-table-column prop="menuType" label="类型" width="80">
          <template #default="{ row }">
            <el-tag :type="row.menuType === 'M' ? 'info' : row.menuType === 'C' ? 'warning' : 'success'">
              {{ row.menuType === 'M' ? '目录' : row.menuType === 'C' ? '菜单' : '按钮' }}
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
    </el-card>

    <!-- 新增/编辑对话框 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="500px">
      <el-form ref="formRef" :model="formData" :rules="rules" label-width="100px">
        <el-form-item label="菜单名称" prop="menuName">
          <el-input v-model="formData.menuName" placeholder="请输入菜单名称" />
        </el-form-item>
        <el-form-item label="父菜单">
          <el-input-number v-model="formData.parentId" :min="0" />
        </el-form-item>
        <el-form-item label="排序" prop="orderNum">
          <el-input-number v-model="formData.orderNum" :min="0" />
        </el-form-item>
        <el-form-item label="路由地址" prop="path">
          <el-input v-model="formData.path" placeholder="请输入路由地址" />
        </el-form-item>
        <el-form-item label="组件路径" prop="component">
          <el-input v-model="formData.component" placeholder="请输入组件路径" />
        </el-form-item>
        <el-form-item label="权限标识" prop="perms">
          <el-input v-model="formData.perms" placeholder="请输入权限标识" />
        </el-form-item>
        <el-form-item label="菜单类型" prop="menuType">
          <el-select v-model="formData.menuType" placeholder="请选择菜单类型">
            <el-option label="目录" value="M" />
            <el-option label="菜单" value="C" />
            <el-option label="按钮" value="F" />
          </el-select>
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
import request from '@/api/request'

interface SysMenu {
  menuId?: number
  menuName: string
  parentId: number
  orderNum: number
  path: string
  component: string
  perms: string
  menuType: string
  createTime?: string
  children?: SysMenu[]
}

const tableData = ref<SysMenu[]>([])
const loading = ref(false)
const dialogVisible = ref(false)
const dialogTitle = ref('新增菜单')
const formRef = ref<FormInstance>()
const submitLoading = ref(false)

const formData = reactive<SysMenu>({
  menuId: undefined,
  menuName: '',
  parentId: 0,
  orderNum: 0,
  path: '',
  component: '',
  perms: '',
  menuType: 'C'
})

const rules: FormRules = {
  menuName: [{ required: true, message: '请输入菜单名称', trigger: 'blur' }],
  menuType: [{ required: true, message: '请选择菜单类型', trigger: 'change' }]
}

const fetchData = async () => {
  loading.value = true
  try {
    const res = await request.get('/system/menu/list')
    tableData.value = buildMenuTree(res.data)
  } catch (error) {
    console.error(error)
  } finally {
    loading.value = false
  }
}

const buildMenuTree = (menus: SysMenu[]): SysMenu[] => {
  const result: SysMenu[] = []
  const map = new Map<number, SysMenu>()

  menus.forEach(menu => {
    map.set(menu.menuId!, menu)
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
  dialogTitle.value = '新增菜单'
  formData.menuId = undefined
  formData.menuName = ''
  formData.parentId = 0
  formData.orderNum = 0
  formData.path = ''
  formData.component = ''
  formData.perms = ''
  formData.menuType = 'C'
  dialogVisible.value = true
}

const handleEdit = (row: SysMenu) => {
  dialogTitle.value = '编辑菜单'
  formData.menuId = row.menuId
  formData.menuName = row.menuName
  formData.parentId = row.parentId
  formData.orderNum = row.orderNum
  formData.path = row.path
  formData.component = row.component
  formData.perms = row.perms
  formData.menuType = row.menuType
  dialogVisible.value = true
}

const handleDelete = async (row: SysMenu) => {
  await ElMessageBox.confirm('确定删除该菜单？', '提示', { type: 'warning' })
  try {
    await request.delete(`/system/menu/${row.menuId}`)
    ElMessage.success('删除成功')
    fetchData()
  } catch (error) {
    console.error(error)
  }
}

const handleSubmit = async () => {
  await formRef.value?.validate()
  submitLoading.value = true
  try {
    if (formData.menuId) {
      await request.put('/system/menu', formData)
      ElMessage.success('更新成功')
    } else {
      await request.post('/system/menu', formData)
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
.menu-page {
  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
}
</style>