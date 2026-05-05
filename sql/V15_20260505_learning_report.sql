-- V15 学习报告功能 - 新增表
-- 创建日期: 2026-05-05

-- 学习报告表
CREATE TABLE IF NOT EXISTS `biz_learning_report` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `report_type` varchar(10) NOT NULL COMMENT '报告类型: weekly/monthly',
  `period_start` date NOT NULL COMMENT '统计周期开始日期',
  `period_end` date NOT NULL COMMENT '统计周期结束日期',
  `report_data` longtext COMMENT '报告数据JSON',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_type` (`user_id`, `report_type`),
  KEY `idx_period` (`period_start`, `period_end`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学习报告表';

-- 薄弱点记录表
CREATE TABLE IF NOT EXISTS `biz_weak_point` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `card_id` bigint(20) NOT NULL COMMENT '卡片ID',
  `error_count` int(11) DEFAULT 1 COMMENT '错误次数',
  `last_error_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最后错误时间',
  `status` varchar(10) DEFAULT 'active' COMMENT '状态: active/reviewed',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_card` (`user_id`, `card_id`),
  KEY `idx_error_count` (`error_count` DESC),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='薄弱点记录表';

-- 每日学习统计快照表
CREATE TABLE IF NOT EXISTS `biz_daily_stats_snapshot` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `stats_date` date NOT NULL COMMENT '统计日期',
  `total_cards` int(11) DEFAULT 0 COMMENT '当日学习卡片数',
  `new_mastered` int(11) DEFAULT 0 COMMENT '当日新掌握卡片数',
  `forgotten` int(11) DEFAULT 0 COMMENT '当日遗忘卡片数',
  `study_duration` int(11) DEFAULT 0 COMMENT '当日学习时长(分钟)',
  `mastery_rate` decimal(5,2) DEFAULT 0.00 COMMENT '当日掌握率',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_date` (`user_id`, `stats_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='每日学习统计快照';
