SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ================================================
-- Card Learn 数据库初始化脚本
-- 合并时间: 2026-05-05
-- 包含所有版本的表结构和数据
-- ================================================

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

-- ----------------------------
-- 系统配置表
-- ----------------------------
CREATE TABLE IF NOT EXISTS `sys_config` (
    `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `config_key` varchar(100) NOT NULL COMMENT '配置键',
    `config_value` varchar(500) NOT NULL COMMENT '配置值',
    `config_name` varchar(100) NOT NULL COMMENT '配置名称',
    `config_type` varchar(50) DEFAULT 'string' COMMENT '配置类型(string/number/date/boolean/json)',
    `description` varchar(200) COMMENT '配置描述',
    `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_config_key` (`config_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统配置表';

INSERT INTO `sys_config` (`config_key`, `config_value`, `config_name`, `config_type`, `description`) VALUES
('sprint_exam_date', '2027-12-20', '考研倒计时日期', 'date', '考研冲刺阶段倒计时目标日期'),
('sprint_exam_name', '2027年全国硕士研究生招生考试', '考试名称', 'string', '冲刺阶段考试名称'),
('sprint_enabled', 'true', '冲刺模式开关', 'boolean', '是否启用冲刺模式倒计时显示');

-- ----------------------------
-- 操作日志表
-- ----------------------------
DROP TABLE IF EXISTS `sys_oper_log`;
CREATE TABLE `sys_oper_log` (
  `oper_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `title` varchar(50) DEFAULT '' COMMENT '模块标题',
  `business_type` int(2) DEFAULT '0' COMMENT '业务类型（0其它 1新增 2修改 3删除）',
  `method` varchar(100) DEFAULT '' COMMENT '方法名称',
  `request_method` varchar(10) DEFAULT '' COMMENT '请求方式',
  `operator_type` int(1) DEFAULT '0' COMMENT '操作类别（0其它 1后台用户 2手机端用户）',
  `oper_name` varchar(50) DEFAULT '' COMMENT '操作人员',
  `oper_url` varchar(255) DEFAULT '' COMMENT '请求URL',
  `oper_param` text COMMENT '请求参数',
  `json_result` text COMMENT '返回结果',
  `status` int(1) DEFAULT '0' COMMENT '操作状态（0正常 1异常）',
  `error_msg` varchar(2000) DEFAULT '' COMMENT '错误消息',
  `oper_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (`oper_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='操作日志表';

-- ----------------------------
-- 系统请求日志表
-- ----------------------------
CREATE TABLE IF NOT EXISTS `sys_request_log` (
    `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `request_method` varchar(10) NOT NULL COMMENT '请求方法(GET/POST/PUT/DELETE)',
    `request_url` varchar(500) NOT NULL COMMENT '请求URL',
    `class_name` varchar(200) NOT NULL COMMENT '类名',
    `method_name` varchar(100) NOT NULL COMMENT '方法名',
    `request_params` text COMMENT '请求参数(JSON)',
    `response_result` text COMMENT '响应结果(JSON)',
    `execution_time` bigint NOT NULL DEFAULT 0 COMMENT '执行耗时(毫秒)',
    `status` char(1) NOT NULL DEFAULT '1' COMMENT '执行状态(1成功 0失败)',
    `error_msg` text COMMENT '错误信息',
    `ip_address` varchar(50) COMMENT '请求IP地址',
    `user_id` bigint COMMENT '操作用户ID',
    `user_name` varchar(50) COMMENT '操作用户名',
    `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_request_url` (`request_url`),
    KEY `idx_create_time` (`create_time`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统请求日志表';

-- ----------------------------
-- 标签表结构变更：添加 subject_id 字段
-- ----------------------------
ALTER TABLE `biz_tag` ADD COLUMN `subject_id` bigint(20) DEFAULT NULL COMMENT '所属科目ID(null表示通用标签)' AFTER `tag_name`;
ALTER TABLE `biz_tag` ADD INDEX `idx_subject_id` (`subject_id`);

-- ----------------------------
-- 用户反馈表
-- ----------------------------
DROP TABLE IF EXISTS `biz_feedback`;
CREATE TABLE `biz_feedback` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint(20) DEFAULT NULL COMMENT '用户ID',
  `card_id` bigint(20) DEFAULT NULL COMMENT '关联的卡片ID（若是对具体卡片的纠错）',
  `major_id` bigint(20) DEFAULT NULL COMMENT '所属专业ID',
  `subject_id` bigint(20) DEFAULT NULL COMMENT '所属科目ID',
  `type` varchar(20) NOT NULL COMMENT '反馈类型: SUGGESTION(建议), ERROR(纠错), FUNCTION(功能问题), OTHER(其他)',
  `rating` tinyint(4) DEFAULT NULL COMMENT '评分（1-5星）',
  `content` text NOT NULL COMMENT '反馈详细内容',
  `contact` varchar(100) DEFAULT NULL COMMENT '用户留下的联系方式',
  `images` text DEFAULT NULL COMMENT '图片附件（存储URL列表，JSON格式）',
  `status` char(1) DEFAULT '0' COMMENT '处理状态（0待处理 1已采纳 2已忽略）',
  `admin_reply` text DEFAULT NULL COMMENT '管理员回复内容',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '处理时间',
  `update_user_id` bigint(20) DEFAULT NULL COMMENT '更新人ID',
  PRIMARY KEY (`id`),
  KEY `idx_card_id` (`card_id`),
  KEY `idx_status` (`status`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户反馈表';

-- ----------------------------
-- V2: 用户录入知识卡片审批功能 - 表结构变更
-- Date: 2026-04-24
-- ----------------------------
ALTER TABLE `biz_card` ADD COLUMN `audit_status` char(1) DEFAULT '1' COMMENT '审批状态（0待审批 1已通过 2已拒绝）' AFTER `difficulty_level`;
ALTER TABLE `biz_card` ADD COLUMN `create_user_id` bigint DEFAULT NULL COMMENT '创建用户ID（系统创建为NULL，用户录入则有值）' AFTER `audit_status`;
ALTER TABLE `biz_card` ADD COLUMN `audit_user_id` bigint DEFAULT NULL COMMENT '审批人ID' AFTER `create_user_id`;
ALTER TABLE `biz_card` ADD COLUMN `audit_time` datetime DEFAULT NULL COMMENT '审批时间' AFTER `audit_user_id`;
ALTER TABLE `biz_card` ADD COLUMN `audit_remark` varchar(500) DEFAULT NULL COMMENT '审批备注（拒绝原因等）' AFTER `audit_time`;
ALTER TABLE `biz_card` ADD INDEX `idx_audit_status` (`audit_status`);
ALTER TABLE `biz_card` ADD INDEX `idx_create_user_id` (`create_user_id`);
UPDATE `biz_card` SET `audit_status` = '1' WHERE `audit_status` IS NULL OR `audit_status` = '';

-- ----------------------------
-- V3: 用户录入知识卡片临时表（审批流程）
-- Date: 2026-04-24
-- ----------------------------
DROP TABLE IF EXISTS `biz_card_draft`;
CREATE TABLE `biz_card_draft` (
  `draft_id` bigint NOT NULL AUTO_INCREMENT COMMENT '临时卡片ID',
  `subject_id` bigint NOT NULL COMMENT '所属科目ID',
  `front_content` text NOT NULL COMMENT '卡片正面(支持Markdown/LaTeX)',
  `back_content` text NOT NULL COMMENT '卡片反面(答案/解析)',
  `difficulty_level` tinyint DEFAULT '2' COMMENT '难度系数(1-5)',
  `create_user_id` bigint NOT NULL COMMENT '创建用户ID（小程序用户）',
  `tag_ids` varchar(500) DEFAULT NULL COMMENT '标签ID列表（JSON格式存储）',
  `audit_status` char(1) DEFAULT '0' COMMENT '审批状态（0待审批 1已通过 2已拒绝）',
  `audit_user_id` bigint DEFAULT NULL COMMENT '审批人ID',
  `audit_time` datetime DEFAULT NULL COMMENT '审批时间',
  `audit_remark` varchar(500) DEFAULT NULL COMMENT '审批备注（拒绝原因等）',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`draft_id`),
  KEY `idx_subject_id` (`subject_id`),
  KEY `idx_create_user_id` (`create_user_id`),
  KEY `idx_audit_status` (`audit_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户录入卡片临时表（待审批）';

DROP TABLE IF EXISTS `biz_card_audit_log`;
CREATE TABLE `biz_card_audit_log` (
  `log_id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `draft_id` bigint NOT NULL COMMENT '临时卡片ID',
  `card_id` bigint DEFAULT NULL COMMENT '正式卡片ID（审批通过后生成）',
  `audit_status` char(1) NOT NULL COMMENT '审批状态（1通过 2拒绝）',
  `audit_user_id` bigint NOT NULL COMMENT '审批人ID',
  `audit_remark` varchar(500) DEFAULT NULL COMMENT '审批备注',
  `audit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '审批时间',
  PRIMARY KEY (`log_id`),
  KEY `idx_draft_id` (`draft_id`),
  KEY `idx_card_id` (`card_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='卡片审批历史日志表';

-- ----------------------------
-- V4: 添加更新时间和更新人字段
-- Date: 2026-04-24
-- ----------------------------
ALTER TABLE `biz_card`
ADD COLUMN `update_user_id` bigint DEFAULT NULL COMMENT '更新人ID' AFTER `update_time`;

ALTER TABLE `biz_card_draft`
ADD COLUMN `update_user_id` bigint DEFAULT NULL COMMENT '更新人ID' AFTER `update_time`;

ALTER TABLE `biz_card_audit_log`
ADD COLUMN `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间' AFTER `audit_time`,
ADD COLUMN `update_user_id` bigint DEFAULT NULL COMMENT '更新人ID' AFTER `update_time`;

ALTER TABLE `biz_card_tag`
ADD COLUMN `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间' AFTER `tag_id`,
ADD COLUMN `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间' AFTER `create_time`,
ADD COLUMN `update_user_id` bigint DEFAULT NULL COMMENT '更新人ID' AFTER `update_time`;

ALTER TABLE `biz_subject`
ADD COLUMN `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间' AFTER `order_num`,
ADD COLUMN `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间' AFTER `create_time`,
ADD COLUMN `update_user_id` bigint DEFAULT NULL COMMENT '更新人ID' AFTER `update_time`;

ALTER TABLE `biz_major`
ADD COLUMN `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间' AFTER `status`,
ADD COLUMN `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间' AFTER `create_time`,
ADD COLUMN `update_user_id` bigint DEFAULT NULL COMMENT '更新人ID' AFTER `update_time`;

ALTER TABLE `sys_user`
ADD COLUMN `update_user_id` bigint DEFAULT NULL COMMENT '更新人ID' AFTER `update_time`;

ALTER TABLE `sys_app_user`
ADD COLUMN `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间' AFTER `create_time`,
ADD COLUMN `update_user_id` bigint DEFAULT NULL COMMENT '更新人ID' AFTER `update_time`;

ALTER TABLE `biz_feedback`
ADD COLUMN `update_user_id` bigint DEFAULT NULL COMMENT '更新人ID' AFTER `update_time`;

ALTER TABLE `biz_card` ADD INDEX `idx_update_user_id` (`update_user_id`);
ALTER TABLE `biz_card_draft` ADD INDEX `idx_update_user_id` (`update_user_id`);
ALTER TABLE `biz_subject` ADD INDEX `idx_update_user_id` (`update_user_id`);
ALTER TABLE `biz_major` ADD INDEX `idx_update_user_id` (`update_user_id`);

-- ----------------------------
-- V5: 闪卡评论表
-- Date: 2026-04-25
-- ----------------------------
CREATE TABLE IF NOT EXISTS `biz_card_comment` (
    `comment_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '评论ID',
    `card_id` BIGINT NOT NULL COMMENT '卡片ID',
    `app_user_id` BIGINT NOT NULL COMMENT '用户ID',
    `user_nickname` VARCHAR(50) DEFAULT NULL COMMENT '用户昵称（冗余字段）',
    `content` TEXT NOT NULL COMMENT '评论内容',
    `rating` INT DEFAULT 5 COMMENT '评分（1-5星）',
    `comment_type` VARCHAR(20) NOT NULL DEFAULT 'NEUTRAL' COMMENT '评论类型：QUALITY(优质内容)/POOR(劣质内容)/NEUTRAL(中性)',
    `status` VARCHAR(2) DEFAULT '0' COMMENT '状态：0正常 1已处理 2已隐藏',
    `admin_reply` TEXT DEFAULT NULL COMMENT '管理员回复',
    `feedback_id` BIGINT DEFAULT NULL COMMENT '关联的反馈ID（劣质评论自动生成反馈时）',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`comment_id`),
    INDEX `idx_card_id` (`card_id`),
    INDEX `idx_app_user_id` (`app_user_id`),
    INDEX `idx_comment_type` (`comment_type`),
    INDEX `idx_feedback_id` (`feedback_id`),
    INDEX `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='闪卡评论表';

CREATE OR REPLACE VIEW `v_card_comment_stats` AS
SELECT
    card_id,
    COUNT(*) AS total_comments,
    SUM(CASE WHEN comment_type = 'QUALITY' THEN 1 ELSE 0 END) AS quality_count,
    SUM(CASE WHEN comment_type = 'POOR' THEN 1 ELSE 0 END) AS poor_count,
    AVG(rating) AS avg_rating
FROM biz_card_comment
WHERE status = '0'
GROUP BY card_id;

-- ----------------------------
-- V6: 合并 sys_app_user 到 sys_user，统一用户表
-- Date: 2026-04-27
-- ----------------------------
ALTER TABLE `biz_user_progress` CHANGE COLUMN `app_user_id` `user_id` BIGINT DEFAULT NULL COMMENT '用户ID';
ALTER TABLE `biz_user_progress` DROP INDEX `idx_user_card`;
ALTER TABLE `biz_user_progress` ADD INDEX `idx_user_card` (`user_id`, `card_id`);

ALTER TABLE `biz_feedback` CHANGE COLUMN `app_user_id` `user_id` BIGINT DEFAULT NULL COMMENT '用户ID';
ALTER TABLE `biz_feedback` DROP INDEX `idx_app_user_id`;
ALTER TABLE `biz_feedback` ADD INDEX `idx_user_id` (`user_id`);

ALTER TABLE `biz_card_comment` CHANGE COLUMN `app_user_id` `user_id` BIGINT NOT NULL COMMENT '用户ID';
ALTER TABLE `biz_card_comment` DROP INDEX `idx_app_user_id`;
ALTER TABLE `biz_card_comment` ADD INDEX `idx_user_id` (`user_id`);

-- ----------------------------
-- V7: 学习历史记录表
-- Date: 2026-04-30
-- ----------------------------
CREATE TABLE biz_study_history (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT COMMENT '用户ID',
  card_id BIGINT NOT NULL COMMENT '卡片ID',
  status TINYINT NOT NULL COMMENT '状态: 0=未学, 1=模糊, 2=掌握',
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '学习时间',
  INDEX idx_user_card (user_id, card_id),
  INDEX idx_user_status (user_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学习历史记录表';

-- ----------------------------
-- V8: 为 biz_user_progress 表添加 SM-2 算法字段
-- Date: 2026-05-04
-- ----------------------------
ALTER TABLE `biz_user_progress`
  ADD COLUMN `ease_factor` DOUBLE DEFAULT 2.5 COMMENT 'SM-2容易系数' AFTER `status`,
  ADD COLUMN `repetitions` INT DEFAULT 0 COMMENT 'SM-2连续正确次数' AFTER `ease_factor`,
  ADD COLUMN `interval_days` INT DEFAULT 1 COMMENT 'SM-2复习间隔天数' AFTER `repetitions`;

-- ----------------------------
-- V9: biz_feedback 表添加 major_id、subject_id、update_user_id 字段
-- Date: 2026-05-04
-- 注意: 这些字段已在 biz_feedback 表创建时添加，此处保留兼容
-- ----------------------------
-- ALTER TABLE `biz_feedback` ADD COLUMN `major_id` bigint(20) DEFAULT NULL COMMENT '所属专业ID' AFTER `card_id`;
-- ALTER TABLE `biz_feedback` ADD COLUMN `subject_id` bigint(20) DEFAULT NULL COMMENT '所属科目ID' AFTER `major_id`;
-- ALTER TABLE `biz_feedback` ADD COLUMN `update_user_id` bigint(20) DEFAULT NULL COMMENT '更新人ID' AFTER `update_time`;

-- ----------------------------
-- V10: 统一所有表的 user_id 字段名 + 添加缺失列
-- Date: 2026-05-04
-- 注意: V6已执行过app_user_id到user_id的迁移，此处保留兼容
-- ----------------------------
-- ALTER TABLE `biz_feedback` CHANGE COLUMN `app_user_id` `user_id` BIGINT DEFAULT NULL COMMENT '用户ID';
-- ALTER TABLE `biz_feedback` DROP INDEX `idx_app_user_id`;
-- ALTER TABLE `biz_feedback` ADD INDEX `idx_user_id` (`user_id`);
-- ALTER TABLE `biz_feedback` ADD COLUMN `major_id` bigint(20) DEFAULT NULL COMMENT '所属专业ID' AFTER `card_id`;
-- ALTER TABLE `biz_feedback` ADD COLUMN `subject_id` bigint(20) DEFAULT NULL COMMENT '所属科目ID' AFTER `major_id`;
-- ALTER TABLE `biz_feedback` ADD COLUMN `update_user_id` bigint(20) DEFAULT NULL COMMENT '更新人ID' AFTER `update_time';

-- ALTER TABLE `biz_user_progress` CHANGE COLUMN `app_user_id` `user_id` BIGINT DEFAULT NULL COMMENT '用户ID';
-- ALTER TABLE `biz_user_progress` DROP INDEX `idx_user_card`;
-- ALTER TABLE `biz_user_progress` ADD INDEX `idx_user_card` (`user_id`, `card_id`);
-- ALTER TABLE `biz_user_progress` ADD COLUMN `ease_factor` DOUBLE DEFAULT 2.5 COMMENT 'SM-2容易系数' AFTER `status`;
-- ALTER TABLE `biz_user_progress` ADD COLUMN `repetitions` INT DEFAULT 0 COMMENT 'SM-2连续正确次数' AFTER `ease_factor`;
-- ALTER TABLE `biz_user_progress` ADD COLUMN `interval_days` INT DEFAULT 1 COMMENT 'SM-2复习间隔天数' AFTER `repetitions`;

-- ALTER TABLE `biz_card_comment` CHANGE COLUMN `app_user_id` `user_id` BIGINT NOT NULL COMMENT '用户ID';
-- ALTER TABLE `biz_card_comment` DROP INDEX `idx_app_user_id`;
-- ALTER TABLE `biz_card_comment` ADD INDEX `idx_user_id` (`user_id`);

-- ----------------------------
-- V11: 评论回复、点赞、笔记功能
-- Date: 2026-05-04
-- ----------------------------
ALTER TABLE `biz_card_comment` ADD COLUMN `is_note` TINYINT(1) DEFAULT 0 COMMENT '是否作为笔记：0否 1是' AFTER `feedback_id`;
ALTER TABLE `biz_card_comment` ADD COLUMN `like_count` INT DEFAULT 0 COMMENT '点赞数（冗余）' AFTER `is_note`;
ALTER TABLE `biz_card_comment` ADD COLUMN `reply_count` INT DEFAULT 0 COMMENT '回复数量（冗余）' AFTER `like_count`;

CREATE TABLE IF NOT EXISTS `biz_card_reply` (
    `reply_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '回复ID',
    `comment_id` BIGINT NOT NULL COMMENT '所属评论ID',
    `card_id` BIGINT NOT NULL COMMENT '卡片ID（冗余）',
    `user_id` BIGINT NOT NULL COMMENT '回复用户ID',
    `user_nickname` VARCHAR(50) DEFAULT NULL COMMENT '回复用户昵称（冗余）',
    `content` TEXT NOT NULL COMMENT '回复内容',
    `like_count` INT DEFAULT 0 COMMENT '点赞数（冗余）',
    `parent_reply_id` BIGINT DEFAULT NULL COMMENT '父回复ID（null=第1层）',
    `status` VARCHAR(1) DEFAULT '0' COMMENT '状态：0正常 1已删除',
    `create_by` BIGINT DEFAULT NULL COMMENT '创建人',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `update_by` BIGINT DEFAULT NULL COMMENT '修改人',
    PRIMARY KEY (`reply_id`),
    INDEX `idx_comment_id` (`comment_id`),
    INDEX `idx_card_id` (`card_id`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_parent_reply_id` (`parent_reply_id`),
    INDEX `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='评论回复表';

CREATE TABLE IF NOT EXISTS `biz_comment_like` (
    `like_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '点赞ID',
    `comment_id` BIGINT DEFAULT NULL COMMENT '评论ID',
    `reply_id` BIGINT DEFAULT NULL COMMENT '回复ID',
    `user_id` BIGINT NOT NULL COMMENT '点赞用户ID',
    `create_by` BIGINT DEFAULT NULL COMMENT '创建人',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `update_by` BIGINT DEFAULT NULL COMMENT '修改人',
    PRIMARY KEY (`like_id`),
    UNIQUE INDEX `uk_comment_user` (`comment_id`, `user_id`),
    UNIQUE INDEX `uk_reply_user` (`reply_id`, `user_id`),
    INDEX `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='评论/回复点赞表';

-- ----------------------------
-- V12: 删除 sys_app_user 表，统一使用 sys_user
-- Date: 2026-05-04
-- ----------------------------
DROP TABLE IF EXISTS `sys_app_user`;

-- ----------------------------
-- V13: 添加 like_type 和 dislike_count 字段
-- Date: 2026-05-04
-- ----------------------------
ALTER TABLE `biz_comment_like` ADD COLUMN `like_type` TINYINT(1) NOT NULL DEFAULT 1
    COMMENT '1=喜欢 2=不喜欢' AFTER `user_id`;

ALTER TABLE `biz_card_comment` ADD COLUMN `dislike_count` INT DEFAULT 0
    COMMENT '不喜欢数' AFTER `like_count`;

ALTER TABLE `biz_card_reply` ADD COLUMN `dislike_count` INT DEFAULT 0
    COMMENT '不喜欢数' AFTER `like_count`;

-- ----------------------------
-- V14: 激励系统数据库表结构
-- Date: 2026-05-05
-- ----------------------------
CREATE TABLE IF NOT EXISTS `biz_achievement` (
  `achievement_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '成就ID',
  `achievement_code` VARCHAR(64) NOT NULL COMMENT '成就代码(唯一标识)',
  `name` VARCHAR(64) NOT NULL COMMENT '成就名称',
  `description` VARCHAR(255) DEFAULT NULL COMMENT '成就描述',
  `icon` VARCHAR(128) DEFAULT NULL COMMENT '成就图标(Unicode或SF Symbols)',
  `tier` TINYINT NOT NULL DEFAULT 1 COMMENT '等级(1铜牌2银牌3金牌4钻石)',
  `category` VARCHAR(32) NOT NULL COMMENT '分类(streak/count/subject/social)',
  `condition_type` VARCHAR(32) NOT NULL COMMENT '条件类型(streak_days/learn_count/master_count/review_count/comment_count/contribute_count)',
  `condition_value` INT NOT NULL DEFAULT 0 COMMENT '条件值',
  `exp_reward` INT NOT NULL DEFAULT 0 COMMENT '奖励经验值',
  `sort_order` INT NOT NULL DEFAULT 0 COMMENT '排序',
  `enabled` TINYINT NOT NULL DEFAULT 1 COMMENT '是否启用(0禁用1启用)',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`achievement_id`),
  UNIQUE KEY `uk_code` (`achievement_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='成就定义表';

CREATE TABLE IF NOT EXISTS `biz_user_achievement` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `achievement_id` BIGINT NOT NULL COMMENT '成就ID',
  `achievement_code` VARCHAR(64) NOT NULL COMMENT '成就代码',
  `achieved_at` DATETIME NOT NULL COMMENT '获得时间',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_achievement_id` (`achievement_id`),
  UNIQUE KEY `uk_user_achievement` (`user_id`, `achievement_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户成就记录表';

CREATE TABLE IF NOT EXISTS `biz_user_level` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `level` INT NOT NULL DEFAULT 1 COMMENT '当前等级',
  `current_exp` INT NOT NULL DEFAULT 0 COMMENT '当前等级经验',
  `total_exp` INT NOT NULL DEFAULT 0 COMMENT '累计获得经验',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户等级表';

CREATE TABLE IF NOT EXISTS `biz_exp_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `exp_change` INT NOT NULL COMMENT '经验变化(正数增加)',
  `source_type` VARCHAR(32) NOT NULL COMMENT '来源类型(STUDY/MASTER/REVIEW/GOAL/ACHIEVEMENT/COMMENT/CONTRIBUTE)',
  `source_id` VARCHAR(64) DEFAULT NULL COMMENT '来源ID(如卡片ID)',
  `description` VARCHAR(128) DEFAULT NULL COMMENT '变动描述',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='经验值变动日志表';

CREATE TABLE IF NOT EXISTS `biz_learning_goal` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `goal_type` VARCHAR(16) NOT NULL COMMENT '目标类型(daily_learn/daily_master)',
  `target_count` INT NOT NULL DEFAULT 20 COMMENT '目标数量',
  `enabled` TINYINT NOT NULL DEFAULT 1 COMMENT '是否启用(0禁用1启用)',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_goal_type` (`user_id`, `goal_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户学习目标表';

CREATE TABLE IF NOT EXISTS `biz_goal_record` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `goal_date` DATE NOT NULL COMMENT '目标日期',
  `goal_type` VARCHAR(16) NOT NULL COMMENT '目标类型',
  `target_count` INT NOT NULL COMMENT '目标数量',
  `actual_count` INT NOT NULL DEFAULT 0 COMMENT '实际完成',
  `completed` TINYINT NOT NULL DEFAULT 0 COMMENT '是否完成(0未完成1完成)',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_date_type` (`user_id`, `goal_date`, `goal_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='每日目标完成记录表';

CREATE TABLE IF NOT EXISTS `biz_user_daily_count` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `count_date` DATE NOT NULL COMMENT '统计日期',
  `learn_count` INT NOT NULL DEFAULT 0 COMMENT '当日学习卡片数',
  `master_count` INT NOT NULL DEFAULT 0 COMMENT '当日掌握卡片数',
  `review_count` INT NOT NULL DEFAULT 0 COMMENT '当日复习卡片数',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_date` (`user_id`, `count_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户每日学习计数表';

INSERT INTO `biz_achievement` (`achievement_code`, `name`, `description`, `icon`, `tier`, `category`, `condition_type`, `condition_value`, `exp_reward`, `sort_order`) VALUES
('FIRST_LEARN', '初次学习', '完成第一次卡片学习', 'book.fill', 1, 'count', 'learn_count', 1, 10, 1),
('FIRST_MASTER', '初次掌握', '掌握第一张卡片', 'star.fill', 1, 'count', 'master_count', 1, 15, 2),
('FIRST_REVIEW', '初次复习', '完成第一次复习', 'arrow.clockwise', 1, 'count', 'review_count', 1, 5, 3),
('FIRST_COMMENT', '初发议论', '首次评论卡片', 'bubble.left.fill', 1, 'social', 'comment_count', 1, 10, 4);

INSERT INTO `biz_achievement` (`achievement_code`, `name`, `description`, `icon`, `tier`, `category`, `condition_type`, `condition_value`, `exp_reward`, `sort_order`) VALUES
('STREAK_3', '初露锋芒', '连续学习3天', 'flame', 1, 'streak', 'streak_days', 3, 30, 10),
('STREAK_7', '持之以恒', '连续学习7天', 'flame.fill', 2, 'streak', 'streak_days', 7, 80, 11),
('STREAK_14', '坚持不懈', '连续学习14天', 'bolt.fill', 2, 'streak', 'streak_days', 14, 150, 12),
('STREAK_30', '锲而不舍', '连续学习30天', 'flame.circle.fill', 3, 'streak', 'streak_days', 30, 300, 13),
('STREAK_60', '悬梁刺股', '连续学习60天', 'crown.fill', 3, 'streak', 'streak_days', 60, 600, 14),
('STREAK_100', '学业有成', '连续学习100天', 'crown.circle.fill', 4, 'streak', 'streak_days', 100, 1000, 15);

INSERT INTO `biz_achievement` (`achievement_code`, `name`, `description`, `icon`, `tier`, `category`, `condition_type`, `condition_value`, `exp_reward`, `sort_order`) VALUES
('LEARN_50', '学而时习', '累计学习50张卡片', 'book', 1, 'count', 'learn_count', 50, 30, 20),
('LEARN_100', '学而不厌', '累计学习100张卡片', 'books.vertical.fill', 1, 'count', 'learn_count', 100, 50, 21),
('LEARN_300', '力学笃行', '累计学习300张卡片', 'graduationcap.fill', 2, 'count', 'learn_count', 300, 150, 22),
('LEARN_500', '博学多识', '累计学习500张卡片', 'brain.head.profile', 2, 'count', 'learn_count', 500, 250, 23),
('LEARN_1000', '学富五车', '累计学习1000张卡片', 'book.circle.fill', 3, 'count', 'learn_count', 1000, 500, 24);

INSERT INTO `biz_achievement` (`achievement_code`, `name`, `description`, `icon`, `tier`, `category`, `condition_type`, `condition_value`, `exp_reward`, `sort_order`) VALUES
('MASTER_10', '初窥门径', '累计掌握10张卡片', 'star', 1, 'count', 'master_count', 10, 30, 30),
('MASTER_50', '小有所成', '累计掌握50张卡片', 'star.fill', 1, 'count', 'master_count', 50, 100, 31),
('MASTER_100', '融会贯通', '累计掌握100张卡片', 'star.circle.fill', 2, 'count', 'master_count', 100, 200, 32),
('MASTER_300', '学有小成', '累计掌握300张卡片', 'sparkles', 2, 'count', 'master_count', 300, 450, 33),
('MASTER_500', '学贯中西', '累计掌握500张卡片', 'star.square.fill', 3, 'count', 'master_count', 500, 750, 34);

INSERT INTO `biz_achievement` (`achievement_code`, `name`, `description`, `icon`, `tier`, `category`, `condition_type`, `condition_value`, `exp_reward`, `sort_order`) VALUES
('SUBJECT_FIRST', '学科入门', '完成任意科目第一张卡片学习', 'bookmark.fill', 1, 'subject', 'subject_first', 1, 20, 40),
('SUBJECT_LEARN_ALL', '学无遗阙', '学习某科目全部卡片', 'checkmark.seal.fill', 2, 'subject', 'subject_learn_rate', 100, 200, 41),
('SUBJECT_MASTER_HALF', '半壁江山', '掌握某科目50%以上卡片', 'chart.pie.fill', 2, 'subject', 'subject_master_rate', 50, 150, 42),
('SUBJECT_MASTER_ALL', '学科全通', '掌握某科目全部卡片', 'checkmark.seal.circle.fill', 3, 'subject', 'subject_master_rate', 100, 500, 43);

INSERT INTO `biz_achievement` (`achievement_code`, `name`, `description`, `icon`, `tier`, `category`, `condition_type`, `condition_value`, `exp_reward`, `sort_order`) VALUES
('FIRST_CONTRIBUTE', '初次投稿', '首次提交卡片', 'square.and.pencil', 1, 'social', 'contribute_count', 1, 30, 50),
('CONTRIBUTE_ADOPTED', '稿件采纳', '投稿被采纳', 'checkmark.circle.fill', 2, 'social', 'contribute_adopted', 1, 100, 51),
('FIRST_CORRECTION', '捉虫大师', '首次纠错被采纳', 'ant.fill', 1, 'social', 'correction_adopted', 1, 50, 52);

-- ----------------------------
-- V15: 学习报告功能 - 新增表
-- Date: 2026-05-05
-- ----------------------------
CREATE TABLE IF NOT EXISTS `biz_learning_report` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `report_type` varchar(10) NOT NULL COMMENT '报告类型: weekly/monthly',
  `period_start` date NOT NULL COMMENT '统计周期开始日期',
  `period_end` date NOT NULL COMMENT '统计周期结束日期',
  `report_data` longtext COMMENT '报告数据JSON',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_type` (`user_id`, `report_type`),
  KEY `idx_period` (`period_start`, `period_end`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学习报告表';

CREATE TABLE IF NOT EXISTS `biz_weak_point` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `card_id` bigint(20) NOT NULL COMMENT '卡片ID',
  `error_count` int(11) DEFAULT 1 COMMENT '错误次数',
  `last_error_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最后错误时间',
  `status` varchar(10) DEFAULT 'active' COMMENT '状态: active/reviewed',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_card` (`user_id`, `card_id`),
  KEY `idx_error_count` (`error_count` DESC),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='薄弱点记录表';

CREATE TABLE IF NOT EXISTS `biz_daily_stats_snapshot` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `stats_date` date NOT NULL COMMENT '统计日期',
  `total_cards` int(11) DEFAULT 0 COMMENT '当日学习卡片数',
  `new_mastered` int(11) DEFAULT 0 COMMENT '当日新掌握卡片数',
  `forgotten` int(11) DEFAULT 0 COMMENT '当日遗忘卡片数',
  `study_duration` int(11) DEFAULT 0 COMMENT '当日学习时长(分钟)',
  `mastery_rate` decimal(5,2) DEFAULT 0.00 COMMENT '当日掌握率',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_date` (`user_id`, `stats_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='每日学习统计快照';

-- ----------------------------
-- 模拟数据插入脚本
-- ----------------------------
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('时间复杂度', 1);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('空间复杂度', 1);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('排序算法', 1);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('查找算法', 1);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('树', 1);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('图', 1);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('Cache', 2);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('中断', 2);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('DMA', 2);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('浮点数', 2);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('流水线', 2);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('PV操作', 3);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('进程调度', 3);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('内存管理', 3);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('死锁', 3);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('文件系统', 3);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('TCP', 4);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('UDP', 4);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('IP协议', 4);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('HTTP', 4);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('滑动窗口', 4);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(1, '什么是时间复杂度？如何计算算法的时间复杂度？', '时间复杂度是衡量算法运行时间随输入规模增长的变化趋势的指标。\n\n计算方法：\n1. 找出算法中的基本操作（最深层循环内的操作）\n2. 计算基本操作执行的次数与输入规模n的关系\n3. 取最高阶项，忽略低阶项和常数系数\n\n常见时间复杂度：O(1) < O(logn) < O(n) < O(nlogn) < O(n²) < O(n³) < O(2^n)', 2);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(1, '快速排序的基本思想和时间复杂度是什么？', '基本思想：分治法\n1. 选取一个基准元素(pivot)\n2. 将数组分为两部分：小于pivot的放左边，大于pivot的放右边\n3. 递归地对左右两部分进行排序\n\n时间复杂度：\n- 平均情况：O(nlogn)\n- 最坏情况：O(n²)（每次选取的pivot都是最大或最小元素）\n- 最好情况：O(nlogn)\n\n空间复杂度：O(logn)（递归调用栈）', 3);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(1, '什么是哈希表？如何解决哈希冲突？', '哈希表：根据关键码值(Key value)直接进行访问的数据结构，通过哈希函数将键映射到数组索引。\n\n解决哈希冲突的方法：\n1. **开放定址法**：线性探测、二次探测、双重哈希\n2. **链地址法**：将冲突的元素用链表连接\n3. **再哈希法**：使用多个哈希函数\n4. **建立公共溢出区**：将冲突元素存放到溢出区\n\n链地址法是最常用的方法，Java的HashMap就采用此方法。', 3);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(1, '二叉树的遍历方式有哪些？各自的实现方式？', '四种主要遍历方式：\n\n1. **前序遍历**（根-左-右）：递归、栈实现\n2. **中序遍历**（左-根-右）：递归、栈实现\n3. **后序遍历**（左-右-根）：递归、栈实现\n4. **层序遍历**（按层次）：队列实现\n\n非递归实现关键：\n- 前序/中序：用栈，入栈顺序不同\n- 后序：需要记录上一个访问的节点\n- 层序：用队列，先进先出', 2);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(1, '什么是红黑树？它的性质有哪些？', '红黑树是一种自平衡的二叉搜索树，保证在最坏情况下基本操作的时间复杂度为O(logn)。\n\n五大性质：\n1. 每个节点是红色或黑色\n2. 根节点是黑色\n3. 所有叶子节点（NIL）是黑色\n4. 红色节点的两个子节点都是黑色（不能有连续的红色节点）\n5. 从任一节点到其每个叶子的所有路径包含相同数量的黑色节点\n\n应用：Java的TreeMap、TreeSet、HashMap在链表长度>8时转为红黑树', 4);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(1, '图的最短路径算法有哪些？Dijkstra算法的原理？', '最短路径算法：\n1. **Dijkstra**：单源最短路径，不含负权边\n2. **Bellman-Ford**：单源最短路径，含负权边\n3. **Floyd**：多源最短路径\n4. **SPFA**：Bellman-Ford的优化\n\nDijkstra原理：\n1. 初始化：起点距离为0，其他为无穷大\n2. 选择距离最小的未访问节点\n3. 更新其邻居节点的距离\n4. 标记该节点为已访问\n5. 重复2-4直到所有节点访问完\n\n时间复杂度：O(V²)或O(ElogV)（用优先队列优化）', 4);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(2, '什么是Cache？Cache的工作原理是什么？', 'Cache（高速缓存）是位于CPU和主存之间的小容量高速存储器。\n\n工作原理：\n1. **局部性原理**：时间局部性（最近访问的数据可能再次访问）、空间局部性（访问位置附近的数据可能被访问）\n2. CPU访问数据时，先查Cache，命中则直接获取；未命中则从主存获取并调入Cache\n\n映射方式：\n- 直接映射：每个主存块只能映射到一个特定Cache行\n- 全相联映射：主存块可映射到任意Cache行\n- 组相联映射：主存块可映射到特定组中的任意行\n\n命中率计算：命中率 = 命中次数 / 总访问次数', 3);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(2, '什么是中断？中断处理的过程是怎样的？', '中断：CPU暂停当前程序，转去处理突发事件，处理完后返回继续执行。\n\n中断处理过程：\n1. **中断请求**：外设向CPU发出中断信号\n2. **中断响应**：CPU在指令周期末检查中断信号\n3. **保护现场**：保存PC、PSW等寄存器\n4. **中断识别**：确定中断源（向量中断或查询中断）\n5. **执行中断服务程序**：处理中断事件\n6. **恢复现场**：恢复保存的寄存器\n7. **中断返回**：返回原程序继续执行\n\n中断类型：硬中断（外设）、软中断（系统调用）、异常（程序错误）', 3);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(2, 'DMA的工作原理是什么？与中断方式的区别？', 'DMA（直接存储器访问）：允许外设直接与主存交换数据，无需CPU干预。\n\n工作原理：\n1. CPU初始化DMA控制器（源地址、目标地址、数据量）\n2. DMA控制器接管总线，直接进行数据传输\n3. 传输完成后，DMA向CPU发送中断信号\n4. CPU处理后续工作\n\n与中断方式的区别：\n- 中断：每次传输一个数据单位就需要CPU干预\n- DMA：批量传输，CPU只需在开始和结束时干预\n\nDMA适用场景：磁盘I/O、网络传输等大量数据传输', 4);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(2, '浮点数的表示方法是什么？IEEE 754标准？', '浮点数表示：N = M × 2^E\n- M：尾数（mantissa），表示精度\n- E：阶码（exponent），表示范围\n\nIEEE 754标准格式：\n- **符号位S**：1位，0正1负\n- **阶码E**：采用移码表示，偏置值=127（32位）或1023（64位）\n- **尾数M**：采用原码表示，隐含最高位1\n\n32位浮点数(float)：\n- S(1位) + E(8位) + M(23位)\n- 范围约：±3.4×10^38\n\n64位浮点数(double)：\n- S(1位) + E(11位) + M(52位)\n- 范围约：±1.8×10^308', 4);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(2, '流水线技术的基本原理？流水线的性能指标？', '流水线技术：将指令执行过程分解为多个阶段，各阶段并行工作。\n\n典型5级流水线：\n1. IF（取指）\n2. ID（译码）\n3. EX（执行）\n4. MEM（访存）\n5. WB（写回）\n\n性能指标：\n- **吞吐率**：单位时间完成的指令数 TP = n / Tk\n- **加速比**：S = T顺序 / T流水\n- **效率**：E = 有效时空区 / 总时空区\n\n流水线冲突：\n1. 结构冲突：资源冲突\n2. 数据冲突：数据依赖\n3. 控制冲突：分支指令\n\n解决方法：暂停、转发、预测', 4);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(3, '什么是PV操作？如何使用PV操作实现互斥？', 'PV操作是信号量的两种基本操作，用于进程同步与互斥。\n\n**P操作（wait）**：\n- S.value--\n- 若S.value < 0，进程阻塞，放入等待队列\n\n**V操作（signal）**：\n- S.value++\n- 若S.value <= 0，唤醒等待队列中的一个进程\n\n实现互斥：\n```\nsemaphore mutex = 1;\nP1: P(mutex); 临界区; V(mutex);\nP2: P(mutex); 临界区; V(mutex);\n```\n\n注意：PV操作必须成对出现，P在临界区前，V在临界区后。', 3);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(3, '进程调度算法有哪些？各自的优缺点？', '常见进程调度算法：\n\n1. **FCFS（先来先服务）**：简单但可能导致"护航效应"\n\n2. **SJF/SPF（短作业优先）**：平均等待时间最短，但需要预知作业长度\n\n3. **SRTN（最短剩余时间优先）**：SJF的抢占版本\n\n4. **RR（时间片轮转）**：公平，适合分时系统，时间片大小影响性能\n\n5. **优先级调度**：可抢占或非抢占，可能导致低优先级进程"饥饿"\n\n6. **多级反馈队列**：综合多种算法，动态调整优先级和时间片\n\n评价标准：CPU利用率、吞吐量、周转时间、等待时间、响应时间', 3);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(3, '虚拟内存的基本原理？页面置换算法有哪些？', '虚拟内存：将部分进程数据装入内存，其余放在磁盘，需要时调入。\n\n基本原理：\n1. **分页**：将进程和内存划分为固定大小的页和页框\n2. **页表**：记录页与页框的映射关系\n3. **TLB**：快表，加速地址转换\n4. **缺页中断**：访问的页不在内存时触发\n\n页面置换算法：\n1. **OPT（最优）**：置换未来最长时间不使用的页（理论算法）\n2. **FIFO**：置换最早进入的页，可能出现Belady异常\n3. **LRU**：置换最近最少使用的页\n4. **Clock**：LRU的近似实现，用访问位\n5. **LFU**：置换访问次数最少的页', 4);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(3, '什么是死锁？死锁的四个必要条件？如何预防？', '死锁：多个进程因争夺资源而互相等待，导致都无法继续执行。\n\n**四个必要条件**（必须同时满足）：\n1. **互斥条件**：资源不能共享\n2. **请求与保持条件**：进程持有资源同时请求新资源\n3. **不剥夺条件**：已获得的资源不能被强制抢占\n4. **循环等待条件**：存在进程资源的循环等待链\n\n**预防策略**：\n1. 破坏互斥：不易实现\n2. 破坏请求与保持：一次性申请所有资源\n3. 破坏不剥夺：资源可被抢占\n4. 破坏循环等待：资源有序分配\n\n**避免**：银行家算法\n**检测与恢复**：定期检测，剥夺资源或撤销进程', 4);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(3, '文件系统的实现方式？inode是什么？', '文件系统实现方式：\n\n1. **连续分配**：文件占用连续磁盘块\n   - 优点：访问快\n   - 缺点：外部碎片、文件大小固定\n\n2. **链接分配**：每个块包含指向下一块的指针\n   - 优点：无外部碎片\n   - 缺点：随机访问慢、指针占用空间\n\n3. **索引分配**：使用索引块记录所有数据块位置\n   - 优点：支持随机访问\n   - 缺点：索引块开销\n\n**inode（索引节点）**：\n- 存储文件的元数据（权限、时间、大小等）\n- 包含指向数据块的指针\n- 文件名存储在目录项中，inode存储文件内容信息\n\nLinux中：df -i查看inode使用情况', 3);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(4, 'TCP三次握手的过程？为什么需要三次握手？', 'TCP三次握手过程：\n\n1. **第一次**：客户端发送SYN=1，seq=x，进入SYN_SENT状态\n2. **第二次**：服务器回复SYN=1，ACK=1，seq=y，ack=x+1，进入SYN_RCVD状态\n3. **第三次**：客户端发送ACK=1，seq=x+1，ack=y+1，双方进入ESTABLISHED状态\n\n**为什么需要三次握手**：\n1. 防止已失效的连接请求突然到达服务器，导致错误建立连接\n2. 同步双方的初始序列号\n3. 确认双方的接收和发送能力\n\n如果是两次握手，服务器无法确认客户端是否收到自己的SYN。', 3);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(4, 'TCP四次挥手的过程？为什么需要四次？', 'TCP四次挥手过程：\n\n1. **第一次**：客户端发送FIN=1，seq=u，进入FIN_WAIT_1状态\n2. **第二次**：服务器回复ACK=1，ack=u+1，进入CLOSE_WAIT状态；客户端进入FIN_WAIT_2\n3. **第三次**：服务器发送FIN=1，seq=w，进入LAST_ACK状态\n4. **第四次**：客户端回复ACK=1，ack=w+1，进入TIME_WAIT状态（等待2MSL后关闭）；服务器关闭\n\n**为什么需要四次挥手**：\n- TCP是全双工通信，每个方向的关闭需要单独进行\n- 服务器收到FIN后可能还有数据要发送，不能立即关闭\n\n**TIME_WAIT作用**：\n1. 确保ACK到达服务器\n2. 等待旧连接的数据在网络中消失', 3);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(4, 'TCP与UDP的区别？各自的适用场景？', 'TCP vs UDP区别：\n\n| 特性 | TCP | UDP |\n|------|-----|-----|\n| 连接 | 面向连接 | 无连接 |\n| 可靠性 | 可靠传输 | 尽力交付 |\n| 流量控制 | 有（滑动窗口） | 无 |\n| 拥塞控制 | 有 | 无 |\n| 传输方式 | 字节流 | 报文 |\n| 首部开销 | 20字节 | 8字节 |\n| 速度 | 较慢 | 较快 |\n\n**TCP适用场景**：需要可靠传输的应用\n- HTTP、FTP、SMTP、SSH\n\n**UDP适用场景**：实时性强、容忍少量丢包的应用\n- DNS、DHCP、TFTP\n- 视频会议、直播、游戏\n- SNMP', 2);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(4, 'OSI七层模型和TCP/IP四层模型的对应关系？', 'OSI七层模型与TCP/IP四层模型：\n\n| OSI七层 | TCP/IP四层 | 功能 | 协议示例 |\n|---------|------------|------|----------|\n| 应用层 | 应用层 | 用户交互 | HTTP、FTP、DNS |\n| 表示层 | | 数据格式转换 | SSL/TLS |\n| 会话层 | | 会话管理 | RPC |\n| 传输层 | 传输层 | 端到端通信 | TCP、UDP |\n| 网络层 | 网络层 | 路由选择 | IP、ICMP |\n| 数据链路层 | 网络接口层 | 帧传输 | Ethernet、ARP |\n| 物理层 | | 比特传输 | RJ45、光纤 |\n\n每层只与相邻层交互，数据向下封装，向上解封装。', 2);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(4, 'HTTP协议的状态码有哪些？常见状态码的含义？', 'HTTP状态码分类：\n\n- **1xx**：信息性状态码\n- **2xx**：成功状态码\n- **3xx**：重定向状态码\n- **4xx**：客户端错误\n- **5xx**：服务器错误\n\n**常见状态码**：\n\n| 状态码 | 含义 |\n|--------|------|\n| 200 | OK，请求成功 |\n| 301 | Moved Permanently，永久重定向 |\n| 302 | Found，临时重定向 |\n| 304 | Not Modified，缓存有效 |\n| 400 | Bad Request，请求语法错误 |\n| 401 | Unauthorized，未授权 |\n| 403 | Forbidden，禁止访问 |\n| 404 | Not Found，资源不存在 |\n| 500 | Internal Server Error，服务器内部错误 |\n| 503 | Service Unavailable，服务不可用 |', 2);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(4, '什么是滑动窗口？流量控制和拥塞控制的区别？', '滑动窗口：TCP流量控制的机制，控制发送方的发送速率。\n\n**流量控制**：\n- 目的：防止发送方发送过快导致接收方缓冲区溢出\n- 方法：接收方在ACK中通告窗口大小rwnd\n- 发送窗口 = min(rwnd, cwnd)\n\n**拥塞控制**：\n- 目的：防止过多数据注入网络导致网络拥塞\n- 方法：\n  1. **慢开始**：cwnd从1开始指数增长\n  2. **拥塞避免**：cwnd线性增长\n  3. **快重传**：收到3个重复ACK立即重传\n  4. **快恢复**：cwnd减半，直接进入拥塞避免\n\n区别：流量控制是端到端的，拥塞控制是全局的。', 4);

INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (1, 1);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (1, 2);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (2, 3);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (2, 1);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (3, 4);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (4, 5);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (5, 5);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (6, 6);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (7, 7);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (8, 8);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (9, 9);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (10, 10);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (11, 11);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (12, 12);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (13, 13);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (14, 14);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (15, 15);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (16, 17);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (17, 17);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (18, 17);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (18, 18);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (19, 19);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (20, 20);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (21, 21);

INSERT INTO `sys_user` (`user_id`, `username`, `password`, `nickname`, `avatar`, `status`, `del_flag`, `create_time`) VALUES
(2, 'wx_user_001', '', '考研小白', 'https://thirdwx.qlogo.cn/mmopen/vi_32/xxx', '0', '0', NOW());

INSERT INTO `sys_user` (`user_id`, `username`, `password`, `nickname`, `avatar`, `status`, `del_flag`, `create_time`) VALUES
(3, 'wx_user_002', '', '数据结构爱好者', 'https://thirdwx.qlogo.cn/mmopen/vi_32/yyy', '0', '0', NOW());

INSERT INTO `sys_user` (`user_id`, `username`, `password`, `nickname`, `avatar`, `status`, `del_flag`, `create_time`) VALUES
(4, 'wx_user_003', '', '408上岸学姐', 'https://thirdwx.qlogo.cn/mmopen/vi_32/zzz', '0', '0', NOW());

INSERT INTO `biz_user_progress` (`user_id`, `card_id`, `status`, `next_review_time`, `ease_factor`, `repetitions`, `interval_days`) VALUES
(1, 1, 2, NOW() + INTERVAL 7 DAY, 2.5, 1, 7);
INSERT INTO `biz_user_progress` (`user_id`, `card_id`, `status`, `next_review_time`, `ease_factor`, `repetitions`, `interval_days`) VALUES
(1, 2, 1, NOW() + INTERVAL 3 DAY, 2.5, 0, 1);
INSERT INTO `biz_user_progress` (`user_id`, `card_id`, `status`, `next_review_time`, `ease_factor`, `repetitions`, `interval_days`) VALUES
(1, 3, 0, NULL, 2.5, 0, 1);
INSERT INTO `biz_user_progress` (`user_id`, `card_id`, `status`, `next_review_time`, `ease_factor`, `repetitions`, `interval_days`) VALUES
(2, 1, 2, NOW() + INTERVAL 5 DAY, 2.5, 1, 5);
INSERT INTO `biz_user_progress` (`user_id`, `card_id`, `status`, `next_review_time`, `ease_factor`, `repetitions`, `interval_days`) VALUES
(2, 4, 2, NOW() + INTERVAL 4 DAY, 2.5, 1, 4);
INSERT INTO `biz_user_progress` (`user_id`, `card_id`, `status`, `next_review_time`, `ease_factor`, `repetitions`, `interval_days`) VALUES
(2, 5, 1, NOW() + INTERVAL 2 DAY, 2.5, 0, 1);
INSERT INTO `biz_user_progress` (`user_id`, `card_id`, `status`, `next_review_time`, `ease_factor`, `repetitions`, `interval_days`) VALUES
(3, 1, 2, NOW() + INTERVAL 10 DAY, 2.5, 1, 10);
INSERT INTO `biz_user_progress` (`user_id`, `card_id`, `status`, `next_review_time`, `ease_factor`, `repetitions`, `interval_days`) VALUES
(3, 16, 2, NOW() + INTERVAL 6 DAY, 2.5, 1, 6);
INSERT INTO `biz_user_progress` (`user_id`, `card_id`, `status`, `next_review_time`, `ease_factor`, `repetitions`, `interval_days`) VALUES
(3, 17, 1, NOW() + INTERVAL 3 DAY, 2.5, 0, 1);

-- ----------------------------
-- 308护理综合考研数据
-- ----------------------------
INSERT INTO `biz_major` (`major_name`, `description`, `status`) VALUES
('308护理综合考研', '护理学专业综合考试，包含护理学基础、内科护理学、外科护理学三大科目', '0');

INSERT INTO `biz_subject` (`major_id`, `subject_name`, `order_num`) VALUES
(2, '护理学基础', 1),
(2, '内科护理学', 2),
(2, '外科护理学', 3);

INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES
('护理程序', 5),
('护理评估', 5),
('生命体征', 5),
('无菌技术', 5),
('给药护理', 5),
('静脉输液', 5),
('压疮预防', 5),
('心肺复苏', 5),
('疼痛护理', 5),
('卧位与翻身', 5),
('健康教育', 6),
('糖尿病护理', 6),
('高血压护理', 6),
('冠心病护理', 6),
('脑卒中护理', 6),
('呼吸系统', 6),
('消化系统', 6),
('泌尿系统', 6),
('血液系统', 6),
('循环系统', 6),
('神经系统', 6),
('术前准备', 7),
('术后护理', 7),
('伤口护理', 7),
('引流管护理', 7),
('运动系统', 7),
('急救护理', NULL),
('心理护理', NULL),
('营养支持', NULL),
('肿瘤护理', NULL);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(5, '护理程序包括哪五个基本步骤？每个步骤的主要内容是什么？', '护理程序的五个基本步骤：\n\n**1. 护理评估（Assessment）**\n- 收集患者的生理、心理、社会文化等方面的资料\n- 包括主观资料（患者陈述）和客观资料（观察测量）\n- 方法：交谈、观察、体格检查、查阅资料\n\n**2. 护理诊断（Diagnosis）**\n- 分析评估资料，确定患者健康问题\n- NANDA护理诊断分类\n- 格式：P（问题）+ E（原因）+ S（症状/体征）\n\n**3. 护理计划（Planning）**\n- 排定护理诊断优先顺序（首优、中优、次优）\n- 设定预期目标（短期目标、长期目标）\n- 制定护理措施\n\n**4. 护理实施（Implementation）**\n- 执行护理计划\n- 记录护理活动\n- 动态评估患者反应\n\n**5. 护理评价（Evaluation）**\n- 评价目标达成情况\n- 评价护理措施效果\n- 根据评价结果修改计划', 2);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(5, '生命体征包括哪些指标？各指标的正常范围是多少？', '生命体征四大指标及正常范围：\n\n**1. 体温（T）**\n- 正常范围：36.0-37.0℃（口温）\n- 腋温：36.0-36.7℃（比口温低0.3-0.5℃）\n- 肛温：36.5-37.7℃（比口温高0.3-0.5℃）\n- 发热分级：低热37.3-38.0℃，中热38.1-39.0℃，高热39.1-41.0℃，超高热>41.0℃\n\n**2. 脉搏（P）**\n- 正常范围：60-100次/分（成人）\n- 儿童：80-120次/分\n- 婴幼儿：120-140次/分\n- 异常：心动过速>100次/分，心动过缓<60次/分\n\n**3. 呼吸（R）**\n- 正常范围：16-20次/分（成人）\n- 儿童：30-40次/分\n- 婴幼儿：40-45次/分\n- 呼吸与脉搏比例约为1:4\n\n**4. 血压（BP）**\n- 正常范围：收缩压90-139mmHg，舒张压60-89mmHg\n- 高血压：收缩压≥140mmHg或舒张压≥90mmHg\n- 低血压：收缩压<90mmHg或舒张压<60mmHg\n- 脉压：30-40mmHg（收缩压-舒张压）', 2);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(5, '无菌技术的基本原则有哪些？操作中应注意什么？', '无菌技术六大基本原则：\n\n**1. 环境准备**\n- 操作前30分钟停止清扫，减少人员走动\n- 操作区域清洁、宽敞、明亮\n- 治疗室每日紫外线消毒\n\n**2. 工作人员准备**\n- 衣帽整洁，戴口罩，修剪指甲\n- 洗手或手消毒\n- 必要时穿无菌衣、戴无菌手套\n\n**3. 无菌物品管理**\n- 无菌物品与非无菌物品分开放置\n- 无菌物品存放于无菌容器或包内\n- 无菌包有效期：7天（未打开）\n- 无菌包打开后有效期：24小时\n\n**4. 操作原则**\n- 无菌物品一旦取出，即使未使用也不可放回\n- 无菌物品疑有污染或被污染，应弃去不用\n- 操作时身体与无菌台保持一定距离（20cm以上）\n- 手臂不可跨越无菌区\n\n**5. 无菌持物钳使用**\n- 无菌持物钳浸泡在消毒液中，液面以上2-3cm\n- 取放时钳端闭合，不可触碰容器口及边缘\n- 远处取物应连同容器一起移动\n- 每小时更换一次\n\n**6. 无菌容器使用**\n- 打开时盖内面朝上，放于稳妥处\n- 用后立即盖好\n- 手托容器底部，手指不可触及容器边缘及内面', 3);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(5, '给药的五大原则是什么？"三查七对"的内容包括哪些？', '给药五大原则：\n\n**1. 按医嘱给药**\n- 严格执行医嘱，不得擅自更改\n- 有疑问应及时询问医生\n- 一般不执行口头医嘱，紧急情况除外\n\n**2. 严格执行"三查七对"**\n\n**三查**：\n- 操作前查\n- 操作中查\n- 操作后查\n\n**七对**：\n- 对床号\n- 对姓名\n- 对药名\n- 对剂量\n- 对浓度\n- 对方法\n- 对时间\n\n**3. 正确给药**\n- 选择正确的给药途径（口服、注射、吸入等）\n- 掌握正确的给药时间和方法\n- 注意药物配伍禁忌\n\n**4. 观察用药反应**\n- 观察药物疗效和不良反应\n- 及时发现和处理过敏反应\n- 做好记录\n\n**5. 指导患者用药**\n- 解释药物作用、用法和注意事项\n- 指导患者配合用药\n- 做好健康教育\n\n**注意事项**：\n- 易致过敏药物用药前询问过敏史，必要时做过敏试验\n- 用药后发现过敏反应立即停药，报告医生，及时处理\n- 推药速度适宜，观察患者反应', 3);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(5, '静脉输液常见的并发症有哪些？如何预防和处理？', '静脉输液常见并发症及处理：\n\n**1. 发热反应**\n- 原因：输入致热物质（细菌、毒素、杂质）\n- 症状：发冷、寒战、发热，体温可达40℃以上\n- 预防：严格无菌操作，检查药液质量\n- 处理：立即停止输液，通知医生，保留余液和输液器送检，对症处理\n\n**2. 循环负荷过重（急性肺水肿）**\n- 原因：输液速度过快、量过多\n- 症状：呼吸困难、胸闷、咳嗽、咯粉红色泡沫样痰\n- 预防：控制输液速度和量，老年人、心肺疾病患者减慢滴速\n- 处理：立即停止输液，患者端坐位双腿下垂，高流量吸氧（6-8L/min），湿化瓶内加20%-30%酒精，遵医嘱用药\n\n**3. 静脉炎**\n- 原因：长期输液、药物刺激、无菌操作不严\n- 症状：沿静脉走向出现条索状红线，局部红肿热痛\n- 预防：严格无菌操作，保护静脉，药物稀释\n- 处理：患肢抬高并制动，局部热敷或50%硫酸镁湿敷，超短波理疗\n\n**4. 空气栓塞**\n- 原因：输液管内空气未排尽、导管连接不紧\n- 症状：胸闷、呼吸困难、心前区"水泡音"\n- 预防：排尽输液管内空气，加强巡视\n- 处理：立即停止输液，左侧卧位并头低足高，高流量吸氧，通知医生\n\n**5. 液体外渗**\n- 原因：针头滑出血管、针头穿透血管\n- 症状：局部肿胀、疼痛\n- 处理：立即拔针，更换穿刺部位，局部冷敷或热敷（视药物而定）', 4);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(5, '压疮是如何分期的？如何预防压疮的发生？', '压疮分期及表现：\n\n**Ⅰ期（淤血红润期）**\n- 表现：皮肤完整，出现压之不褪色的局限性红斑\n- 处理：去除病因，增加翻身次数，避免受压\n\n**Ⅱ期（炎性浸润期）**\n- 表现：表皮和真皮破损，形成水疱或溃疡\n- 处理：保护创面，防止感染，继续翻身减压\n\n**Ⅲ期（浅度溃疡期）**\n- 表现：全层皮肤破坏，溃疡形成，可见皮下组织\n- 处理：清洁创面，清除坏死组织，促进愈合\n\n**Ⅳ期（坏死溃疡期）**\n- 表现：深层组织坏死，可达肌肉、骨骼\n- 处理：外科清创，控制感染，必要时手术治疗\n\n**压疮预防措施**：\n\n**1. 减压措施**\n- 每2小时翻身一次，必要时30分钟翻身\n- 使用气垫床、减压垫、翻身垫\n- 骨隆突处垫软枕或气圈\n- 避免拖、拉、拽等动作\n\n**2. 保护皮肤**\n- 保持皮肤清洁干燥\n- 床单平整无皱褶\n- 使用润肤剂保护干燥皮肤\n- 避免使用酒精等刺激性强清洁剂\n\n**3. 改善营养**\n- 给予高蛋白、高维生素饮食\n- 补充足够的水分\n- 必要时肠内外营养支持\n\n**4. 健康教育**\n- 教导患者及家属压疮预防知识\n- 指导床上活动方法', 3);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(5, '心肺复苏（CPR）的操作步骤是什么？高质量CPR的要求有哪些？', '心肺复苏（CPR）操作步骤：\n\n**1. 识别心脏骤停**\n- 判断意识：轻拍肩膀，大声呼唤\n- 判断呼吸：看胸廓起伏（5-10秒）\n- 判断脉搏：触摸颈动脉（5-10秒）\n- 如无意识、无呼吸、无脉搏，立即CPR\n\n**2. 呼救**\n- 大声呼救，拨打120\n- 如有AED，立即取用\n\n**3. 胸外按压（C）**\n- 位置：两乳头连线中点（胸骨中下1/3交界处）\n- 方法：双手叠放，掌根按压，手臂伸直垂直用力\n- 深度：成人5-6cm，儿童约5cm，婴幼儿约4cm\n- 频率：100-120次/分\n- 比例：按压与放松时间相等\n- 保证每次按压后胸廓充分回弹\n- 尽量减少中断，中断时间<10秒\n\n**4. 开放气道（A）**\n- 清除口腔异物\n- 仰头举颏法（无颈部损伤）\n- 推举下颌法（疑有颈部损伤）\n\n**5. 人工呼吸（B）**\n- 比例：30:2（按压30次，呼吸2次）\n- 方法：口对口或口对鼻\n- 每次吹气时间约1秒，见胸廓起伏\n- 避免过度通气\n\n**高质量CPR要求**：\n- 按压频率100-120次/分\n- 按压深度5-6cm（成人）\n- 每次按压后胸廓充分回弹\n- 尽量减少按压中断\n- 避免过度通气\n- 每2分钟更换按压者', 4);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(5, '疼痛评估的方法有哪些？如何进行疼痛护理？', '疼痛评估方法：\n\n**1. 疼痛强度评估工具**\n\n**数字评分法（NRS）**：0-10分\n- 0分：无痛\n- 1-3分：轻度疼痛\n- 4-6分：中度疼痛\n- 7-10分：重度疼痛\n\n**视觉模拟评分法（VAS）**：10cm直线\n- 无痛端为0，最痛端为10\n- 患者在直线上标记疼痛位置\n\n**面部表情量表**：适用于儿童和认知障碍者\n- 6个面部表情，从微笑到哭泣\n\n**2. 疼痛部位评估**\n- 确定疼痛部位\n- 评估疼痛性质（锐痛、钝痛、绞痛等）\n- 评估疼痛持续时间\n\n**疼痛护理措施**：\n\n**1. 药物镇痛**\n- 遵医嘱给予镇痛药物\n- 三阶梯镇痛原则（轻度→中度→重度）\n- 按时给药，而非按需给药\n- 观察药物效果和不良反应\n\n**2. 非药物镇痛**\n- 物理方法：冷敷、热敷、按摩、针灸\n- 心理方法：放松训练、音乐疗法、冥想\n- 环境调整：安静、舒适的环境\n\n**3. 健康教育**\n- 告知患者疼痛评估方法\n- 指导正确表达疼痛\n- 教会非药物镇痛方法\n\n**4. 评价与记录**\n- 定时评估疼痛程度\n- 记录镇痛措施效果\n- 及时调整护理方案', 3);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(6, '糖尿病的诊断标准是什么？糖尿病患者的护理措施有哪些？', '糖尿病诊断标准：\n\n**1. 空腹血糖**\n- 正常：<6.1mmol/L\n- 糖尿病：≥7.0mmol/L\n- 空腹血糖受损：6.1-7.0mmol/L\n\n**2. 餐后2小时血糖**\n- 正常：<7.8mmol/L\n- 糖尿病：≥11.1mmol/L\n- 糖耐量受损：7.8-11.1mmol/L\n\n**3. 诊断标准**\n- 有糖尿病症状+随机血糖≥11.1mmol/L\n- 空腹血糖≥7.0mmol/L\n- OGTT 2小时血糖≥11.1mmol/L\n- 以上任意一项，需另一日复查证实\n\n**糖尿病护理措施**：\n\n**1. 饮食护理**\n- 控制总热量摄入\n- 合理分配三大营养素：碳水50-60%，蛋白15-20%，脂肪25-30%\n- 定时定量进餐\n- 限制单糖和双糖摄入\n\n**2. 运动护理**\n- 每周运动3-5次，每次20-40分钟\n- 运动时间：饭后1小时开始\n- 运动强度：中等强度（心率=170-年龄）\n- 避免空腹运动，预防低血糖\n\n**3. 血糖监测**\n- 监测空腹血糖和餐后血糖\n- 血糖控制目标：空腹4.4-7.0mmol/L，餐后<10.0mmol/L\n- 定期检测糖化血红蛋白（目标<7%）\n\n**4. 用药护理**\n- 口服降糖药：按时服药，注意不良反应\n- 胰岛素：正确注射方法，轮换注射部位\n- 低血糖预防和处理\n\n**5. 并发症预防**\n- 定期检查眼底、肾功能、足部\n- 预防感染\n- 心血管病变筛查\n\n**6. 健康教育**\n- 糖尿病知识教育\n- 自我管理技能培训', 4);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(6, '高血压的分级标准是什么？高血压患者的护理要点有哪些？', '高血压分级标准（中国高血压防治指南）：\n\n| 分类 | 收缩压(mmHg) | 舒张压(mmHg) |\n|------|-------------|-------------|\n| 正常血压 | <120 | <80 |\n| 正常高值 | 120-139 | 80-89 |\n| 高血压1级(轻度) | 140-159 | 90-99 |\n| 高血压2级(中度) | 160-179 | 100-109 |\n| 高血压3级(重度) | ≥180 | ≥110 |\n\n**高血压护理要点**：\n\n**1. 非药物治疗**\n- 饮食：低盐（<6g/天）、低脂、高钾高钙\n- 体重：BMI控制在24以下\n- 运动：每周3-5次，每次30分钟中等强度运动\n- 戒烟限酒\n- 心理调节：减轻压力，保持情绪稳定\n\n**2. 用药护理**\n- 遵医嘱按时服药，不可擅自停药或减量\n- 观察药物不良反应\n- 常用降压药：利尿剂、β受体阻滞剂、钙通道阻滞剂、ACEI、ARB\n- 血压控制目标：一般患者<140/90mmHg，合并糖尿病或肾病<130/80mmHg\n\n**3. 血压监测**\n- 家庭自测血压\n- 定期门诊随访\n- 记录血压变化\n\n**4. 急症处理**\n- 高血压急症：血压急剧升高≥180/120mmHg\n- 症状：头痛、呕吐、视力模糊、意识障碍\n- 处理：立即休息，舌下含服降压药，尽快就医\n\n**5. 健康教育**\n- 高血压知识教育\n- 生活方式干预指导\n- 定期随访的重要性', 3);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(6, '冠心病的类型有哪些？心绞痛和心肌梗死的区别是什么？', '冠心病分类：\n\n**1. 无症状性心肌缺血**\n- 无明显症状，但有心肌缺血客观证据\n\n**2. 心绞痛**\n- 稳定型心绞痛\n- 不稳定型心绞痛\n\n**3. 心肌梗死**\n- 急性心肌梗死\n- 陈旧性心肌梗死\n\n**4. 缺血性心肌病**\n- 心脏扩大、心力衰竭\n\n**5. 猝死**\n\n**心绞痛与心肌梗死的区别**：\n\n| 特点 | 心绞痛 | 心肌梗死 |\n|------|--------|----------|\n| 疼痛性质 | 压榨性、窒息性 | 更剧烈，濒死感 |\n| 疼痛部位 | 胸骨后或心前区 | 相同，范围更广 |\n| 疼痛持续时间 | 1-5分钟，不超过15分钟 | 持续>30分钟 |\n| 诱发因素 | 劳累、情绪激动、寒冷 | 可无明显诱因 |\n| 缓解方式 | 休息或含服硝酸甘油可缓解 | 硝酸甘油无效 |\n| 心电图 | ST段暂时性压低或抬高 | ST段持续抬高，病理性Q波 |\n| 心肌酶 | 正常 | 升高（CK-MB、肌钙蛋白） |\n| 并发症 | 少 | 严重（心律失常、休克、心力衰竭） |\n\n**心肌梗死护理要点**：\n- 急性期绝对卧床休息\n- 心电监护\n- 吸氧（2-4L/min）\n- 建立静脉通路\n- 遵医嘱给予抗凝、抗血小板药物\n- 疼痛护理：吗啡或硝酸甘油\n- 观察心律失常、心力衰竭等并发症\n- 饮食：低盐低脂、易消化\n- 心理护理：减轻焦虑恐惧', 4);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(6, '肺炎的分类有哪些？肺炎患者的护理措施包括哪些？', '肺炎分类：\n\n**按病因分类**\n- 细菌性肺炎（最常见）：肺炎链球菌、金黄色葡萄球菌等\n- 病毒性肺炎：流感病毒、新冠病毒等\n- 支原体肺炎\n- 真菌性肺炎\n\n**按解剖分类**\n- 大叶性肺炎\n- 小叶性肺炎（支气管肺炎）\n- 间质性肺炎\n\n**按患病环境分类**\n- 社区获得性肺炎（CAP）\n- 医院获得性肺炎（HAP）\n\n**肺炎护理措施**：\n\n**1. 一般护理**\n- 卧床休息，取半卧位\n- 保持室内空气流通\n- 维持适宜温度和湿度\n\n**2. 发热护理**\n- 监测体温变化\n- 高热时物理降温或药物降温\n- 补充水分\n- 退热后及时更换衣物\n\n**3. 呼吸道护理**\n- 鼓励有效咳嗽、咳痰\n- 痰液粘稠者给予雾化吸入\n- 体位引流促进排痰\n- 必要时吸痰\n- 缺氧者给予氧疗\n\n**4. 用药护理**\n- 遵医嘱使用抗生素\n- 观察药物疗效和不良反应\n- 抗生素按时按量给药\n\n**5. 饮食护理**\n- 高热量、高蛋白、高维生素饮食\n- 多饮水（每日2000-3000ml）\n- 易消化食物\n\n**6. 并发症观察**\n- 观察呼吸频率、节律变化\n- 监测血氧饱和度\n- 注意感染性休克早期表现：面色苍白、血压下降、脉搏细速', 3);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(6, '脑卒中分为哪两类？急性期护理要点是什么？', '脑卒中分类：\n\n**1. 缺血性卒中（脑梗死）**\n- 脑血栓形成：动脉粥样硬化导致\n- 脑栓塞：栓子阻塞脑血管\n- 占脑卒中60-70%\n\n**2. 出血性卒中**\n- 脑出血：高血压是最常见原因\n- 蛛网膜下腔出血：动脉瘤破裂\n- 占脑卒中30-40%\n\n**急性期护理要点**：\n\n**1. 一般护理**\n- 绝对卧床休息\n- 脑出血者床头抬高15-30度\n- 避免搬动和刺激\n- 保持环境安静\n\n**2. 呼吸道护理**\n- 保持呼吸道通畅\n- 及时清除呼吸道分泌物\n- 防止误吸\n- 必要时气管切开\n\n**3. 血压管理**\n- 监测血压变化\n- 缺血性卒中：血压不宜过低\n- 出血性卒中：适当控制血压\n\n**4. 观察病情**\n- 监测意识状态（Glasgow昏迷评分）\n- 观察瞳孔大小和对光反射\n- 监测生命体征\n- 注意颅内压增高表现：头痛、呕吐、意识障碍加重\n\n**5. 预防并发症**\n- 压疮预防：定时翻身\n- 呼吸道感染预防\n- 下肢深静脉血栓预防\n- 应激性溃疡预防\n\n**6. 康复护理**\n- 早期康复介入（生命体征稳定后）\n- 肢体功能位摆放\n- 关节被动活动\n- 语言康复训练', 4);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(7, '手术前患者需要做哪些准备？术前禁食禁水的时间要求？', '手术前准备内容：\n\n**1. 心理准备**\n- 解释手术目的、方法和预期效果\n- 解答患者疑问，减轻焦虑\n- 介绍手术室环境和流程\n- 签署手术知情同意书\n\n**2. 生理准备**\n\n**术前禁食禁水时间**：\n- 普通手术：禁食8-12小时，禁水4小时\n- 局麻小手术：禁食4小时\n- 急诊手术：根据情况尽量禁食\n- 目的：防止麻醉时呕吐误吸\n\n**肠道准备**：\n- 普通手术：术前晚清洁灌肠\n- 结直肠手术：术前3天肠道准备\n  - 术前3天：低渣饮食\n  - 术前2天：流质饮食\n  - 术前1天：口服肠道清洁剂\n  - 术前晚及术晨：清洁灌肠\n\n**皮肤准备**：\n- 术前1天洗澡、更换清洁衣物\n- 手术区域皮肤清洁\n- 必要时剃除毛发（备皮）\n- 注意避免损伤皮肤\n\n**3. 术前用药**\n- 术前30分钟给予术前用药\n- 抗胆碱药：减少呼吸道分泌物\n- 镇静药：减轻焦虑\n- 预防性抗生素\n\n**4. 其他准备**\n- 术前各项检查：血常规、凝血、肝肾功能等\n- 交叉配血\n- 测量生命体征\n- 取下义齿、饰品、假发等\n- 排空膀胱\n- 建立静脉通路\n\n**5. 特殊患者准备**\n- 高血压患者：控制血压\n- 糖尿病患者：控制血糖\n- 心脏病患者：评估心功能\n- 长期服用药物者：抗凝药、激素等需调整', 3);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(7, '手术后患者的护理要点有哪些？术后并发症如何预防？', '手术后护理要点：\n\n**1. 体位护理**\n- 全麻未清醒：平卧位，头偏向一侧（防止呕吐误吸）\n- 全麻清醒后：半卧位（利于呼吸和引流）\n- 腹部手术：半卧位（减轻腹壁张力）\n- 休克患者：中凹卧位（头胸抬高10-20°，下肢抬高20-30°）\n\n**2. 生命体征监测**\n- 监测体温、脉搏、呼吸、血压\n- 大手术后15-30分钟监测一次\n- 病情稳定后改为1-2小时监测一次\n\n**3. 呼吸道护理**\n- 鼓励深呼吸和有效咳嗽\n- 翻身叩背促进排痰\n- 必要时雾化吸入\n- 保持呼吸道通畅\n\n**4. 疼痛护理**\n- 评估疼痛程度\n- 遵医嘱给予镇痛药物\n- 非药物镇痛方法\n- 观察镇痛效果\n\n**5. 饮食护理**\n- 非腹部手术：局麻后即可进食，全麻清醒后进食\n- 腹部手术：待肠功能恢复后进食（排气后）\n- 进食顺序：流质→半流质→普食\n\n**6. 活动护理**\n- 鼓励早期活动\n- 术后第1天床上活动\n- 第2-3天下床活动\n- 逐渐增加活动量\n\n**术后常见并发症及预防**：\n\n| 并发症 | 原因 | 预防措施 |\n|--------|------|----------|\n| 术后出血 | 手术止血不彻底 | 观察引流液性质和量，监测生命体征 |\n| 伤口感染 | 细菌污染 | 无菌操作，保持伤口清洁干燥 |\n| 肺部感染 | 呼吸道分泌物滞留 | 深呼吸、有效咳嗽、翻身叩背 |\n| 尿路感染 | 留置尿管、尿潴留 | 保持尿管通畅，尽早拔除尿管 |\n| 深静脉血栓 | 血液高凝、卧床 | 早期活动，必要时抗凝 |\n| 压疮 | 长期卧床 | 定时翻身，保护皮肤 |', 3);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(7, '伤口愈合的类型有哪些？伤口护理的原则是什么？', '伤口愈合类型：\n\n**1. 一期愈合**\n- 特点：伤口边缘整齐，组织缺损少\n- 无感染，愈合时间短，瘢痕小\n- 如无菌手术切口\n\n**2. 二期愈合**\n- 特点：伤口边缘不整齐，组织缺损大\n- 有感染或坏死组织\n- 愈合时间长，瘢痕大\n- 需清创后愈合\n\n**3. 三期愈合（延期愈合）**\n- 伤口先敞开引流，待感染控制后缝合\n- 如污染伤口清创后暂时不缝合\n\n**伤口护理原则**：\n\n**1. 评估伤口**\n- 伤口类型：清洁、污染、感染\n- 伤口位置、大小、深度\n- 渗出液性质、量\n- 愈合情况\n\n**2. 清洁伤口**\n- 无菌操作\n- 由内向外消毒\n- 清除坏死组织和异物\n- 保护新生组织\n\n**3. 换药技术**\n- 换药频率：清洁伤口2-3天换药一次\n- 感染伤口每日或随时换药\n- 先消毒伤口周围皮肤\n- 清洁伤口内部\n- 选择合适的敷料覆盖\n\n**4. 引流护理**\n- 保持引流通畅\n- 观察引流液性质和量\n- 记录引流情况\n- 及时拔除引流管\n\n**5. 感染伤口护理**\n- 加强换药\n- 清除脓液和坏死组织\n- 遵医嘱使用抗生素\n- 促进引流\n\n**6. 拆线时间**\n- 头面部：4-5天\n- 颈部：5-6天\n- 胸腹部：7-8天\n- 四肢：10-12天\n- 减张缝合：14天', 3);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(7, '外科常见引流管有哪些？引流管护理的共同原则是什么？', '外科常见引流管类型：\n\n**1. 胸腔引流管**\n- 用于胸腔手术后、气胸、胸腔积液\n- 保持引流瓶低于胸腔60cm\n- 保持密闭系统\n- 观察引流液性质和量\n\n**2. 腹腔引流管**\n- 用于腹部手术后引流腹腔渗液\n- 常见类型：橡胶引流管、硅胶引流管\n- 保持引流管通畅\n- 记录引流液量\n\n**3. T型引流管（T管）**\n- 用于胆道手术后引流胆汁\n- 术后2周试行夹管\n- 拔管前做T管造影\n- 一般术后3-4周拔管\n\n**4. 胃管**\n- 用于胃肠减压、胃肠营养\n- 保持胃管通畅\n- 观察引流物性质\n- 记录引流量\n\n**5. 尿管**\n- 用于引流尿液、监测尿量\n- 保持尿管通畅\n- 每日尿道口护理\n- 及时拔除（尽量缩短留置时间）\n\n**引流管护理共同原则**：\n\n**1. 固定**\n- 引流管妥善固定\n- 防止脱出或移位\n- 活动时保护好引流管\n\n**2. 保持通畅**\n- 防止引流管扭曲、受压、堵塞\n- 及时清除堵塞物\n- 必要时冲洗引流管\n\n**3. 观察**\n- 观察引流液的颜色、性质、量\n- 记录引流情况\n- 发现异常及时报告\n\n**4. 无菌操作**\n- 更换引流装置时无菌操作\n- 引流瓶/袋位置低于引流部位\n- 防止逆行感染\n\n**5. 拔管时机**\n- 引流量明显减少\n- 引流液性质正常\n- 病情稳定\n- 遵医嘱拔管', 4);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES
(7, '急腹症患者的护理评估要点有哪些？如何鉴别常见急腹症？', '急腹症护理评估要点：\n\n**1. 病史评估**\n- 起病缓急：急性腹痛、渐进性腹痛\n- 疼痛特点：部位、性质、程度、持续时间\n- 诱因：饮食、活动、体位变化\n- 伴随症状：恶心、呕吐、发热、腹胀等\n- 既往史：腹部手术史、类似发作史\n\n**2. 体格检查**\n- 视诊：腹部外形、腹式呼吸\n- 触诊：压痛、反跳痛、肌紧张、肿块\n- 叩诊：移动性浊音、肝浊音界\n- 听诊：肠鸣音变化\n\n**3. 辅助检查**\n- 血常规：白细胞升高提示感染\n- 腹部X线：膈下游离气体（穿孔）\n- 腹部B超、CT\n- 诊断性腹腔穿刺\n\n**常见急腹症鉴别**：\n\n| 疾病 | 疼痛特点 | 伴随症状 | 特殊体征 |\n|------|----------|----------|----------|\n| 急性阑尾炎 | 转移性右下腹痛 | 发热、恶心呕吐 | McBurney点压痛 |\n| 急性胆囊炎 | 右上腹痛，向右肩放射 | 发热、黄疸 | Murphy征阳性 |\n| 急性胰腺炎 | 上腹正中或偏左，束带状 | 发热、恶心呕吐 | Grey-Turner征、Cullen征 |\n| 胃十二指肠穿孔 | 突发上腹剧痛，迅速扩散 | 面色苍白、出冷汗 | 板状腹、膈下游离气体 |\n| 肠梗阻 | 阵发性腹痛 | 呕吐、腹胀、停止排便排气 | 肠鸣音亢进或消失、可见肠型 |\n| 急性胆管炎 | 右上腹痛 | 发热、黄疸（Charcot三联征） | Reynolds五联征：三联征+休克+意识障碍 |\n\n**护理措施**：\n- 禁食禁水\n- 建立静脉通路\n- 维持水电解质平衡\n- 观察病情变化\n- 禁用止痛药（诊断明确后可用）\n- 必要时胃肠减压\n- 做好急诊手术准备', 4);

INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES
(22, 22),
(22, 23),
(23, 24),
(24, 25),
(25, 26),
(26, 27),
(27, 28),
(27, 31),
(28, 29),
(28, 48),
(29, 30),
(30, 33),
(30, 32),
(31, 34),
(31, 41),
(32, 35),
(32, 41),
(33, 37),
(34, 36),
(34, 42),
(35, 43),
(36, 44),
(37, 45),
(38, 46),
(39, 38),
(39, 48);

SET FOREIGN_KEY_CHECKS = 1;
