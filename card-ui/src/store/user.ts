import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import request from '@/api/request'
import type { SysMenu } from '@/api/types'

export const useUserStore = defineStore('user', () => {
  const token = ref<string>(localStorage.getItem('token') || '')
  const userInfo = ref<any>(JSON.parse(localStorage.getItem('userInfo') || 'null'))
  const menus = ref<SysMenu[]>([])
  const dynamicRouteNames = ref<string[]>([])

  const isAdmin = computed(() => {
    return userInfo.value?.roles?.includes('admin') ?? false
  })

  const setToken = (newToken: string) => {
    token.value = newToken
    localStorage.setItem('token', newToken)
  }

  const setUserInfo = (info: any) => {
    userInfo.value = info
    localStorage.setItem('userInfo', JSON.stringify(info))
  }

  const setMenus = (menuList: SysMenu[]) => {
    menus.value = menuList
  }

  const addDynamicRouteNames = (names: string[]) => {
    dynamicRouteNames.value = names
  }

  const fetchMenus = async (): Promise<SysMenu[]> => {
    const res = await request.get('/system/menu/current')
    menus.value = res.data
    return res.data
  }

  const logout = () => {
    token.value = ''
    userInfo.value = null
    menus.value = []
    dynamicRouteNames.value = []
    localStorage.removeItem('token')
    localStorage.removeItem('userInfo')
  }

  return {
    token,
    userInfo,
    menus,
    dynamicRouteNames,
    isAdmin,
    setToken,
    setUserInfo,
    setMenus,
    addDynamicRouteNames,
    fetchMenus,
    logout
  }
})
