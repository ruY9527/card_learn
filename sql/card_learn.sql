SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- 创建数据库
-- ----------------------------
CREATE DATABASE IF NOT EXISTS `card_learn` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

USE `card_learn`;

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

-- 初始化管理员账号 (密码: admin123)
INSERT INTO `sys_user` (`username`, `password`, `nickname`, `status`) VALUES ('admin', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '管理员', '0');

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

-- 初始化角色
INSERT INTO `sys_role` (`role_name`, `role_key`) VALUES ('超级管理员', 'admin');
INSERT INTO `sys_role` (`role_name`, `role_key`) VALUES ('普通管理员', 'manager');

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

-- 初始化菜单
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `menu_type`) VALUES ('系统管理', 0, 1, 'system', NULL, 'M');
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `menu_type`) VALUES ('用户管理', 1, 1, 'user', 'system/user/index', 'C');
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `menu_type`) VALUES ('内容管理', 0, 2, 'content', NULL, 'M');
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `menu_type`) VALUES ('专业管理', 3, 1, 'major', 'content/major/index', 'C');
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `menu_type`) VALUES ('科目管理', 3, 2, 'subject', 'content/subject/index', 'C');
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `menu_type`) VALUES ('卡片管理', 3, 3, 'card', 'content/card/index', 'C');
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `component`, `menu_type`) VALUES ('标签管理', 3, 4, 'tag', 'content/tag/index', 'C');

-- ----------------------------
-- 4. 用户和角色关联表
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role` (
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `role_id` bigint(20) NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`user_id`,`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户和角色关联表';

-- 初始化用户角色关联
INSERT INTO `sys_user_role` (`user_id`, `role_id`) VALUES (1, 1);

-- ----------------------------
-- 5. 角色和菜单关联表
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_menu`;
CREATE TABLE `sys_role_menu` (
  `role_id` bigint(20) NOT NULL COMMENT '角色ID',
  `menu_id` bigint(20) NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`role_id`,`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色和菜单关联表';

-- 初始化角色菜单关联
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7);

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

-- 初始化专业
INSERT INTO `biz_major` (`major_name`, `description`, `status`) VALUES ('408计算机考研', '计算机学科专业基础综合考试', '0');

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

-- 初始化科目
INSERT INTO `biz_subject` (`major_id`, `subject_name`, `order_num`) VALUES (1, '数据结构', 1);
INSERT INTO `biz_subject` (`major_id`, `subject_name`, `order_num`) VALUES (1, '计算机组成原理', 2);
INSERT INTO `biz_subject` (`major_id`, `subject_name`, `order_num`) VALUES (1, '操作系统', 3);
INSERT INTO `biz_subject` (`major_id`, `subject_name`, `order_num`) VALUES (1, '计算机网络', 4);

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