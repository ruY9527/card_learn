// utils/request.js - 小程序API请求工具

const envConfig = require('../config/env.js')
const BASE_URL = envConfig.BASE_URL

/**
 * 过滤无效参数（null、undefined、空字符串）
 */
const filterParams = (params) => {
  if (!params) return {}
  const filtered = {}
  for (const key in params) {
    const value = params[key]
    // 只保留有效值（不为 null、undefined、空字符串）
    if (value !== null && value !== undefined && value !== '') {
      filtered[key] = value
    }
  }
  return filtered
}

/**
 * 通用请求方法
 * @param {Object} options - 请求配置
 * @param {string} options.url - 请求路径（不含BASE_URL）
 * @param {string} options.method - 请求方法 GET/POST/PUT/DELETE
 * @param {Object} options.data - 请求数据
 * @param {boolean} options.needAuth - 是否需要认证（默认false）
 * @param {boolean} options.showError - 是否显示错误提示（默认true）
 * @returns {Promise} - 返回Promise
 */
const request = (options) => {
  return new Promise((resolve, reject) => {
    // 构建请求头
    const header = {
      'Content-Type': 'application/json'
    }
    // 如果需要认证，添加 token
    if (options.needAuth) {
      const token = wx.getStorageSync('token')
      if (!token) {
        const authError = { code: 401, message: '请先登录后再操作' }
        if (options.showError !== false) {
          wx.showToast({
            title: authError.message,
            icon: 'none'
          })
        }
        reject(authError)
        return
      }
      header['Authorization'] = 'Bearer ' + token
    }

    console.log('请求:', BASE_URL + options.url, options.method || 'GET', options.data)

    wx.request({
      url: BASE_URL + options.url,
      method: options.method || 'GET',
      data: filterParams(options.data),  // 过滤无效参数
      header,
      success: (res) => {
        console.log('响应:', options.url, res.statusCode, res.data)
        if (res.statusCode === 401 || res.statusCode === 403) {
          const authError = {
            code: res.statusCode,
            message: '登录已失效，请重新登录'
          }
          wx.removeStorageSync('token')
          wx.removeStorageSync('userInfo')
          if (options.showError !== false) {
            wx.showToast({
              title: authError.message,
              icon: 'none'
            })
          }
          reject(authError)
          return
        }
        const data = res.data
        if (data.code === 200) {
          resolve(data)
        } else {
          if (options.showError !== false) {
            wx.showToast({
              title: data.message || '请求失败',
              icon: 'none'
            })
          }
          reject(data)
        }
      },
      fail: (err) => {
        console.error('请求失败:', options.url, err)
        if (options.showError !== false) {
          wx.showToast({
            title: '网络错误',
            icon: 'none'
          })
        }
        reject(err)
      }
    })
  })
}

// ==================== 认证相关API ====================

/**
 * 获取验证码
 * @returns {Promise} - 返回 { key, image }
 */
const getCaptcha = () => {
  return new Promise((resolve, reject) => {
    console.log('获取验证码:', BASE_URL + '/captcha/generate')
    wx.request({
      url: BASE_URL + '/captcha/generate',
      method: 'GET',
      header: { 'Content-Type': 'application/json' },
      success: (res) => {
        console.log('验证码响应:', res.data)
        if (res.data && res.data.code === 200) {
          resolve(res.data.data)
        } else {
          wx.showToast({ title: res.data.message || '获取验证码失败', icon: 'none' })
          reject(res.data)
        }
      },
      fail: (err) => {
        console.error('验证码请求失败:', err)
        wx.showToast({ title: '网络错误', icon: 'none' })
        reject(err)
      }
    })
  })
}

/**
 * 用户登录
 * @param {Object} data - 登录数据
 * @param {string} data.username - 用户名
 * @param {string} data.password - 密码
 * @param {string} data.captcha - 验证码
 * @param {string} data.captchaKey - 验证码key
 * @returns {Promise} - 返回 { token, user }
 */
