// pages/feedback-list/feedback-list.js
const { getUserFeedbackList, getFeedbackById } = require('../../utils/request')

Page({
  data: {
    isLoggedIn: false,
    appUserId: null,

    feedbackList: [],
    pageNum: 1,
    pageSize: 10,
    total: 0,
    hasMore: true,
    loading: false,

    // 类型映射
    typeMap: {
      SUGGESTION: '建议',
      ERROR: '纠错',
      FUNCTION: '功能问题',
      OTHER: '其他'
    },

    // 状态映射
    statusMap: {
      '0': '待处理',
      '1': '已采纳',
      '2': '已忽略'
    }
  },

  onLoad() {
    this.checkLoginStatus()
  },

  onShow() {
    // 每次显示页面时重新检查登录状态并加载数据
    this.checkLoginStatus()
    if (this.data.isLoggedIn) {
      this.loadFeedbackList()
    }
  },

  // 检查登录状态
  checkLoginStatus() {
    const userInfo = wx.getStorageSync('userInfo')
    const isLoggedIn = userInfo && userInfo.userId

    this.setData({
      isLoggedIn,
      appUserId: isLoggedIn ? userInfo.userId : null
    })
  },

  // 去登录
  goLogin() {
    wx.setStorageSync('need_show_login', true)
    wx.setStorageSync('login_redirect_url', '/pages/feedback-list/feedback-list')
    wx.switchTab({
      url: '/pages/profile/profile'
    })
  },

  // 加载反馈列表
  async loadFeedbackList() {
    if (this.data.loading) return

    this.setData({ loading: true })

    try {
      const res = await getUserFeedbackList(
        this.data.appUserId,
        this.data.pageNum,
        this.data.pageSize
      )

      const feedbackList = res.data.records || []
      const total = res.data.total || 0

      this.setData({
        feedbackList: this.data.pageNum === 1 ? feedbackList : this.data.feedbackList.concat(feedbackList),
        total,
        hasMore: feedbackList.length >= this.data.pageSize
      })
    } catch (error) {
      wx.showToast({
        title: '加载失败',
        icon: 'none'
      })
    } finally {
      this.setData({ loading: false })
    }
  },

  // 加载更多
  loadMore() {
    if (this.data.loading || !this.data.hasMore) return

    this.setData({
      pageNum: this.data.pageNum + 1
    })

    this.loadFeedbackList()
  },

  // 查看详情
  async viewDetail(e) {
    const id = e.currentTarget.dataset.id

    try {
      const res = await getFeedbackById(id)
      const feedback = res.data

      // 显示详情弹窗
      wx.showModal({
        title: '反馈详情',
        content: feedback.content + (feedback.adminReply ? '\n\n管理员回复:\n' + feedback.adminReply : ''),
        showCancel: false
      })
    } catch (error) {
      wx.showToast({
        title: '获取详情失败',
        icon: 'none'
      })
    }
  },

  // 去提交反馈
  goFeedback() {
    wx.navigateTo({
      url: '/pages/feedback/feedback'
    })
  }
})
