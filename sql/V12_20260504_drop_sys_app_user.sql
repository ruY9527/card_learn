-- V12: 删除 sys_app_user 表，统一使用 sys_user
-- 前提：sys_app_user 数据已迁移到 sys_user

-- 1. 删除 sys_app_user 表
DROP TABLE IF EXISTS `sys_app_user`;
