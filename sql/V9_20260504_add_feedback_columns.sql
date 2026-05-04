-- V9: biz_feedback 表添加 major_id、subject_id、update_user_id 字段
-- 前提：V6 迁移已执行（app_user_id 已重命名为 user_id）
-- 执行前请备份数据库！

ALTER TABLE `biz_feedback` ADD COLUMN `major_id` bigint(20) DEFAULT NULL COMMENT '所属专业ID' AFTER `card_id`;
ALTER TABLE `biz_feedback` ADD COLUMN `subject_id` bigint(20) DEFAULT NULL COMMENT '所属科目ID' AFTER `major_id`;
ALTER TABLE `biz_feedback` ADD COLUMN `update_user_id` bigint(20) DEFAULT NULL COMMENT '更新人ID' AFTER `update_time`;
