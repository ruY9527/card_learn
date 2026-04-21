# 技术栈清单 (Stack)

## 后端

**核心框架**：Spring Boot 2.7.x (JDK 8 的稳定版本)。

**持久层**：MyBatis Plus。作为 Java 开发者，你懂的，这能极大地减少样板代码。

**数据库**：MySQL 8.0。

**缓存/并发**：Redis。用于处理游客模式下的热点数据以及后续的登录 Token。

**API 文档**：Knife4j (Swagger 的增强版)。方便在 Cursor 开发时让 AI 快速理解接口。

**安全认证**：Spring Security + JWT。

**公共依赖包**：**lombok** ，**hutool-all**， **fastjson** 



## 前端 (Frontend) - 微信小程序

**框架**：Uni-app (Vue 3 + TS) 或 原生微信小程序开发。

- *建议*：继续使用 **Uni-app**，因为它对 Vue 3 的支持让你在处理复杂逻辑时更得心应手。

**样式/UI**：Tailwind CSS (通过 UnoCSS 适配小程序)。

**渲染引擎**：`mp-html`（支持 LaTeX 和代码块渲染，这对 408 极其重要）



## 前端 (Frontend) - Web 管理后台

**任务 1**：基于 Vue 3 + Element Plus 快速搭建一个简单的 Dashboard。

**任务 2**：**AI 辅助录入功能**。在 Web 端做一个文本框，你可以把 Qwen 生成的 408 知识点直接粘贴进去，点击“解析并入库”。



## 数据库设计

数据库使用的是mysql8，sql的脚本也是需要按照mysql8进行生成

