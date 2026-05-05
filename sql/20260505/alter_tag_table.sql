-- 标签表结构变更：添加 subject_id 字段
-- 执行时间：2026-04-24

USE `card_learn`;

-- 添加 subject_id 字段
ALTER TABLE `biz_tag` ADD COLUMN `subject_id` bigint(20) DEFAULT NULL COMMENT '所属科目ID(null表示通用标签)' AFTER `tag_name`;

-- 添加索引
ALTER TABLE `biz_tag` ADD INDEX `idx_subject_id` (`subject_id`);

-- 说明：
-- 1. subject_id 为 null 表示通用标签，可在任意科目卡片中使用
-- 2. subject_id 为具体科目ID 表示该科目的专属标签
-- 3. 不同科目可以有同名标签，通过 subject_id 区分