const login = (data) => {
  return new Promise((resolve, reject) => {
    const loginData = {
      username: data.username.trim(),
      password: data.password.trim(),
      captcha: data.captcha.trim(),
      captchaKey: data.captchaKey
    }
    console.log('登录请求:', BASE_URL + '/auth/login', loginData)

    wx.request({
      url: BASE_URL + '/auth/login',
      method: 'POST',
      header: { 'Content-Type': 'application/json' },
      data: loginData,
      success: (res) => {
        console.log('登录响应:', res.statusCode, res.data)
        if (res.data && res.data.code === 200) {
          // 保存登录信息到本地
          const userData = res.data.data.user || {}
          const userInfo = {
            userId: userData.userId,
            nickname: userData.nickname || loginData.username,
            avatar: userData.avatar || '',
            username: userData.username || loginData.username
          }
          wx.setStorageSync('userInfo', userInfo)
          wx.setStorageSync('token', res.data.data.token || '')
          resolve(res.data.data)
        } else {
          wx.showToast({ title: res.data.message || '登录失败', icon: 'none' })
          reject(res.data)
        }
      },
      fail: (err) => {
        console.error('登录请求失败:', err)
        wx.showToast({ title: '网络错误', icon: 'none' })
        reject(err)
      }
    })
  })
}

// ==================== 小程序专用API ====================

/**
 * 获取专业列表
 */
const getMajorList = () => request({ url: '/api/miniprogram/majors' })

/**
 * 获取科目列表
 * @param {number} majorId - 专业ID（可选）
 */
const getSubjectList = (majorId) =>
  request({ url: '/api/miniprogram/subjects', data: { majorId } })

/**
 * 分页获取卡片列表
 * @param {Object} params - 参数
 * @param {number} params.subjectId - 科目ID（可选）
 * @param {string} params.frontContent - 正面内容关键词（可选）
 * @param {number} params.userId - 用户ID（可选）
 * @param {string} params.status - 状态筛选：all/learned/unlearned/mastered/review
 * @param {number} params.pageNum - 页码
 * @param {number} params.pageSize - 每页数量
 */
const getCardPage = (params) =>
  request({ url: '/api/miniprogram/cards', data: params })

/**
 * 获取已学习卡片列表
 * @param {number} userId - 用户ID
 * @param {number} pageNum - 页码
 * @param {number} pageSize - 每页数量
 */
const getLearnedCards = (userId, pageNum = 1, pageSize = 20) =>
  request({ url: '/api/miniprogram/cards', data: { userId: userId, status: 'learned', pageNum, pageSize } })

/**
 * 获取已掌握卡片列表
 * @param {number} userId - 用户ID
 * @param {number} pageNum - 页码
 * @param {number} pageSize - 每页数量
 */
const getMasteredCards = (userId, pageNum = 1, pageSize = 20) =>
  request({ url: '/api/miniprogram/cards', data: { userId: userId, status: 'mastered', pageNum, pageSize } })

/**
 * 获取待复习卡片列表
 * @param {number} userId - 用户ID
 * @param {number} pageNum - 页码
 * @param {number} pageSize - 每页数量
 */
const getReviewCardsList = (userId, pageNum = 1, pageSize = 20) =>
  request({ url: '/api/miniprogram/cards', data: { userId: userId, status: 'review', pageNum, pageSize } })

/**
 * 获取卡片详情
 * @param {number} cardId - 卡片ID
 * @param {number} userId - 用户ID（可选）
 */
const getCardById = (cardId, userId) =>
  request({ url: `/api/miniprogram/cards/${cardId}`, data: { userId: userId } })

/**
 * 更新学习进度
 * @param {Object} data - 进度数据
 * @param {number} data.cardId - 卡片ID
 * @param {number} data.userId - 用户ID（可选，游客模式可不传）
 * @param {number} data.status - 状态 0未学/1模糊/2掌握
 */
const updateProgress = (data) =>
  request({ url: '/api/miniprogram/progress', method: 'POST', data })

/**
 * 获取学习统计
 * @param {number} userId - 用户ID（可选）
 */
const getProgressStats = (userId) =>
  request({ url: '/api/miniprogram/stats', data: { userId: userId } })

/**
 * 获取科目学习统计
 * @param {number} subjectId - 科目ID
 * @param {number} userId - 用户ID（可选）
 */
const getSubjectStats = (subjectId, userId) =>
  request({ url: `/api/miniprogram/subjects/${subjectId}/stats`, data: { userId: userId } })