```
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- 1. 后台管理员表
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user` (
  `user_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` varchar(50) NOT NULL COMMENT '登录账号',
  `password` varchar(100) NOT NULL COMMENT '密码',
  `nickname` varchar(50) DEFAULT NULL COMMENT '用户昵称',
  `avatar` varchar(255) DEFAULT '' COMMENT '头像地址',
  `status` char(1) DEFAULT '0' COMMENT '帐号状态（0正常 1停用）',
  `del_flag` char(1) DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='后台用户信息表';

-- ----------------------------
-- 2. 角色表
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role` (
  `role_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `role_name` varchar(30) NOT NULL COMMENT '角色名称',
  `role_key` varchar(100) NOT NULL COMMENT '角色权限字符串',
  `status` char(1) DEFAULT '0' COMMENT '角色状态（0正常 1停用）',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色信息表';

-- ----------------------------
-- 3. 菜单权限表
-- ----------------------------
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu` (
  `menu_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '菜单ID',
  `menu_name` varchar(50) NOT NULL COMMENT '菜单名称',
  `parent_id` bigint(20) DEFAULT '0' COMMENT '父菜单ID',
  `order_num` int(4) DEFAULT '0' COMMENT '显示顺序',
  `path` varchar(200) DEFAULT '' COMMENT '路由地址',
  `component` varchar(255) DEFAULT NULL COMMENT '组件路径',
  `perms` varchar(100) DEFAULT NULL COMMENT '权限标识',
  `menu_type` char(1) DEFAULT '' COMMENT '菜单类型（M目录 C菜单 F按钮）',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='菜单权限表';

-- ----------------------------
-- 4. 用户和角色关联表
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role` (
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `role_id` bigint(20) NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`user_id`,`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户和角色关联表';

-- ----------------------------
-- 5. 角色和菜单关联表
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_menu`;
CREATE TABLE `sys_role_menu` (
  `role_id` bigint(20) NOT NULL COMMENT '角色ID',
  `menu_id` bigint(20) NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`role_id`,`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色和菜单关联表';

-- ----------------------------
-- 6. 专业表
-- ----------------------------
DROP TABLE IF EXISTS `biz_major`;
CREATE TABLE `biz_major` (
  `major_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '专业ID',
  `major_name` varchar(50) NOT NULL COMMENT '专业名称(如: 408计算机)',
  `description` text COMMENT '专业描述',
  `status` char(1) DEFAULT '0' COMMENT '状态',
  PRIMARY KEY (`major_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='专业信息表';

-- ----------------------------
-- 7. 科目表
-- ----------------------------
DROP TABLE IF EXISTS `biz_subject`;
CREATE TABLE `biz_subject` (
  `subject_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '科目ID',
  `major_id` bigint(20) NOT NULL COMMENT '所属专业ID',
  `subject_name` varchar(50) NOT NULL COMMENT '科目名称(如: 数据结构)',
  `icon` varchar(255) DEFAULT NULL COMMENT '科目图标',
  `order_num` int(4) DEFAULT '0' COMMENT '排序',
  PRIMARY KEY (`subject_id`),
  KEY `idx_major_id` (`major_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='科目信息表';

-- ----------------------------
-- 8. 知识点卡片表 (核心)
-- ----------------------------
DROP TABLE IF EXISTS `biz_card`;
CREATE TABLE `biz_card` (
  `card_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '卡片ID',
  `subject_id` bigint(20) NOT NULL COMMENT '所属科目ID',
  `front_content` text NOT NULL COMMENT '卡片正面(支持Markdown/LaTeX)',
  `back_content` text NOT NULL COMMENT '卡片反面(答案/解析)',
  `difficulty_level` tinyint(4) DEFAULT '1' COMMENT '难度系数(1-5)',
  `del_flag` char(1) DEFAULT '0' COMMENT '删除标志',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`card_id`),
  KEY `idx_subject_id` (`subject_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='知识点卡片表';

-- ----------------------------
-- 9. 标签表及关联表
-- ----------------------------
DROP TABLE IF EXISTS `biz_tag`;
CREATE TABLE `biz_tag` (
  `tag_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '标签ID',
  `tag_name` varchar(50) NOT NULL COMMENT '标签名称(如:#PV操作)',
  PRIMARY KEY (`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='标签表';

DROP TABLE IF EXISTS `biz_card_tag`;
CREATE TABLE `biz_card_tag` (
  `card_id` bigint(20) NOT NULL,
  `tag_id` bigint(20) NOT NULL,
  PRIMARY KEY (`card_id`,`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='卡片标签关联表';


-- ----------------------------
-- 10. 小程序用户表 (预留)
-- ----------------------------
DROP TABLE IF EXISTS `sys_app_user`;
CREATE TABLE `sys_app_user` (
  `app_user_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '小程序用户ID',
  `openid` varchar(100) NOT NULL COMMENT '微信OpenID',
  `unionid` varchar(100) DEFAULT NULL COMMENT '微信UnionID',
  `nickname` varchar(50) DEFAULT NULL COMMENT '昵称',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像',
  `last_login_time` datetime DEFAULT NULL COMMENT '最后登录时间',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  PRIMARY KEY (`app_user_id`),
  UNIQUE KEY `uk_openid` (`openid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='小程序用户信息表';

-- ----------------------------
-- 11. 用户学习进度表
-- ----------------------------
DROP TABLE IF EXISTS `biz_user_progress`;
CREATE TABLE `biz_user_progress` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `app_user_id` bigint(20) DEFAULT NULL COMMENT '用户ID(游客模式下可为空)',
  `card_id` bigint(20) NOT NULL COMMENT '卡片ID',
  `status` tinyint(4) DEFAULT '0' COMMENT '掌握状态(0未学 1模糊 2掌握)',
  `next_review_time` datetime DEFAULT NULL COMMENT '建议下次复习时间(艾宾浩斯逻辑)',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_card` (`app_user_id`,`card_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户学习进度表';

SET FOREIGN_KEY_CHECKS = 1;
```



# 项目模块生成

后端模块名字：card-learn-boot

小程序模块名字:  card-mini

前端管理系统: card-ui

sql脚本管理:  sql

分别按照上面的文件夹来生成相关的技术
