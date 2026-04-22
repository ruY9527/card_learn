// pages/progress-cards/progress-cards.js
const { getLearnedCards, getMasteredCards, getReviewCardsList } = require('../../utils/request')

Page({
  data: {
    statusType: '',        // learned/mastered/review
    title: '',             // 页面标题
    appUserId: null,
    cardList: [],
    loading: false,
    hasMore: true,
    pageNum: 1,
    pageSize: 20,
    total: 0,

    // 状态映射
    statusMap: {
      learned: { title: '已学习卡片', color: '#409eff' },
      mastered: { title: '已掌握卡片', color: '#67c23a' },
      review: { title: '待复习卡片', color: '#e6a23c' }
    }
  },

  onLoad(options) {
    const statusType = options.type || 'learned'
    const userInfo = wx.getStorageSync('userInfo')
    const appUserId = userInfo ? userInfo.userId : null

    const statusInfo = this.data.statusMap[statusType] || this.data.statusMap.learned

    this.setData({
      statusType,
      title: statusInfo.title,
      appUserId
    })

    // 设置导航栏标题
    wx.setNavigationBarTitle({ title: statusInfo.title })

    // 加载卡片列表
    this.loadCards()
  },

  // 加载卡片列表
  async loadCards() {
    if (this.data.loading || !this.data.hasMore) return

    this.setData({ loading: true })

    try {
      const { appUserId, statusType, pageNum, pageSize } = this.data
      let result

      switch (statusType) {
        case 'learned':
          result = await getLearnedCards(appUserId, pageNum, pageSize)
          break
        case 'mastered':
          result = await getMasteredCards(appUserId, pageNum, pageSize)
          break
        case 'review':
          result = await getReviewCardsList(appUserId, pageNum, pageSize)
          break
        default:
          result = await getLearnedCards(appUserId, pageNum, pageSize)
      }

      const newCards = result.data.records || []
      const total = result.data.total || 0

      // 格式化时间显示
      const formattedCards = newCards.map(card => ({
        ...card,
        formattedTime: this.formatTime(card.updateTime),
        fullTime: this.formatFullTime(card.updateTime)
      }))

      this.setData({
        cardList: pageNum === 1 ? formattedCards : [...this.data.cardList, ...formattedCards],
        total,
        hasMore: this.data.cardList.length + formattedCards.length < total,
        pageNum: pageNum + 1,
        loading: false
      })
    } catch (error) {
      console.error('加载卡片失败:', error)
      this.setData({ loading: false })
      wx.showToast({
        title: '加载失败',
        icon: 'none'
      })
    }
  },

  // 下拉刷新
  onPullDownRefresh() {
    this.setData({
      pageNum: 1,
      cardList: [],
      hasMore: true
    })
    this.loadCards().then(() => {
      wx.stopPullDownRefresh()
    })
  },

  // 上拉加载更多
  onReachBottom() {
    this.loadCards()
  },

  // 点击卡片查看详情
  onCardTap(e) {
    const card = e.currentTarget.dataset.card
    if (!card || !card.cardId) return

    wx.navigateTo({
      url: `/pages/card/card?cardId=${card.cardId}`
    })
  },

  // 获取状态标签样式
  getStatusStyle(status) {
    switch (status) {
      case 2:
        return { text: '已掌握', class: 'mastered' }
      case 1:
        return { text: '待复习', class: 'review' }
      default:
        return { text: '未学习', class: 'unlearned' }
    }
  },

  // 格式化卡片内容（截取前50字）
  formatContent(content) {
    if (!content) return ''
    return content.length > 50 ? content.substring(0, 50) + '...' : content
  },

  // 格式化时间显示
  formatTime(timeStr) {
    if (!timeStr) return ''
    
    // 解析时间字符串
    const date = new Date(timeStr)
    if (isNaN(date.getTime())) return ''
    
    const now = new Date()
    const diff = now - date  // 毫秒差
    
    // 计算时间差
    const minutes = Math.floor(diff / 60000)
    const hours = Math.floor(diff / 3600000)
    const days = Math.floor(diff / 86400000)
    
    if (minutes < 1) {
      return '刚刚'
    } else if (minutes < 60) {
      return `${minutes}分钟前`
    } else if (hours < 24) {
      return `${hours}小时前`
    } else if (days < 7) {
      return `${days}天前`
    } else {
      // 显示具体日期
      const month = date.getMonth() + 1
      const day = date.getDate()
      return `${month}月${day}日`
    }
  },

  // 格式化完整时间
  formatFullTime(timeStr) {
    if (!timeStr) return ''
    
    const date = new Date(timeStr)
    if (isNaN(date.getTime())) return ''
    
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    const hour = String(date.getHours()).padStart(2, '0')
    const minute = String(date.getMinutes()).padStart(2, '0')
    
    return `${year}-${month}-${day} ${hour}:${minute}`
  }
})