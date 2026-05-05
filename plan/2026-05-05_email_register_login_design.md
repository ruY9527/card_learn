# 邮箱注册登录功能设计规划

**创建日期**: 2026-05-05
**功能模块**: 用户认证 - 邮箱注册与登录
**项目**: card_learn 考研知识点学习卡片系统

---

## 一、需求概述

### 1.1 功能目标

- 支持用户使用邮箱进行注册
- 用户名自动使用邮箱前缀，保证全局唯一
- 支持邮箱+密码登录（同时保留用户名登录）
- 注册后需邮箱激活才能使用
- 支持忘记密码功能

### 1.2 设计原则

- 复用现有 `sys_user` 表结构
- 复用现有认证体系（JWT、BCrypt）
- Tab切换整合登录/注册页面
- 统一登录框自动识别用户名或邮箱

---

## 二、用户流程

### 2.1 注册流程

```
1. 用户输入邮箱 → 点击获取验证码
2. 邮箱收到验证码（5分钟有效）
3. 输入验证码 + 密码（6-20位，字母+数字）
4. 点击"注册并登录"
5. 系统创建用户（status=1 待激活）→ 发送激活邮件
6. 提示"注册成功，请查收激活邮件并在24小时内完成激活"
```

### 2.2 激活流程

```
1. 用户点击邮件中的激活链接
2. 链接格式: /auth/activate?code=xxx&key=yyy
3. 验证激活码有效性和时效性（24小时）
4. 更新用户状态 status=0（激活）
5. 自动登录 → 跳转首页
```

### 2.3 登录流程

```
1. 用户输入用户名/邮箱（自动识别）
2. 输入密码 + 图片验证码
3. 点击登录
4. 验证通过 → 返回JWT Token → 登录成功
```

### 2.4 忘记密码流程

```
1. 用户输入邮箱 → 点击获取验证码
2. 邮箱收到验证码（5分钟有效）
3. 输入验证码 + 新密码（6-20位，字母+数字）
4. 点击重置密码 → 验证通过 → 更新密码
5. 提示"密码重置成功，请使用新密码登录"
```

---

## 三、API 接口设计

### 3.1 接口列表

| # | 方法 | 路径 | 说明 | 是否需要认证 |
|---|------|------|------|-------------|
| 1 | POST | `/auth/email-code/send` | 发送邮箱验证码 | 否 |
| 2 | POST | `/auth/email/register` | 邮箱注册 | 否 |
| 3 | GET | `/auth/activate` | 激活账号 | 否 |
| 4 | POST | `/auth/login` | 统一登录（用户名或邮箱） | 否 |
| 5 | POST | `/auth/password/reset-code/send` | 发送重置密码验证码 | 否 |
| 6 | POST | `/auth/password/reset` | 重置密码 | 否 |

### 3.2 接口详情

#### 接口1: 发送邮箱验证码

```
POST /auth/email-code/send
Content-Type: application/json

请求体:
{
  "email": "user@example.com",
  "type": "register"  // register | reset
}

响应:
{
  "code": 200,
  "msg": "验证码已发送",
  "data": {
    "codeKey": "email:verify:abc123def456..."
  }
}

错误码:
- 400: 邮箱格式错误
- 400: 该邮箱已注册 (type=register时)
- 400: 该邮箱未注册 (type=reset时)
- 429: 发送太频繁，请60秒后重试
- 429: 今日发送次数已用完
```

#### 接口2: 邮箱注册

```
POST /auth/email/register
Content-Type: application/json

请求体:
{
  "email": "user@example.com",
  "code": "123456",
  "codeKey": "email:verify:abc123def456...",
  "password": "Password123"
}

响应:
{
  "code": 200,
  "msg": "注册成功，请查收激活邮件并在24小时内完成激活",
  "data": {
    "username": "zhangsan"
  }
}

错误码:
- 400: 邮箱格式错误
- 400: 该邮箱已注册
- 400: 验证码错误
- 400: 验证码已过期
- 400: 密码格式不正确 (需6-20位，必须字母+数字)
```

#### 接口3: 激活账号

```
GET /auth/activate?code=abc123&key=uuid

响应 (成功):
{
  "code": 200,
  "msg": "激活成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
      "userId": 1,
      "username": "zhangsan",
      "email": "zhangsan@example.com",
      "nickname": "zhangsan",
      "avatar": ""
    }
  }
}

错误码:
- 400: 激活链接已失效，请重新注册
- 400: 该账号已激活，请直接登录
```

