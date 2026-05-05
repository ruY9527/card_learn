-- ----------------------------
-- 用户反馈表
-- ----------------------------
DROP TABLE IF EXISTS `biz_feedback`;
CREATE TABLE `biz_feedback` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint(20) DEFAULT NULL COMMENT '用户ID',
  `card_id` bigint(20) DEFAULT NULL COMMENT '关联的卡片ID（若是对具体卡片的纠错）',
  `major_id` bigint(20) DEFAULT NULL COMMENT '所属专业ID',
  `subject_id` bigint(20) DEFAULT NULL COMMENT '所属科目ID',
  `type` varchar(20) NOT NULL COMMENT '反馈类型: SUGGESTION(建议), ERROR(纠错), FUNCTION(功能问题), OTHER(其他)',
  `rating` tinyint(4) DEFAULT NULL COMMENT '评分（1-5星）',
  `content` text NOT NULL COMMENT '反馈详细内容',
  `contact` varchar(100) DEFAULT NULL COMMENT '用户留下的联系方式',
  `images` text DEFAULT NULL COMMENT '图片附件（存储URL列表，JSON格式）',
  `status` char(1) DEFAULT '0' COMMENT '处理状态（0待处理 1已采纳 2已忽略）',
  `admin_reply` text DEFAULT NULL COMMENT '管理员回复内容',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '处理时间',
  `update_user_id` bigint(20) DEFAULT NULL COMMENT '更新人ID',
  PRIMARY KEY (`id`),
  KEY `idx_card_id` (`card_id`),
  KEY `idx_status` (`status`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户反馈表';
