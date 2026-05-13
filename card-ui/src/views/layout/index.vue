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
        <template v-for="menu in visibleMenus" :key="menu.menuId">
          <!-- 有子菜单的目录 -->
          <el-sub-menu v-if="menu.children?.length" :index="`menu-${menu.menuId}`">
            <template #title>
              <el-icon v-if="menu.icon && iconMap[menu.icon]">
                <component :is="iconMap[menu.icon]" />
              </el-icon>
              <span>{{ menu.menuName }}</span>
            </template>
            <template v-for="child in menu.children" :key="child.menuId">
              <el-sub-menu v-if="child.children?.length" :index="`menu-${child.menuId}`">
                <template #title>
                  <el-icon v-if="child.icon && iconMap[child.icon]">
                    <component :is="iconMap[child.icon]" />
                  </el-icon>
                  <span>{{ child.menuName }}</span>
                </template>
                <el-menu-item
                  v-for="grandchild in child.children"
                  :key="grandchild.menuId"
                  v-show="grandchild.hidden !== '1'"
                  :index="getNavPath(grandchild)"
                >
                  <el-icon v-if="grandchild.icon && iconMap[grandchild.icon]">
                    <component :is="iconMap[grandchild.icon]" />
                  </el-icon>
                  <template #title>{{ grandchild.menuName }}</template>
                </el-menu-item>
              </el-sub-menu>
              <el-menu-item v-else-if="child.hidden !== '1'" :index="getNavPath(child)">
                <el-icon v-if="child.icon && iconMap[child.icon]">
                  <component :is="iconMap[child.icon]" />
                </el-icon>
                <template #title>{{ child.menuName }}</template>
              </el-menu-item>
            </template>
          </el-sub-menu>
          <!-- 无子菜单的独立菜单项 -->
          <el-menu-item v-else-if="menu.hidden !== '1'" :index="getNavPath(menu)">
            <el-icon v-if="menu.icon && iconMap[menu.icon]">
              <component :is="iconMap[menu.icon]" />
            </el-icon>
            <template #title>{{ menu.menuName }}</template>
          </el-menu-item>
        </template>
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
import {
  Sunny, Moon, Fold, Expand, Trophy, UserFilled,
  HomeFilled, Folder, FolderOpened, Document, Tickets, PriceTag,
  ChatDotRound, ChatLineSquare, CircleCheck, Comment, Notebook,
  DataAnalysis, TrendCharts, List, Calendar,
  Odometer, Medal, Histogram,
  MagicStick, Setting, User, UserFilled as UserFilledIcon,
  Menu, DocumentCopy, Message, Operation
} from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'
import { useTheme } from '@/composables/useTheme'
import { getNavPath } from '@/router/dynamicRoutes'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const { isDark, toggleTheme } = useTheme()

const isCollapse = ref(false)
const activeMenu = computed(() => route.path)

// 图标映射：后端存储的图标名 → Element Plus 图标组件
const iconMap: Record<string, any> = {
  HomeFilled,
  Folder,
  FolderOpened,
  Document,
  Tickets,
  PriceTag,
  ChatDotRound,
  ChatLineSquare,
  CircleCheck,
  Comment,
  Notebook,
  DataAnalysis,
  TrendCharts,
  List,
  Calendar,
  Trophy,
  Odometer,
  Medal,
  Histogram,
  MagicStick,
  Setting,
  User,
  UserFilled: UserFilledIcon,
  Menu,
  DocumentCopy,
  Message,
  Sprint: Operation
}

// 过滤隐藏菜单
const visibleMenus = computed(() => {
  return (userStore.menus || []).filter(m => m.hidden !== '1')
})

const handleCommand = (command: string) => {
  if (command === 'logout') {
    // 清理动态路由
    for (const name of userStore.dynamicRouteNames) {
      router.removeRoute(name)
    }
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
