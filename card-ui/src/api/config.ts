import request from './request'
import type { SysConfig, SprintConfig } from './types'

// 获取所有配置列表
export const getConfigList = () => {
  return request.get<any, { data: SysConfig[] }>('/system/config/list')
}

// 根据配置键获取配置
export const getConfigByKey = (key: string) => {
  return request.get<any, { data: SysConfig }>(`/system/config/${key}`)
}

// 更新配置值
export const updateConfigValue = (key: string, value: string) => {
  return request.put<any, void>(`/system/config/${key}`, { value })
}

// 更新配置对象
export const updateConfigEntity = (config: SysConfig) => {
  return request.put<any, void>('/system/config', config)
}

// 新增配置
export const addConfig = (config: SysConfig) => {
  return request.post<any, void>('/system/config', config)
}

// 删除配置
export const deleteConfig = (key: string) => {
  return request.delete<any, void>(`/system/config/${key}`)
}

// 获取冲刺配置
export const getSprintConfig = () => {
  return request.get<any, { data: SprintConfig }>('/system/config/sprint')
}

// 更新冲刺配置
export const updateSprintConfig = (data: {
  examDate?: string
  examName?: string
  enabled?: string
}) => {
  return request.put<any, void>('/system/config/sprint', data)
}