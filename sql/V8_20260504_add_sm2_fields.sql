-- V8: 为 biz_user_progress 表添加 SM-2 算法字段
-- ease_factor: SM-2 容易系数，默认 2.5
-- repetitions: SM-2 连续正确次数，默认 0
-- interval_days: SM-2 复习间隔天数，默认 1

ALTER TABLE `biz_user_progress`
  ADD COLUMN `ease_factor` DOUBLE DEFAULT 2.5 COMMENT 'SM-2容易系数' AFTER `status`,
  ADD COLUMN `repetitions` INT DEFAULT 0 COMMENT 'SM-2连续正确次数' AFTER `ease_factor`,
  ADD COLUMN `interval_days` INT DEFAULT 1 COMMENT 'SM-2复习间隔天数' AFTER `repetitions`;
