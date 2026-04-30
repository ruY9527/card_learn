// pages/study/study.js
const { getCardPage, getProgressStats, getSubjectStats } = require('../../utils/request')

Page({
  data: {
    subjectId: null,
    subjectName: '',
    cardList: [],
    totalCount: 0,
    learnedCount: 0,
    masteredCount: 0,
    reviewCount: 0,
    unlearnedCount: 0,
    currentTab: 'all',
    pageNum: 1,
    pageSize: 10,
    hasMore: true,
    loading: false,
    error: false,
    errorMsg: '',
    appUserId: null,
    searchKeyword: '' // 搜索关键词
  },

  onLoad(options) {
    console.log('学习页面参数:', options)

    // 获取用户信息
    const userInfo = wx.getStorageSync('userInfo')
    const appUserId = userInfo ? userInfo.userId : null

    let subjectId = null
    if (options.subjectId) {
      subjectId = parseInt(options.subjectId)
      if (isNaN(subjectId)) {
        subjectId = null
      }
    }

    let subjectName = '科目学习'

    if (options.subjectName) {
      try {
        subjectName = decodeURIComponent(options.subjectName)
      } catch (e) {
        subjectName = options.subjectName
      }
    }

    console.log('科目ID:', subjectId, '科目名称:', subjectName)

    if (!subjectId) {
      this.setData({
        error: true,
        errorMsg: '请从首页选择科目进入学习',
        loading: false
      })
      return
    }

    // 设置页面标题
    wx.setNavigationBarTitle({
      title: subjectName
    })

    // 先设置数据，然后在回调中调用请求
    this.setData({
      subjectId: subjectId,
      subjectName: subjectName,
      appUserId: appUserId
    }, () => {
      // setData回调中确保数据已设置
      this.fetchCards()
      this.fetchSubjectStats()
    })
  },

  // 获取卡片列表
  fetchCards() {
    const subjectId = this.data.subjectId
    if (this.data.loading || !subjectId) {
      console.log('fetchCards条件不满足:', this.data.loading, subjectId)
      return
    }

    this.setData({ loading: true, error: false })

    const params = {
      subjectId: subjectId,
      frontContent: this.data.searchKeyword || undefined,
      pageNum: this.data.pageNum,
      pageSize: this.data.pageSize,
      status: this.data.currentTab,
      userId: this.data.appUserId
    }

    console.log('请求卡片参数:', params)

    getCardPage(params).then(res => {
      console.log('卡片列表响应:', res)

      const cards = res.data && res.data.records ? res.data.records : []
      const total = res.data && res.data.total ? res.data.total : 0

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

  // 获取科目学习统计
  fetchSubjectStats() {
    const subjectId = this.data.subjectId
    if (!subjectId) {
      console.log('fetchSubjectStats subjectId为空')
      return
    }

    getSubjectStats(subjectId, this.data.appUserId).then(res => {
      console.log('科目统计:', res)
      if (res.data) {
        this.setData({
          learnedCount: res.data.learned || 0,
          masteredCount: res.data.mastered || 0,
          reviewCount: res.data.review || 0,
          unlearnedCount: res.data.unlearned || 0,
          totalCount: res.data.total || 0
        })
      }
    }).catch(error => {
      console.log('获取科目统计失败，使用本地数据:', error)
      const stats = wx.getStorageSync('stats') || { learned: 0, mastered: 0, review: 0 }
      this.setData({
        learnedCount: stats.learned || 0,
        masteredCount: stats.mastered || 0,
        reviewCount: stats.review || 0
      })
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

  // 搜索输入事件
  onSearchInput(e) {
    this.setData({
      searchKeyword: e.detail.value.trim()
    })
  },

  // 执行搜索
  handleSearch() {
    console.log('搜索:', this.data.searchKeyword)
    this.setData({
      pageNum: 1,
      cardList: []
    })
    this.fetchCards()
  },

  // 清除搜索
  clearSearch() {
    this.setData({
      searchKeyword: '',
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
      let startCard = this.data.cardList[0]
      for (let card of this.data.cardList) {
        if (!card.status || card.status === 0) {
          startCard = card
          break
        }
      }

      wx.navigateTo({
        url: `/pages/card/card?cardId=${startCard.cardId}&subjectId=${this.data.subjectId}&subjectName=${encodeURIComponent(this.data.subjectName)}`
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
    this.fetchSubjectStats()
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
    this.fetchSubjectStats()
    wx.stopPullDownRefresh()
  }
})