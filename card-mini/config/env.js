/**
 * 环境配置文件
 * 
 * 使用方法：
 * 1. 本地开发：设置 ENV = 'development'
 * 2. 生产环境：设置 ENV = 'production'
 * 
 * 或者直接修改对应环境的 BASE_URL
 */

const ENV = 'development'  // 当前环境：development | production

// 环境配置
const envConfig = {
  // 本地开发环境
  development: {
    BASE_URL: 'http://localhost:8080',
    API_PREFIX: '/api'
  },
  
  // 生产环境
  production: {
    BASE_URL: 'http://learn.thisforyou.cn:180/api',
    API_PREFIX: '/api'
  }
}

// 获取当前环境配置
const currentConfig = envConfig[ENV]

// 导出配置
module.exports = {
  ENV,
  BASE_URL: currentConfig.BASE_URL,
  API_PREFIX: currentConfig.API_PREFIX,
  
  // 完整API地址
  getApiUrl: (path) => {
    // 如果路径已经包含 /api，直接拼接
    if (path.startsWith('/api')) {
      return currentConfig.BASE_URL + path
    }
    return currentConfig.BASE_URL + currentConfig.API_PREFIX + path
  }
}