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

-- 初始化角色（8个角色：2大类人员体系）
INSERT INTO `sys_role` (`role_id`, `role_name`, `role_key`, `status`) VALUES
(1, '超级管理员', 'admin', '0'),
(3, '内容编辑员', 'content_editor', '0'),
(4, '审核员', 'reviewer', '0'),
(5, '数据分析师', 'data_analyst', '0'),
(6, '系统管理员', 'system_admin', '0'),
(7, '普通学习者', 'learner', '0'),
(8, '高级学习者', 'premium_learner', '0');

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
  `icon` varchar(100) DEFAULT NULL COMMENT '菜单图标',
  `hidden` char(1) DEFAULT '0' COMMENT '是否隐藏（0否 1是）',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='菜单权限表';

-- 初始化菜单
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `menu_type`, `icon`) VALUES
(1, '系统管理', 0, 7, 'system', NULL, 'M', 'Setting'),
(2, '用户管理', 1, 1, 'system/user', 'views/system/user/index.vue', 'C', 'User'),
(3, '内容管理', 0, 2, 'content', NULL, 'M', 'Folder'),
(4, '专业管理', 3, 1, 'major', 'views/content/major/index.vue', 'C', 'FolderOpened'),
(5, '科目管理', 3, 2, 'subject', 'views/content/subject/index.vue', 'C', 'Document'),
(6, '卡片管理', 3, 3, 'card', 'views/content/card/index.vue', 'C', 'Tickets'),
(7, '标签管理', 3, 4, 'tag', 'views/content/tag/index.vue', 'C', 'PriceTag'),
(8, '首页', 0, 0, 'dashboard', 'views/dashboard/index.vue', 'C', 'HomeFilled'),
(9, '用户反馈', 0, 3, 'feedback', NULL, 'M', 'ChatDotRound'),
(10, '反馈管理', 9, 1, 'feedback', 'views/feedback/index.vue', 'C', 'ChatLineSquare'),
(11, '卡片审批', 9, 2, 'card-audit', 'views/feedback/card-audit/index.vue', 'C', 'CircleCheck'),
(12, '评论管理', 9, 3, 'comment', 'views/comment/index.vue', 'C', 'Comment'),
(13, '笔记管理', 9, 4, 'note', 'views/note/index.vue', 'C', 'Notebook'),
(14, '数据统计', 0, 4, 'stats', NULL, 'M', 'DataAnalysis'),
(15, '学习数据统计', 14, 1, 'stats/learning', 'views/stats/learning/index.vue', 'C', 'TrendCharts'),
(16, '学习记录', 14, 2, 'stats/study-history', 'views/stats/study-history/index.vue', 'C', 'List'),
(17, '复习计划', 14, 3, 'stats/review-plan', 'views/stats/review-plan/index.vue', 'C', 'Calendar'),
(18, '学习报告', 14, 4, 'stats/report', 'views/stats/report/index.vue', 'C', 'Document'),
(19, '激励管理', 0, 5, 'incentive', NULL, 'M', 'Trophy'),
(20, '激励仪表盘', 19, 1, 'incentive/dashboard', 'views/incentive/dashboard/index.vue', 'C', 'Odometer'),
(21, '成就管理', 19, 2, 'incentive/achievement', 'views/incentive/achievement/index.vue', 'C', 'Medal'),
(22, '排行榜', 19, 3, 'incentive/rank', 'views/incentive/rank/index.vue', 'C', 'Histogram'),
(23, 'AI转化', 0, 6, 'ai', 'views/ai/index.vue', 'C', 'MagicStick'),
(24, '角色管理', 1, 2, 'system/role', 'views/system/role/index.vue', 'C', 'UserFilled'),
(25, '菜单管理', 1, 3, 'system/menu', 'views/system/menu/index.vue', 'C', 'Menu'),
(26, '日志管理', 1, 4, 'system/log', 'views/system/log/index.vue', 'C', 'DocumentCopy'),
(27, '冲刺配置', 1, 5, 'system/sprint', 'views/system/sprint/index.vue', 'C', 'Sprint'),
(28, '邮箱配置', 1, 6, 'system/email-config', 'views/system/email-config/index.vue', 'C', 'Message');

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
-- 超级管理员(role_id=1): 全部菜单
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7),
(1, 8), (1, 9), (1, 10), (1, 11), (1, 12), (1, 13),
(1, 14), (1, 15), (1, 16), (1, 17), (1, 18),
(1, 19), (1, 20), (1, 21), (1, 22),
(1, 23),
(1, 24), (1, 25), (1, 26), (1, 27), (1, 28);

-- 内容编辑员(role_id=3): 首页 + 内容管理
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES
(3, 8), (3, 3), (3, 4), (3, 5), (3, 6), (3, 7);

-- 审核员(role_id=4): 首页 + 用户反馈
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES
(4, 8), (4, 9), (4, 10), (4, 11), (4, 12), (4, 13);

-- 数据分析师(role_id=5): 首页 + 数据统计
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES
(5, 8), (5, 14), (5, 15), (5, 16), (5, 17), (5, 18);

-- 系统管理员(role_id=6): 首页 + 系统管理
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES
(6, 8), (6, 1), (6, 2), (6, 24), (6, 25), (6, 26), (6, 27), (6, 28);

-- 普通学习者(role_id=7): 首页 + AI + 统计 + 激励
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES
(7, 8), (7, 23), (7, 14), (7, 15), (7, 16), (7, 17), (7, 18),
(7, 19), (7, 20), (7, 21), (7, 22);

-- 高级学习者(role_id=8): 普通学习者 + 反馈管理 + 笔记管理
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES
(8, 8), (8, 23), (8, 14), (8, 15), (8, 16), (8, 17), (8, 18),
(8, 19), (8, 20), (8, 21), (8, 22), (8, 9), (8, 10), (8, 13);

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
-- 10. 用户学习进度表
-- ----------------------------
DROP TABLE IF EXISTS `biz_user_progress`;
CREATE TABLE `biz_user_progress` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) DEFAULT NULL COMMENT '用户ID(游客模式下可为空)',
  `card_id` bigint(20) NOT NULL COMMENT '卡片ID',
  `status` tinyint(4) DEFAULT '0' COMMENT '掌握状态(0未学 1模糊 2掌握)',
  `next_review_time` datetime DEFAULT NULL COMMENT '建议下次复习时间(艾宾浩斯逻辑)',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_card` (`user_id`,`card_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户学习进度表';

SET FOREIGN_KEY_CHECKS = 1;