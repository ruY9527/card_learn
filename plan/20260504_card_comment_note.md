# 卡片评论（笔记）功能设计方案 v1.0

## 一、需求总结

| 需求点 | 设计决策 |
|--------|----------|
| 核心概念 | 评论即笔记，对卡片的评论自动成为个人笔记 |
| 笔记入口 | iOS/Web端"我的笔记"独立入口 |
| 笔记属性 | 笔记标题非必填，关联原卡片 |
| 嵌套回复 | 限制2层（评论→回复→子回复） |
| 懒加载 | 评论/回复支持懒加载，避免一次性加载过多 |
| 点赞功能 | 评论和回复均可点赞 |
| 导出功能 | 多维度筛选+实时流式下载，过大提示迭代中 |
| 分享功能 | 生成图片分享，包含卡片+笔记内容 |
| 排序规则 | 按热度（点赞+回复）排序，相同按时间 |

---

## 二、数据库设计

### 2.1 修改表：`biz_card_comment`

| 字段 | 类型 | 说明 |
|------|------|------|
| `is_note` | TINYINT(1) | 是否作为笔记：0否 1是 |
| `like_count` | INT | 点赞数（冗余） |
| `reply_count` | INT | 回复数量（冗余） |
| `create_user` | BIGINT | 创建人 |
| `create_time` | DATETIME | 创建时间 |
| `update_user` | BIGINT | 修改人 |
| `update_time` | DATETIME | 修改时间 |

### 2.2 新建表：`biz_card_reply`

| 字段 | 类型 | 说明 |
|------|------|------|
| `reply_id` | BIGINT | 主键，自增 |
| `comment_id` | BIGINT | 所属评论ID |
| `card_id` | BIGINT | 卡片ID（冗余） |
| `user_id` | BIGINT | 回复用户ID |
| `user_nickname` | VARCHAR(50) | 回复用户昵称（冗余） |
| `content` | TEXT | 回复内容 |
| `like_count` | INT | 点赞数（冗余） |
| `parent_reply_id` | BIGINT | 父回复ID（null=第1层） |
| `status` | VARCHAR(1) | 状态：0正常 1已删除 |
| `create_user` | BIGINT | 创建人 |
| `create_time` | DATETIME | 创建时间 |
| `update_user` | BIGINT | 修改人 |
| `update_time` | DATETIME | 修改时间 |

### 2.3 新建表：`biz_comment_like`

| 字段 | 类型 | 说明 |
|------|------|------|
| `like_id` | BIGINT | 主键 |
| `comment_id` | BIGINT | 评论ID |
| `reply_id` | BIGINT | 回复ID |
| `user_id` | BIGINT | 点赞用户ID |
| `create_user` | BIGINT | 创建人 |
| `create_time` | DATETIME | 创建时间 |
| `update_user` | BIGINT | 修改人 |
| `update_time` | DATETIME | 修改时间 |

---

## 三、API 设计

### 3.1 笔记 API

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/miniprogram/note/my` | 获取我的笔记列表 |
| GET | `/api/miniprogram/note/{noteId}` | 获取笔记详情 |
| PUT | `/api/miniprogram/note/{noteId}` | 编辑笔记 |
| DELETE | `/api/miniprogram/note/{noteId}` | 删除笔记 |
| GET | `/api/miniprogram/note/export` | 导出笔记（流式下载） |

**查询参数（GET /my）：**

| 参数 | 说明 |
|------|------|
| `subjectId` | 按科目筛选 |
| `startDate` | 开始日期 |
| `endDate` | 结束日期 |
| `cardId` | 按卡片筛选 |
| `keyword` | 关键词搜索 |
| `pageNum` | 页码 |
| `pageSize` | 每页数量 |

**导出参数（GET /export）：**

| 参数 | 说明 |
|------|------|
| `subjectId` | 按科目筛选（可选） |
| `startDate` | 开始日期（可选） |
| `endDate` | 结束日期（可选） |
| `format` | 格式：txt/md/json |

### 3.2 评论 API

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/miniprogram/comment/submit` | 提交评论 |
| PUT | `/api/miniprogram/comment/{commentId}` | 编辑评论 |
| DELETE | `/api/miniprogram/comment/{commentId}` | 删除评论 |
| GET | `/api/miniprogram/comment/list/{cardId}` | 获取评论列表（懒加载） |
| GET | `/api/miniprogram/comment/stats/{cardId}` | 获取评论统计 |

