const { getMyNotes, deleteNote, exportNotes, getSubjectList } = require('../../utils/request')

Page({
  data: {
    notes: [],
    pageNum: 1,
    pageSize: 10,
    hasMore: true,
    loading: false,
    userId: null,

    // 筛选
    subjects: [],
    subjectIndex: 0,
    keyword: '',
    startDate: '',
    endDate: ''
  },

  onLoad() {
    const userInfo = wx.getStorageSync('userInfo')
    if (!userInfo || !userInfo.userId) {
      wx.showModal({
        title: '提示',
        content: '请先登录后查看笔记',
        showCancel: false,
        success() {
          wx.switchTab({ url: '/pages/profile/profile' })
        }
      })
      return
    }

    this.setData({ userId: userInfo.userId })
    this.loadSubjects()
    this.loadNotes(true)
  },

  onShow() {
    // 从其他页面返回时刷新
    if (this.data.userId) {
      this.loadNotes(true)
    }
  },

  // 加载科目列表
  loadSubjects() {
    getSubjectList().then(res => {
      const subjects = [{ subjectId: 0, subjectName: '全部科目' }].concat(res.data || [])
      this.setData({ subjects })
    }).catch(err => {
      console.error('获取科目列表失败:', err)
    })
  },

  // 加载笔记列表
  loadNotes(refresh) {
    if (this.data.loading) return

    const pageNum = refresh ? 1 : this.data.pageNum
    this.setData({ loading: true })

    const params = {
      userId: this.data.userId,
      pageNum,
      pageSize: this.data.pageSize
    }

    const subjectId = this.data.subjects[this.data.subjectIndex]?.subjectId
    if (subjectId && subjectId > 0) {
      params.subjectId = subjectId
    }
    if (this.data.keyword) {
      params.keyword = this.data.keyword
    }
    if (this.data.startDate) {
      params.startDate = this.data.startDate
    }
    if (this.data.endDate) {
      params.endDate = this.data.endDate
    }

    getMyNotes(params).then(res => {
      const pageData = res.data || {}
      const newNotes = pageData.records || []

      this.setData({
        notes: refresh ? newNotes : this.data.notes.concat(newNotes),
        pageNum: pageNum + 1,
        hasMore: newNotes.length >= this.data.pageSize,
        loading: false
      })
    }).catch(err => {
      console.error('获取笔记失败:', err)
      this.setData({ loading: false })
      wx.showToast({ title: '加载失败', icon: 'none' })
    })
  },

  // 上拉加载更多
  onReachBottom() {
    if (this.data.hasMore) {
      this.loadNotes(false)
    }
  },

  // 下拉刷新
  onPullDownRefresh() {
    this.loadNotes(true)
    wx.stopPullDownRefresh()
  },

  // 选择科目
  bindSubjectChange(e) {
    this.setData({ subjectIndex: e.detail.value })
    this.loadNotes(true)
  },

  // 搜索关键词
  onSearchInput(e) {
    this.setData({ keyword: e.detail.value })
  },

  onSearch() {
    this.loadNotes(true)
  },

  // 日期筛选
  onStartDateChange(e) {
    this.setData({ startDate: e.detail.value })
    this.loadNotes(true)
  },

  onEndDateChange(e) {
    this.setData({ endDate: e.detail.value })
    this.loadNotes(true)
  },

  // 清除筛选
  clearFilter() {
    this.setData({
      subjectIndex: 0,
      keyword: '',
      startDate: '',
      endDate: ''
    })
    this.loadNotes(true)
  },

  // 删除笔记
  handleDelete(e) {
    const noteId = e.currentTarget.dataset.id
    const index = e.currentTarget.dataset.index

    wx.showModal({
      title: '确认删除',
      content: '确定要删除这条笔记吗？',
      success: (res) => {
        if (res.confirm) {
          deleteNote(noteId, this.data.userId).then(() => {
            wx.showToast({ title: '已删除', icon: 'success' })
            const notes = this.data.notes
            notes.splice(index, 1)
            this.setData({ notes })
          }).catch(err => {
            wx.showToast({ title: '删除失败', icon: 'none' })
          })
        }
      }
    })
  },

  // 导出笔记
  handleExport() {
    const params = {
      userId: this.data.userId
    }

    const subjectId = this.data.subjects[this.data.subjectIndex]?.subjectId
    if (subjectId && subjectId > 0) {
      params.subjectId = subjectId
    }
    if (this.data.startDate) {
      params.startDate = this.data.startDate
    }
    if (this.data.endDate) {
      params.endDate = this.data.endDate
    }

    wx.showLoading({ title: '导出中...' })
    exportNotes(params).then(res => {
      wx.hideLoading()
      const content = res.data || ''
      if (!content) {
        wx.showToast({ title: '没有可导出的笔记', icon: 'none' })
        return
      }

      // 复制到剪贴板
      wx.setClipboardData({
        data: content,
        success() {
          wx.showToast({ title: '已复制到剪贴板', icon: 'success' })
        }
      })
    }).catch(err => {
      wx.hideLoading()
      wx.showToast({ title: '导出失败', icon: 'none' })
    })
  },

  // 跳转到卡片详情
  goCardDetail(e) {
    const cardId = e.currentTarget.dataset.cardId
    wx.navigateTo({
      url: `/pages/card/card?cardId=${cardId}`
    })
  }
})
