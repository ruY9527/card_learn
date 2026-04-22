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
- [x] 后端完整API实现
- [x] 管理后台完整页面
- [x] 小程序完整功能
- [x] LaTeX公式渲染支持
- [ ] 艾宾浩斯复习提醒
- [ ] AI辅助录入功能

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