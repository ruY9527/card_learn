// 环境配置
type EnvConfig = {
  baseURL: string
}

type Config = {
  development: EnvConfig
  production: EnvConfig
}

const config: Config = {
  development: {
    baseURL: '/api'
  },
  production: {
    baseURL: '/api'
  }
}

const mode = import.meta.env.MODE as keyof Config
export default config[mode] || config.development