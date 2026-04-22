// 通用响应类型
export interface Result<T = any> {
  code: number
  message: string
  data: T
}

// 分页结果
export interface PageResult<T> {
  code: number
  message: string
  data: {
    records: T[]
    total: number
    size: number
    current: number
    pages: number
  }
}

// 验证码结果
export interface CaptchaResult {
  code: number
  message: string
  data: {
    key: string
    image: string
  }
}

// 登录表单
export interface LoginForm {
  username: string
  password: string
  captcha: string
  captchaKey: string
}

// 登录结果
export interface LoginResult {
  code: number
  message: string
  data: {
    token: string
    user: UserInfo
  }
}

// 用户信息
export interface UserInfo {
  userId: number
  username: string
  nickname: string
  avatar: string
  status: string
}

// 专业
export interface Major {
  majorId?: number
  majorName: string
  description?: string
  status?: string
}

// 科目
export interface Subject {
  subjectId?: number
  majorId: number
  majorName?: string
  subjectName: string
  icon?: string
  orderNum?: number
}

// 知识点卡片
export interface Card {
  cardId?: number
  subjectId: number
  subjectName?: string
  frontContent: string
  backContent: string
  difficultyLevel?: number
  createTime?: string
  updateTime?: string
}

// 标签
export interface Tag {
  tagId?: number
  tagName: string
}

// 系统用户
export interface SysUser {
  userId?: number
  username: string
  password?: string
  nickname: string
  avatar?: string
  status: string
  createTime?: string
}

// 系统角色
export interface SysRole {
  roleId?: number
  roleName: string
  roleKey: string
  status: string
  createTime?: string
}

// 系统菜单
export interface SysMenu {
  menuId?: number
  menuName: string
  parentId: number
  orderNum: number
  path: string
  component: string
  perms: string
  menuType: string
  createTime?: string
  children?: SysMenu[]
}

// AI卡片DTO
export interface AiCardDTO {
  frontContent: string
  backContent: string
  difficultyLevel: number
  tags?: string[]
}

// 用户反馈
export interface Feedback {
  id?: number
  appUserId?: number
  userNickname?: string
  cardId?: number
  cardFrontContent?: string
  type: string
  rating?: number
  content: string
  contact?: string
  images?: string
  status?: string
  adminReply?: string
  createTime?: string
  updateTime?: string
}

// 反馈视图对象（包含用户和卡片信息）
export interface FeedbackVO {
  id?: number
  appUserId?: number
  userNickname?: string
  cardId?: number
  cardFrontContent?: string
  type: string
  rating?: number
  content: string
  contact?: string
  images?: string
  status?: string
  adminReply?: string
  createTime?: string
  updateTime?: string
}

// 系统请求日志
export interface RequestLog {
  id: number
  requestMethod: string
  requestUrl: string
  className: string
  methodName: string
  requestParams?: string
  responseResult?: string
  executionTime: number
  status: string
  errorMsg?: string
  ipAddress?: string
  userId?: number
  userName?: string
  createTime: string
}

// 日志统计信息
export interface LogStats {
  total: number
  success: number
  fail: number
  today: number
}

// 系统配置
export interface SysConfig {
  id: number
  configKey: string
  configValue: string
  configName: string
  configType: string
  description?: string
  createTime?: string
  updateTime?: string
}

// 冲刺配置
export interface SprintConfig {
  examName: string
  examDate: string
  daysRemaining: number
  isExpired: boolean
  enabled: boolean
}