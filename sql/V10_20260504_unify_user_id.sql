-- V10: 统一所有表的 user_id 字段名 + 添加缺失列
-- 将 app_user_id 重命名为 user_id，并添加缺失的列
-- 执行前请备份数据库！
-- 如果某些 ALTER 语句报错（列已存在），可以忽略该条继续执行

-- ============================================================
-- 1. biz_feedback: app_user_id → user_id
-- ============================================================
ALTER TABLE `biz_feedback` CHANGE COLUMN `app_user_id` `user_id` BIGINT DEFAULT NULL COMMENT '用户ID';
ALTER TABLE `biz_feedback` DROP INDEX `idx_app_user_id`;
ALTER TABLE `biz_feedback` ADD INDEX `idx_user_id` (`user_id`);
ALTER TABLE `biz_feedback` ADD COLUMN `major_id` bigint(20) DEFAULT NULL COMMENT '所属专业ID' AFTER `card_id`;
ALTER TABLE `biz_feedback` ADD COLUMN `subject_id` bigint(20) DEFAULT NULL COMMENT '所属科目ID' AFTER `major_id`;
ALTER TABLE `biz_feedback` ADD COLUMN `update_user_id` bigint(20) DEFAULT NULL COMMENT '更新人ID' AFTER `update_time`;

-- ============================================================
-- 2. biz_user_progress: app_user_id → user_id
-- ============================================================
ALTER TABLE `biz_user_progress` CHANGE COLUMN `app_user_id` `user_id` BIGINT DEFAULT NULL COMMENT '用户ID';
ALTER TABLE `biz_user_progress` DROP INDEX `idx_user_card`;
ALTER TABLE `biz_user_progress` ADD INDEX `idx_user_card` (`user_id`, `card_id`);
ALTER TABLE `biz_user_progress` ADD COLUMN `ease_factor` DOUBLE DEFAULT 2.5 COMMENT 'SM-2容易系数' AFTER `status`;
ALTER TABLE `biz_user_progress` ADD COLUMN `repetitions` INT DEFAULT 0 COMMENT 'SM-2连续正确次数' AFTER `ease_factor`;
ALTER TABLE `biz_user_progress` ADD COLUMN `interval_days` INT DEFAULT 1 COMMENT 'SM-2复习间隔天数' AFTER `repetitions`;

-- ============================================================
-- 3. biz_card_comment: app_user_id → user_id
-- ============================================================
ALTER TABLE `biz_card_comment` CHANGE COLUMN `app_user_id` `user_id` BIGINT NOT NULL COMMENT '用户ID';
ALTER TABLE `biz_card_comment` DROP INDEX `idx_app_user_id`;
ALTER TABLE `biz_card_comment` ADD INDEX `idx_user_id` (`user_id`);
