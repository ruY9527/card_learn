// components/markdown-render/markdown-render.js
/**
 * Markdown渲染组件
 * 简化版本：直接渲染文本内容，支持基本的换行处理
 */
Component({
  properties: {
    content: {
      type: String,
      value: ''
    }
  },

  data: {
    displayContent: ''
  },

  observers: {
    'content': function(content) {
      if (content) {
        // 处理换行，将 \n 转换为可显示的格式
        const displayContent = content
        this.setData({ displayContent })
      } else {
        this.setData({ displayContent: '' })
      }
    }
  },

  lifetimes: {
    attached() {
      if (this.properties.content) {
        this.setData({ displayContent: this.properties.content })
      }
    }
  }
})