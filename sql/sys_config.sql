-- 系统配置表
CREATE TABLE IF NOT EXISTS `sys_config` (
    `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `config_key` varchar(100) NOT NULL COMMENT '配置键',
    `config_value` varchar(500) NOT NULL COMMENT '配置值',
    `config_name` varchar(100) NOT NULL COMMENT '配置名称',
    `config_type` varchar(50) DEFAULT 'string' COMMENT '配置类型(string/number/date/boolean/json)',
    `description` varchar(200) COMMENT '配置描述',
    `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_config_key` (`config_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统配置表';

-- 初始化冲刺阶段配置
INSERT INTO `sys_config` (`config_key`, `config_value`, `config_name`, `config_type`, `description`) VALUES
('sprint_exam_date', '2027-12-20', '考研倒计时日期', 'date', '考研冲刺阶段倒计时目标日期'),
('sprint_exam_name', '2027年全国硕士研究生招生考试', '考试名称', 'string', '冲刺阶段考试名称'),
('sprint_enabled', 'true', '冲刺模式开关', 'boolean', '是否启用冲刺模式倒计时显示');