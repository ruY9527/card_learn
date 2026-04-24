// app.js
const envConfig = require('./config/env.js')

App({
  globalData: {
    userInfo: null,
    token: '',
    baseUrl: envConfig.BASE_URL,
    env: envConfig.ENV
  },

  onLaunch() {
    // 检查本地存储的token
    const token = wx.getStorageSync('token')
    if (token) {
      this.globalData.token = token
    }
    
    // 检查更新
    const updateManager = wx.getUpdateManager()
    updateManager.onUpdateReady(() => {
      wx.showModal({
        title: '更新提示',
        content: '新版本已经准备好，是否重启应用？',
        success: (res) => {
          if (res.confirm) {
            updateManager.applyUpdate()
          }
        }
      })
    })
  },

  onShow() {
    console.log('App Show')
  },

  onHide() {
    console.log('App Hide')
  }
})