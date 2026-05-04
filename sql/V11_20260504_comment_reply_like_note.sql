-- V11: 评论回复、点赞、笔记功能
-- 新增 biz_card_reply、biz_comment_like 表
-- 修改 biz_card_comment 表增加 is_note、like_count、reply_count 字段

-- ============================================================
-- 1. 修改 biz_card_comment：增加笔记标识和计数冗余字段
-- ============================================================
ALTER TABLE `biz_card_comment` ADD COLUMN `is_note` TINYINT(1) DEFAULT 0 COMMENT '是否作为笔记：0否 1是' AFTER `feedback_id`;
ALTER TABLE `biz_card_comment` ADD COLUMN `like_count` INT DEFAULT 0 COMMENT '点赞数（冗余）' AFTER `is_note`;
ALTER TABLE `biz_card_comment` ADD COLUMN `reply_count` INT DEFAULT 0 COMMENT '回复数量（冗余）' AFTER `like_count`;

-- ============================================================
-- 2. 新建 biz_card_reply：评论回复表
-- ============================================================
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

-- ============================================================
-- 3. 新建 biz_comment_like：点赞表
-- ============================================================
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
