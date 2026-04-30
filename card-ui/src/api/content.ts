import request from './request'
import type { Major, Subject, Card, Tag, SysUser, Feedback, FeedbackVO, PageResult, CardAuditVO, LearningStats, DailyLearnTrend, UserLearnRank, SubjectLearnStats, StudiedCard, StudyHistoryRecord } from './types'

// 专业相关
export const getMajorList = () => {
  return request.get<any, { data: Major[] }>('/major/list')
}

export const getMajorPage = (params: { majorName?: string; status?: string; pageNum: number; pageSize: number }) => {
  return request.get<any, PageResult<Major>>('/major/page', { params })
}

export const createMajor = (data: Major) => {
  return request.post('/major', data)
}

export const updateMajor = (data: Major) => {
  return request.put('/major', data)
}

export const deleteMajor = (id: number) => {
  return request.delete(`/major/${id}`)
}

// 科目相关
export const getSubjectList = (majorId?: number) => {
  return request.get<any, { data: Subject[] }>('/subject/list', { params: { majorId } })
}

export const getSubjectPage = (params: { majorId?: number; subjectName?: string; pageNum: number; pageSize: number }) => {
  return request.get<any, PageResult<Subject>>('/subject/page', { params })
}

export const createSubject = (data: Subject) => {
  return request.post('/subject', data)
}

export const updateSubject = (data: Subject) => {
  return request.put('/subject', data)
}

export const deleteSubject = (id: number) => {
  return request.delete(`/subject/${id}`)
}

// 卡片相关
export const getCardPage = (params: { subjectId?: number; frontContent?: string; pageNum: number; pageSize: number }) => {
  return request.get<any, PageResult<Card>>('/card/page', { params })
}

export const getCardById = (id: number) => {
  return request.get<any, { data: Card }>(`/card/${id}`)
}

export const getCardTags = (id: number) => {
  return request.get<any, { data: Tag[] }>(`/card/${id}/tags`)
}

export const createCard = (data: Card) => {
  return request.post<any, { data: number }>('/card', data)
}

export const updateCard = (data: Card) => {
  return request.put('/card', data)
}

export const setCardTags = (id: number, tagIds: number[]) => {
  return request.put(`/card/${id}/tags`, tagIds)
}

export const deleteCard = (id: number) => {
  return request.delete(`/card/${id}`)
}

// 标签相关
export const getTagPage = (params: { tagName?: string; subjectId?: number; pageNum: number; pageSize: number }) => {
  return request.get<any, { data: { records: Tag[]; total: number; pageNum: number; pageSize: number } }>('/tag/page', { params })
}

export const getTagList = (subjectId?: number) => {
  return request.get<any, { data: Tag[] }>('/tag/list', { params: { subjectId } })
}

export const createTag = (data: Tag) => {
  return request.post('/tag', data)
}

export const updateTag = (data: Tag) => {
  return request.put('/tag', data)
}

export const deleteTag = (id: number) => {
  return request.delete(`/tag/${id}`)
}

// 反馈相关
export const getFeedbackPage = (params: { type?: string; status?: string; pageNum: number; pageSize: number }) => {
  return request.get<any, PageResult<FeedbackVO>>('/feedback/page', { params })
}

export const getFeedbackById = (id: number) => {
  return request.get<any, { data: Feedback }>(`/feedback/${id}`)
}

export const processFeedback = (id: number, status: string, adminReply?: string) => {
  return request.put(`/feedback/${id}/process`, null, { params: { status, adminReply } })
}

export const deleteFeedback = (id: number) => {
  return request.delete(`/feedback/${id}`)
}

export const getPendingFeedbackCount = () => {
  return request.get<any, { data: number }>('/feedback/pending/count')
}

// ==================== 卡片审批相关 ====================

/**
 * 分页查询待审批卡片列表
 */
export const getCardAuditPage = (params: { auditStatus?: string; pageNum: number; pageSize: number }) => {
  return request.get<any, PageResult<CardAuditVO>>('/card/audit/page', { params })
}

/**
 * 获取卡片详情（用于审批）
 */