/**
 * 获取待复习卡片
 * @param {number} userId - 用户ID（可选）
 */
const getReviewCards = (userId) =>
  request({ url: '/api/miniprogram/review', data: { userId: userId } })

// ==================== 反馈相关API（需登录） ====================

/**
 * 提交反馈
 * @param {Object} data - 反馈数据
 * @param {number} data.userId - 用户ID（必填）
 * @param {number} data.cardId - 卡片ID（可选，卡片纠错时必填）
 * @param {string} data.type - 反馈类型：SUGGESTION/ERROR/FUNCTION/OTHER
 * @param {number} data.rating - 评分 1-5（可选）
 * @param {string} data.content - 反馈内容（必填）
 * @param {string} data.contact - 联系方式（可选）
 * @param {string} data.images - 图片URL列表JSON字符串（可选）
 */
const submitFeedback = (data) =>
  request({ url: '/api/miniprogram/feedback', method: 'POST', data, needAuth: true })

/**
 * 获取用户反馈列表
 * @param {number} userId - 用户ID
 * @param {number} pageNum - 页码
 * @param {number} pageSize - 每页数量
 */
const getUserFeedbackList = (userId, pageNum = 1, pageSize = 10) =>
  request({ url: '/api/miniprogram/feedback/list', data: { userId: userId, pageNum, pageSize }, needAuth: true })

/**
 * 获取反馈详情
 * @param {number} id - 反馈ID
 */
const getFeedbackById = (id) =>
  request({ url: `/api/miniprogram/feedback/${id}`, needAuth: true })

/**
 * 获取冲刺配置（倒计时）
 */
const getSprintConfig = () =>
  request({ url: '/api/miniprogram/sprint-config' })

/**
 * 获取今日推荐卡片（每个科目2条）
 * @param {number} majorId - 专业ID（可选，不传则获取所有专业的推荐）
 */
const getRecommendCards = (majorId) =>
  request({ url: '/api/miniprogram/recommend', data: { majorId } })

// ==================== 用户录入卡片API ====================

/**
 * 用户录入卡片
 * @param {Object} data - 卡片数据
 */
const createCardByUser = (data) =>
  request({ url: '/api/miniprogram/card/create', method: 'POST', data, needAuth: true })

/**
 * 获取我的卡片列表
 * @param {Object} params - 参数
 * @param {number} params.pageNum - 页码
 * @param {number} params.pageSize - 每页数量
 * @param {string} params.auditStatus - 审核状态 0待审批 1已通过 2已拒绝
 */
const getMyCards = (params) =>
  request({ url: '/api/miniprogram/card/my', data: params, needAuth: true })

/**
 * 获取我的卡片统计
 */
const getMyCardStats = () =>
  request({ url: '/api/miniprogram/card/my/stats', needAuth: true })

/**
 * 删除我的卡片
 * @param {number} id - 草稿ID
 */
const deleteMyCard = (id) =>
  request({ url: `/api/miniprogram/card/my/${id}`, method: 'DELETE', needAuth: true })

// ==================== 评论相关API ====================

/**
 * 提交评论
 * @param {Object} data - 评论数据
 * @param {number} data.cardId - 卡片ID
 * @param {number} data.userId - 用户ID
 * @param {string} data.content - 评论内容
 * @param {number} data.rating - 评分1-5
 * @param {string} data.commentType - 评论类型：QUALITY/POOR/NEUTRAL
 */
const submitComment = (data) =>
  request({ url: '/api/miniprogram/comment/submit', method: 'POST', data, needAuth: true })

/**
 * 获取卡片评论列表
 * @param {number} cardId - 卡片ID
 * @param {number} pageNum - 页码
 * @param {number} pageSize - 每页数量
 */
const getCardComments = (cardId, pageNum = 1, pageSize = 10) =>
  request({ url: `/api/miniprogram/comment/list/${cardId}`, data: { pageNum, pageSize } })

/**
 * 获取卡片评论统计
 * @param {number} cardId - 卡片ID
 */
const getCommentStats = (cardId) =>
  request({ url: `/api/miniprogram/comment/stats/${cardId}` })

// ==================== 回复相关API ====================

