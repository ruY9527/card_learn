-- 添加 like_type 字段到 biz_comment_like 表
ALTER TABLE `biz_comment_like` ADD COLUMN `like_type` TINYINT(1) NOT NULL DEFAULT 1
    COMMENT '1=喜欢 2=不喜欢' AFTER `user_id`;

-- 添加 dislike_count 字段到 biz_card_comment 表
ALTER TABLE `biz_card_comment` ADD COLUMN `dislike_count` INT DEFAULT 0
    COMMENT '不喜欢数' AFTER `like_count`;

-- 添加 dislike_count 字段到 biz_card_reply 表
ALTER TABLE `biz_card_reply` ADD COLUMN `dislike_count` INT DEFAULT 0
    COMMENT '不喜欢数' AFTER `like_count`;
