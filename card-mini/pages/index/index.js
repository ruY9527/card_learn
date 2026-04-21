// pages/index/index.js
const { getMajorList, getSubjectList, getCardPage } = require('../../utils/request')

Page({
  data: {
    majorList: [],
    currentMajor: null,
    subjectList: [],
    recommendCards: [],
    loading: false,
    countdownDays: 0,
    countdownText: ''
  },

  onLoad() {
    this.calculateCountdown()
    this.fetchData()
  },

  onShow() {
    this.calculateCountdown()
    this.fetchData()
  },

  // 计算考研倒计时
  calculateCountdown() {
    // 考研日期：每年12月最后一个周六
    // 2025年考研日期约为12月20日左右（具体以官方公告为准）
    const now = new Date()
    const currentYear = now.getFullYear()

    // 计算2026年考研日期（默认设置12月21日）
    let examDate = new Date(currentYear + 1, 11, 21) // 12月21日

    // 如果当前已超过今年的考研日期，则计算下一年的
    const thisYearExamDate = new Date(currentYear, 11, 21)
    if (now > thisYearExamDate) {
      examDate = new Date(currentYear + 1, 11, 21)
    } else {
      examDate = thisYearExamDate
    }

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
      countdownText: countdownText
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

    // 加载推荐卡片
    getCardPage({ pageNum: 1, pageSize: 5 }).then(cardRes => {
      console.log('推荐卡片:', cardRes)
      this.setData({
        recommendCards: cardRes.data && cardRes.data.records ? cardRes.data.records : []
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
    this.calculateCountdown()
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