/**
 * 提交回复
 * @param {number} commentId - 评论ID
 * @param {Object} data - 回复数据
 */
const submitReply = (commentId, data) =>
  request({ url: `/api/miniprogram/reply/${commentId}`, method: 'POST', data, needAuth: true })

/**
 * 获取评论的回复列表
 * @param {number} commentId - 评论ID
 * @param {number} userId - 用户ID（可选，用于判断点赞状态）
 * @param {number} pageNum - 页码
 * @param {number} pageSize - 每页数量
 */
const getReplyList = (commentId, userId, pageNum = 1, pageSize = 10) =>
  request({ url: `/api/miniprogram/reply/list/${commentId}`, data: { userId, pageNum, pageSize } })

/**
 * 获取子回复列表
 * @param {number} parentReplyId - 父回复ID
 * @param {number} userId - 用户ID（可选）
 */
const getChildrenReplies = (parentReplyId, userId) =>
  request({ url: `/api/miniprogram/reply/children/${parentReplyId}`, data: { userId } })

/**
 * 删除回复
 * @param {number} replyId - 回复ID
 * @param {number} userId - 用户ID
 */
const deleteReply = (replyId, userId) =>
  request({ url: `/api/miniprogram/reply/${replyId}`, method: 'DELETE', data: { userId }, needAuth: true })

// ==================== 点赞相关API ====================

/**
 * 点赞/取消点赞评论
 * @param {number} commentId - 评论ID
 * @param {number} userId - 用户ID
 */
const toggleCommentLike = (commentId, userId) =>
  request({ url: `/api/miniprogram/like/comment/${commentId}`, method: 'POST', data: { userId }, needAuth: true })

/**
 * 点赞/取消点赞回复
 * @param {number} replyId - 回复ID
 * @param {number} userId - 用户ID
 */
const toggleReplyLike = (replyId, userId) =>
  request({ url: `/api/miniprogram/like/reply/${replyId}`, method: 'POST', data: { userId }, needAuth: true })

// ==================== 笔记相关API ====================

/**
 * 获取我的笔记列表
 * @param {Object} params - 查询参数
 */
const getMyNotes = (params) =>
  request({ url: '/api/miniprogram/note/my', data: params, needAuth: true })

/**
 * 编辑笔记
 * @param {number} noteId - 笔记ID
 * @param {number} userId - 用户ID
 * @param {string} content - 笔记内容
 */
const editNote = (noteId, userId, content) =>
  request({ url: `/api/miniprogram/note/${noteId}`, method: 'PUT', data: { userId, content }, needAuth: true })

/**
 * 删除笔记
 * @param {number} noteId - 笔记ID
 * @param {number} userId - 用户ID
 */
const deleteNote = (noteId, userId) =>
  request({ url: `/api/miniprogram/note/${noteId}`, method: 'DELETE', data: { userId }, needAuth: true })

/**
 * 导出笔记
 * @param {Object} params - 查询参数
 */
const exportNotes = (params) =>
  request({ url: '/api/miniprogram/note/export', data: params, needAuth: true })

/**
 * 简化复习提交（服务端自动计算SM-2）
 * @param {Object} data
 * @param {number} data.cardId - 卡片ID
 * @param {number} data.userId - 用户ID
 * @param {number} data.status - 状态 0未学/1模糊/2掌握
 */
const submitReview = (data) =>
  request({ url: '/api/learning/review/simple', method: 'POST', data })

// 导出API方法
module.exports = {
  request,
  getCaptcha,
  login,
  getMajorList,
  getSubjectList,
  getCardPage,
  getLearnedCards,
  getMasteredCards,
  getReviewCardsList,
  getCardById,
  updateProgress,
  getProgressStats,
  getSubjectStats,
  getReviewCards,
  submitFeedback,
  getUserFeedbackList,
  getFeedbackById,
  getSprintConfig,
  getRecommendCards,
  createCardByUser,
  getMyCards,
  getMyCardStats,
  deleteMyCard,
  submitComment,
  getCardComments,
  getCommentStats,
  submitReply,
  getReplyList,
  getChildrenReplies,
  deleteReply,
  toggleCommentLike,
  toggleReplyLike,
  getMyNotes,
  editNote,
  deleteNote,
  exportNotes,
  submitReview
}
