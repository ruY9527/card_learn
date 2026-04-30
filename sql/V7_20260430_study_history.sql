-- V7: 学习历史记录表
-- 记录用户每次学习行为，保留完整历史（biz_user_progress 只保留最新状态）

CREATE TABLE biz_study_history (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT COMMENT '用户ID',
  card_id BIGINT NOT NULL COMMENT '卡片ID',
  status TINYINT NOT NULL COMMENT '状态: 0=未学, 1=模糊, 2=掌握',
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '学习时间',
  INDEX idx_user_card (user_id, card_id),
  INDEX idx_user_status (user_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学习历史记录表';
