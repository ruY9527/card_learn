-- ----------------------------
-- 用户录入知识卡片审批功能 - 表结构变更
-- Date: 2026-04-24
-- Description: 为biz_card表添加审批相关字段，支持用户录入卡片审批流程
-- ----------------------------

-- 1. 添加审批状态字段（默认值为'1'已通过，兼容现有系统卡片）
ALTER TABLE `biz_card` ADD COLUMN `audit_status` char(1) DEFAULT '1' COMMENT '审批状态（0待审批 1已通过 2已拒绝）' AFTER `difficulty_level`;

-- 2. 添加创建用户ID字段（系统创建为NULL，用户录入则有值）
ALTER TABLE `biz_card` ADD COLUMN `create_user_id` bigint DEFAULT NULL COMMENT '创建用户ID（系统创建为NULL，用户录入则有值）' AFTER `audit_status`;

-- 3. 添加审批人ID字段
ALTER TABLE `biz_card` ADD COLUMN `audit_user_id` bigint DEFAULT NULL COMMENT '审批人ID' AFTER `create_user_id`;

-- 4. 添加审批时间字段
ALTER TABLE `biz_card` ADD COLUMN `audit_time` datetime DEFAULT NULL COMMENT '审批时间' AFTER `audit_user_id`;

-- 5. 添加审批备注字段（拒绝原因等）
ALTER TABLE `biz_card` ADD COLUMN `audit_remark` varchar(500) DEFAULT NULL COMMENT '审批备注（拒绝原因等）' AFTER `audit_time`;

-- 6. 添加索引优化查询性能
ALTER TABLE `biz_card` ADD INDEX `idx_audit_status` (`audit_status`);
ALTER TABLE `biz_card` ADD INDEX `idx_create_user_id` (`create_user_id`);

-- 7. 更新现有数据的审批状态为已通过（确保兼容性）
UPDATE `biz_card` SET `audit_status` = '1' WHERE `audit_status` IS NULL OR `audit_status` = '';