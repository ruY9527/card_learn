import request from './request'
import type { SendEmailCodeForm, EmailRegisterForm, ResetPasswordForm, EmailCodeResult, LoginResult } from './types'

// 发送邮箱验证码
export const sendEmailCode = (data: SendEmailCodeForm) => {
  return request.post<any, { code: number; message: string; data: EmailCodeResult }>('/auth/email-code/send', data)
}

// 邮箱注册（可能返回username或LoginVO）
export const emailRegister = (data: EmailRegisterForm) => {
  return request.post<any, { code: number; message: string; data: any }>('/auth/email/register', data)
}

// 激活账号
export const activateAccount = (code: string, key: string) => {
  return request.get<any, LoginResult>(`/auth/activate?code=${code}&key=${key}`)
}

// 发送重置密码验证码
export const sendResetCode = (email: string) => {
  return request.post<any, { code: number; message: string; data: EmailCodeResult }>('/auth/password/reset-code/send', { email })
}

// 重置密码
export const resetPassword = (data: ResetPasswordForm) => {
  return request.post<any, { code: number; message: string }>('/auth/password/reset', data)
}
