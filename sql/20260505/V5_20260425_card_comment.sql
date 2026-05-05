-- V5 闪卡评论表
-- 用于用户对闪卡知识点进行评价，劣质内容与反馈管理联动

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

-- 创建视图：评论统计（每张卡片的优质/劣质评论数）
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