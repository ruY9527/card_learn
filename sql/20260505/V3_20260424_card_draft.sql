-- ----------------------------
-- 用户录入知识卡片临时表（审批流程）
-- Date: 2026-04-24
-- Description: 创建biz_card_draft临时表，存储用户提交的待审批卡片
-- ----------------------------

-- 1. 创建临时表 biz_card_draft
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

-- 2. 创建审批历史表 biz_card_audit_log（记录审批操作历史）
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

-- 注意：原有的biz_card表中的审批相关字段可以保留用于其他场景
-- 但用户录入的卡片将使用临时表方案