#### 接口4: 统一登录

```
POST /auth/login
Content-Type: application/json

请求体 (用户名登录):
{
  "username": "zhangsan",
  "password": "Password123",
  "captcha": "1234",
  "captchaKey": "uuid"
}

请求体 (邮箱登录):
{
  "email": "zhangsan@example.com",
  "password": "Password123",
  "captcha": "1234",
  "captchaKey": "uuid"
}

响应:
{
  "code": 200,
  "msg": "登录成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
      "userId": 1,
      "username": "zhangsan",
      "email": "zhangsan@example.com",
      "nickname": "zhangsan",
      "avatar": ""
    }
  }
}

错误码:
- 400: 账号未激活
- 400: 用户名或密码错误
- 400: 账号已停用
- 400: 图片验证码错误/过期
```

#### 接口5: 发送重置密码验证码

```
POST /auth/password/reset-code/send
Content-Type: application/json

请求体:
{
  "email": "user@example.com"
}

响应:
{
  "code": 200,
  "msg": "验证码已发送",
  "data": {
    "codeKey": "email:reset:xyz789..."
  }
}
```

#### 接口6: 重置密码

```
POST /auth/password/reset
Content-Type: application/json

请求体:
{
  "email": "user@example.com",
  "code": "123456",
  "codeKey": "email:reset:xyz789...",
  "newPassword": "NewPassword123"
}

响应:
{
  "code": 200,
  "msg": "密码重置成功"
}
```

---

## 四、数据库设计

### 4.1 表结构变更 (sys_user)

```sql
-- 添加 email 字段
ALTER TABLE `sys_user`
  ADD COLUMN `email` varchar(100) NOT NULL COMMENT '邮箱' AFTER `nickname`;

-- 添加唯一约束
ALTER TABLE `sys_user`
  ADD UNIQUE KEY `uk_email` (`email`);
```

### 4.2 实体类变更

在 `SysUser.java` 添加:
```java
private String email;
```

---

## 五、业务逻辑设计

### 5.1 用户名生成逻辑

```java
private String generateUsername(String email) {
    // 1. 提取邮箱前缀
    String base = email.split("@")[0];

    // 2. 保留字母、数字，移除特殊字符
    String cleaned = base.replaceAll("[^a-zA-Z0-9]", "");

    // 3. 确保不以数字开头
    if (cleaned.length() > 0 && Character.isDigit(cleaned.charAt(0))) {
        cleaned = "user" + cleaned;
    }

    // 4. 如果清洗后为空，生成随机用户名
    if (cleaned.isEmpty()) {
        cleaned = "user" + System.currentTimeMillis() % 10000;
    }

    // 5. 检查唯一性，冲突则追加数字
    return ensureUniqueUsername(cleaned);
}

private String ensureUniqueUsername(String baseUsername) {
    String username = baseUsername;
    int counter = 1;
    while (userMapper.existsByUsername(username)) {
        username = baseUsername + counter;
        counter++;
    }
    return username;
}
```

### 5.2 密码验证逻辑

```java
private boolean isValidPassword(String password) {
    // 6-20位，必须包含字母和数字
    if (password == null || password.length() < 6 || password.length() > 20) {
        return false;
    }
    boolean hasLetter = password.matches(".*[a-zA-Z].*");
    boolean hasDigit = password.matches(".*[0-9].*");
    return hasLetter && hasDigit;
}
```

### 5.3 统一登录识别逻辑

```java
private boolean isEmail(String input) {
    // 邮箱格式: 包含@和.
    return input != null && input.matches("^[\\w.-]+@[\\w.-]+\\.\\w+$");
}

private SysUser findUserByLoginId(String loginId) {
    if (isEmail(loginId)) {
        return userService.getByEmail(loginId);
    } else {
        return userService.getByUsername(loginId);
    }
}
```

---

## 六、Redis Key 设计

| Key Pattern | Value | TTL | 说明 |
|-------------|-------|-----|------|
| `captcha:{uuid}` | 验证码 | 120秒 | 图片验证码 |
| `email:verify:{uuid}` | `{email}:{code}` | 300秒 | 注册验证码 |
| `email:reset:{uuid}` | `{email}:{code}` | 300秒 | 重置密码验证码 |
| `email:activate:{uuid}` | `{userId}` | 86400秒 | 激活链接（24小时） |
| `email:send:last:{email}` | timestamp | 60秒 | 上次发送时间 |
| `email:send:count:{email}` | count | 86400秒 | 当日发送次数 |
| `ip:register:count:{ip}` | count | 86400秒 | IP注册次数 |

