// 环境配置
const config = {
  // 开发环境
  development: {
    baseURL: '/api'
  },
  // 生产环境
  production: {
    baseURL: '/api'  // 使用 nginx 代理，保持相对路径
  }
}

// 根据环境导出配置
export default config[import.meta.env.MODE] || config.development