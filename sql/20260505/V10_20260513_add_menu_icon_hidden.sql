-- V10: sys_menu 添加 icon、hidden 字段，并补全所有菜单数据

ALTER TABLE `sys_menu` ADD COLUMN `icon` varchar(100) DEFAULT NULL COMMENT '菜单图标' AFTER `menu_type`;
ALTER TABLE `sys_menu` ADD COLUMN `hidden` char(1) DEFAULT '0' COMMENT '是否隐藏（0否 1是）' AFTER `icon`;

-- 更新已有菜单的 icon、path 和 component
UPDATE `sys_menu` SET `icon` = 'Setting', `path` = 'system' WHERE `menu_id` = 1;
UPDATE `sys_menu` SET `icon` = 'User', `path` = 'system/user', `component` = 'views/system/user/index.vue' WHERE `menu_id` = 2;
UPDATE `sys_menu` SET `icon` = 'Folder', `path` = 'content' WHERE `menu_id` = 3;
UPDATE `sys_menu` SET `icon` = 'FolderOpened', `path` = 'major', `component` = 'views/content/major/index.vue' WHERE `menu_id` = 4;
UPDATE `sys_menu` SET `icon` = 'Document', `path` = 'subject', `component` = 'views/content/subject/index.vue' WHERE `menu_id` = 5;
UPDATE `sys_menu` SET `icon` = 'Tickets', `path` = 'card', `component` = 'views/content/card/index.vue' WHERE `menu_id` = 6;
UPDATE `sys_menu` SET `icon` = 'PriceTag', `path` = 'tag', `component` = 'views/content/tag/index.vue' WHERE `menu_id` = 7;

-- 补全缺失菜单：首页
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `menu_type`, `icon`) VALUES
(8, '首页', 0, 0, 'dashboard', 'views/dashboard/index.vue', 'C', 'HomeFilled');

-- 用户反馈目录 + 子菜单
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `menu_type`, `icon`) VALUES
(9, '用户反馈', 0, 3, 'feedback', NULL, 'M', 'ChatDotRound'),
(10, '反馈管理', 9, 1, 'feedback', 'views/feedback/index.vue', 'C', 'ChatLineSquare'),
(11, '卡片审批', 9, 2, 'card-audit', 'views/feedback/card-audit/index.vue', 'C', 'CircleCheck'),
(12, '评论管理', 9, 3, 'comment', 'views/comment/index.vue', 'C', 'Comment'),
(13, '笔记管理', 9, 4, 'note', 'views/note/index.vue', 'C', 'Notebook');

-- 数据统计目录 + 子菜单
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `menu_type`, `icon`) VALUES
(14, '数据统计', 0, 4, 'stats', NULL, 'M', 'DataAnalysis'),
(15, '学习数据统计', 14, 1, 'stats/learning', 'views/stats/learning/index.vue', 'C', 'TrendCharts'),
(16, '学习记录', 14, 2, 'stats/study-history', 'views/stats/study-history/index.vue', 'C', 'List'),
(17, '复习计划', 14, 3, 'stats/review-plan', 'views/stats/review-plan/index.vue', 'C', 'Calendar'),
(18, '学习报告', 14, 4, 'stats/report', 'views/stats/report/index.vue', 'C', 'Document');

-- 激励管理目录 + 子菜单
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `menu_type`, `icon`) VALUES
(19, '激励管理', 0, 5, 'incentive', NULL, 'M', 'Trophy'),
(20, '激励仪表盘', 19, 1, 'incentive/dashboard', 'views/incentive/dashboard/index.vue', 'C', 'Odometer'),
(21, '成就管理', 19, 2, 'incentive/achievement', 'views/incentive/achievement/index.vue', 'C', 'Medal'),
(22, '排行榜', 19, 3, 'incentive/rank', 'views/incentive/rank/index.vue', 'C', 'Histogram');

-- AI转化
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `menu_type`, `icon`) VALUES
(23, 'AI转化', 0, 6, 'ai', 'views/ai/index.vue', 'C', 'MagicStick');

-- 系统管理子菜单
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `menu_type`, `icon`) VALUES
(24, '角色管理', 1, 2, 'system/role', 'views/system/role/index.vue', 'C', 'UserFilled'),
(25, '菜单管理', 1, 3, 'system/menu', 'views/system/menu/index.vue', 'C', 'Menu'),
(26, '日志管理', 1, 4, 'system/log', 'views/system/log/index.vue', 'C', 'DocumentCopy'),
(27, '冲刺配置', 1, 5, 'system/sprint', 'views/system/sprint/index.vue', 'C', 'Sprint'),
(28, '邮箱配置', 1, 6, 'system/email-config', 'views/system/email-config/index.vue', 'C', 'Message');

-- admin 角色关联所有菜单
DELETE FROM `sys_role_menu` WHERE `role_id` = 1;
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7),
(1, 8), (1, 9), (1, 10), (1, 11), (1, 12), (1, 13),
(1, 14), (1, 15), (1, 16), (1, 17), (1, 18),
(1, 19), (1, 20), (1, 21), (1, 22),
(1, 23),
(1, 24), (1, 25), (1, 26), (1, 27), (1, 28);
