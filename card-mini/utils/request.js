// utils/request.js - 小程序API请求工具

const BASE_URL = 'http://localhost:8080'

/**
 * 通用请求方法
 * @param {Object} options - 请求配置
 * @param {string} options.url - 请求路径（不含BASE_URL）
 * @param {string} options.method - 请求方法 GET/POST/PUT/DELETE
 * @param {Object} options.data - 请求数据
 * @returns {Promise} - 返回Promise
 */
const request = (options) => {
  return new Promise((resolve, reject) => {
    wx.request({
      url: BASE_URL + options.url,
      method: options.method || 'GET',
      data: options.data,
      header: {
        'Content-Type': 'application/json'
      },
      success: (res) => {
        const data = res.data
        if (data.code === 200) {
          resolve(data)
        } else {
          wx.showToast({
            title: data.message || '请求失败',
            icon: 'none'
          })
          reject(data)
        }
      },
      fail: (err) => {
        wx.showToast({
          title: '网络错误',
          icon: 'none'
        })
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
 * @param {number} params.pageNum - 页码
 * @param {number} params.pageSize - 每页数量
 */
const getCardPage = (params) => 
  request({ url: '/api/miniprogram/cards', data: params })

/**
 * 获取卡片详情
 * @param {number} cardId - 卡片ID
 */
const getCardById = (cardId) => 
  request({ url: `/api/miniprogram/cards/${cardId}` })

/**
 * 更新学习进度
 * @param {Object} data - 进度数据
 * @param {number} data.cardId - 卡片ID
 * @param {number} data.appUserId - 用户ID（可选，游客模式可不传）
 * @param {number} data.status - 状态 0未学/1模糊/2掌握
 */
const updateProgress = (data) => 
  request({ url: '/api/miniprogram/progress', method: 'POST', data })

/**
 * 获取学习统计
 * @param {number} appUserId - 用户ID（可选）
 */
const getProgressStats = (appUserId) => 
  request({ url: '/api/miniprogram/stats', data: { appUserId } })

/**
 * 获取待复习卡片
 * @param {number} appUserId - 用户ID（可选）
 */
const getReviewCards = (appUserId) => 
  request({ url: '/api/miniprogram/review', data: { appUserId } })

// 导出API方法
module.exports = {
  request,
  getMajorList,
  getSubjectList,
  getCardPage,
  getCardById,
  updateProgress,
  getProgressStats,
  getReviewCards
}