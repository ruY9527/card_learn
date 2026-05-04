// pages/card/card.js
const { getCardById, getCardPage, updateProgress, getCommentStats, submitComment, submitReview } = require('../../utils/request')

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
    swipeDirection: '',

    // 评论相关
    commentStats: {},
    showCommentDialog: false,
    commentType: 'NEUTRAL',
    rating: 5,
    commentContent: '',
    canSubmit: true
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
        this.loadCommentStats()
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

    this.setData({
      loading: true,
      pageNum: 1,
      cardList: [],
      currentCard: null,
      currentIndex: 0,
      totalCount: 0,
      hasMore: true
    })

    getCardPage({
      subjectId: this.data.subjectId,
      pageNum: 1,
      pageSize: this.data.pageSize,
      userId: appUserId
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
      this.loadCommentStats()
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
      userId: this.data.appUserId
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

    // 有用户ID时使用SM-2复习接口，否则使用旧接口（游客模式）
    const apiCall = this.data.appUserId
      ? submitReview({ cardId: card.cardId, userId: this.data.appUserId, status: status })
      : updateProgress({ cardId: card.cardId, userId: this.data.appUserId, status: status })

    apiCall.then((res) => {
      // 显示下次复习时间
      let toastTitle = this.getStatusToast(status)
      if (res && res.data && res.data.intervalDays) {
        toastTitle = `${toastTitle}，${res.data.intervalDays}天后复习`
      }
      wx.showToast({
        title: toastTitle,
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

  // 加载评论统计
  loadCommentStats() {
    const card = this.data.currentCard
    if (!card) return

    getCommentStats(card.cardId).then(res => {
      this.setData({ commentStats: res.data || {} })
    }).catch(err => {
      console.error('获取评论统计失败:', err)
    })
  },

  // 显示评论弹窗
  showCommentModal() {
    const userInfo = wx.getStorageSync('userInfo')
    if (!userInfo || !userInfo.userId) {
      wx.showToast({
        title: '请先登录后再评价',
        icon: 'none'
      })
      return
    }

    this.setData({
      showCommentDialog: true,
      commentType: 'NEUTRAL',
      rating: 5,
      commentContent: ''
    })
  },

  // 隐藏评论弹窗
  hideCommentModal() {
    this.setData({ showCommentDialog: false })
  },

  // 选择评论类型
  selectCommentType(e) {
    const type = e.currentTarget.dataset.type
    this.setData({ commentType: type })
  },

  // 设置评分
  setRating(e) {
    const rating = e.currentTarget.dataset.rating
    this.setData({ rating })
  },

  // 输入评论内容
  onCommentInput(e) {
    this.setData({ commentContent: e.detail.value })
  },

  // 提交评论
  submitComment() {
    const userInfo = wx.getStorageSync('userInfo')
    if (!userInfo || !userInfo.userId) {
      wx.showToast({
        title: '请先登录',
        icon: 'none'
      })
      return
    }

    const card = this.data.currentCard
    if (!card) return

    this.setData({ canSubmit: false })

    submitComment({
      cardId: card.cardId,
      userId: userInfo.userId,
      content: this.data.commentContent,
      rating: this.data.rating,
      commentType: this.data.commentType
    }).then(res => {
      wx.showToast({
        title: '评价成功',
        icon: 'success'
      })
      this.hideCommentModal()
      this.loadCommentStats()
    }).catch(err => {
      wx.showToast({
        title: err.message || '评价失败',
        icon: 'none'
      })
    }).finally(() => {
      this.setData({ canSubmit: true })
    })
  },

  // 显示评论列表
  showComments() {
    const card = this.data.currentCard
    if (!card) return

    wx.navigateTo({
      url: `/pages/comment-list/comment-list?cardId=${card.cardId}`
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