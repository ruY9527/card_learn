# 功能名字：用户反馈回路（User Feedback Loop）
这属于用户反馈回路（User Feedback Loop）。通过这个功能，你可以直接获取 408 考研学生对卡片内容的纠错建议（比如公式错误、解析不准）以及对系统功能的吐槽

# Web 后台管理端设计 (Web Admin Side)
Web 端是处理这些反馈的工作台，直接影响系统的迭代速度。
功能模块计划

    反馈列表看板：

        待办提醒：在 Web 首页显示“今日新增反馈 X 条”，提醒管理员处理。

        多维度筛选：按“待处理/已忽略/已采纳”状态过滤；按“纠错类型”排序（优先处理 408 内容纠错）。

    详情处理弹窗：

        内容比对：如果反馈关联了 card_id，右侧直接显示原卡片内容，左侧显示用户反馈，方便快速对比修改。

        快捷操作：提供“采纳并修改”按钮，点击后直接跳转到该卡片的编辑页面。

    回复系统：

        管理员可以填写处理意见，为以后小程序上线消息通知做准备。


# 后端接口开发 (Spring Boot)

提交接口 (POST /api/v1/feedback)：

    限流保护：同一设备每分钟限提交一次。

    异步通知：提交成功后，后端可通过集成钉钉/企业微信机器人通知你，让你第一时间知道有人纠错。

管理接口 (GET /admin/feedback/list)：

    支持分页和按状态过滤。

# 小程序端功能设计 (App Side)

在小程序端，反馈功能应分为“主动反馈”和“卡片纠错”两个入口。
2.1 功能描述

    入口一：卡片详情页纠错

        在知识点卡片的背面（解析页）放置一个“报错/纠错”图标。

        自动锚定：点击时自动带入当前 card_id，方便后台定位。

    入口二：个人中心/关于页反馈

        属于通用的功能建议或系统评价。

    核心交互：

        评分组件：1-5星好评，用于收集用户对系统的整体满意度。

        分类选择：通过 Picker 选择反馈类型（内容有误、排版问题、新功能建议）。

        图片上传：支持拍照或从相册选择（如用户拍下教材原文来证明你的卡片写错了）。

2.2 游客模式适配

    即便不登录，用户也可以提交反馈。

    技术细节：提交时后端记录用户的 IP 地址或 设备标识，防止恶意刷票/攻击。

# 数据库设计
```docker
-- ----------------------------
-- 12. 用户反馈与评分表
-- ----------------------------
DROP TABLE IF EXISTS `biz_feedback`;
CREATE TABLE `biz_feedback` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `app_user_id` bigint(20) DEFAULT NULL COMMENT '用户ID（游客模式可为空）',
  `card_id` bigint(20) DEFAULT NULL COMMENT '关联的卡片ID（若是对具体卡片的纠错）',
  `type` varchar(20) NOT NULL COMMENT '反馈类型: SUGGESTION(建议), ERROR(纠错), FUNCTION(功能), OTHER(其他)',
  `rating` tinyint(4) DEFAULT NULL COMMENT '评分（1-5星）',
  `content` text NOT NULL COMMENT '反馈详细内容',
  `contact` varchar(100) DEFAULT NULL COMMENT '用户留下的联系方式',
  `images` text DEFAULT NULL COMMENT '图片附件（存储URL列表，JSON格式）',
  `status` char(1) DEFAULT '0' COMMENT '处理状态（0待处理 1已采纳 2已忽略）',
  `admin_reply` text DEFAULT NULL COMMENT '管理员回复内容',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '处理时间',
  PRIMARY KEY (`id`),
  KEY `idx_card_id` (`card_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户反馈表';
```

# 阶段性价值建议
V1 阶段：重点放在内容纠错上。408 的知识点非常严谨，一旦用户发现你的公式或伪代码有误并反馈，你必须以最快速度修改。这不仅是优化，更是建立专业口碑的过程。

数据驱动迭代：

    如果某张卡片的纠错率极高，说明该知识点本身是难点，或者是你的 AI 初始生成的质量不行。

    你可以根据反馈频率，决定接下来是优先更新“操作系统”的卡片，还是优先完善“计网”的内容。