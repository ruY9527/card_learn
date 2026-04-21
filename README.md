# 408知识点学习卡片系统

一个专注于408计算机考研知识点学习的小程序系统，采用卡片式学习方法，帮助用户高效掌握知识点。

## 项目结构

```
card_learn/
├── card-learn-boot/     # 后端项目 (Spring Boot)
├── card-mini/           # 小程序项目 (Uni-app Vue3 + TS)
├── card-ui/             # 管理后台 (Vue 3 + Element Plus)
├── sql/                 # 数据库脚本
└── plans/               # 项目规划文档
```

## 技术栈

### 后端 (card-learn-boot)
- Spring Boot 2.7.x (JDK 8)
- MyBatis Plus 3.5.x
- MySQL 8.0
- Redis
- Spring Security + JWT
- Knife4j (API文档)

### 小程序 (card-mini)
- Uni-app (Vue 3 + TypeScript)
- UnoCSS (样式适配)
- mp-html (支持LaTeX渲染)

### 管理后台 (card-ui)
- Vue 3 + TypeScript
- Element Plus
- Vite
- Axios

## 快速开始

### 1. 初始化数据库

```bash
# 执行SQL脚本
mysql -u root -p < sql/card_learn.sql
```

### 2. 启动后端

```bash
cd card-learn-boot
mvn clean install
mvn spring-boot:run
```

后端默认运行在 http://localhost:8080

API文档地址: http://localhost:8080/doc.html

### 3. 启动管理后台

```bash
cd card-ui
npm install
npm run dev
```

管理后台运行在 http://localhost:3000

默认账号: admin / admin123

### 4. 启动小程序

```bash
cd card-mini
npm install
npm run dev:mp-weixin
```

使用微信开发者工具打开 `dist/dev/mp-weixin` 目录

## 功能模块

### 管理后台
- 专业管理
- 科目管理
- 知识点卡片管理 (支持Markdown/LaTeX)
- 标签管理
- 用户管理

### 小程序
- 首页: 专业分类、科目列表、推荐卡片
- 学习: 按科目学习卡片、进度跟踪
- 卡片详情: 翻转式卡片、学习状态标记
- 个人中心: 学习统计、设置

## 数据库表结构

| 表名 | 说明 |
|------|------|
| sys_user | 后台管理员表 |
| sys_role | 角色表 |
| sys_menu | 菜单权限表 |
| biz_major | 专业表 |
| biz_subject | 科目表 |
| biz_card | 知识点卡片表(核心) |
| biz_tag | 标签表 |
| sys_app_user | 小程序用户表 |
| biz_user_progress | 用户学习进度表 |

## 开发计划

- [x] 项目初始化
- [ ] 后端完整API实现
- [ ] 管理后台完整页面
- [ ] 小程序完整功能
- [ ] LaTeX公式渲染支持
- [ ] 艾宾浩斯复习提醒
- [ ] AI辅助录入功能

## License

MIT