const { getMyCards, getMyCardStats, deleteMyCard } = require('../../utils/request')

Page({
  data: {
    isLoggedIn: false,
    loading: false,
    statsLoading: false,
    cardList: [],
    pageNum: 1,
    pageSize: 10,
    total: 0,
    hasMore: true,
    activeStatus: '',
    statusTabs: [
      { label: '全部', value: '' },
      { label: '待审批', value: '0' },
      { label: '已通过', value: '1' },
      { label: '已拒绝', value: '2' }
    ],
    stats: {
      total: 0,
      pending: 0,
      passed: 0,
      rejected: 0
    }
  },

  onLoad() {
    this.checkLoginStatus()
  },

  onShow() {
    this.checkLoginStatus()
    if (this.data.isLoggedIn) {
      this.refreshAll()
    }
  },

  onPullDownRefresh() {
    if (!this.data.isLoggedIn) {
      wx.stopPullDownRefresh()
      return
    }
    this.refreshAll()
  },

  onReachBottom() {
    this.loadMore()
  },

  checkLoginStatus() {
    const userInfo = wx.getStorageSync('userInfo')
    const token = wx.getStorageSync('token')
    const isLoggedIn = !!(userInfo && userInfo.userId && token)

    if (!isLoggedIn) {
      wx.removeStorageSync('userInfo')
      wx.removeStorageSync('token')
    }

    this.setData({ isLoggedIn })
  },

  goLogin() {
    wx.setStorageSync('need_show_login', true)
    wx.setStorageSync('login_redirect_url', '/pages/my-cards/my-cards')
    wx.switchTab({
      url: '/pages/profile/profile'
    })
  },

  async refreshAll() {
    this.setData({
      pageNum: 1,
      hasMore: true,
      cardList: []
    })

    await Promise.all([
      this.loadStats(),
      this.loadCardList(true)
    ])

    wx.stopPullDownRefresh()
  },

  async loadStats() {
    this.setData({ statsLoading: true })
    try {
      const res = await getMyCardStats()
      this.setData({
        stats: {
          total: res.data.total || 0,
          pending: res.data.pending || 0,
          passed: res.data.passed || 0,
          rejected: res.data.rejected || 0
        }
      })
    } catch (error) {
      console.error('加载卡片统计失败:', error)
      if (error && (error.code === 401 || error.code === 403)) {
        this.setData({ isLoggedIn: false })
      }
    } finally {
      this.setData({ statsLoading: false })
    }
  },

  async loadCardList(reset = false) {
    if (this.data.loading) return

    this.setData({ loading: true })

    try {
      const res = await getMyCards({
        auditStatus: this.data.activeStatus,
        pageNum: this.data.pageNum,
        pageSize: this.data.pageSize
      })

      const records = (res.data && res.data.records) || []
      const total = (res.data && res.data.total) || 0

      this.setData({
        cardList: reset ? records : this.data.cardList.concat(records),
        total,
        hasMore: this.data.pageNum * this.data.pageSize < total
      })
    } catch (error) {
      console.error('加载我的添加记录失败:', error)
      if (error && (error.code === 401 || error.code === 403)) {
        this.setData({ isLoggedIn: false })
        return
      }
      if (error && error.code !== 401 && error.code !== 403) {
        wx.showToast({
          title: '加载失败，请重试',
          icon: 'none'
        })
      }
    } finally {
      this.setData({ loading: false })
    }
  },

  onStatusChange(e) {
    const status = e.currentTarget.dataset.status
    if (status === this.data.activeStatus) return

    this.setData({
      activeStatus: status,
      pageNum: 1,
      hasMore: true,
      cardList: []
    })
    this.loadCardList(true)
  },

  loadMore() {
    if (this.data.loading || !this.data.hasMore || !this.data.isLoggedIn) return

    this.setData({
      pageNum: this.data.pageNum + 1
    })
    this.loadCardList()
  },

  viewCardDetail(e) {
    const card = e.currentTarget.dataset.card
    if (!card) return

    const sections = [
      `科目：${card.subjectName || '未分类'}`,
      `状态：${card.auditStatusText || '待审批'}`,
      `难度：${card.difficultyLevel || 2}级`,
      `提交时间：${card.createTime || '-'}`,
      '',
      '正面内容：',
      card.frontContent || '',
      '',
      '反面内容：',
      card.backContent || ''
    ]

    if (card.auditRemark) {
      sections.push('', '审核备注：', card.auditRemark)
    }

    wx.showModal({
      title: '卡片详情',
      content: sections.join('\n'),
      showCancel: false
    })
  },

  deleteCard(e) {
    const { id, status } = e.currentTarget.dataset
    if (!id) return

    if (status !== '0') {
      wx.showToast({
        title: '只有待审批记录可删除',
        icon: 'none'
      })
      return
    }

    wx.showModal({
      title: '删除记录',
      content: '确定删除这条添加记录吗？删除后不可恢复。',
      confirmColor: '#f56c6c',
      success: async (res) => {
        if (!res.confirm) return

        try {
          await deleteMyCard(id)
          wx.showToast({
            title: '删除成功',
            icon: 'success'
          })
          this.refreshAll()
        } catch (error) {
          console.error('删除添加记录失败:', error)
          if (error && (error.code === 401 || error.code === 403)) {
            this.setData({ isLoggedIn: false })
            return
          }
          if (error && error.code !== 401 && error.code !== 403) {
            wx.showToast({
              title: error.message || '删除失败',
              icon: 'none'
            })
          }
        }
      }
    })
  },

  goAddCard() {
    wx.navigateTo({
      url: '/pages/add-card/add-card'
    })
  }
})
