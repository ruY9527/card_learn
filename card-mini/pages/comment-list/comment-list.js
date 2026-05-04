const { getCardComments, getReplyList, submitReply, toggleCommentLike, toggleReplyLike, getChildrenReplies } = require('../../utils/request')

Page({
  data: {
    cardId: null,
    comments: [],
    pageNum: 1,
    pageSize: 10,
    hasMore: true,
    loading: false,
    userId: null,

    // 回复相关
    showReplyDialog: false,
    replyCommentId: null,
    replyContent: '',
    replyTarget: '',

    // 展开的回复
    expandedReplies: {},
    replyLoading: {}
  },

  onLoad(options) {
    const cardId = parseInt(options.cardId) || 0
    const userInfo = wx.getStorageSync('userInfo')
    const userId = userInfo ? userInfo.userId : null

    this.setData({ cardId, userId })
    this.loadComments(true)
  },

  // 加载评论列表
  loadComments(refresh) {
    if (this.data.loading) return

    const pageNum = refresh ? 1 : this.data.pageNum
    this.setData({ loading: true })

    getCardComments(this.data.cardId, pageNum, this.data.pageSize).then(res => {
      const pageData = res.data || {}
      const newComments = (pageData.records || []).map(c => ({
        ...c,
        likeStatus: c.likeStatus || false
      }))

      this.setData({
        comments: refresh ? newComments : this.data.comments.concat(newComments),
        pageNum: pageNum + 1,
        hasMore: newComments.length >= this.data.pageSize,
        loading: false
      })
    }).catch(err => {
      console.error('获取评论失败:', err)
      this.setData({ loading: false })
      wx.showToast({ title: '加载失败', icon: 'none' })
    })
  },

  // 上拉加载更多
  onReachBottom() {
    if (this.data.hasMore) {
      this.loadComments(false)
    }
  },

  // 下拉刷新
  onPullDownRefresh() {
    this.loadComments(true)
    wx.stopPullDownRefresh()
  },

  // 点赞/取消点赞评论
  toggleLike(e) {
    if (!this.data.userId) {
      wx.showToast({ title: '请先登录', icon: 'none' })
      return
    }

    const commentId = e.currentTarget.dataset.id
    const index = e.currentTarget.dataset.index

    toggleCommentLike(commentId, this.data.userId).then(res => {
      const liked = res.data
      const key = `comments[${index}].likeStatus`
      const countKey = `comments[${index}].likeCount`
      const current = this.data.comments[index]
      this.setData({
        [key]: liked,
        [countKey]: liked ? (current.likeCount || 0) + 1 : Math.max(0, (current.likeCount || 0) - 1)
      })
    }).catch(err => {
      wx.showToast({ title: '操作失败', icon: 'none' })
    })
  },

  // 展开/收起回复
  toggleReplies(e) {
    const commentId = e.currentTarget.dataset.id
    const index = e.currentTarget.dataset.index
    const expanded = this.data.expandedReplies[commentId]

    if (expanded) {
      this.setData({ [`expandedReplies.${commentId}`]: false })
    } else {
      this.setData({
        [`expandedReplies.${commentId}`]: true,
        [`replyLoading.${commentId}`]: true
      })
      this.loadReplies(commentId, index)
    }
  },

  // 加载回复列表
  loadReplies(commentId, commentIndex) {
    getReplyList(commentId, this.data.userId, 1, 50).then(res => {
      const pageData = res.data || {}
      const replies = pageData.records || []
      this.setData({
        [`comments[${commentIndex}].replies`]: replies,
        [`comments[${commentIndex}].hasMoreReplies`]: replies.length >= 50,
        [`replyLoading.${commentId}`]: false
      })
    }).catch(err => {
      console.error('获取回复失败:', err)
      this.setData({ [`replyLoading.${commentId}`]: false })
    })
  },

  // 加载子回复
  loadChildren(e) {
    const parentReplyId = e.currentTarget.dataset.parentId
    const commentIndex = e.currentTarget.dataset.commentIndex
    const replyIndex = e.currentTarget.dataset.replyIndex

    getChildrenReplies(parentReplyId, this.data.userId).then(res => {
      const children = res.data || []
      this.setData({
        [`comments[${commentIndex}].replies[${replyIndex}].children`]: children,
        [`comments[${commentIndex}].replies[${replyIndex}].hasMoreChildren`]: false
      })
    }).catch(err => {
      wx.showToast({ title: '加载失败', icon: 'none' })
    })
  },

  // 点赞/取消点赞回复
  toggleReplyLike(e) {
    if (!this.data.userId) {
      wx.showToast({ title: '请先登录', icon: 'none' })
      return
    }

    const replyId = e.currentTarget.dataset.replyId
    const commentIndex = e.currentTarget.dataset.commentIndex
    const replyIndex = e.currentTarget.dataset.replyIndex

    toggleReplyLike(replyId, this.data.userId).then(res => {
      const liked = res.data
      const reply = this.data.comments[commentIndex].replies[replyIndex]
      this.setData({
        [`comments[${commentIndex}].replies[${replyIndex}].likeStatus`]: liked,
        [`comments[${commentIndex}].replies[${replyIndex}].likeCount`]: liked ? (reply.likeCount || 0) + 1 : Math.max(0, (reply.likeCount || 0) - 1)
      })
    }).catch(err => {
      wx.showToast({ title: '操作失败', icon: 'none' })
    })
  },

  // 显示回复弹窗
  showReplyModal(e) {
    if (!this.data.userId) {
      wx.showToast({ title: '请先登录', icon: 'none' })
      return
    }

    const commentId = e.currentTarget.dataset.commentId
    const nickname = e.currentTarget.dataset.nickname || ''

    this.setData({
      showReplyDialog: true,
      replyCommentId: commentId,
      replyContent: '',
      replyTarget: nickname ? `回复 ${nickname}` : '写回复...'
    })
  },

  // 隐藏回复弹窗
  hideReplyModal() {
    this.setData({ showReplyDialog: false })
  },

  // 输入回复内容
  onReplyInput(e) {
    this.setData({ replyContent: e.detail.value })
  },

  // 提交回复
  submitReply() {
    if (!this.data.replyContent.trim()) {
      wx.showToast({ title: '请输入回复内容', icon: 'none' })
      return
    }

    const userInfo = wx.getStorageSync('userInfo')
    submitReply(this.data.replyCommentId, {
      userId: userInfo.userId,
      userNickname: userInfo.nickname || '匿名用户',
      content: this.data.replyContent
    }).then(res => {
      wx.showToast({ title: '回复成功', icon: 'success' })
      this.hideReplyModal()
      // 刷新评论列表
      this.loadComments(true)
    }).catch(err => {
      wx.showToast({ title: err.message || '回复失败', icon: 'none' })
    })
  },

  // 阻止弹窗穿透
  preventTouchMove() {}
})
