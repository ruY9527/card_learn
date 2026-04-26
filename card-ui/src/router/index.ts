import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'

const routes: RouteRecordRaw[] = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/login/index.vue'),
    meta: { title: '登录' }
  },
  {
    path: '/',
    name: 'Layout',
    component: () => import('@/views/layout/index.vue'),
    redirect: '/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('@/views/dashboard/index.vue'),
        meta: { title: '首页' }
      },
      {
        path: 'major',
        name: 'Major',
        component: () => import('@/views/content/major/index.vue'),
        meta: { title: '专业管理' }
      },
      {
        path: 'subject',
        name: 'Subject',
        component: () => import('@/views/content/subject/index.vue'),
        meta: { title: '科目管理' }
      },
      {
        path: 'card',
        name: 'Card',
        component: () => import('@/views/content/card/index.vue'),
        meta: { title: '卡片管理' }
      },
      {
        path: 'tag',
        name: 'Tag',
        component: () => import('@/views/content/tag/index.vue'),
        meta: { title: '标签管理' }
      },
      {
        path: 'ai',
        name: 'Ai',
        component: () => import('@/views/ai/index.vue'),
        meta: { title: 'AI转化' }
      },
      {
        path: 'system/user',
        name: 'User',
        component: () => import('@/views/system/user/index.vue'),
        meta: { title: '用户管理' }
      },
      {
        path: 'system/role',
        name: 'Role',
        component: () => import('@/views/system/role/index.vue'),
        meta: { title: '角色管理' }
      },
      {
        path: 'system/menu',
        name: 'Menu',
        component: () => import('@/views/system/menu/index.vue'),
        meta: { title: '菜单管理' }
      },
      {
        path: 'system/log',
        name: 'Log',
        component: () => import('@/views/system/log/index.vue'),
        meta: { title: '日志管理' }
      },
      {
        path: 'system/sprint',
        name: 'Sprint',
        component: () => import('@/views/system/sprint/index.vue'),
        meta: { title: '冲刺配置' }
      },
      {
        path: 'feedback',
        name: 'Feedback',
        component: () => import('@/views/feedback/index.vue'),
        meta: { title: '反馈管理' }
      },
      {
        path: 'card-audit',
        name: 'CardAudit',
        component: () => import('@/views/feedback/card-audit/index.vue'),
        meta: { title: '卡片审批' }
      },
      {
        path: 'comment',
        name: 'Comment',
        component: () => import('@/views/comment/index.vue'),
        meta: { title: '评论管理' }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 路由守卫
router.beforeEach((to, _from, next) => {
  document.title = `${to.meta.title || '首页'} - 考研知识点学习卡片管理系统`
  const token = localStorage.getItem('token')
  if (!token && to.path !== '/login') {
    next('/login')
  } else {
    next()
  }
})

export default router