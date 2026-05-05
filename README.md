# 408知识点学习卡片系统

一个专注于408计算机考研知识点学习的多平台卡片系统，采用卡片式学习方法，结合SM-2间隔重复算法，帮助用户高效掌握知识点。

## 项目结构

```
card_learn/
├── card-learn-boot/     # 后端项目 (Spring Boot)
├── card-ios/            # iOS 客户端 (SwiftUI)
├── card-mini/           # 小程序项目 (Uni-app Vue3 + TS)
├── card-ui/             # 管理后台 (Vue 3 + Element Plus)
├── sql/                 # 数据库脚本
└── plans/               # 项目规划文档
```

## 技术栈

### 后端 (card-learn-boot)
- Spring Boot 2.7.x (JDK 8 / JDK 17)
- MyBatis Plus 3.5.x
- MySQL 8.0
- Redis
- Spring Security + JWT
- Knife4j (API文档)
- SM-2 间隔重复算法

### iOS 客户端 (card-ios)
- SwiftUI
- iOS 16+
- MVVM 架构
- 翻转卡片交互

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
- 卡片审批（用户提交卡片需审批后上线）
- 复习计划管理
- 激励仪表盘、成就管理、排行榜
- 学习报告与数据统计
- 邮箱配置（激活开关、激活链接地址）
- 冲刺配置（考试倒计时）

### iOS 客户端
- 首页: 专业分类、科目列表、卡片学习
- 学习: 翻转卡片、学习状态标记（不熟/模糊/掌握）
- 复习计划: SM-2算法生成的复习计划、按日期分组展示
- 学习统计: 连续学习天数、今日学习/掌握数量、科目进度
- 今日学习/掌握: 点击查看当日学习的卡片详情
- 学习历史: 每张卡片的学习记录追踪
- 评论系统: 卡片评论、回复、点赞/踩（三态切换）
- 笔记管理: 查看个人笔记列表
- 用户反馈: 可关联卡片提交反馈
- 添加卡片: 用户自主创建知识点卡片
- 我的卡片: 查看个人提交的卡片及审批状态
- 激励中心: 等级经验、成就列表、排行榜
- 学习报告: 趋势分析、薄弱知识点、学习习惯
- 邮箱注册/登录、忘记密码

### 小程序
- 首页: 专业分类、科目列表、推荐卡片
- 学习: 按科目学习卡片、进度跟踪
- 卡片详情: 翻转式卡片、学习状态标记
- 评论列表: 查看卡片评论及回复
- 笔记列表: 查看个人学习笔记
- 个人中心: 学习统计、设置

## 数据库表结构

| 表名 | 说明 |
|------|------|
| sys_user | 用户表（管理员+小程序用户） |
| sys_role | 角色表 |
| sys_menu | 菜单权限表 |
| biz_major | 专业表 |
| biz_subject | 科目表 |
| biz_card | 知识点卡片表(核心) |
| biz_tag | 标签表 |
| biz_card_tag | 卡片标签关联表 |
| biz_user_progress | 用户学习进度表 |
| biz_review_plan | 复习计划表 |
| biz_study_history | 学习历史记录表 |
| biz_feedback | 用户反馈表 |
| biz_learning_streak | 学习连续记录表 |
| biz_card_reply | 评论回复表 |
| biz_comment_like | 评论点赞/踩记录表 |
| biz_card_draft | 用户投稿卡片草稿表 |
| sys_config | 系统配置表 |
| biz_achievement | 成就定义表 |
| biz_user_achievement | 用户成就记录表 |
| biz_user_level | 用户等级经验表 |
| biz_exp_log | 经验变动日志表 |
| biz_learning_goal | 学习目标表 |
| biz_goal_record | 目标完成记录表 |
| biz_user_daily_count | 用户每日学习统计表 |
| biz_daily_stats_snapshot | 每日统计快照表 |
| biz_learning_report | 学习报告表 |
| biz_weak_point | 薄弱知识点表 |

## 开发计划

- [x] 项目初始化
- [x] 后端完整API实现
- [x] 管理后台完整页面
- [x] 小程序完整功能
- [x] LaTeX公式渲染支持
- [x] SM-2间隔重复算法
- [x] 复习计划系统
- [x] iOS客户端
- [x] 学习统计与连续记录
- [x] 卡片审批流程
- [x] 用户反馈系统
- [x] 评论回复与点赞/踩系统
- [x] 笔记管理功能
- [x] 邮箱注册/登录与忘记密码
- [x] 邮箱激活可配置化
- [x] 激励系统（成就、等级、经验、排行榜、目标）
- [x] 学习报告（趋势分析、薄弱知识点、学习习惯）
- [x] SQL脚本整合归档
- [ ] AI辅助录入功能

## 版本历史

### v1.3 (2026-05-06)

