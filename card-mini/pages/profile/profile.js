// pages/profile/profile.js
const { getCaptcha, login, getSprintConfig } = require('../../utils/request')

Page({
  data: {
    isLoggedIn: false,
    userInfo: {
      nickname: '游客',
      avatar: ''
    },
    sprintConfig: {
      enabled: false,
      examName: '',
      examDate: '',
      daysRemaining: 0,
      isExpired: false
    },
    stats: {
      learned: 0,
      mastered: 0,
      review: 0
    },
    historyList: [],
    settings: {
      notification: true,
      sound: false
    },
    showLoginModal: false,
    loginLoading: false,
    username: '',
    password: '',
    captcha: '',
    captchaKey: '',
    captchaImage: '',
    needNavigateBack: false,  // 是否需要在登录成功后返回上一页
    showPassword: false,      // 是否显示密码
    canSubmit: false          // 是否可以提交登录
  },

  onLoad(options) {
    // 先检查本地存储的登录状态（同步）
    const userInfo = wx.getStorageSync('userInfo')
    const isLoggedIn = userInfo && userInfo.userId

    this.setData({
      isLoggedIn,
      userInfo: isLoggedIn ? userInfo : { nickname: '游客', avatar: '' }
    })

    this.loadLocalData()
    this.fetchStats()
    this.fetchSprintConfig()

    // 检查是否需要显示登录弹窗（从反馈页面跳转过来）
    const needShowLogin = wx.getStorageSync('need_show_login')
    if (needShowLogin && !isLoggedIn) {
      wx.removeStorageSync('need_show_login')
      this.setData({ needNavigateBack: true })
      this.showLoginModal()
    }
  },

  onShow() {
    this.checkLoginStatus()
    this.fetchSprintConfig()
    if (this.data.isLoggedIn) {
      this.fetchStats()
      this.loadHistory()
    }

    // 检查是否需要显示登录弹窗（从反馈页面跳转过来）
    const needShowLogin = wx.getStorageSync('need_show_login')
    if (needShowLogin && !this.data.isLoggedIn) {
      wx.removeStorageSync('need_show_login')
      this.setData({ needNavigateBack: true })
      this.showLoginModal()
    }
  },

  // 检查登录状态
  checkLoginStatus() {
    const userInfo = wx.getStorageSync('userInfo')
    const isLoggedIn = userInfo && userInfo.userId

    this.setData({
      isLoggedIn,
      userInfo: isLoggedIn ? userInfo : { nickname: '游客', avatar: '' }
    })
  },

  // 加载本地数据
  loadLocalData() {
    const settings = wx.getStorageSync('settings')
    if (settings) {
      this.setData({ settings })
    }
  },

  // 加载学习历史
  loadHistory() {
    const history = wx.getStorageSync('history') || []
    this.setData({ historyList: history.slice(0, 5) })
  },

  // 获取学习统计
  fetchStats() {
    const stats = wx.getStorageSync('stats') || { learned: 0, mastered: 0, review: 0 }
    this.setData({
      stats: {
        learned: stats.learned || 0,
        mastered: stats.mastered || 0,
        review: stats.review || 0
      }
    })
  },

  // 获取冲刺配置
  fetchSprintConfig() {
    getSprintConfig().then(res => {
      if (res && res.data) {
        this.setData({
          sprintConfig: {
            enabled: res.data.enabled || false,
            examName: res.data.examName || '',
            examDate: res.data.examDate || '',
            daysRemaining: res.data.daysRemaining || 0,
            isExpired: res.data.isExpired || false
          }
        })
      }
    }).catch(err => {
      console.error('获取冲刺配置失败:', err)
    })
  },

  // 点击用户卡片 - 显示登录弹窗
  handleUserCardClick() {
    if (!this.data.isLoggedIn) {
      this.showLoginModal()
    }
  },

  // 显示登录弹窗
  showLoginModal() {
    this.setData({
      showLoginModal: true,
      username: '',
      password: '',
      captcha: '',
      showPassword: false,
      canSubmit: false
    })
    this.fetchCaptcha()
  },

  // 关闭登录弹窗
  hideLoginModal() {
    this.setData({
      showLoginModal: false,
      username: '',
      password: '',
      captcha: '',
      captchaImage: '',
      showPassword: false,
      canSubmit: false,
      needNavigateBack: false
    })
  },

  // 获取验证码
  async fetchCaptcha() {
    try {
      const captchaData = await getCaptcha()
      this.setData({
        captchaImage: captchaData.image,
        captchaKey: captchaData.key
      })
    } catch (error) {
      console.error('获取验证码失败:', error)
    }
  },

  // 刷新验证码
  refreshCaptcha() {
    this.setData({ captcha: '' })
    this.fetchCaptcha()
  },

  // 输入账号
  onUsernameInput(e) {
    this.setData({ username: e.detail.value })
    this.checkCanSubmit()
  },

  // 输入密码
  onPasswordInput(e) {
    this.setData({ password: e.detail.value })
    this.checkCanSubmit()
  },

  // 输入验证码
  onCaptchaInput(e) {
    this.setData({ captcha: e.detail.value })
    this.checkCanSubmit()
  },

  // 清除账号
  clearUsername() {
    this.setData({ username: '' })
    this.checkCanSubmit()
  },

  // 切换密码显示
  togglePassword() {
    this.setData({ showPassword: !this.data.showPassword })
  },

  // 检查是否可以提交登录
  checkCanSubmit() {
    const { username, password, captcha } = this.data
    const canSubmit = username.trim() && password.trim() && captcha.trim()
    this.setData({ canSubmit })
  },

  // 输入框聚焦效果
  onInputFocus(e) {
    const field = e.currentTarget.dataset.field
    console.log('聚焦:', field)
  },

  // 输入框失焦效果
  onInputBlur(e) {
    console.log('失焦')
  },

  // 执行登录 - 使用统一的登录API
  async doLogin() {
    // 检查是否可以提交
    if (!this.data.canSubmit || this.data.loginLoading) {
      return
    }

    const { username, password, captcha, captchaKey } = this.data

    this.setData({ loginLoading: true })

    try {
      const loginResult = await login({
        username,
        password,
        captcha,
        captchaKey
      })

      // 登录成功
      const userInfo = wx.getStorageSync('userInfo')
      this.setData({
        isLoggedIn: true,
        userInfo: userInfo,
        showLoginModal: false,
        username: '',
        password: '',
        captcha: '',
        loginLoading: false,
        showPassword: false,
        canSubmit: false
      })

      wx.showToast({ title: '登录成功', icon: 'success' })
      this.fetchStats()
      this.loadHistory()

      // 如果是从反馈页面跳转过来登录的，重新跳转到反馈页面
      if (this.data.needNavigateBack) {
        this.setData({ needNavigateBack: false })
        setTimeout(() => {
          wx.navigateTo({
            url: '/pages/feedback/feedback'
          })
        }, 1000)
      }
    } catch (error) {
      console.error('登录失败:', error)
      this.setData({ loginLoading: false })
      this.refreshCaptcha()
    }
  },

  // 退出登录
  logout() {
    wx.showModal({
      title: '退出登录',
      content: '确定要退出登录吗？',
      confirmText: '退出',
      cancelText: '取消',
      success: (res) => {
        if (res.confirm) {
          wx.removeStorageSync('userInfo')
          wx.removeStorageSync('token')
          this.setData({
            isLoggedIn: false,
            userInfo: { nickname: '游客', avatar: '' },
            stats: { learned: 0, mastered: 0, review: 0 },
            historyList: []
          })
          wx.showToast({ title: '已退出', icon: 'success' })
        }
      }
    })
  },

  // 设置切换
  handleSetting(e) {
    const key = e.currentTarget.dataset.key
    const settings = this.data.settings
    settings[key] = !settings[key]
    this.setData({ settings })
    wx.setStorageSync('settings', settings)
  },

  // 清除缓存
  handleClearCache() {
    wx.showModal({
      title: '清除缓存',
      content: '确定清除所有本地数据？',
      confirmText: '清除',
      confirmColor: '#f56c6c',
      success: (res) => {
        if (res.confirm) {
          const userInfo = wx.getStorageSync('userInfo')
          const token = wx.getStorageSync('token')
          wx.clearStorage()
          if (userInfo) wx.setStorageSync('userInfo', userInfo)
          if (token) wx.setStorageSync('token', token)

          this.setData({
            stats: { learned: 0, mastered: 0, review: 0 },
            historyList: []
          })
          wx.showToast({ title: '已清除', icon: 'success' })
        }
      }
    })
  },

  // 去提交反馈
  goFeedback() {
    wx.navigateTo({
      url: '/pages/feedback/feedback'
    })
  },

  // 去反馈记录列表
  goFeedbackList() {
    wx.navigateTo({
      url: '/pages/feedback-list/feedback-list'
    })
  },

  // 去进度卡片列表页面
  goToProgressCards(e) {
    const type = e.currentTarget.dataset.type
    if (!type) return

    // 未登录时提示
    if (!this.data.isLoggedIn) {
      wx.showModal({
        title: '提示',
        content: '登录后才能查看学习进度详情',
        confirmText: '去登录',
        success: (res) => {
          if (res.confirm) {
            this.setData({ needNavigateBack: true })
            this.showLoginModal()
          }
        }
      })
      return
    }

    wx.navigateTo({
      url: `/pages/progress-cards/progress-cards?type=${type}`
    })
  },

  // 下拉刷新
  onPullDownRefresh() {
    this.checkLoginStatus()
    if (this.data.isLoggedIn) {
      this.fetchStats()
      this.loadHistory()
    }
    wx.stopPullDownRefresh()
  }
})