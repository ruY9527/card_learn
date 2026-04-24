// pages/add-card/add-card.js
const { getMajorList, getSubjectList, createCardByUser } = require('../../utils/request')

Page({
  data: {
    // 专业列表
    majorList: [],
    majorIndex: -1,
    selectedMajor: null,
    
    // 科目列表（根据专业联动）
    subjectList: [],
    subjectIndex: -1,
    selectedSubject: null,
    
    // 卡片内容
    frontContent: '',
    backContent: '',
    
    // 难度
    difficultyLevel: 2, // 默认中等难度
    difficultyOptions: [
      { value: 1, label: '简单' },
      { value: 2, label: '中等' },
      { value: 3, label: '较难' },
      { value: 4, label: '困难' },
      { value: 5, label: '极难' }
    ],
    
    // 状态
    canSubmit: false,
    submitting: false
  },

  onLoad() {
    this.loadMajors()
  },

  // 加载专业列表
  loadMajors() {
    getMajorList().then(res => {
      this.setData({
        majorList: res.data || []
      })
    }).catch(err => {
      console.error('加载专业失败:', err)
      wx.showToast({
        title: '加载专业失败',
        icon: 'none'
      })
    })
  },

  // 专业选择变化 - 联动更新科目列表
  onMajorChange(e) {
    const index = e.detail.value
    const selectedMajor = this.data.majorList[index]
    
    // 重置科目选择
    this.setData({
      majorIndex: index,
      selectedMajor: selectedMajor,
      subjectIndex: -1,
      selectedSubject: null,
      subjectList: [],
      canSubmit: false
    })
    
    // 根据专业ID加载科目列表（联动）
    if (selectedMajor && selectedMajor.majorId) {
      this.loadSubjectsByMajor(selectedMajor.majorId)
    }
  },

  // 根据专业ID加载科目列表（联动函数）
  loadSubjectsByMajor(majorId) {
    getSubjectList(majorId).then(res => {
      this.setData({
        subjectList: res.data || []
      })
      
      // 如果该专业下没有科目，提示用户
      if (!res.data || res.data.length === 0) {
        wx.showToast({
          title: '该专业暂无科目',
          icon: 'none'
        })
      }
    }).catch(err => {
      console.error('加载科目失败:', err)
      wx.showToast({
        title: '加载科目失败',
        icon: 'none'
      })
    })
  },

  // 科目选择变化
  onSubjectChange(e) {
    const index = e.detail.value
    const selectedSubject = this.data.subjectList[index]
    this.setData({
      subjectIndex: index,
      selectedSubject: selectedSubject
    })
    this.checkCanSubmit()
  },

  // 输入正面内容
  onFrontInput(e) {
    const value = e.detail.value
    this.setData({
      frontContent: value
    })
    this.checkCanSubmit()
  },

  // 输入反面内容
  onBackInput(e) {
    const value = e.detail.value
    this.setData({
      backContent: value
    })
    this.checkCanSubmit()
  },

  // 难度选择
  onDifficultyChange(e) {
    const value = e.currentTarget.dataset.value
    this.setData({
      difficultyLevel: value
    })
  },

  // 检查是否可以提交
  checkCanSubmit() {
    const { selectedMajor, selectedSubject, frontContent, backContent } = this.data
    const canSubmit = selectedMajor &&
                      selectedSubject &&
                      frontContent.trim().length > 0 &&
                      backContent.trim().length > 0
    this.setData({ canSubmit })
  },

  // 提交卡片
  submitCard() {
    if (!this.data.canSubmit || this.data.submitting) {
      return
    }

    // 获取当前登录用户信息
    const userInfo = wx.getStorageSync('userInfo')
    const token = wx.getStorageSync('token')
    if (!userInfo || !userInfo.userId || !token) {
      wx.showModal({
        title: '提示',
        content: '请先登录后再提交卡片',
        confirmText: '去登录',
        success: (res) => {
          if (res.confirm) {
            wx.navigateTo({
              url: '/pages/profile/profile'
            })
          }
        }
      })
      return
    }

    this.setData({ submitting: true })

    const cardData = {
      subjectId: this.data.selectedSubject.subjectId,
      frontContent: this.data.frontContent.trim(),
      backContent: this.data.backContent.trim(),
      difficultyLevel: this.data.difficultyLevel,
      createUserId: userInfo.userId
    }

    createCardByUser(cardData).then(res => {
      this.setData({ submitting: false })

      if (res.code === 200) {
        wx.showModal({
          title: '提交成功',
          content: '卡片已提交，等待管理员审核',
          cancelText: '继续添加',
          confirmText: '查看记录',
          success: (modalRes) => {
            if (modalRes.confirm) {
              wx.redirectTo({
                url: '/pages/my-cards/my-cards'
              })
              return
            }

            this.setData({
              majorIndex: -1,
              selectedMajor: null,
              subjectList: [],
              subjectIndex: -1,
              selectedSubject: null,
              frontContent: '',
              backContent: '',
              difficultyLevel: 2,
              canSubmit: false
            })
          }
        })
      } else {
        wx.showToast({
          title: res.message || '提交失败',
          icon: 'none'
        })
      }
    }).catch(err => {
      this.setData({ submitting: false })
      if (err && (err.code === 401 || err.code === 403)) {
        wx.showModal({
          title: '登录失效',
          content: '当前登录状态已失效，请重新登录后再提交卡片',
          confirmText: '去登录',
          success: (res) => {
            if (res.confirm) {
              wx.switchTab({
                url: '/pages/profile/profile'
              })
            }
          }
        })
        return
      }
      wx.showToast({
        title: '网络错误，请重试',
        icon: 'none'
      })
    })
  }
})
