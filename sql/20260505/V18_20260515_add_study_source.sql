-- 学习历史表新增来源字段，标记学习来自 web/ios/mini
ALTER TABLE `biz_study_history`
  ADD COLUMN `source` VARCHAR(20) DEFAULT NULL COMMENT '学习来源: web/ios/mini' AFTER `status`;