### 3.3 回复 API

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/miniprogram/reply/{commentId}` | 提交回复 |
| PUT | `/api/miniprogram/reply/{replyId}` | 编辑回复 |
| DELETE | `/api/miniprogram/reply/{replyId}` | 删除回复 |
| GET | `/api/miniprogram/reply/list/{commentId}` | 获取回复列表（懒加载） |

### 3.4 点赞 API

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/miniprogram/like/comment/{commentId}` | 点赞评论 |
| DELETE | `/api/miniprogram/like/comment/{commentId}` | 取消点赞 |
| POST | `/api/miniprogram/like/reply/{replyId}` | 点赞回复 |
| DELETE | `/api/miniprogram/like/reply/{replyId}` | 取消点赞 |

### 3.5 分享 API

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/miniprogram/share/note/{noteId}` | 生成笔记分享图片 |
| POST | `/api/miniprogram/share/comment/{commentId}` | 生成评论分享图片 |

---

## 四、数据结构

### 4.1 评论 VO

```json
{
  "commentId": 1,
  "cardId": 100,
  "cardFrontContent": "什么是操作系统？",
  "subjectName": "操作系统",
  "userId": 10,
  "userNickname": "学习者A",
  "content": "操作系统是管理计算机...",
  "isNote": true,
  "rating": 5,
  "likeCount": 12,
  "likeStatus": true,
  "replyCount": 3,
  "replies": [],
  "hasMoreReplies": true,
  "createTime": "2026-05-04 10:00:00"
}
```

### 4.2 回复 VO

```json
{
  "replyId": 1,
  "commentId": 1,
  "userId": 11,
  "userNickname": "学习者B",
  "content": "补充一下...",
  "likeCount": 5,
  "likeStatus": false,
  "parentReplyId": null,
  "children": [],
  "hasMoreChildren": false,
  "createTime": "2026-05-04 11:00:00"
}
```

---

## 五、iOS 端设计

### 5.1 入口

`ProfileView.swift` → "我的笔记" 入口

### 5.2 页面

| 页面 | 文件 | 功能 |
|------|------|------|
| 笔记列表 | `MyNotesView.swift` | 筛选、搜索、删除、导出 |
| 笔记详情 | `NoteDetailView.swift` | 内容查看、跳转卡片、分享 |
| 评论面板 | `CardCommentView.swift` | 评论列表、回复、点赞、记为笔记 |

### 5.3 懒加载策略

```
评论列表：
├── 评论1 (2条回复)
├── 评论2 (0条回复)
├── 评论3 (5条回复) → 点击"展开更多2条回复"
└── 上拉加载更多

回复列表：
├── 评论3
    ├── 回复A (2条子回复)
    └── 回复B → 点击"展开更多1条"
```

---

## 六、Web 端 Vue 设计

### 6.1 页面结构

```
views/
├── content/card/components/
│   ├── CardComment.vue    # 评论面板容器
│   ├── CommentList.vue    # 评论列表（懒加载）
│   ├── CommentItem.vue    # 评论项
│   └── CommentEditor.vue   # 评论编辑器
└── my/
    └── NoteList.vue        # 我的笔记列表
```

### 6.2 我的笔记页面

```
┌─────────────────────────────────────────────────────┐
│ 我的笔记                              [导出] [分享]  │
├─────────────────────────────────────────────────────┤
│ [科目▼] [日期范围] [搜索...]                        │
├─────────────────────────────────────────────────────┤
│ ○ [操作系统]                        2026-05-04     │
│   什么是操作系统？                                   │
│   操作系统是管理计算机...          12赞 3回复 [查看] │
├─────────────────────────────────────────────────────┤
│ ○ [数据结构]                        2026-05-03     │
│   二叉树的遍历方式有哪些？                         │
│   先序遍历的实现...                8赞 2回复 [查看]│
└─────────────────────────────────────────────────────┘
```

---

## 七、实现顺序

```
第一阶段：后端基础
1. 数据库表创建
2. Reply实体+Mapper+Service+Controller
3. Like实体+Mapper+Service+Controller
4. 评论/回复CRUD + 点赞功能

第二阶段：后端笔记
5. 笔记API（列表、详情、编辑、删除）
6. 笔记导出（流式下载）
7. 分享图片生成

第三阶段：iOS端
8. 数据模型扩展
9. API扩展
10. 笔记列表页面
11. 评论/回复页面
12. 分享功能

第四阶段：Web端
13. Vue笔记列表页面
14. 评论组件
15. 分享功能
```

---

## 八、分享图片设计

```
┌─────────────────────────────────────┐
│  📚 CardLearn                       │
├─────────────────────────────────────┤
│  [科目标签]                          │
│                                     │
│  卡片内容：                          │
│  什么是操作系统？                    │
│                                     │
│  ─────────────────                  │
│                                     │
│  我的笔记：                          │
│  操作系统是管理计算机硬件和软件...    │
│                                     │
│  ─────────────────                  │
│                                     │
│  @学习者A  ·  2026-05-04           │
└─────────────────────────────────────┘
```