export const getCardAuditById = (id: number) => {
  return request.get<any, { data: CardAuditVO }>(`/card/audit/${id}`)
}

/**
 * 审批卡片
 */
export const auditCard = (data: { cardId: number; auditStatus: string; auditUserId?: number; auditRemark?: string }) => {
  return request.post<any, { data: { cardId: number | null; message: string } }>('/card/audit/process', data)
}

/**
 * 获取待审批卡片数量
 */
export const getPendingCardCount = () => {
  return request.get<any, { data: number }>('/card/audit/pending/count')
}

/**
 * 批量审批通过
 */
export const batchApproveCards = (draftIds: number[], auditUserId: number) => {
  return request.post<any, { data: string }>('/card/audit/batch/pass', draftIds, { params: { auditUserId } })
}

/**
 * 批量审批拒绝
 */
export const batchRejectCards = (draftIds: number[], auditUserId: number, auditRemark?: string) => {
  return request.post<any, { data: string }>('/card/audit/batch/reject', draftIds, { params: { auditUserId, auditRemark } })
}

// ==================== 评论管理 ====================

/**
 * 分页查询评论列表
 */
export const getCommentPage = (params: { cardId?: number; commentType?: string; status?: string; pageNum: number; pageSize: number }) => {
  return request.get<any, PageResult<CommentVO>>('/admin/comment/page', { params })
}

/**
 * 管理员回复评论
 */
export const replyComment = (commentId: number, reply: string) => {
  return request.post(`/admin/comment/reply/${commentId}`, reply)
}

/**
 * 处理评论
 */
export const handleComment = (commentId: number, status: string) => {
  return request.post(`/admin/comment/handle/${commentId}`, null, { params: { status } })
}

/**
 * 删除评论
 */
export const deleteComment = (commentId: number) => {
  return request.delete(`/admin/comment/${commentId}`)
}

// 评论类型
export interface CommentVO {
  commentId: number
  cardId: number
  cardFrontContent: string
  subjectName: string
  userId: number
  userNickname: string
  content: string
  rating: number
  commentType: string
  commentTypeText: string
  status: string
  statusText: string
  adminReply: string
  feedbackId: number
  createTime: string
  updateTime: string
}

// ==================== 学习数据统计 ====================

/**
 * 总体学习统计
 */
export const getLearningStats = (userId?: number) => {
  return request.get<any, { data: LearningStats }>('/dashboard/learning-stats', { params: { userId } })
}

/**
 * 每日学习趋势
 */
export const getLearnTrend = (days?: number, userId?: number) => {
  return request.get<any, { data: DailyLearnTrend[] }>('/dashboard/learn-trend', { params: { days: days || 30, userId } })
}

/**
 * 用户学习排行榜
 */
export const getUserRanking = (limit?: number) => {
  return request.get<any, { data: UserLearnRank[] }>('/dashboard/user-ranking', { params: { limit: limit || 10 } })
}

/**
 * 科目学习统计
 */
export const getSubjectStats = (userId?: number) => {
  return request.get<any, { data: SubjectLearnStats[] }>('/dashboard/subject-stats', { params: { userId } })
}

/**
 * 获取系统用户列表（用于下拉选择）
 */
export const getUserList = async (): Promise<SysUser[]> => {
  const res = await request.get<any, { data: SysUser[] }>('/system/user/list')
  return res.data
}

// ==================== 学习历史 ====================

/**
 * 获取用户学习过的卡片列表（分页）
 */
export const getStudiedCards = (params: { userId?: number; pageNum: number; pageSize: number }) => {
  return request.get<any, { data: { records: StudiedCard[]; total: number; pageNum: number; pageSize: number } }>('/miniprogram/study-history/cards', { params })
}

/**
 * 获取某张卡片的学习历史记录（分页）
 */
export const getCardStudyHistory = (params: { cardId: number; userId?: number; pageNum?: number; pageSize?: number }) => {
  return request.get<any, { data: { cardId: number; frontContent: string; records: StudyHistoryRecord[]; total: number } }>(`/miniprogram/study-history/card/${params.cardId}`, { params: { userId: params.userId, pageNum: params.pageNum || 1, pageSize: params.pageSize || 50 } })
}