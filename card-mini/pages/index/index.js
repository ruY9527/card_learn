// pages/index/index.js
const { getMajorList, getSubjectList, getSprintConfig, getRecommendCards } = require('../../utils/request')

Page({
  data: {
    majorList: [],
    filteredMajorList: [], // 搜索过滤后的专业列表
    currentMajor: null,
    selectedMajorName: '', // 当前选中的专业名称
    majorSearchKeyword: '', // 搜索关键词
    showMajorPicker: false, // 是否显示下拉面板
    subjectList: [],
    recommendCards: [],
    loading: false,
    countdownDays: 0,
    countdownText: '',
    sprintConfig: {
      enabled: false,
      examName: '',
      examDate: '',
      daysRemaining: 0,
      isExpired: false
    },
    initialized: false // 是否已初始化
  },

  onLoad() {
    this.fetchSprintConfig()
    this.initializePage()
  },

  onShow() {
    // 只更新冲刺配置，不重新加载专业数据
    this.fetchSprintConfig()
    
    // 如果已初始化，恢复用户之前选择的专业
    if (this.data.initialized) {
      this.restoreSelectedMajor()
    }
  },

  // 初始化页面（只在onLoad时调用一次）
  initializePage() {
    this.setData({ loading: true })

    // 获取专业列表
    getMajorList().then(majorRes => {
      console.log('专业列表:', majorRes)
      const majorList = majorRes.data || []
      
      this.setData({
        majorList: majorList,
        filteredMajorList: majorList,
        initialized: true
      })

      // 尝试恢复用户之前选择的专业
      const savedMajorId = wx.getStorageSync('selected_major_id')
      const savedMajorName = wx.getStorageSync('selected_major_name')
      
      if (savedMajorId && savedMajorName) {
        // 检查保存的专业是否在列表中
        const majorExists = majorList.find(m => m.majorId === savedMajorId)
        if (majorExists) {
          console.log('恢复用户选择的专业:', savedMajorId, savedMajorName)
          this.setData({
            currentMajor: savedMajorId,
            selectedMajorName: savedMajorName
          })
          this.fetchSubjects(savedMajorId)
          this.fetchRecommendCards(savedMajorId)
        } else {
          // 如果保存的专业不存在，加载第一个专业
          this.loadFirstMajor(majorList)
        }
      } else {
        // 没有保存的专业，加载第一个专业
        this.loadFirstMajor(majorList)
      }
    }).catch(error => {
      console.error('获取专业失败:', error)
      this.setData({ 
        loading: false, 
        majorList: [], 
        filteredMajorList: [],
        initialized: true
      })
    })
  },

  // 加载第一个专业
  loadFirstMajor(majorList) {
    if (majorList.length > 0) {
      const firstMajor = majorList[0]
      this.setData({
        currentMajor: firstMajor.majorId,
        selectedMajorName: firstMajor.majorName
      })
      this.saveSelectedMajor(firstMajor.majorId, firstMajor.majorName)
      this.fetchSubjects(firstMajor.majorId)
      this.fetchRecommendCards(firstMajor.majorId)
    } else {
      this.setData({ loading: false })
    }
  },

  // 恢复用户选择的专业
  restoreSelectedMajor() {
    const savedMajorId = wx.getStorageSync('selected_major_id')
    const savedMajorName = wx.getStorageSync('selected_major_name')
    
    if (savedMajorId && savedMajorName) {
      // 检查是否需要更新（与当前不同）
      if (this.data.currentMajor !== savedMajorId) {
        console.log('onShow恢复专业:', savedMajorId, savedMajorName)
        this.setData({
          currentMajor: savedMajorId,
          selectedMajorName: savedMajorName
        })
        this.fetchSubjects(savedMajorId)
        this.fetchRecommendCards(savedMajorId)
      }
    }
  },

  // 保存用户选择的专业到本地存储
  saveSelectedMajor(majorId, majorName) {
    wx.setStorageSync('selected_major_id', majorId)
    wx.setStorageSync('selected_major_name', majorName)
    console.log('保存选择的专业:', majorId, majorName)
  },

  // 获取冲刺配置（从后端获取）
  fetchSprintConfig() {
    getSprintConfig().then(res => {
      console.log('冲刺配置:', res)
      if (res && res.data) {
        const config = res.data
        let countdownText = ''

        if (config.enabled && !config.isExpired) {
          const days = config.daysRemaining
          if (days > 365) {
            countdownText = '备战考研'
          } else if (days > 100) {
            countdownText = '冲刺阶段'
          } else if (days > 30) {
            countdownText = '考前冲刺'
          } else if (days > 7) {
            countdownText = '最后冲刺'
          } else if (days > 0) {
            countdownText = '考前一周'
          } else {
            countdownText = '考试进行中'
          }

          this.setData({
            countdownDays: days,
            countdownText: countdownText,
            sprintConfig: {
              enabled: config.enabled,
              examName: config.examName || '',
              examDate: config.examDate || '',
              daysRemaining: config.daysRemaining || 0,
              isExpired: config.isExpired || false
            }
          })
        } else {
          this.calculateDefaultCountdown()
        }
      } else {
        this.calculateDefaultCountdown()
      }
    }).catch(err => {
      console.error('获取冲刺配置失败:', err)
      this.calculateDefaultCountdown()
    })
  },

  // 默认倒计时计算
  calculateDefaultCountdown() {
    const now = new Date()
    const currentYear = now.getFullYear()
    let examDate = new Date(currentYear, 11, 21)

    const diffTime = examDate - now
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))

    let countdownText = ''
    if (diffDays > 365) {
      countdownText = '备战考研'
    } else if (diffDays > 100) {
      countdownText = '冲刺阶段'
    } else if (diffDays > 30) {
      countdownText = '考前冲刺'
    } else if (diffDays > 0) {
      countdownText = '最后冲刺'
    } else {
      countdownText = '考试进行中'
    }

    this.setData({
      countdownDays: diffDays > 0 ? diffDays : 0,
      countdownText: countdownText,
      sprintConfig: {
        enabled: false,
        examName: '',
        examDate: '',
        daysRemaining: 0,
        isExpired: true
      }
    })
  },

  // 获取科目列表
  fetchSubjects(majorId) {
    console.log('获取科目, majorId:', majorId)

    getSubjectList(majorId).then(res => {
      console.log('科目列表:', res)
      this.setData({
        subjectList: res.data || [],
        loading: false
      })
    }).catch(error => {
      console.error('获取科目失败:', error)
      this.setData({
        subjectList: [],
        loading: false
      })
    })
  },

  // 切换下拉面板显示状态
  toggleMajorPicker() {
    this.setData({
      showMajorPicker: !this.data.showMajorPicker
    })
  },

  // 搜索输入事件
  onMajorSearchInput(e) {
    const keyword = e.detail.value.trim().toLowerCase()
    this.setData({
      majorSearchKeyword: keyword
    })

    if (keyword) {
      const filteredList = this.data.majorList.filter(major =>
        major.majorName.toLowerCase().includes(keyword) ||
        (major.description && major.description.toLowerCase().includes(keyword))
      )
      this.setData({
        filteredMajorList: filteredList
      })
    } else {
      this.setData({
        filteredMajorList: this.data.majorList
      })
    }
  },

  // 清除搜索关键词
  clearMajorSearch() {
    this.setData({
      majorSearchKeyword: '',
      filteredMajorList: this.data.majorList
    })
  },

  // 选择专业
  selectMajor(e) {
    const majorId = e.currentTarget.dataset.majorId
    const majorName = e.currentTarget.dataset.majorName

    console.log('选择专业, majorId:', majorId, 'majorName:', majorName)

    // 保存用户选择的专业
    this.saveSelectedMajor(majorId, majorName)

    // 更新选中状态并关闭下拉面板
    this.setData({
      currentMajor: majorId,
      selectedMajorName: majorName,
      showMajorPicker: false,
      majorSearchKeyword: '',
      filteredMajorList: this.data.majorList,
      subjectList: [],
      recommendCards: []
    })

    // 加载对应专业的科目和推荐卡片
    this.fetchSubjects(majorId)
    this.fetchRecommendCards(majorId)
  },

  // 获取推荐卡片
  fetchRecommendCards(majorId) {
    getRecommendCards(majorId).then(cardRes => {
      console.log('今日推荐卡片:', cardRes)
      this.setData({
        recommendCards: cardRes.data || []
      })
    }).catch(error => {
      console.error('获取推荐卡片失败:', error)
      this.setData({ recommendCards: [] })
    })
  },

  // 点击科目，跳转到学习页
  handleSubjectClick(e) {
    const subjectId = e.currentTarget.dataset.subjectId
    const subjectName = e.currentTarget.dataset.subjectName

    console.log('点击科目:', subjectId, subjectName)

    wx.navigateTo({
      url: `/pages/study/study?subjectId=${subjectId}&subjectName=${encodeURIComponent(subjectName)}`
    })
  },

  // 点击推荐卡片，跳转到详情页
  handleCardClick(e) {
    const cardId = e.currentTarget.dataset.cardId

    console.log('点击卡片:', cardId)

    wx.navigateTo({
      url: `/pages/card/card?cardId=${cardId}`
    })
  },

  // 页面隐藏时关闭下拉面板
  onHide() {
    this.setData({
      showMajorPicker: false
    })
  },

  // 下拉刷新
  onPullDownRefresh() {
    this.fetchSprintConfig()
    
    // 刷新时重新获取数据
    getMajorList().then(majorRes => {
      const majorList = majorRes.data || []
      this.setData({
        majorList: majorList,
        filteredMajorList: majorList
      })

      // 恢复之前选择的专业
      const savedMajorId = wx.getStorageSync('selected_major_id')
      if (savedMajorId) {
        this.setData({
          currentMajor: savedMajorId,
          selectedMajorName: wx.getStorageSync('selected_major_name') || ''
        })
        this.fetchSubjects(savedMajorId)
        this.fetchRecommendCards(savedMajorId)
      } else if (majorList.length > 0) {
        this.loadFirstMajor(majorList)
      }
    }).catch(error => {
      console.error('刷新失败:', error)
      this.setData({ loading: false })
    })

    wx.stopPullDownRefresh()
  }
})