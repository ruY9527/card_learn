import request from './request'

// 学习统计
export const getLearnStats = (userId?: number) => {
  return request.get<any, { data: any }>('/dashboard/learning-stats', { params: { userId } })
}

// 冲刺配置
export const getSprintConfigData = () => {
  return request.get<any, { data: any }>('/miniprogram/sprint-config')
}

// 今日推荐
export const getRecommendCards = () => {
  return request.get<any, { data: any[] }>('/miniprogram/recommend')
}

// 专业列表
export const getMajorList = () => {
  return request.get<any, { data: any[] }>('/miniprogram/majors')
}

// 科目列表
export const getSubjectList = (majorId?: number) => {
  const params = majorId ? { majorId } : {}
  return request.get<any, { data: any[] }>('/miniprogram/subjects', { params })
}

// 卡片列表（支持筛选）
export const getCardList = (params: {
  subjectId?: number
  status?: string
  pageNum?: number
  pageSize?: number
  random?: boolean
  userId?: number
}) => {
  return request.get<any, { data: any }>('/miniprogram/cards', { params })
}

// 卡片详情
export const getCardDetail = (cardId: number) => {
  return request.get<any, { data: any }>(`/miniprogram/cards/${cardId}`)
}

// 更新学习进度
export const updateProgress = (data: {
  cardId: number
  status: number
}) => {
  return request.post<any, any>('/miniprogram/progress', data)
}

// SM-2 算法复习提交（与iOS端一致）
export const submitSimpleReview = (data: {
  cardId: number
  userId: number
  status: number
  source?: string
}) => {
  return request.post<any, any>('/learning/review/simple', data)
}

// 某日学习详情（热力图点击）
export const getDayLearnDetail = (date: string, userId: number) => {
  return request.get<any, { data: any }>('/dashboard/day-detail', { params: { date, userId } })
}
