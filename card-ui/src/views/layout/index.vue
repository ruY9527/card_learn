<template>
  <el-container class="layout-container">
    <el-aside :width="isCollapse ? '64px' : '200px'" class="layout-aside">
      <div class="logo-area">
        <span v-if="!isCollapse" class="logo-text">学习卡片</span>
        <span v-else class="logo-icon">卡</span>
      </div>
      <el-menu
        :default-active="activeMenu"
        :collapse="isCollapse"
        :collapse-transition="false"
        background-color="var(--sidebar-bg)"
        text-color="var(--sidebar-text)"
        active-text-color="var(--sidebar-active-text)"
        router
      >
        <el-menu-item index="/dashboard">
          <el-icon><HomeFilled /></el-icon>
          <template #title>首页</template>
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
          <el-menu-item index="/stats/review-plan">复习计划</el-menu-item>
        </el-sub-menu>
        <el-menu-item index="/ai">
          <el-icon><MagicStick /></el-icon>
          <template #title>AI转化</template>
        </el-menu-item>
      </el-menu>
    </el-aside>
    <el-container>
      <el-header>
        <div class="header-content">
          <div class="header-left">
            <el-icon class="collapse-btn" @click="isCollapse = !isCollapse">
              <Fold v-if="!isCollapse" />
              <Expand v-else />
            </el-icon>
            <span class="title">考研知识点学习卡片管理系统</span>
          </div>
          <div class="header-actions">
            <el-tooltip :content="isDark ? '切换浅色模式' : '切换深色模式'" placement="bottom">
              <el-button :icon="isDark ? Sunny : Moon" circle @click="toggleTheme" />
            </el-tooltip>
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
        </div>
      </el-header>
      <el-main>
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Sunny, Moon, Fold, Expand } from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'
import { useTheme } from '@/composables/useTheme'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const { isDark, toggleTheme } = useTheme()

const isCollapse = ref(false)
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

  .layout-aside {
    background-color: var(--sidebar-bg);
    transition: width 0.3s;
    overflow: hidden;

    .logo-area {
      height: 50px;
      display: flex;
      align-items: center;
      justify-content: center;
      border-bottom: 1px solid rgba(255, 255, 255, 0.1);

      .logo-text {
        font-size: 16px;
        font-weight: bold;
        color: #409eff;
        white-space: nowrap;
      }

      .logo-icon {
        font-size: 18px;
        font-weight: bold;
        color: #409eff;
      }
    }

    .el-menu {
      border-right: none;
      height: calc(100% - 50px);

      // 确保菜单颜色与侧边栏一致，避免折叠时闪黑
      :deep(.el-menu-item),
      :deep(.el-sub-menu__title) {
        color: var(--sidebar-text);

        &:hover,
        &:focus {
          background-color: rgba(64, 158, 255, 0.1);
        }
      }

      :deep(.el-menu-item.is-active) {
        color: var(--sidebar-active-text);
        background-color: rgba(64, 158, 255, 0.15);
      }

      // 折叠时弹出的子菜单样式
      :deep(.el-menu--popup) {
        background-color: var(--sidebar-bg);

        .el-menu-item {
          color: var(--sidebar-text);

          &:hover {
            background-color: rgba(64, 158, 255, 0.1);
          }
        }
      }
    }
  }

  .el-header {
    background-color: var(--header-bg);
    border-bottom: 1px solid var(--header-border);
    display: flex;
    align-items: center;

    .header-content {
      width: 100%;
      display: flex;
      justify-content: space-between;
      align-items: center;

      .header-left {
        display: flex;
        align-items: center;
        gap: 12px;
      }

      .collapse-btn {
        font-size: 20px;
        cursor: pointer;
        color: var(--text-color-regular);
        transition: color 0.2s;

        &:hover {
          color: #409eff;
        }
      }

      .title {
        font-size: 18px;
        font-weight: bold;
        color: #409eff;
      }

      .header-actions {
        display: flex;
        align-items: center;
        gap: 12px;
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
    background-color: var(--bg-color-page);
    padding: 20px;
  }
}
</style>