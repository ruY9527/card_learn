-- V17: 添加学习提醒时间字段
-- 在biz_learning_goal表中添加reminder_hour和reminder_minute字段

ALTER TABLE `biz_learning_goal`
  ADD COLUMN `reminder_hour` INT DEFAULT NULL COMMENT '提醒小时(0-23)' AFTER `enabled`,
  ADD COLUMN `reminder_minute` INT DEFAULT NULL COMMENT '提醒分钟(0-59)' AFTER `reminder_hour`;
