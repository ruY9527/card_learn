// custom-tab-bar/index.js
Component({
  data: {
    selected: 0,
    list: [
      { pagePath: '/pages/index/index', text: '首页' },
      { pagePath: '/pages/study/study', text: '学习' },
      { pagePath: '/pages/profile/profile', text: '我的' }
    ]
  },

  methods: {
    switchTab(e) {
      const index = e.currentTarget.dataset.index
      const url = this.data.list[index].pagePath
      
      wx.switchTab({ url })
      
      this.setData({
        selected: index
      })
    }
  }
})