**新功能：**
- 激励系统：成就系统、用户等级与经验值、排行榜、学习目标管理，三端同步实现
- 学习报告：统计快照、趋势分析、薄弱知识点识别、学习习惯分析、科目深度分析，三端同步实现
- 邮箱注册/登录：支持邮箱验证码注册、邮箱+密码登录，三端同步实现
- 忘记密码：通过邮箱验证码重置密码，三端同步实现
- 邮箱激活可配置化：管理员可在「系统管理 > 邮箱配置」中开关激活流程及配置激活链接地址
- 登录页面全新UI：左右分栏布局、Tab切换登录/注册、渐变按钮、响应式适配
- iOS新增页面：激励中心、成就列表、排行榜、经验日志、目标设置、学习报告、连续学习详情、薄弱知识点
- Web管理后台新增：激励仪表盘、成就管理、排行榜、学习报告页面

**优化：**
- SQL脚本整合归档：按日期目录组织，合并生成完整数据库初始化脚本
- 修复用户管理分配角色时Content-Type不正确的问题
- 修复iOS端EmailAuthApiService和ForgotPasswordView未加入Xcode项目的编译错误
- sys_config表新增激励系统、学习报告、邮箱配置等配置项

### v1.2 (2026-05-05)

**新功能：**
- 评论点赞/踩系统：支持三态切换（喜欢/不喜欢/取消）
- 评论回复功能：支持对评论进行回复
- 笔记管理：Web端笔记管理改为按用户名搜索，使用子查询优化
- 小程序新增评论列表、笔记列表页面

**优化：**
- iOS端重构APIService为模块化架构（7个子服务+门面模式）
- 评论列表按喜欢数>回复数>时间降序排序
- Web端专业/评论/笔记/反馈管理列表按ID升序排序
- 修复回复提交时缺少card_id的SQL错误
- 修复回复用户名显示为匿名用户的问题

### v1.1 (2026-05-04)

**新功能：**
- 学习功能完善与SM2算法支持
- 数据统计功能增强
- 今日学习/今日掌握卡片点击跳转
- 用户反馈系统与卡片审批流程

**优化：**
- 统计查询去重与日期边界修复
- iOS反馈、卡片选择、分页字段名等多项修复

### v1.0 (2026-04)

**初始版本：**
- 后端Spring Boot完整API实现
- 管理后台Vue 3 + Element Plus
- 小程序Uni-app完整功能
- iOS SwiftUI客户端
- SM-2间隔重复算法
- 复习计划系统
- Docker部署支持

## 部署脚本
文件清单

    1. 主管理脚本 card-learn.sh

    使用方法：

     1 ./card-learn.sh <命令> [参数]

    支持命令：

    ┌─────────────┬───────────────┐
    │ 命令        │ 功能          │
    ├─────────────┼───────────────┤
    │ start       │ 启动服务      │
    ├─────────────┼───────────────┤
    │ stop        │ 停止服务      │
    ├─────────────┼───────────────┤
    │ restart     │ 重启服务      │
    ├─────────────┼───────────────┤
    │ status      │ 查看运行状态  │
    ├─────────────┼───────────────┤
    │ clean       │ 清理日志      │
    ├─────────────┼───────────────┤
    │ logs [type] │ 查看日志      │
    ├─────────────┼───────────────┤
    │ tail [type] │ 实时查看日志  │
    ├─────────────┼───────────────┤
    │ jvm         │ 显示 JVM 配置 │
    └─────────────┴───────────────┘


    环境变量配置：

     1 export JVM_XMS=512m        # 初始堆内存
     2 export JVM_XMX=1024m       # 最大堆内存
     3 export GC_TYPE=G1          # GC 类型 (G1/CMS/Parallel)
     4 export LOG_RETENTION_DAYS=7  # 日志保留天数

    2. 日志清理脚本 scripts/clean_logs.sh

    定时任务配置（crontab）：

     1 # 每天凌晨3点执行日志清理
     2 0 3 * * * /path/to/card-learn-boot/scripts/clean_logs.sh >> logs/clean.log 2>&1

    3. 配置文件 conf/application.yml
     - 生产环境配置示例
     - 放在 jar 同级目录的 conf/ 下

    4. Logback 配置 src/main/resources/logback-spring.xml
     - 按日期和大小滚动
     - 自动清理过期日志
     - 区分开发和生产环境

    目录结构

      1 card-learn-boot/
      2   ├── card-learn.jar          # jar 文件
      3   ├── card-learn.sh           # 管理脚本
      4   ├── conf/
      5   │   └── application.yml     # 配置文件
      6   ├── logs/
      7   │   ├── console.log         # 控制台日志
      8   │   ├── gc.log              # GC 日志
      9   │   ├── card-learn.log      # 应用日志
     10   │   └── card-learn-error.log # 错误日志
     11   ├── scripts/
     12   │   └── clean_logs.sh       # 日志清理脚本
     13   └── card-learn-boot.pid     # PID 文件

    JVM 配置说明

    脚本默认配置：
     - 内存: -Xms256m -Xmx512m
     - GC: G1GC，带详细日志输出
     - OOM处理: 自动生成 heap dump
     - 错误日志: JVM crash 日志自动保存


## License

MIT