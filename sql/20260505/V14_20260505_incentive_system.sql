-- =============================================
-- 激励系统数据库表结构
-- 版本: V14
-- 日期: 2026-05-05
-- =============================================

-- 1. 成就定义表
CREATE TABLE IF NOT EXISTS `biz_achievement` (
  `achievement_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '成就ID',
  `achievement_code` VARCHAR(64) NOT NULL COMMENT '成就代码(唯一标识)',
  `name` VARCHAR(64) NOT NULL COMMENT '成就名称',
  `description` VARCHAR(255) DEFAULT NULL COMMENT '成就描述',
  `icon` VARCHAR(128) DEFAULT NULL COMMENT '成就图标(Unicode或SF Symbols)',
  `tier` TINYINT NOT NULL DEFAULT 1 COMMENT '等级(1铜牌2银牌3金牌4钻石)',
  `category` VARCHAR(32) NOT NULL COMMENT '分类(streak/count/subject/social)',
  `condition_type` VARCHAR(32) NOT NULL COMMENT '条件类型(streak_days/learn_count/master_count/review_count/comment_count/contribute_count)',
  `condition_value` INT NOT NULL DEFAULT 0 COMMENT '条件值',
  `exp_reward` INT NOT NULL DEFAULT 0 COMMENT '奖励经验值',
  `sort_order` INT NOT NULL DEFAULT 0 COMMENT '排序',
  `enabled` TINYINT NOT NULL DEFAULT 1 COMMENT '是否启用(0禁用1启用)',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`achievement_id`),
  UNIQUE KEY `uk_code` (`achievement_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='成就定义表';

-- 2. 用户成就记录表
CREATE TABLE IF NOT EXISTS `biz_user_achievement` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `achievement_id` BIGINT NOT NULL COMMENT '成就ID',
  `achievement_code` VARCHAR(64) NOT NULL COMMENT '成就代码',
  `achieved_at` DATETIME NOT NULL COMMENT '获得时间',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_achievement_id` (`achievement_id`),
  UNIQUE KEY `uk_user_achievement` (`user_id`, `achievement_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户成就记录表';

-- 3. 用户等级表
CREATE TABLE IF NOT EXISTS `biz_user_level` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `level` INT NOT NULL DEFAULT 1 COMMENT '当前等级',
  `current_exp` INT NOT NULL DEFAULT 0 COMMENT '当前等级经验',
  `total_exp` INT NOT NULL DEFAULT 0 COMMENT '累计获得经验',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户等级表';

-- 4. 经验值变动日志表
CREATE TABLE IF NOT EXISTS `biz_exp_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `exp_change` INT NOT NULL COMMENT '经验变化(正数增加)',
  `source_type` VARCHAR(32) NOT NULL COMMENT '来源类型(STUDY/MASTER/REVIEW/GOAL/ACHIEVEMENT/COMMENT/CONTRIBUTE)',
  `source_id` VARCHAR(64) DEFAULT NULL COMMENT '来源ID(如卡片ID)',
  `description` VARCHAR(128) DEFAULT NULL COMMENT '变动描述',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='经验值变动日志表';

-- 5. 用户学习目标表
CREATE TABLE IF NOT EXISTS `biz_learning_goal` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `goal_type` VARCHAR(16) NOT NULL COMMENT '目标类型(daily_learn/daily_master)',
  `target_count` INT NOT NULL DEFAULT 20 COMMENT '目标数量',
  `enabled` TINYINT NOT NULL DEFAULT 1 COMMENT '是否启用(0禁用1启用)',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_goal_type` (`user_id`, `goal_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户学习目标表';

-- 6. 每日目标完成记录表
CREATE TABLE IF NOT EXISTS `biz_goal_record` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `goal_date` DATE NOT NULL COMMENT '目标日期',
  `goal_type` VARCHAR(16) NOT NULL COMMENT '目标类型',
  `target_count` INT NOT NULL COMMENT '目标数量',
  `actual_count` INT NOT NULL DEFAULT 0 COMMENT '实际完成',
  `completed` TINYINT NOT NULL DEFAULT 0 COMMENT '是否完成(0未完成1完成)',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_date_type` (`user_id`, `goal_date`, `goal_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='每日目标完成记录表';

-- 7. 用户每日学习计数表
CREATE TABLE IF NOT EXISTS `biz_user_daily_count` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `count_date` DATE NOT NULL COMMENT '统计日期',
  `learn_count` INT NOT NULL DEFAULT 0 COMMENT '当日学习卡片数',
  `master_count` INT NOT NULL DEFAULT 0 COMMENT '当日掌握卡片数',
  `review_count` INT NOT NULL DEFAULT 0 COMMENT '当日复习卡片数',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_date` (`user_id`, `count_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户每日学习计数表';

-- =============================================
-- 初始成就数据
-- =============================================

-- 学习入门类
INSERT INTO `biz_achievement` (`achievement_code`, `name`, `description`, `icon`, `tier`, `category`, `condition_type`, `condition_value`, `exp_reward`, `sort_order`) VALUES
('FIRST_LEARN', '初次学习', '完成第一次卡片学习', 'book.fill', 1, 'count', 'learn_count', 1, 10, 1),
('FIRST_MASTER', '初次掌握', '掌握第一张卡片', 'star.fill', 1, 'count', 'master_count', 1, 15, 2),
('FIRST_REVIEW', '初次复习', '完成第一次复习', 'arrow.clockwise', 1, 'count', 'review_count', 1, 5, 3),
('FIRST_COMMENT', '初发议论', '首次评论卡片', 'bubble.left.fill', 1, 'social', 'comment_count', 1, 10, 4);

-- 连续学习类
INSERT INTO `biz_achievement` (`achievement_code`, `name`, `description`, `icon`, `tier`, `category`, `condition_type`, `condition_value`, `exp_reward`, `sort_order`) VALUES
('STREAK_3', '初露锋芒', '连续学习3天', 'flame', 1, 'streak', 'streak_days', 3, 30, 10),
('STREAK_7', '持之以恒', '连续学习7天', 'flame.fill', 2, 'streak', 'streak_days', 7, 80, 11),
('STREAK_14', '坚持不懈', '连续学习14天', 'bolt.fill', 2, 'streak', 'streak_days', 14, 150, 12),
('STREAK_30', '锲而不舍', '连续学习30天', 'flame.circle.fill', 3, 'streak', 'streak_days', 30, 300, 13),
('STREAK_60', '悬梁刺股', '连续学习60天', 'crown.fill', 3, 'streak', 'streak_days', 60, 600, 14),
('STREAK_100', '学业有成', '连续学习100天', 'crown.circle.fill', 4, 'streak', 'streak_days', 100, 1000, 15);

-- 学习数量类
INSERT INTO `biz_achievement` (`achievement_code`, `name`, `description`, `icon`, `tier`, `category`, `condition_type`, `condition_value`, `exp_reward`, `sort_order`) VALUES
('LEARN_50', '学而时习', '累计学习50张卡片', 'book', 1, 'count', 'learn_count', 50, 30, 20),
('LEARN_100', '学而不厌', '累计学习100张卡片', 'books.vertical.fill', 1, 'count', 'learn_count', 100, 50, 21),
('LEARN_300', '力学笃行', '累计学习300张卡片', 'graduationcap.fill', 2, 'count', 'learn_count', 300, 150, 22),
('LEARN_500', '博学多识', '累计学习500张卡片', 'brain.head.profile', 2, 'count', 'learn_count', 500, 250, 23),
('LEARN_1000', '学富五车', '累计学习1000张卡片', 'book.circle.fill', 3, 'count', 'learn_count', 1000, 500, 24);

-- 掌握数量类
INSERT INTO `biz_achievement` (`achievement_code`, `name`, `description`, `icon`, `tier`, `category`, `condition_type`, `condition_value`, `exp_reward`, `sort_order`) VALUES
('MASTER_10', '初窥门径', '累计掌握10张卡片', 'star', 1, 'count', 'master_count', 10, 30, 30),
('MASTER_50', '小有所成', '累计掌握50张卡片', 'star.fill', 1, 'count', 'master_count', 50, 100, 31),
('MASTER_100', '融会贯通', '累计掌握100张卡片', 'star.circle.fill', 2, 'count', 'master_count', 100, 200, 32),
('MASTER_300', '学有小成', '累计掌握300张卡片', 'sparkles', 2, 'count', 'master_count', 300, 450, 33),
('MASTER_500', '学贯中西', '累计掌握500张卡片', 'star.square.fill', 3, 'count', 'master_count', 500, 750, 34);

-- 科目成就类
INSERT INTO `biz_achievement` (`achievement_code`, `name`, `description`, `icon`, `tier`, `category`, `condition_type`, `condition_value`, `exp_reward`, `sort_order`) VALUES
('SUBJECT_FIRST', '学科入门', '完成任意科目第一张卡片学习', 'bookmark.fill', 1, 'subject', 'subject_first', 1, 20, 40),
('SUBJECT_LEARN_ALL', '学无遗阙', '学习某科目全部卡片', 'checkmark.seal.fill', 2, 'subject', 'subject_learn_rate', 100, 200, 41),
('SUBJECT_MASTER_HALF', '半壁江山', '掌握某科目50%以上卡片', 'chart.pie.fill', 2, 'subject', 'subject_master_rate', 50, 150, 42),
('SUBJECT_MASTER_ALL', '学科全通', '掌握某科目全部卡片', 'checkmark.seal.circle.fill', 3, 'subject', 'subject_master_rate', 100, 500, 43);

-- 社交类
INSERT INTO `biz_achievement` (`achievement_code`, `name`, `description`, `icon`, `tier`, `category`, `condition_type`, `condition_value`, `exp_reward`, `sort_order`) VALUES
('FIRST_CONTRIBUTE', '初次投稿', '首次提交卡片', 'square.and.pencil', 1, 'social', 'contribute_count', 1, 30, 50),
('CONTRIBUTE_ADOPTED', '稿件采纳', '投稿被采纳', 'checkmark.circle.fill', 2, 'social', 'contribute_adopted', 1, 100, 51),
('FIRST_CORRECTION', '捉虫大师', '首次纠错被采纳', 'ant.fill', 1, 'social', 'correction_adopted', 1, 50, 52);
