import request from './request'
import type { RequestLog, LogStats } from './types'

// 获取日志列表
export const getLogList = (params: {
  pageNum?: number
  pageSize?: number
  requestMethod?: string
  requestUrl?: string
  status?: string
  startTime?: string
  endTime?: string
}) => {
  return request.get<any, { data: { records: RequestLog[]; total: number; pageNum: number; pageSize: number } }>('/system/request-log/list', { params })
}

// 获取日志详情
export const getLogById = (id: number) => {
  return request.get<any, { data: RequestLog }>(`/system/request-log/${id}`)
}

// 清理历史日志
export const cleanLogs = (days: number = 30) => {
  return request.post<any, { data: number }>('/system/request-log/clean', null, { params: { days } })
}

// 获取日志统计
export const getLogStats = () => {
  return request.get<any, { data: LogStats }>('/system/request-log/stats')
}