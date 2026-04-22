-- 系统请求日志表
CREATE TABLE IF NOT EXISTS `sys_request_log` (
    `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `request_method` varchar(10) NOT NULL COMMENT '请求方法(GET/POST/PUT/DELETE)',
    `request_url` varchar(500) NOT NULL COMMENT '请求URL',
    `class_name` varchar(200) NOT NULL COMMENT '类名',
    `method_name` varchar(100) NOT NULL COMMENT '方法名',
    `request_params` text COMMENT '请求参数(JSON)',
    `response_result` text COMMENT '响应结果(JSON)',
    `execution_time` bigint NOT NULL DEFAULT 0 COMMENT '执行耗时(毫秒)',
    `status` char(1) NOT NULL DEFAULT '1' COMMENT '执行状态(1成功 0失败)',
    `error_msg` text COMMENT '错误信息',
    `ip_address` varchar(50) COMMENT '请求IP地址',
    `user_id` bigint COMMENT '操作用户ID',
    `user_name` varchar(50) COMMENT '操作用户名',
    `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_request_url` (`request_url`),
    KEY `idx_create_time` (`create_time`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统请求日志表';