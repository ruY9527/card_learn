-- V16: 邮箱注册登录功能 - sys_user表添加email字段
-- 日期: 2026-05-05

-- 添加email字段
ALTER TABLE `sys_user`
  ADD COLUMN `email` varchar(100) NOT NULL DEFAULT '' COMMENT '邮箱' AFTER `nickname`;

-- 添加唯一约束
ALTER TABLE `sys_user`
  ADD UNIQUE KEY `uk_email` (`email`);

-- 邮箱激活配置项
INSERT INTO `sys_config` (`config_key`, `config_value`, `config_name`, `config_type`, `description`)
VALUES ('email_activation_required', 'true', '邮箱激活开关', 'boolean', '注册后是否需要邮箱激活，true=需要激活，false=直接激活');

INSERT INTO `sys_config` (`config_key`, `config_value`, `config_name`, `config_type`, `description`)
VALUES ('email_activate_url', 'http://localhost:5173/auth/activate', '邮箱激活链接地址', 'string', '激活邮件中的链接域名地址，如 https://yourdomain.com/auth/activate');
