import request from './request'
import type { Major, Subject, Card, Tag, Feedback, FeedbackVO, PageResult } from './types'

// 专业相关
export const getMajorList = () => {
  return request.get<any, { data: Major[] }>('/major/list')
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
export const getCardPage = (params: { subjectId?: number; pageNum: number; pageSize: number }) => {
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
export const getTagList = () => {
  return request.get<any, { data: Tag[] }>('/tag/list')
}

export const createTag = (data: Tag) => {
  return request.post('/tag', data)
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