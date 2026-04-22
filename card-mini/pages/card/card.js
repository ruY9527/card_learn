// pages/card/card.js
const { getCardById, getCardPage, updateProgress } = require('../../utils/request')

Page({
  data: {
    subjectId: null,
    subjectName: '',
    cardList: [],
    currentIndex: 0,
    currentCard: null,
    isFlipped: false,
    totalCount: 0,
    progress: 0,
    pageNum: 1,
    pageSize: 20,
    hasMore: true,
    loading: false,
    isSingleMode: false,
    appUserId: null,

    // 滑动相关
    startX: 0,
    startY: 0,
    moveX: 0,
    isSwiping: false,
    swipeDirection: ''
  },

  onLoad(options) {
    console.log('卡片页面参数:', options)

    // 获取用户信息
    const userInfo = wx.getStorageSync('userInfo')
    const appUserId = userInfo ? userInfo.userId : null

    const subjectId = parseInt(options.subjectId) || 0
    const cardId = parseInt(options.cardId) || 0
    let subjectName = ''

    if (options.subjectName) {
      try {
        subjectName = decodeURIComponent(options.subjectName)
      } catch (e) {
        subjectName = options.subjectName
      }
    }

    this.setData({ appUserId })

    if (!subjectId && cardId) {
      this.setData({ isSingleMode: true })
      this.loadSingleCard(cardId, appUserId)
    } else {
      this.setData({ subjectId, subjectName, isSingleMode: false })
      this.loadCards(cardId, appUserId)
    }
  },

  // 单卡模式：只加载单个卡片
  loadSingleCard(cardId, appUserId) {
    this.setData({ loading: true })

    getCardById(cardId, appUserId).then(res => {
      console.log('单卡详情:', res)

      if (res.data) {
        this.setData({
          currentCard: res.data,
          cardList: [res.data],
          currentIndex: 0,
          totalCount: 1,
          progress: 100,
          loading: false,
          subjectName: res.data.subjectName || '知识点卡片'
        })
      } else {
        this.setData({ loading: false })
        wx.showToast({
          title: '卡片不存在',
          icon: 'none'
        })
      }
    }).catch(error => {
      console.error('获取卡片失败:', error)
      this.setData({ loading: false })
      wx.showToast({
        title: '获取卡片失败',
        icon: 'none'
      })
    })
  },

  // 加载卡片列表（从学习页进入）
  loadCards(startCardId = 0, appUserId) {
    if (this.data.loading) return

    this.setData({ loading: true })

    getCardPage({
      subjectId: this.data.subjectId,
      pageNum: this.data.pageNum,
      pageSize: this.data.pageSize,
      appUserId: appUserId
    }).then(res => {
      console.log('卡片列表响应:', res)

      const cards = res.data && res.data.records ? res.data.records : []
      const total = res.data && res.data.total ? res.data.total : 0

      let startIndex = 0
      if (startCardId > 0) {
        const idx = cards.findIndex(c => c.cardId === startCardId)
        if (idx >= 0) startIndex = idx
      }

      this.setData({
        cardList: cards,
        totalCount: total,
        currentIndex: startIndex,
        currentCard: cards[startIndex] || null,
        hasMore: cards.length < total,
        loading: false,
        progress: total > 0 ? Math.round(((startIndex + 1) / total) * 100) : 0
      })
    }).catch(error => {
      console.error('获取卡片失败:', error)
      this.setData({ loading: false })
      wx.showToast({
        title: '获取卡片失败',
        icon: 'none'
      })
    })
  },

  // 加载更多卡片
  loadMoreCards() {
    if (!this.data.hasMore || this.data.loading) return

    const prevLength = this.data.cardList.length

    this.setData({
      pageNum: this.data.pageNum + 1,
      loading: true
    })

    getCardPage({
      subjectId: this.data.subjectId,
      pageNum: this.data.pageNum,
      pageSize: this.data.pageSize,
      appUserId: this.data.appUserId
    }).then(res => {
      const newCards = res.data && res.data.records ? res.data.records : []
      const total = res.data && res.data.total ? res.data.total : 0

      this.setData({
        cardList: [...this.data.cardList, ...newCards],
        totalCount: total,
        hasMore: this.data.cardList.length < total,
        loading: false,
        // 设置当前卡片为加载后的第一张新卡片
        currentIndex: prevLength,
        currentCard: newCards[0] || this.data.cardList[prevLength],
        isFlipped: false
      })
    }).catch(error => {
      console.error('加载更多失败:', error)
      this.setData({ loading: false })
      wx.showToast({
        title: '加载失败',
        icon: 'none'
      })
    })
  },

  // 翻转卡片
  toggleFlip() {
    this.setData({ isFlipped: !this.data.isFlipped })
    console.log('翻转卡片:', this.data.isFlipped)
  },

  // 处理学习状态
  handleStatus(e) {
    const status = parseInt(e.currentTarget.dataset.status)
    console.log('更新学习状态:', status)

    const card = this.data.currentCard
    if (!card) return

    updateProgress({
      cardId: card.cardId,
      appUserId: this.data.appUserId,
      status: status
    }).then(() => {
      wx.showToast({
        title: this.getStatusToast(status),
        icon: 'success',
        duration: 1000
      })

      // 更新卡片状态
      const cardList = this.data.cardList
      if (cardList[this.data.currentIndex]) {
        cardList[this.data.currentIndex].status = status
        this.setData({ cardList })
      }

      // 更新当前卡片状态
      const currentCard = this.data.currentCard
      currentCard.status = status
      this.setData({ currentCard })

      // 保存到本地存储
      this.saveProgressLocal(status)

      // 单卡模式不自动跳转
      if (!this.data.isSingleMode) {
        setTimeout(() => {
          this.goToNext()
        }, 1000)
      }
    }).catch(error => {
      console.error('更新进度失败:', error)
      this.saveProgressLocal(status)
      if (!this.data.isSingleMode) {
        setTimeout(() => {
          this.goToNext()
        }, 1000)
      }
    })
  },

  // 获取状态提示
  getStatusToast(status) {
    if (status === 2) return '已掌握 ✓'
    if (status === 1) return '继续加油 ~'
    return '需要复习'
  },

  // 保存进度到本地
  saveProgressLocal(status) {
    let stats = wx.getStorageSync('stats') || { learned: 0, mastered: 0, review: 0 }

    // 防止重复计数
    const prevStatus = this.data.currentCard.status || 0
    
    // 调整计数
    if (prevStatus === 0 && status >= 1) stats.learned++
    if (prevStatus === 1 && status === 2) {
      stats.mastered++
      stats.review--
    }
    if (prevStatus === 0 && status === 1) stats.review++
    if (prevStatus === 2 && status === 1) {
      stats.mastered--
      stats.review++
    }

    // 确保数值不为负
    stats.learned = Math.max(0, stats.learned)
    stats.mastered = Math.max(0, stats.mastered)
    stats.review = Math.max(0, stats.review)

    wx.setStorageSync('stats', stats)
    console.log('保存本地统计:', stats)
  },

  // 触摸开始
  onTouchStart(e) {
    this.setData({
      startX: e.touches[0].clientX,
      startY: e.touches[0].clientY,
      moveX: 0,
      isSwiping: true,
      swipeDirection: ''
    })
  },

  // 触摸移动
  onTouchMove(e) {
    if (!this.data.isSwiping) return

    const moveX = e.touches[0].clientX - this.data.startX
    const moveY = e.touches[0].clientY - this.data.startY

    if (!this.data.swipeDirection) {
      if (Math.abs(moveX) > Math.abs(moveY) && Math.abs(moveX) > 10) {
        this.setData({ swipeDirection: 'horizontal' })
      } else if (Math.abs(moveY) > Math.abs(moveX) && Math.abs(moveY) > 10) {
        this.setData({ swipeDirection: 'vertical' })
      }
    }

    if (this.data.swipeDirection === 'horizontal') {
      this.setData({ moveX })
    }
  },

  // 触摸结束
  onTouchEnd(e) {
    if (!this.data.isSwiping) return

    const { moveX, swipeDirection, isSingleMode } = this.data

    this.setData({
      isSwiping: false,
      moveX: 0,
      swipeDirection: ''
    })

    if (isSingleMode || swipeDirection !== 'horizontal') return

    const threshold = 80

    if (moveX > threshold) {
      this.goToPrev()
    } else if (moveX < -threshold) {
      this.goToNext()
    }
  },

  // 上一张
  goToPrev() {
    if (this.data.currentIndex <= 0) {
      wx.showToast({
        title: '已经是第一张',
        icon: 'none',
        duration: 1000
      })
      return
    }

    const newIndex = this.data.currentIndex - 1
    const newCard = this.data.cardList[newIndex]
    this.setData({
      currentIndex: newIndex,
      currentCard: newCard,
      isFlipped: false,
      progress: Math.round(((newIndex + 1) / this.data.totalCount) * 100)
    })
    console.log('切换到上一张:', newIndex, newCard)
  },

  // 下一张
  goToNext() {
    const { currentIndex, cardList, totalCount, hasMore, isSingleMode } = this.data

    if (isSingleMode) {
      wx.showToast({
        title: '点击返回继续学习',
        icon: 'none',
        duration: 1500
      })
      return
    }

    if (currentIndex >= cardList.length - 1) {
      if (hasMore) {
        wx.showToast({
          title: '加载更多...',
          icon: 'loading',
          duration: 1000
        })
        this.loadMoreCards()
        return
      }

      wx.showToast({
        title: '恭喜！已完成学习',
        icon: 'success',
        duration: 2000
      })
      return
    }

    const newIndex = currentIndex + 1
    const newCard = cardList[newIndex]
    this.setData({
      currentIndex: newIndex,
      currentCard: newCard,
      isFlipped: false,
      progress: Math.round(((newIndex + 1) / totalCount) * 100)
    })
    console.log('切换到下一张:', newIndex, newCard)
  },

  // 按钮点击上一张
  handlePrev() {
    this.goToPrev()
  },

  // 按钮点击下一张
  handleNext() {
    this.goToNext()
  },

  // 返回上一页
  handleBack() {
    wx.navigateBack()
  },

  // 去反馈页面
  goFeedback() {
    const card = this.data.currentCard
    if (!card) return

    // 跳转到反馈页面，携带卡片ID和正面内容
    wx.navigateTo({
      url: `/pages/feedback/feedback?cardId=${card.cardId}&content=${encodeURIComponent(card.frontContent.substring(0, 50))}`
    })
  },

  // 分享功能
  onShareAppMessage() {
    return {
      title: `${this.data.subjectName} - 知识点卡片`,
      path: `/pages/card/card?cardId=${this.data.currentCard.cardId}&subjectId=${this.data.subjectId}&subjectName=${encodeURIComponent(this.data.subjectName)}`,
      imageUrl: '' // 可自定义分享图片
    }
  }
})