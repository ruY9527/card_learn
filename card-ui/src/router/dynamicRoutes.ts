import type { RouteRecordRaw } from 'vue-router'
import type { SysMenu } from '@/api/types'

// 使用 import.meta.glob 自动导入所有 views 下的 vue 组件
const viewModules = import.meta.glob('@/views/**/*.vue')

/**
 * 从后端菜单树生成 Vue Router 路由记录
 * 只处理 menuType='C' 的叶子菜单（菜单页面），跳过目录（M）和按钮（F）
 *
 * 路由将以相对路径注册为 AdminLayout 的子路由：
 * - 数据库 path='dashboard' → 路由 path='dashboard' → 匹配 /admin/dashboard
 * - 数据库 path='major' → 路由 path='major' → 匹配 /admin/major
 */
export function generateRoutesFromMenus(menus: SysMenu[]): RouteRecordRaw[] {
  const routes: RouteRecordRaw[] = []

  const traverse = (items: SysMenu[]) => {
    for (const menu of items) {
      if (menu.menuType === 'C' && menu.component) {
        const componentPath = `/src/${menu.component}`
        // 使用相对路径，作为 AdminLayout 子路由时会自动拼接 /admin/ 前缀
        const route: RouteRecordRaw = {
          path: menu.path,
          name: `Dynamic_${menu.menuId}`,
          component: viewModules[componentPath],
          meta: {
            title: menu.menuName,
            menuId: menu.menuId
          }
        }
        routes.push(route)
      }
      if (menu.children?.length) {
        traverse(menu.children)
      }
    }
  }

  traverse(menus)
  return routes
}

/**
 * 获取菜单的完整导航路径（带 /admin/ 前缀）
 * 用于 el-menu-item 的 index 属性
 */
export function getNavPath(menu: SysMenu): string {
  return `/admin/${menu.path}`
}
