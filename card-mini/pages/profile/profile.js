// pages/profile/profile.js
const BASE_URL = 'http://localhost:8080'

Page({
  data: {
    isLoggedIn: false,
    userInfo: {
      nickname: '游客',
      avatar: ''
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
    captchaImage: ''
  },

  onLoad() {
    this.checkLoginStatus()
    this.loadLocalData()
    this.fetchStats()
  },

  onShow() {
    this.checkLoginStatus()
    if (this.data.isLoggedIn) {
      this.fetchStats()
      this.loadHistory()
    }
  },

  // 检查登录状态
  checkLoginStatus() {
    const userInfo = wx.getStorageSync('userInfo')
    if (userInfo && userInfo.nickname) {
      this.setData({
        isLoggedIn: true,
        userInfo: userInfo
      })
    } else {
      this.setData({
        isLoggedIn: false,
        userInfo: { nickname: '游客', avatar: '' }
      })
    }
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
      captcha: ''
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
      captchaImage: ''
    })
  },

  // 获取验证码
  fetchCaptcha() {
    wx.request({
      url: BASE_URL + '/captcha/generate',
      method: 'GET',
      success: (res) => {
        if (res.data && res.data.code === 200) {
          this.setData({
            captchaImage: res.data.data.image,
            captchaKey: res.data.data.key
          })
        }
      },
      fail: (err) => {
        console.error('获取验证码失败:', err)
        wx.showToast({
          title: '获取验证码失败',
          icon: 'none'
        })
      }
    })
  },

  // 刷新验证码
  refreshCaptcha() {
    this.setData({ captcha: '' })
    this.fetchCaptcha()
  },

  // 输入账号
  onUsernameInput(e) {
    this.setData({ username: e.detail.value })
  },

  // 输入密码
  onPasswordInput(e) {
    this.setData({ password: e.detail.value })
  },

  // 输入验证码
  onCaptchaInput(e) {
    this.setData({ captcha: e.detail.value })
  },

  // 执行登录
  doLogin() {
    const { username, password, captcha, captchaKey } = this.data

    if (!username.trim()) {
      wx.showToast({ title: '请输入账号', icon: 'none' })
      return
    }

    if (!password.trim()) {
      wx.showToast({ title: '请输入密码', icon: 'none' })
      return
    }

    if (!captcha.trim()) {
      wx.showToast({ title: '请输入验证码', icon: 'none' })
      return
    }

    this.setData({ loginLoading: true })

    wx.request({
      url: BASE_URL + '/api/miniprogram/login',
      method: 'POST',
      data: {
        username: username.trim(),
        password: password.trim(),
        captcha: captcha.trim(),
        captchaKey: captchaKey
      },
      success: (res) => {
        if (res.data && res.data.code === 200) {
          const userInfo = res.data.data.user || {
            userId: Date.now(),
            nickname: username.trim(),
            avatar: ''
          }

          wx.setStorageSync('userInfo', userInfo)
          wx.setStorageSync('token', res.data.data.token || '')

          this.setData({
            isLoggedIn: true,
            userInfo: userInfo,
            showLoginModal: false,
            username: '',
            password: '',
            captcha: '',
            loginLoading: false
          })

          wx.showToast({ title: '登录成功', icon: 'success' })
          this.fetchStats()
          this.loadHistory()
        } else {
          wx.showToast({
            title: res.data.message || '登录失败',
            icon: 'none'
          })
          this.setData({ loginLoading: false })
          this.refreshCaptcha()
        }
      },
      fail: (err) => {
        console.error('登录失败:', err)
        wx.showToast({
          title: '登录失败，请检查网络',
          icon: 'none'
        })
        this.setData({ loginLoading: false })
        this.refreshCaptcha()
      }
    })
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