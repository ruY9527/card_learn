<template>
  <el-container class="layout-container">
    <el-aside width="200px">
      <el-menu
        :default-active="activeMenu"
        router
        background-color="#304156"
        text-color="#bfcbd9"
        active-text-color="#409eff"
      >
        <el-menu-item index="/dashboard">
          <el-icon><HomeFilled /></el-icon>
          <span>首页</span>
        </el-menu-item>
        <el-sub-menu index="content">
          <template #title>
            <el-icon><Folder /></el-icon>
            <span>内容管理</span>
          </template>
          <el-menu-item index="/major">专业管理</el-menu-item>
          <el-menu-item index="/subject">科目管理</el-menu-item>
          <el-menu-item index="/card">卡片管理</el-menu-item>
          <el-menu-item index="/tag">标签管理</el-menu-item>
        </el-sub-menu>
        <el-sub-menu index="system">
          <template #title>
            <el-icon><Setting /></el-icon>
            <span>系统管理</span>
          </template>
          <el-menu-item index="/system/user">用户管理</el-menu-item>
          <el-menu-item index="/system/role">角色管理</el-menu-item>
          <el-menu-item index="/system/menu">菜单管理</el-menu-item>
          <el-menu-item index="/system/log">日志管理</el-menu-item>
          <el-menu-item index="/system/sprint">冲刺配置</el-menu-item>
        </el-sub-menu>
        <el-sub-menu index="feedback">
          <template #title>
            <el-icon><ChatDotRound /></el-icon>
            <span>用户反馈</span>
          </template>
          <el-menu-item index="/feedback">反馈管理</el-menu-item>
          <el-menu-item index="/card-audit">卡片审批</el-menu-item>
        </el-sub-menu>
        <el-sub-menu index="stats">
          <template #title>
            <el-icon><DataAnalysis /></el-icon>
            <span>数据统计</span>
          </template>
          <el-menu-item index="/stats/learning">学习数据统计</el-menu-item>
          <el-menu-item index="/stats/study-history">学习记录</el-menu-item>
        </el-sub-menu>
        <el-menu-item index="/ai">
          <el-icon><MagicStick /></el-icon>
          <span>AI转化</span>
        </el-menu-item>
      </el-menu>
    </el-aside>
    <el-container>
      <el-header>
        <div class="header-content">
          <span class="title">考研知识点学习卡片管理系统</span>
          <el-dropdown @command="handleCommand">
            <span class="user-info">
              <el-avatar :size="32" :src="userStore.userInfo?.avatar || ''">
                <el-icon><UserFilled /></el-icon>
              </el-avatar>
              <span>{{ userStore.userInfo?.nickname || '管理员' }}</span>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="logout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>
      <el-main>
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '@/store/user'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const activeMenu = computed(() => route.path)

const handleCommand = (command: string) => {
  if (command === 'logout') {
    userStore.logout()
    router.push('/login')
  }
}
</script>

<style scoped lang="scss">
.layout-container {
  height: 100vh;

  .el-aside {
    background-color: #304156;

    .el-menu {
      border-right: none;
      height: 100%;
    }
  }

  .el-header {
    background-color: #fff;
    border-bottom: 1px solid #e6e6e6;
    display: flex;
    align-items: center;

    .header-content {
      width: 100%;
      display: flex;
      justify-content: space-between;
      align-items: center;

      .title {
        font-size: 18px;
        font-weight: bold;
        color: #409eff;
      }

      .user-info {
        display: flex;
        align-items: center;
        gap: 8px;
        cursor: pointer;
      }
    }
  }

  .el-main {
    background-color: #f5f5f5;
    padding: 20px;
  }
}
</style>