import request from './request'
import type { Achievement, RankItem, PageResult } from './types'

// ========== 成就相关API ==========

export const getAchievementList = (params?: { category?: string }) => {
  return request.get<any, { data: Achievement[] }>('/admin/incentive/achievement/list', { params })
}

export const getAchievementStats = () => {
  return request.get<any, { data: { totalAchievements: number } }>('/admin/incentive/achievement/stats')
}

// ========== 排行榜API ==========

export const getTotalRank = (params: { pageNum: number; pageSize: number }) => {
  return request.get<any, PageResult<RankItem>>('/admin/incentive/rank/total', { params })
}

export const getWeekRank = (params: { pageNum: number; pageSize: number }) => {
  return request.get<any, PageResult<RankItem>>('/admin/incentive/rank/week', { params })
}

export const getStreakRank = (params: { pageNum: number; pageSize: number }) => {
  return request.get<any, PageResult<RankItem>>('/admin/incentive/rank/streak', { params })
}
