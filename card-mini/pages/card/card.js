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
    isSingleMode: false, // 单卡模式（从首页推荐进入）

    // 滑动相关
    startX: 0,
    startY: 0,
    moveX: 0,
    isSwiping: false,
    swipeDirection: ''
  },

  onLoad(options) {
    console.log('卡片页面参数:', options)

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

    // 如果没有 subjectId，说明是从首页推荐进入，使用单卡模式
    if (!subjectId && cardId) {
      this.setData({ isSingleMode: true })
      this.loadSingleCard(cardId)
    } else {
      // 从学习页进入，加载整个科目卡片列表
      this.setData({ subjectId, subjectName, isSingleMode: false })
      this.loadCards(cardId)
    }
  },

  // 单卡模式：只加载单个卡片
  loadSingleCard(cardId) {
    this.setData({ loading: true })

    getCardById(cardId).then(res => {
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
  loadCards(startCardId = 0) {
    if (this.data.loading) return

    this.setData({ loading: true })

    getCardPage({
      subjectId: this.data.subjectId,
      pageNum: this.data.pageNum,
      pageSize: this.data.pageSize
    }).then(res => {
      console.log('卡片列表响应:', res)

      const cards = res.data && res.data.records ? res.data.records : []
      const total = res.data && res.data.total ? res.data.total : 0

      // 查找起始卡片位置
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

    this.setData({
      pageNum: this.data.pageNum + 1,
      loading: true
    })

    getCardPage({
      subjectId: this.data.subjectId,
      pageNum: this.data.pageNum,
      pageSize: this.data.pageSize
    }).then(res => {
      const newCards = res.data && res.data.records ? res.data.records : []
      const total = res.data && res.data.total ? res.data.total : 0

      this.setData({
        cardList: [...this.data.cardList, ...newCards],
        totalCount: total,
        hasMore: this.data.cardList.length + newCards.length < total,
        loading: false
      })
    }).catch(error => {
      console.error('加载更多失败:', error)
      this.setData({ loading: false })
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

      // 保存到本地存储
      this.saveProgressLocal(status)

      // 单卡模式不自动跳转，列表模式自动下一张
      if (!this.data.isSingleMode) {
        setTimeout(() => {
          this.goToNext()
        }, 800)
      }
    }).catch(error => {
      console.error('更新进度失败:', error)
      // 即使失败也保存本地
      this.saveProgressLocal(status)
      if (!this.data.isSingleMode) {
        setTimeout(() => {
          this.goToNext()
        }, 800)
      }
    })
  },

  // 获取状态提示
  getStatusToast(status) {
    if (status === 2) return '已掌握 ✓'
    if (status === 1) return '继续加油 ~'
    return '需要复习 ✗'
  },

  // 保存进度到本地
  saveProgressLocal(status) {
    let stats = wx.getStorageSync('stats') || { learned: 0, mastered: 0, review: 0 }

    if (status >= 1) stats.learned++
    if (status === 2) stats.mastered++
    if (status === 1) stats.review++

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

    // 判断滑动方向（水平优先）
    if (!this.data.swipeDirection) {
      if (Math.abs(moveX) > Math.abs(moveY) && Math.abs(moveX) > 10) {
        this.setData({ swipeDirection: 'horizontal' })
      } else if (Math.abs(moveY) > Math.abs(moveX) && Math.abs(moveY) > 10) {
        this.setData({ swipeDirection: 'vertical' })
      }
    }

    // 只处理水平滑动
    if (this.data.swipeDirection === 'horizontal') {
      this.setData({ moveX })
    }
  },

  // 触摸结束
  onTouchEnd(e) {
    if (!this.data.isSwiping) return

    const { moveX, swipeDirection, isSingleMode } = this.data

    // 重置状态
    this.setData({
      isSwiping: false,
      moveX: 0,
      swipeDirection: ''
    })

    // 单卡模式下不支持滑动切换
    if (isSingleMode || swipeDirection !== 'horizontal') return

    const threshold = 80 // 滑动阈值

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
        title: '已经是第一张了',
        icon: 'none',
        duration: 1000
      })
      return
    }

    const newIndex = this.data.currentIndex - 1
    this.setData({
      currentIndex: newIndex,
      currentCard: this.data.cardList[newIndex],
      isFlipped: false,
      progress: Math.round(((newIndex + 1) / this.data.totalCount) * 100)
    })
  },

  // 下一张
  goToNext() {
    const { currentIndex, cardList, totalCount, hasMore, isSingleMode } = this.data

    // 单卡模式提示
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
        title: '恭喜！已学习完成',
        icon: 'success',
        duration: 2000
      })
      return
    }

    const newIndex = currentIndex + 1
    this.setData({
      currentIndex: newIndex,
      currentCard: cardList[newIndex],
      isFlipped: false,
      progress: Math.round(((newIndex + 1) / totalCount) * 100)
    })
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
  }
})