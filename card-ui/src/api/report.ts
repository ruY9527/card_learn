import request from './request'
import type { Result } from './types'

// 报告详情
export interface ReportDetail {
  reportId: number | null
  reportType: string
  periodStart: string
  periodEnd: string
  overview: ReportOverview
  masteryTrend: MasteryTrend | null
  subjectAnalysis: SubjectAnalysis[] | null
  learningHabits: LearningHabits | null
  weakPoints: WeakPoint[] | null
  suggestions: Suggestion[] | null
}

export interface ReportOverview {
  totalCards: number
  newMastered: number
  forgotten: number
  streakDays: number
  studyDuration: number | null
  comparison: Comparison | null
}

export interface Comparison {
  totalCardsChange: string | null
  newMasteredChange: string | null
  forgottenChange: string | null
}

export interface MasteryTrend {
  startRate: number
  endRate: number
  changeRate: number
  trendData: TrendPoint[] | null
}

export interface TrendPoint {
  date: string
  rate: number
}

export interface SubjectAnalysis {
  subjectId: number
  subjectName: string
  totalCards: number
  mastered: number
  weakPoints: number
  masteryRate: number
}

export interface LearningHabits {
  morning: number
  afternoon: number
  evening: number
  peakHour: string
  mostActiveDay: string
  avgDailyDuration: number
  studyFrequency: number
}

export interface WeakPoint {
  cardId: number
  subjectName: string | null
  frontContent: string | null
  errorCount: number
  lastErrorTime: string | null
}

export interface Suggestion {
  type: string
  priority: string
  content: string
}

export interface ReportListItem {
  reportId: number
  reportType: string
  periodStart: string
  periodEnd: string
  overview: ReportOverview | null
}

export interface ReportHistoryResponse {
  records: ReportListItem[]
  total: number
  pages: number
}

export interface WeakPointResponse {
  records: WeakPoint[]
  total: number
}

// 获取当前周期报告
export const getCurrentReport = (type: string = 'weekly', userId?: number) => {
  return request.get<any, Result<ReportDetail>>('/learning/report/current', {
    params: { type, userId }
  })
}

// 获取历史报告列表
export const getHistoryReports = (type: string = 'weekly', page: number = 1, size: number = 4, userId?: number) => {
  return request.get<any, Result<ReportHistoryResponse>>('/learning/report/history', {
    params: { type, page, size, userId }
  })
}

// 获取指定报告详情
export const getReportById = (id: number, userId?: number) => {
  return request.get<any, Result<ReportDetail>>(`/learning/report/${id}`, {
    params: { userId }
  })
}

// 获取薄弱点列表
export const getWeakPoints = (page: number = 1, size: number = 20, userId?: number) => {
  return request.get<any, Result<WeakPointResponse>>('/learning/weak-points', {
    params: { page, size, userId }
  })
}

// 标记薄弱点已复习
export const markWeakPointReviewed = (cardId: number, userId?: number) => {
  return request.post<any, Result<null>>(`/learning/weak-points/${cardId}/review`, null, {
    params: { userId }
  })
}