---

## 七、安全措施

| 措施 | 说明 |
|------|------|
| 验证码有效期 | 5分钟 |
| 激活链接有效期 | 24小时 |
| 发送频率限制 | 同一邮箱 60秒内只能发送1次 |
| 每日发送上限 | 同一邮箱每天最多10次 |
| IP注册限制 | 同一IP 24小时最多注册5个账号 |
| 密码强度 | 6-20位，必须包含字母和数字 |
| 验证码一次性使用 | 验证成功后立即删除 |
| 登录防机器人 | 需要同时输入图片验证码 |

---

## 八、前端设计

### 8.1 登录页面 (Tab切换)

```
┌────────────────────────────────────────────────────────┐
│           考研知识点学习卡片管理系统                      │
│                                                        │
│   ┌──────────┐ ┌──────────┐ ┌──────────┐            │
│   │用户名登录 │ │ 邮箱登录  │ │  注册    │  ← Tab切换  │
│   └──────────┘ └──────────┘ └──────────┘            │
│   ─────────────────────────────────────────            │
│                                                        │
│   用户名/邮箱: [________________________]              │
│   密码:       [________________________]              │
│   验证码:     [________] [刷新] [图片]                  │
│                                                        │
│   [              登录 / 注册              ]             │
│                                                        │
│   ┌──────────────────────────────────────┐            │
│   │  忘记密码？                           │            │
│   └──────────────────────────────────────┘            │
└────────────────────────────────────────────────────────┘
```

### 8.2 注册Tab

```
┌────────────────────────────────────────────────────────┐
│  注册                                                   │
│                                                        │
│  邮箱:       [________________________] 📧              │
│  验证码:     [________] [获取验证码] (60s倒计时)       │
│  密码:       [________________________] 🔒 6-20位字母+数字│
│  确认密码:   [________________________] 🔒              │
│                                                        │
│  [               注册并登录                ]            │
│                                                        │
│  已有账号? [立即登录]                                   │
└────────────────────────────────────────────────────────┘
```

### 8.3 忘记密码页面

```
┌────────────────────────────────────────────────────────┐
│           忘记密码                                       │
│                                                        │
│  邮箱:       [________________________] 📧              │
│  验证码:     [________] [获取验证码] (60s倒计时)       │
│  新密码:     [________________________] 🔒 6-20位字母+数字│
│  确认新密码: [________________________] 🔒              │
│                                                        │
│  [               重置密码                  ]            │
│                                                        │
│  [返回登录]                                            │
└────────────────────────────────────────────────────────┘
```

---

## 九、邮件模板

### 9.1 注册验证码邮件

```
主题: 【考研学习卡片】注册验证码

您好！

您的注册验证码为: 385927
验证码5分钟内有效，请勿泄露给他人。

如果不是您本人操作，请忽略此邮件。
```

### 9.2 注册激活邮件

```
主题: 【考研学习卡片】邮箱激活 - 请在24小时内完成

您好，zhangsan！

您注册的邮箱是: zhangsan@example.com
请点击以下链接激活账号:

[激活账号] https://yourdomain.com/auth/activate?code=xxx&key=yyy

链接有效期: 24小时

如果无法点击，请复制以下链接到浏览器打开:
https://yourdomain.com/auth/activate?code=xxx&key=yyy

如果不是您本人操作，请忽略此邮件。
```

### 9.3 重置密码验证码邮件

```
主题: 【考研学习卡片】重置密码验证码

您好！

您申请重置密码，验证码为: 385927
验证码5分钟内有效，请勿泄露给他人。

如果不是您本人操作，请立即联系管理员。
```

---

## 十、文件变更清单

### 10.1 后端 (Spring Boot)

