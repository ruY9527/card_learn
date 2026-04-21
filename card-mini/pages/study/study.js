// pages/study/study.js
const { getCardPage, getProgressStats } = require('../../utils/request')

Page({
  data: {
    subjectId: null,
    subjectName: '',
    cardList: [],
    totalCount: 0,
    learnedCount: 0,
    reviewCount: 0,
    currentTab: 'all',
    pageNum: 1,
    pageSize: 10,
    hasMore: true,
    loading: false,
    error: false,
    errorMsg: ''
  },

  onLoad(options) {
    console.log('学习页面参数:', options)

    // 确保 subjectId 正确解析
    let subjectId = null
    if (options.subjectId) {
      subjectId = parseInt(options.subjectId)
      // 如果解析失败，保持为 null
      if (isNaN(subjectId)) {
        subjectId = null
      }
    }

    let subjectName = '科目学习'

    // 解码科目名称
    if (options.subjectName) {
      try {
        subjectName = decodeURIComponent(options.subjectName)
      } catch (e) {
        subjectName = options.subjectName
      }
    }

    console.log('科目ID:', subjectId, '科目名称:', subjectName)

    // 如果没有有效的 subjectId，显示错误提示
    if (!subjectId) {
      this.setData({
        error: true,
        errorMsg: '请从首页选择科目进入学习',
        loading: false
      })
      return
    }

    this.setData({ subjectId, subjectName })
    this.fetchCards()
    this.fetchStats()
  },

  // 获取卡片列表
  fetchCards() {
    if (this.data.loading || !this.data.subjectId) return

    this.setData({ loading: true, error: false })

    console.log('请求卡片参数:', {
      subjectId: this.data.subjectId,
      pageNum: this.data.pageNum,
      pageSize: this.data.pageSize
    })

    getCardPage({
      subjectId: this.data.subjectId,
      pageNum: this.data.pageNum,
      pageSize: this.data.pageSize
    }).then(res => {
      console.log('卡片列表响应:', res)

      const cards = res.data && res.data.records ? res.data.records : []
      const total = res.data && res.data.total ? res.data.total : 0

      console.log('卡片数量:', cards.length, '总数:', total)

      this.setData({
        cardList: this.data.pageNum === 1 ? cards : [...this.data.cardList, ...cards],
        totalCount: total,
        hasMore: cards.length < total,
        loading: false,
        error: false
      })
    }).catch(error => {
      console.error('获取卡片失败:', error)
      this.setData({
        cardList: [],
        loading: false,
        error: true,
        errorMsg: '获取卡片失败，请检查网络连接'
      })
      wx.showToast({
        title: '获取卡片失败',
        icon: 'none',
        duration: 2000
      })
    })
  },

  // 获取学习统计
  fetchStats() {
    // 从本地存储获取统计
    const stats = wx.getStorageSync('stats') || { learned: 0, mastered: 0, review: 0 }
    this.setData({
      learnedCount: stats.learned || 0,
      reviewCount: stats.review || 0
    })

    // 尝试从服务器获取
    if (!this.data.subjectId) return

    getProgressStats().then(res => {
      console.log('学习统计:', res)
      if (res.data) {
        this.setData({
          learnedCount: Math.max(this.data.learnedCount, res.data.learned || 0),
          reviewCount: Math.max(this.data.reviewCount, res.data.review || 0)
        })
      }
    }).catch(error => {
      console.log('使用本地统计数据')
    })
  },

  // 切换标签
  handleTabChange(e) {
    const tab = e.currentTarget.dataset.tab
    console.log('切换标签:', tab)
    this.setData({
      currentTab: tab,
      pageNum: 1,
      cardList: []
    })
    this.fetchCards()
  },

  // 点击卡片
  handleCardClick(e) {
    const card = e.currentTarget.dataset.card
    if (!card || !card.cardId) {
      wx.showToast({ title: '卡片数据错误', icon: 'none' })
      return
    }

    console.log('点击卡片:', card)

    wx.navigateTo({
      url: `/pages/card/card?cardId=${card.cardId}&subjectId=${this.data.subjectId}&subjectName=${encodeURIComponent(this.data.subjectName)}`
    })
  },

  // 开始学习按钮
  handleStartStudy() {
    if (this.data.cardList.length > 0) {
      const firstCard = this.data.cardList[0]
      if (!firstCard || !firstCard.cardId) {
        wx.showToast({ title: '卡片数据错误', icon: 'none' })
        return
      }
      wx.navigateTo({
        url: `/pages/card/card?cardId=${firstCard.cardId}&subjectId=${this.data.subjectId}&subjectName=${encodeURIComponent(this.data.subjectName)}`
      })
    } else {
      wx.showToast({
        title: '暂无卡片',
        icon: 'none'
      })
    }
  },

  // 重新加载
  handleRetry() {
    this.setData({ pageNum: 1, cardList: [], error: false })
    this.fetchCards()
  },

  // 返回首页
  handleGoHome() {
    wx.switchTab({ url: '/pages/index/index' })
  },

  // 加载更多
  loadMore() {
    if (!this.data.hasMore || this.data.loading) return
    this.setData({ pageNum: this.data.pageNum + 1 })
    this.fetchCards()
  },

  // 下拉刷新
  onPullDownRefresh() {
    this.setData({ pageNum: 1, cardList: [], error: false })
    this.fetchCards()
    wx.stopPullDownRefresh()
  }
})