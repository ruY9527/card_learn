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
    path: '/forgot-password',
    name: 'ForgotPassword',
    component: () => import('@/views/forgot-password/index.vue'),
    meta: { title: '忘记密码' }
  },
  {
    path: '/auth/activate',
    name: 'Activate',
    component: () => import('@/views/activate/index.vue'),
    meta: { title: '账号激活' }
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
        path: 'system/email-config',
        name: 'EmailConfig',
        component: () => import('@/views/system/email-config/index.vue'),
        meta: { title: '邮箱配置' }
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
      },
      {
        path: 'note',
        name: 'Note',
        component: () => import('@/views/note/index.vue'),
        meta: { title: '笔记管理' }
      },
      {
        path: 'stats/learning',
        name: 'LearningStats',
        component: () => import('@/views/stats/learning/index.vue'),
        meta: { title: '学习数据统计' }
      },
      {
        path: 'stats/study-history',
        name: 'StudyHistory',
        component: () => import('@/views/stats/study-history/index.vue'),
        meta: { title: '学习记录' }
      },
      {
        path: 'stats/review-plan',
        name: 'ReviewPlan',
        component: () => import('@/views/stats/review-plan/index.vue'),
        meta: { title: '复习计划' }
      },
      {
        path: 'stats/report',
        name: 'LearningReport',
        component: () => import('@/views/stats/report/index.vue'),
        meta: { title: '学习报告' }
      },
      {
        path: 'incentive/dashboard',
        name: 'IncentiveDashboard',
        component: () => import('@/views/incentive/dashboard/index.vue'),
        meta: { title: '激励仪表盘' }
      },
      {
        path: 'incentive/achievement',
        name: 'IncentiveAchievement',
        component: () => import('@/views/incentive/achievement/index.vue'),
        meta: { title: '成就管理' }
      },
      {
        path: 'incentive/rank',
        name: 'IncentiveRank',
        component: () => import('@/views/incentive/rank/index.vue'),
        meta: { title: '排行榜' }
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
  const publicPaths = ['/login', '/forgot-password', '/auth/activate']
  if (!token && !publicPaths.includes(to.path)) {
    next('/login')
  } else {
    next()
  }
})

export default router