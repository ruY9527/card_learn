-- ----------------------------
-- 添加更新时间和更新人字段
-- Date: 2026-04-24
-- Description: 为所有业务表添加 update_time 和 update_user_id 字段
-- ----------------------------

-- 1. biz_card 表 - 添加 update_user_id
ALTER TABLE `biz_card` 
ADD COLUMN `update_user_id` bigint DEFAULT NULL COMMENT '更新人ID' AFTER `update_time`;

-- 2. biz_card_draft 表 - 添加 update_user_id
ALTER TABLE `biz_card_draft` 
ADD COLUMN `update_user_id` bigint DEFAULT NULL COMMENT '更新人ID' AFTER `update_time`;

-- 3. biz_card_audit_log 表 - 添加 update_time 和 update_user_id
ALTER TABLE `biz_card_audit_log` 
ADD COLUMN `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间' AFTER `audit_time`,
ADD COLUMN `update_user_id` bigint DEFAULT NULL COMMENT '更新人ID' AFTER `update_time`;

-- 4. biz_card_tag 表 - 添加 create_time, update_time 和 update_user_id
ALTER TABLE `biz_card_tag` 
ADD COLUMN `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间' AFTER `tag_id`,
ADD COLUMN `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间' AFTER `create_time`,
ADD COLUMN `update_user_id` bigint DEFAULT NULL COMMENT '更新人ID' AFTER `update_time`;

-- 5. biz_subject 表 - 添加 create_time, update_time 和 update_user_id
ALTER TABLE `biz_subject` 
ADD COLUMN `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间' AFTER `order_num`,
ADD COLUMN `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间' AFTER `create_time`,
ADD COLUMN `update_user_id` bigint DEFAULT NULL COMMENT '更新人ID' AFTER `update_time`;

-- 6. biz_major 表 - 添加 create_time, update_time 和 update_user_id
ALTER TABLE `biz_major` 
ADD COLUMN `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间' AFTER `status`,
ADD COLUMN `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间' AFTER `create_time`,
ADD COLUMN `update_user_id` bigint DEFAULT NULL COMMENT '更新人ID' AFTER `update_time`;

-- 7. sys_user 表 - 添加 update_user_id (已有 update_by，添加数字ID字段)
ALTER TABLE `sys_user` 
ADD COLUMN `update_user_id` bigint DEFAULT NULL COMMENT '更新人ID' AFTER `update_time`;

-- 8. sys_app_user 表 - 添加 update_time 和 update_user_id
ALTER TABLE `sys_app_user` 
ADD COLUMN `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间' AFTER `create_time`,
ADD COLUMN `update_user_id` bigint DEFAULT NULL COMMENT '更新人ID' AFTER `update_time`;

-- 9. biz_feedback 表 - 添加 update_user_id
ALTER TABLE `biz_feedback` 
ADD COLUMN `update_user_id` bigint DEFAULT NULL COMMENT '更新人ID' AFTER `update_time`;

-- 添加索引（可选，用于查询优化）
ALTER TABLE `biz_card` ADD INDEX `idx_update_user_id` (`update_user_id`);
ALTER TABLE `biz_card_draft` ADD INDEX `idx_update_user_id` (`update_user_id`);
ALTER TABLE `biz_subject` ADD INDEX `idx_update_user_id` (`update_user_id`);
ALTER TABLE `biz_major` ADD INDEX `idx_update_user_id` (`update_user_id`);