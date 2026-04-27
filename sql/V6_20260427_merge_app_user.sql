-- V6: 合并 sys_app_user 到 sys_user，统一用户表
-- 执行前请备份数据库！

-- 1. biz_user_progress: app_user_id → user_id
ALTER TABLE `biz_user_progress` CHANGE COLUMN `app_user_id` `user_id` BIGINT DEFAULT NULL COMMENT '用户ID';
ALTER TABLE `biz_user_progress` DROP INDEX IF EXISTS `idx_user_card`;
ALTER TABLE `biz_user_progress` ADD INDEX `idx_user_card` (`user_id`, `card_id`);

-- 2. biz_feedback: app_user_id → user_id
ALTER TABLE `biz_feedback` CHANGE COLUMN `app_user_id` `user_id` BIGINT DEFAULT NULL COMMENT '用户ID';
ALTER TABLE `biz_feedback` DROP INDEX IF EXISTS `idx_app_user_id`;
ALTER TABLE `biz_feedback` ADD INDEX `idx_user_id` (`user_id`);

-- 3. biz_card_comment: app_user_id → user_id
ALTER TABLE `biz_card_comment` CHANGE COLUMN `app_user_id` `user_id` BIGINT NOT NULL COMMENT '用户ID';
ALTER TABLE `biz_card_comment` DROP INDEX IF EXISTS `idx_app_user_id`;
ALTER TABLE `biz_card_comment` ADD INDEX `idx_user_id` (`user_id`);

-- 4. 删除 sys_app_user 表（确认数据已迁移后再执行）
-- DROP TABLE IF EXISTS `sys_app_user`;
