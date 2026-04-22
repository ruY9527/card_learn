// pages/index/index.js
const { getMajorList, getSubjectList, getSprintConfig, getRecommendCards } = require('../../utils/request')

Page({
  data: {
    majorList: [],
    currentMajor: null,
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
    }
  },

  onLoad() {
    this.fetchSprintConfig()
    this.fetchData()
  },

  onShow() {
    this.fetchSprintConfig()
    this.fetchData()
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
          // 冲刺模式未启用或已过期，使用默认值
          this.calculateDefaultCountdown()
        }
      } else {
        this.calculateDefaultCountdown()
      }
    }).catch(err => {
      console.error('获取冲刺配置失败:', err)
      // API失败时使用默认计算
      this.calculateDefaultCountdown()
    })
  },

  // 默认倒计时计算（API失败时的备用方案）
  calculateDefaultCountdown() {
    const now = new Date()
    const currentYear = now.getFullYear()
    
    // 默认使用12月21日
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

  // 获取初始数据
  fetchData() {
    this.setData({ loading: true })

    // 获取专业列表
    getMajorList().then(majorRes => {
      console.log('专业列表:', majorRes)
      this.setData({ majorList: majorRes.data || [] })

      // 默认加载第一个专业的科目
      if (majorRes.data && majorRes.data.length > 0) {
        const majorId = majorRes.data[0].majorId
        this.setData({ currentMajor: majorId })
        this.fetchSubjects(majorId)
      } else {
        this.setData({ loading: false })
      }
    }).catch(error => {
      console.error('获取专业失败:', error)
      this.setData({ loading: false, majorList: [] })
    })

    // 加载推荐卡片（每个科目2条，共8条）
    getRecommendCards().then(cardRes => {
      console.log('今日推荐卡片:', cardRes)
      this.setData({
        recommendCards: cardRes.data || []
      })
    }).catch(error => {
      console.error('获取推荐卡片失败:', error)
      this.setData({ recommendCards: [] })
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

  // 点击专业
  handleMajorClick(e) {
    const majorId = e.currentTarget.dataset.majorId
    console.log('点击专业, majorId:', majorId)

    this.setData({
      currentMajor: majorId,
      subjectList: []
    })

    this.fetchSubjects(majorId)
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

  // 下拉刷新
  onPullDownRefresh() {
    this.fetchSprintConfig()
    this.setData({
      majorList: [],
      subjectList: [],
      recommendCards: [],
      currentMajor: null
    })

    this.fetchData()

    wx.stopPullDownRefresh()
  }
})