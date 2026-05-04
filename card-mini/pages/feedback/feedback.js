// pages/feedback/feedback.js
const { submitFeedback, getMajorList, getSubjectList } = require('../../utils/request')

Page({
  data: {
    isLoggedIn: false,
    userInfo: null,
    userId: null,

    // 卡片纠错模式
    cardId: null,
    cardFrontContent: '',

    // 专业和科目选择
    majorList: [],
    majorIndex: 0,
    subjectList: [],
    subjectIndex: 0,
    selectedMajorId: null,
    selectedSubjectId: null,

    // 反馈类型选项
    typeOptions: [
      { value: 'SUGGESTION', label: '建议' },
      { value: 'ERROR', label: '纠错' },
      { value: 'FUNCTION', label: '功能问题' },
      { value: 'OTHER', label: '其他' }
    ],
    typeIndex: 0,

    // 评分
    rating: 0,

    // 反馈内容
    content: '',
    contact: '',
    images: [],

    // 提交状态
    submitting: false,
    canSubmit: false
  },

  onLoad(options) {
    // 如果从卡片页面跳转过来，获取卡片信息并保存到本地
    if (options.cardId) {
      const cardId = parseInt(options.cardId)
      const cardContent = decodeURIComponent(options.content || '')
      this.setData({
        cardId,
        cardFrontContent: cardContent,
        typeIndex: 1  // 卡片纠错时默认选择纠错类型
      })
      // 保存到本地，防止登录跳转后丢失
      wx.setStorageSync('feedback_card_id', cardId)
      wx.setStorageSync('feedback_card_content', cardContent)
    } else {
      // 从本地恢复卡片信息（登录返回后）
      const savedCardId = wx.getStorageSync('feedback_card_id')
      const savedCardContent = wx.getStorageSync('feedback_card_content')
      if (savedCardId) {
        this.setData({
          cardId: savedCardId,
          cardFrontContent: savedCardContent,
          typeIndex: 1
        })
      }
    }

    // 检查登录状态
    this.checkLoginStatus()
    
    // 加载专业列表
    this.loadMajorList()
  },

  onShow() {
    // 每次显示页面时重新检查登录状态
    this.checkLoginStatus()

    // 如果登录成功后返回，重新检查是否有保存的卡片信息
    if (!this.data.cardId) {
      const savedCardId = wx.getStorageSync('feedback_card_id')
      const savedCardContent = wx.getStorageSync('feedback_card_content')
      if (savedCardId) {
        this.setData({
          cardId: savedCardId,
          cardFrontContent: savedCardContent,
          typeIndex: 1
        })
      }
    }
  },

  onUnload() {
    // 只有在提交成功后才清理卡片信息（通过 submitFeedback 中的逻辑）
    // 不在这里清理，因为 switchTab 时页面会被关闭，需要保留卡片信息用于登录后恢复
  },

  // 检查登录状态
  checkLoginStatus() {
    const userInfo = wx.getStorageSync('userInfo')
    const isLoggedIn = userInfo && userInfo.userId

    this.setData({
      isLoggedIn,
      userInfo: isLoggedIn ? userInfo : null,
      userId: isLoggedIn ? userInfo.userId : null
    })

    // 登录状态变化后重新检查是否可以提交
    this.checkCanSubmit()
  },

  // 加载专业列表
  async loadMajorList() {
    try {
      const res = await getMajorList()
      const majorList = res.data || []
      this.setData({
        majorList,
        majorIndex: 0,
        selectedMajorId: majorList.length > 0 ? majorList[0].majorId : null
      })
      
      // 加载第一个专业的科目列表
      if (majorList.length > 0) {
        this.loadSubjectList(majorList[0].majorId)
      }
    } catch (error) {
      console.error('加载专业列表失败', error)
    }
  },

  // 加载科目列表（根据专业ID）
  async loadSubjectList(majorId) {
    try {
      const res = await getSubjectList(majorId)
      const subjectList = res.data || []
      this.setData({
        subjectList,
        subjectIndex: 0,
        selectedSubjectId: subjectList.length > 0 ? subjectList[0].subjectId : null
      })
    } catch (error) {
      console.error('加载科目列表失败', error)
    }
  },

  // 专业选择变化
  onMajorChange(e) {
    const index = parseInt(e.detail.value)
    const major = this.data.majorList[index]
    this.setData({
      majorIndex: index,
      selectedMajorId: major ? major.majorId : null,
      subjectIndex: 0,
      selectedSubjectId: null
    })
    
    // 根据选中的专业重新加载科目列表
    if (major) {
      this.loadSubjectList(major.majorId)
    }
  },

  // 科目选择变化
  onSubjectChange(e) {
    const index = parseInt(e.detail.value)
    const subject = this.data.subjectList[index]
    this.setData({
      subjectIndex: index,
      selectedSubjectId: subject ? subject.subjectId : null
    })
  },

  // 去登录
  goLogin() {
    // 设置标志，告诉 profile 页面需要显示登录弹窗
    wx.setStorageSync('need_show_login', true)
    wx.setStorageSync('login_redirect_url', '/pages/feedback/feedback')
    wx.switchTab({
      url: '/pages/profile/profile'
    })
  },

  // 类型选择
  onTypeChange(e) {
    this.setData({
      typeIndex: e.detail.value
    })
    this.checkCanSubmit()
  },

  // 评分选择
  onRatingTap(e) {
    const rating = e.currentTarget.dataset.rating
    this.setData({ rating })
  },

  // 内容输入
  onContentInput(e) {
    this.setData({
      content: e.detail.value
    })
    this.checkCanSubmit()
  },

  // 联系方式输入
  onContactInput(e) {
    this.setData({
      contact: e.detail.value
    })
  },

  // 选择图片
  chooseImage() {
    const that = this
    wx.chooseMedia({
      count: 3 - that.data.images.length,
      mediaType: ['image'],
      sourceType: ['album', 'camera'],
      success(res) {
        const newImages = res.tempFiles.map(file => file.tempFilePath)
        that.setData({
          images: that.data.images.concat(newImages)
        })
      }
    })
  },

  // 预览图片
  previewImage(e) {
    const url = e.currentTarget.dataset.url
    wx.previewImage({
      urls: this.data.images,
      current: url
    })
  },

  // 移除图片
  removeImage(e) {
    const index = e.currentTarget.dataset.index
    const images = this.data.images.filter((_, i) => i !== index)
    this.setData({ images })
  },

  // 检查是否可以提交
  checkCanSubmit() {
    const canSubmit = this.data.content.trim().length > 0 && 
                      this.data.isLoggedIn &&
                      this.data.selectedMajorId &&
                      this.data.selectedSubjectId
    this.setData({ canSubmit })
  },

  // 提交反馈
  async submitFeedback() {
    if (!this.data.canSubmit || this.data.submitting) return

    this.setData({ submitting: true })

    try {
      const feedbackData = {
        userId: this.data.userId,
        cardId: this.data.cardId,
        majorId: this.data.selectedMajorId,
        subjectId: this.data.selectedSubjectId,
        type: this.data.typeOptions[this.data.typeIndex].value,
        rating: this.data.rating,
        content: this.data.content.trim(),
        contact: this.data.contact.trim(),
        images: this.data.images.length > 0 ? JSON.stringify(this.data.images) : null
      }

      await submitFeedback(feedbackData)

      wx.showToast({
        title: '提交成功',
        icon: 'success'
      })

      // 保存是否需要返回的标志
      const needNavigateBack = this.data.cardId

      // 清空表单和本地存储的卡片信息
      wx.removeStorageSync('feedback_card_id')
      wx.removeStorageSync('feedback_card_content')

      this.setData({
        typeIndex: 0,
        rating: 0,
        content: '',
        contact: '',
        images: [],
        canSubmit: false,
        cardId: null,
        cardFrontContent: ''
      })

      // 如果是从卡片页面跳转过来的，返回上一页
      if (needNavigateBack) {
        setTimeout(() => {
          wx.navigateBack()
        }, 1500)
      }
    } catch (error) {
      wx.showToast({
        title: '提交失败，请重试',
        icon: 'none'
      })
    } finally {
      this.setData({ submitting: false })
    }
  },

  // 查看反馈列表
  goFeedbackList() {
    wx.navigateTo({
      url: '/pages/feedback-list/feedback-list'
    })
  }
})
