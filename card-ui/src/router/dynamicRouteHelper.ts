import { useUserStore } from '@/store/user'
import { generateRoutesFromMenus } from './dynamicRoutes'
import router, { setMenuLoaded } from './index'

/**
 * 注册动态路由：将后端菜单转换为路由，作为 AdminLayout 的子路由添加
 * 供登录页面调用，在跳转前先注册好动态路由
 */
export async function registerDynamicRoutes(userStore: ReturnType<typeof useUserStore>) {
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
  setMenuLoaded(true)
}