| 文件 | 操作 | 说明 |
|------|------|------|
| `entity/SysUser.java` | 修改 | 添加 `email` 字段 |
| `dto/EmailRegisterDTO.java` | 新增 | 邮箱注册请求 |
| `dto/LoginDTO.java` | 修改 | 支持 email 字段 |
| `dto/SendEmailCodeDTO.java` | 新增 | 发送验证码请求 |
| `dto/ResetPasswordDTO.java` | 新增 | 重置密码请求 |
| `dto/ActivateDTO.java` | 新增 | 激活请求参数 |
| `vo/UserVO.java` | 新增 | 用户信息返回(含email) |
| `vo/LoginUserInfoVO.java` | 修改 | 添加 email 字段 |
| `ISysUserService.java` | 修改 | 添加 `getByEmail()` |
| `SysUserMapper.java` | 修改 | 添加 `getByEmail` 方法 |
| `SysUserMapper.xml` | 修改 | 添加 `getByEmail` SQL |
| `IEmailAuthService.java` | 新增 | 邮箱认证服务接口 |
| `EmailAuthServiceImpl.java` | 新增 | 邮箱认证服务实现 |
| `IEmailService.java` | 新增 | 邮件服务接口 |
| `EmailServiceImpl.java` | 新增 | 邮件发送实现 |
| `EmailUtil.java` | 新增 | 邮件工具类 |
| `SysLoginController.java` | 修改 | 添加邮箱相关接口+激活接口 |
| `SecurityConfig.java` | 修改 | 放行新接口 |
| `application.yml` | 修改 | 添加邮件配置 |
| `sql/card_learn.sql` | 修改 | 添加 email 字段DDL |

### 10.2 Web端 (Vue)

| 文件 | 操作 | 说明 |
|------|------|------|
| `views/login/index.vue` | 修改 | Tab切换整合登录/注册 |
| `views/forgot-password/index.vue` | 新增 | 忘记密码页面 |
| `api/email-auth.ts` | 新增 | 邮箱认证API |
| `api/types.ts` | 修改 | 添加邮箱相关类型 |
| `api/auth.ts` | 修改 | 支持邮箱登录 |
| `router/index.ts` | 修改 | 添加激活路由 |

### 10.3 iOS端 (SwiftUI)

| 文件 | 操作 | 说明 |
|------|------|------|
| `Views/LoginModal.swift` | 修改 | Tab切换整合 |
| `Views/EmailLoginView.swift` | 新增 | 邮箱登录 |
| `Views/RegisterView.swift` | 新增 | 注册页面 |
| `Views/ForgotPasswordView.swift` | 新增 | 忘记密码 |
| `Views/ActivationView.swift` | 新增 | 激活成功页面 |
| `Services/EmailAuthApiService.swift` | 新增 | 邮箱认证API |
| `Models/Models.swift` | 修改 | 添加邮箱相关模型 |

---

## 十一、配置项

### 11.1 application.yml 新增配置

```yaml
spring:
  mail:
    host: smtp.example.com
    port: 587
    username: noreply@example.com
    password: xxxxxx
    properties:
      mail:
        smtp:
          auth: true
          starttls:
            enable: true

email:
  from: noreply@example.com
  verify-code-ttl: 300
  activate-code-ttl: 86400
  send-limit-per-day: 10
  send-interval-seconds: 60
```

---

## 十二、用户状态流转

```
注册 ──► 待激活(status=1) ──► 激活成功(status=0) ──► 可登录
                                  │
                                  ▼
                           (正常账号)
                                  │
                                  ▼
                           账号停用(status=1)
                                  │
                                  ▼
                           账号删除(del_flag=2)
```

| 状态值 | 说明 | 能否登录 |
|--------|------|----------|
| status=0, del_flag=0 | 正常 | ✓ |
| status=1, del_flag=0 | 待激活/停用 | ✗ |
| del_flag=2 | 已删除 | ✗ |

---

## 十三、异常处理

| 错误码 | 错误信息 | HTTP状态码 |
|--------|----------|------------|
| 1001 | 邮箱格式错误 | 400 |
| 1002 | 验证码错误 | 400 |
| 1003 | 验证码已过期 | 400 |
| 1004 | 该邮箱已注册 | 400 |
| 1005 | 该邮箱未注册 | 400 |
| 1006 | 密码格式错误（需6-20位字母+数字） | 400 |
| 1007 | 发送太频繁 | 429 |
| 1008 | 今日发送次数已用完 | 429 |
| 1009 | 用户名或密码错误 | 400 |
| 1010 | 账号已停用 | 403 |
| 1011 | 账号未激活 | 403 |
| 1012 | 激活链接已失效 | 400 |
| 1013 | 该账号已激活 | 400 |
| 1014 | 注册太频繁，请稍后再试 | 429 |

---

## 十四、待确认事项

- [ ] 邮件SMTP配置信息（QQ/网易/其他）
- [ ] 前端部署域名（用于激活链接）
- [ ] 是否需要配置化邮件模板

---

**文档版本**: v1.0
**最后更新**: 2026-05-05
