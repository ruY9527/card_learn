import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'
import { useUserStore } from '@/store/user'
import { generateRoutesFromMenus } from './dynamicRoutes'

const routes: RouteRecordRaw[] = [
  // ===== 公开路由 =====
  {
    path: '/',
    name: 'Portal',
    component: () => import('@/views/portal/index.vue'),
    meta: { title: '首页', public: true }
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/login/index.vue'),
    meta: { title: '登录', public: true }
  },
  {
    path: '/forgot-password',
    name: 'ForgotPassword',
    component: () => import('@/views/forgot-password/index.vue'),
    meta: { title: '忘记密码', public: true }
  },
  {
    path: '/auth/activate',
    name: 'Activate',
    component: () => import('@/views/activate/index.vue'),
    meta: { title: '账号激活', public: true }
  },

  // ===== 学习中心（普通用户） =====
  {
    path: '/learn',
    name: 'LearnLayout',
    component: () => import('@/views/learn/layout.vue'),
    redirect: '/learn/home',
    children: [
      {
        path: 'home',
        name: 'LearnHome',
        component: () => import('@/views/learn/index.vue'),
        meta: { title: '学习中心' }
      },
      {
        path: 'study',
        name: 'LearnStudy',
        component: () => import('@/views/learn/study/index.vue'),
        meta: { title: '刷知识卡片' }
      },
      {
        path: 'study/:subjectId',
        name: 'LearnStudySubject',
        component: () => import('@/views/learn/study/index.vue'),
        meta: { title: '刷知识卡片' }
      }
    ]
  },

  // ===== 管理后台（动态路由，子路由由后端菜单驱动） =====
  {
    path: '/admin',
    name: 'AdminLayout',
    component: () => import('@/views/layout/index.vue'),
    redirect: '/admin/dashboard',
    children: []
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 标记是否已加载过菜单（避免重复加载）
let menuLoaded = false

/**
 * 注册动态路由：将后端菜单转换为路由，作为 AdminLayout 的子路由添加
 */
async function registerDynamicRoutes(userStore: ReturnType<typeof useUserStore>) {
  // 如果已有菜单数据（登录时返回的），直接使用
  let menuData = userStore.menus
  if (!menuData || menuData.length === 0) {
    // 否则从后端获取
    menuData = await userStore.fetchMenus()
  }
  const dynamicRoutes = generateRoutesFromMenus(menuData)
  const addedNames: string[] = []
  for (const route of dynamicRoutes) {
    // 作为 AdminLayout 的子路由注册，确保页面被 Layout 包裹
    router.addRoute('AdminLayout', route)
    if (route.name) {
      addedNames.push(route.name as string)
    }
  }
  userStore.addDynamicRouteNames(addedNames)
  menuLoaded = true
}

// 路由守卫
router.beforeEach(async (to, _from, next) => {
  document.title = `${to.meta.title || '首页'} - 考研知识点学习卡片系统`
  const token = localStorage.getItem('token')

  // 公开路由
  if (to.meta.public || to.path === '/') {
    if (token) {
      const userInfoStr = localStorage.getItem('userInfo')
      const roles: string[] = userInfoStr ? (JSON.parse(userInfoStr).roles || []) : []
      const isAdmin = roles.includes('admin')
      // 已登录用户访问公开页，重定向到对应首页
      if (to.path === '/login' || to.path === '/' || to.path === '/forgot-password') {
        next(isAdmin ? '/admin/dashboard' : '/learn')
        return
      }
    }
    next()
    return
  }

  // 需要登录的路由
  if (!token) {
    next('/login')
    return
  }

  // 已登录，访问登录页则重定向
  if (to.path === '/login') {
    const userInfoStr = localStorage.getItem('userInfo')
    const roles: string[] = userInfoStr ? (JSON.parse(userInfoStr).roles || []) : []
    next(roles.includes('admin') ? '/admin/dashboard' : '/learn')
    return
  }

  // 动态路由尚未加载，先加载再导航
  if (!menuLoaded) {
    try {
      const userStore = useUserStore()
      await registerDynamicRoutes(userStore)
      // 使用 next({ ...to }) 确保新添加的路由被匹配
      next({ ...to, replace: true })
      return
    } catch (error) {
      console.error('加载菜单失败:', error)
      // token 可能已过期，清除并跳转登录
      localStorage.removeItem('token')
      localStorage.removeItem('userInfo')
      next('/login')
      return
    }
  }

  next()
})

export default router
