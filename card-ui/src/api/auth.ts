import request from './request'
import type { LoginForm, LoginResult, CaptchaResult } from './types'

// 获取验证码
export const getCaptcha = () => {
  return request.get<any, CaptchaResult>('/captcha/generate')
}

// 登录
export const login = (data: LoginForm) => {
  return request.post<any, LoginResult>('/auth/login', data)
}

// 登出
export const logout = () => {
  return request.post('/auth/logout')
}