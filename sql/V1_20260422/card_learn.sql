/*
 Navicat Premium Data Transfer

 Source Server         : docker_3308_8
 Source Server Type    : MySQL
 Source Server Version : 80032 (8.0.32)
 Source Host           : localhost:3308
 Source Schema         : card_learn

 Target Server Type    : MySQL
 Target Server Version : 80032 (8.0.32)
 File Encoding         : 65001

 Date: 22/04/2026 18:43:44
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for biz_card
-- ----------------------------
DROP TABLE IF EXISTS `biz_card`;
CREATE TABLE `biz_card` (
  `card_id` bigint NOT NULL AUTO_INCREMENT COMMENT '卡片ID',
  `subject_id` bigint NOT NULL COMMENT '所属科目ID',
  `front_content` text NOT NULL COMMENT '卡片正面(支持Markdown/LaTeX)',
  `back_content` text NOT NULL COMMENT '卡片反面(答案/解析)',
  `difficulty_level` tinyint DEFAULT '1' COMMENT '难度系数(1-5)',
  `del_flag` char(1) DEFAULT '0' COMMENT '删除标志',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`card_id`),
  KEY `idx_subject_id` (`subject_id`)
) ENGINE=InnoDB AUTO_INCREMENT=266 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='知识点卡片表';

-- ----------------------------
-- Records of biz_card
-- ----------------------------
BEGIN;
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (1, 1, '什么是时间复杂度？如何计算算法的时间复杂度？', '时间复杂度是衡量算法运行时间随输入规模增长的变化趋势的指标。\n\n计算方法：\n1. 找出算法中的基本操作（最深层循环内的操作）\n2. 计算基本操作执行的次数与输入规模n的关系\n3. 取最高阶项，忽略低阶项和常数系数\n\n常见时间复杂度：O(1) < O(logn) < O(n) < O(nlogn) < O(n²) < O(n³) < O(2^n)', 2, '0', '2026-04-21 13:22:07', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (2, 1, '快速排序的基本思想和时间复杂度是什么？', '基本思想：分治法\n1. 选取一个基准元素(pivot)\n2. 将数组分为两部分：小于pivot的放左边，大于pivot的放右边\n3. 递归地对左右两部分进行排序\n\n时间复杂度：\n- 平均情况：O(nlogn)\n- 最坏情况：O(n²)（每次选取的pivot都是最大或最小元素）\n- 最好情况：O(nlogn)\n\n空间复杂度：O(logn)（递归调用栈）', 3, '0', '2026-04-21 13:22:07', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (3, 1, '什么是哈希表？如何解决哈希冲突？', '哈希表：根据关键码值(Key value)直接进行访问的数据结构，通过哈希函数将键映射到数组索引。\n\n解决哈希冲突的方法：\n1. **开放定址法**：线性探测、二次探测、双重哈希\n2. **链地址法**：将冲突的元素用链表连接\n3. **再哈希法**：使用多个哈希函数\n4. **建立公共溢出区**：将冲突元素存放到溢出区\n\n链地址法是最常用的方法，Java的HashMap就采用此方法。', 3, '0', '2026-04-21 13:22:07', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (4, 1, '二叉树的遍历方式有哪些？各自的实现方式？', '四种主要遍历方式：\n\n1. **前序遍历**（根-左-右）：递归、栈实现\n2. **中序遍历**（左-根-右）：递归、栈实现\n3. **后序遍历**（左-右-根）：递归、栈实现\n4. **层序遍历**（按层次）：队列实现\n\n非递归实现关键：\n- 前序/中序：用栈，入栈顺序不同\n- 后序：需要记录上一个访问的节点\n- 层序：用队列，先进先出', 2, '0', '2026-04-21 13:22:07', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (5, 1, '什么是红黑树？它的性质有哪些？', '红黑树是一种自平衡的二叉搜索树，保证在最坏情况下基本操作的时间复杂度为O(logn)。\n\n五大性质：\n1. 每个节点是红色或黑色\n2. 根节点是黑色\n3. 所有叶子节点（NIL）是黑色\n4. 红色节点的两个子节点都是黑色（不能有连续的红色节点）\n5. 从任一节点到其每个叶子的所有路径包含相同数量的黑色节点\n\n应用：Java的TreeMap、TreeSet、HashMap在链表长度>8时转为红黑树', 4, '0', '2026-04-21 13:22:07', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (6, 1, '图的最短路径算法有哪些？Dijkstra算法的原理？', '最短路径算法：\n1. **Dijkstra**：单源最短路径，不含负权边\n2. **Bellman-Ford**：单源最短路径，含负权边\n3. **Floyd**：多源最短路径\n4. **SPFA**：Bellman-Ford的优化\n\nDijkstra原理：\n1. 初始化：起点距离为0，其他为无穷大\n2. 选择距离最小的未访问节点\n3. 更新其邻居节点的距离\n4. 标记该节点为已访问\n5. 重复2-4直到所有节点访问完\n\n时间复杂度：O(V²)或O(ElogV)（用优先队列优化）', 4, '0', '2026-04-21 13:22:07', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (7, 2, '什么是Cache？Cache的工作原理是什么？', 'Cache（高速缓存）是位于CPU和主存之间的小容量高速存储器。\n\n工作原理：\n1. **局部性原理**：时间局部性（最近访问的数据可能再次访问）、空间局部性（访问位置附近的数据可能被访问）\n2. CPU访问数据时，先查Cache，命中则直接获取；未命中则从主存获取并调入Cache\n\n映射方式：\n- 直接映射：每个主存块只能映射到一个特定Cache行\n- 全相联映射：主存块可映射到任意Cache行\n- 组相联映射：主存块可映射到特定组中的任意行\n\n命中率计算：命中率 = 命中次数 / 总访问次数', 3, '0', '2026-04-21 13:22:07', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (8, 2, '什么是中断？中断处理的过程是怎样的？', '中断：CPU暂停当前程序，转去处理突发事件，处理完后返回继续执行。\n\n中断处理过程：\n1. **中断请求**：外设向CPU发出中断信号\n2. **中断响应**：CPU在指令周期末检查中断信号\n3. **保护现场**：保存PC、PSW等寄存器\n4. **中断识别**：确定中断源（向量中断或查询中断）\n5. **执行中断服务程序**：处理中断事件\n6. **恢复现场**：恢复保存的寄存器\n7. **中断返回**：返回原程序继续执行\n\n中断类型：硬中断（外设）、软中断（系统调用）、异常（程序错误）', 3, '0', '2026-04-21 13:22:07', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (9, 2, 'DMA的工作原理是什么？与中断方式的区别？', 'DMA（直接存储器访问）：允许外设直接与主存交换数据，无需CPU干预。\n\n工作原理：\n1. CPU初始化DMA控制器（源地址、目标地址、数据量）\n2. DMA控制器接管总线，直接进行数据传输\n3. 传输完成后，DMA向CPU发送中断信号\n4. CPU处理后续工作\n\n与中断方式的区别：\n- 中断：每次传输一个数据单位就需要CPU干预\n- DMA：批量传输，CPU只需在开始和结束时干预\n\nDMA适用场景：磁盘I/O、网络传输等大量数据传输', 4, '0', '2026-04-21 13:22:07', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (10, 2, '浮点数的表示方法是什么？IEEE 754标准？', '浮点数表示：N = M × 2^E\n- M：尾数（mantissa），表示精度\n- E：阶码（exponent），表示范围\n\nIEEE 754标准格式：\n- **符号位S**：1位，0正1负\n- **阶码E**：采用移码表示，偏置值=127（32位）或1023（64位）\n- **尾数M**：采用原码表示，隐含最高位1\n\n32位浮点数(float)：\n- S(1位) + E(8位) + M(23位)\n- 范围约：±3.4×10^38\n\n64位浮点数(double)：\n- S(1位) + E(11位) + M(52位)\n- 范围约：±1.8×10^308', 4, '0', '2026-04-21 13:22:07', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (11, 2, '流水线技术的基本原理？流水线的性能指标？', '流水线技术：将指令执行过程分解为多个阶段，各阶段并行工作。\n\n典型5级流水线：\n1. IF（取指）\n2. ID（译码）\n3. EX（执行）\n4. MEM（访存）\n5. WB（写回）\n\n性能指标：\n- **吞吐率**：单位时间完成的指令数 TP = n / Tk\n- **加速比**：S = T顺序 / T流水\n- **效率**：E = 有效时空区 / 总时空区\n\n流水线冲突：\n1. 结构冲突：资源冲突\n2. 数据冲突：数据依赖\n3. 控制冲突：分支指令\n\n解决方法：暂停、转发、预测', 4, '0', '2026-04-21 13:22:07', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (12, 3, '什么是PV操作？如何使用PV操作实现互斥？', 'PV操作是信号量的两种基本操作，用于进程同步与互斥。\n\n**P操作（wait）**：\n- S.value--\n- 若S.value < 0，进程阻塞，放入等待队列\n\n**V操作（signal）**：\n- S.value++\n- 若S.value <= 0，唤醒等待队列中的一个进程\n\n实现互斥：\n```\nsemaphore mutex = 1;\nP1: P(mutex); 临界区; V(mutex);\nP2: P(mutex); 临界区; V(mutex);\n```\n\n注意：PV操作必须成对出现，P在临界区前，V在临界区后。', 3, '0', '2026-04-21 13:22:07', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (13, 3, '进程调度算法有哪些？各自的优缺点？', '常见进程调度算法：\n\n1. **FCFS（先来先服务）**：简单但可能导致\"护航效应\"\n\n2. **SJF/SPF（短作业优先）**：平均等待时间最短，但需要预知作业长度\n\n3. **SRTN（最短剩余时间优先）**：SJF的抢占版本\n\n4. **RR（时间片轮转）**：公平，适合分时系统，时间片大小影响性能\n\n5. **优先级调度**：可抢占或非抢占，可能导致低优先级进程\"饥饿\"\n\n6. **多级反馈队列**：综合多种算法，动态调整优先级和时间片\n\n评价标准：CPU利用率、吞吐量、周转时间、等待时间、响应时间', 3, '0', '2026-04-21 13:22:07', '2026-04-22 10:32:11');
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (14, 3, '虚拟内存的基本原理？页面置换算法有哪些？', '虚拟内存：将部分进程数据装入内存，其余放在磁盘，需要时调入。\n\n基本原理：\n1. **分页**：将进程和内存划分为固定大小的页和页框\n2. **页表**：记录页与页框的映射关系\n3. **TLB**：快表，加速地址转换\n4. **缺页中断**：访问的页不在内存时触发\n\n页面置换算法：\n1. **OPT（最优）**：置换未来最长时间不使用的页（理论算法）\n2. **FIFO**：置换最早进入的页，可能出现Belady异常\n3. **LRU**：置换最近最少使用的页\n4. **Clock**：LRU的近似实现，用访问位\n5. **LFU**：置换访问次数最少的页', 4, '0', '2026-04-21 13:22:07', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (15, 3, '什么是死锁？死锁的四个必要条件？如何预防？', '死锁：多个进程因争夺资源而互相等待，导致都无法继续执行。\n\n**四个必要条件**（必须同时满足）：\n1. **互斥条件**：资源不能共享\n2. **请求与保持条件**：进程持有资源同时请求新资源\n3. **不剥夺条件**：已获得的资源不能被强制抢占\n4. **循环等待条件**：存在进程资源的循环等待链\n\n**预防策略**：\n1. 破坏互斥：不易实现\n2. 破坏请求与保持：一次性申请所有资源\n3. 破坏不剥夺：资源可被抢占\n4. 破坏循环等待：资源有序分配\n\n**避免**：银行家算法\n**检测与恢复**：定期检测，剥夺资源或撤销进程', 4, '0', '2026-04-21 13:22:07', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (16, 3, '文件系统的实现方式？inode是什么？', '文件系统实现方式：\n\n1. **连续分配**：文件占用连续磁盘块\n   - 优点：访问快\n   - 缺点：外部碎片、文件大小固定\n\n2. **链接分配**：每个块包含指向下一块的指针\n   - 优点：无外部碎片\n   - 缺点：随机访问慢、指针占用空间\n\n3. **索引分配**：使用索引块记录所有数据块位置\n   - 优点：支持随机访问\n   - 缺点：索引块开销\n\n**inode（索引节点）**：\n- 存储文件的元数据（权限、时间、大小等）\n- 包含指向数据块的指针\n- 文件名存储在目录项中，inode存储文件内容信息\n\nLinux中：df -i查看inode使用情况', 3, '0', '2026-04-21 13:22:07', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (17, 4, 'TCP三次握手的过程？为什么需要三次握手？', 'TCP三次握手过程：\n\n1. **第一次**：客户端发送SYN=1，seq=x，进入SYN_SENT状态\n2. **第二次**：服务器回复SYN=1，ACK=1，seq=y，ack=x+1，进入SYN_RCVD状态\n3. **第三次**：客户端发送ACK=1，seq=x+1，ack=y+1，双方进入ESTABLISHED状态\n\n**为什么需要三次握手**：\n1. 防止已失效的连接请求突然到达服务器，导致错误建立连接\n2. 同步双方的初始序列号\n3. 确认双方的接收和发送能力\n\n如果是两次握手，服务器无法确认客户端是否收到自己的SYN。', 3, '0', '2026-04-21 13:22:07', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (18, 4, 'TCP四次挥手的过程？为什么需要四次？', 'TCP四次挥手过程：\n\n1. **第一次**：客户端发送FIN=1，seq=u，进入FIN_WAIT_1状态\n2. **第二次**：服务器回复ACK=1，ack=u+1，进入CLOSE_WAIT状态；客户端进入FIN_WAIT_2\n3. **第三次**：服务器发送FIN=1，seq=w，进入LAST_ACK状态\n4. **第四次**：客户端回复ACK=1，ack=w+1，进入TIME_WAIT状态（等待2MSL后关闭）；服务器关闭\n\n**为什么需要四次挥手**：\n- TCP是全双工通信，每个方向的关闭需要单独进行\n- 服务器收到FIN后可能还有数据要发送，不能立即关闭\n\n**TIME_WAIT作用**：\n1. 确保ACK到达服务器\n2. 等待旧连接的数据在网络中消失', 3, '0', '2026-04-21 13:22:07', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (19, 4, 'TCP与UDP的区别？各自的适用场景？', 'TCP vs UDP区别：\n\n| 特性 | TCP | UDP |\n|------|-----|-----|\n| 连接 | 面向连接 | 无连接 |\n| 可靠性 | 可靠传输 | 尽力交付 |\n| 流量控制 | 有（滑动窗口） | 无 |\n| 拥塞控制 | 有 | 无 |\n| 传输方式 | 字节流 | 报文 |\n| 首部开销 | 20字节 | 8字节 |\n| 速度 | 较慢 | 较快 |\n\n**TCP适用场景**：需要可靠传输的应用\n- HTTP、FTP、SMTP、SSH\n\n**UDP适用场景**：实时性强、容忍少量丢包的应用\n- DNS、DHCP、TFTP\n- 视频会议、直播、游戏\n- SNMP', 2, '0', '2026-04-21 13:22:07', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (20, 4, 'OSI七层模型和TCP/IP四层模型的对应关系？', 'OSI七层模型与TCP/IP四层模型：\n\n| OSI七层 | TCP/IP四层 | 功能 | 协议示例 |\n|---------|------------|------|----------|\n| 应用层 | 应用层 | 用户交互 | HTTP、FTP、DNS |\n| 表示层 | | 数据格式转换 | SSL/TLS |\n| 会话层 | | 会话管理 | RPC |\n| 传输层 | 传输层 | 端到端通信 | TCP、UDP |\n| 网络层 | 网络层 | 路由选择 | IP、ICMP |\n| 数据链路层 | 网络接口层 | 帧传输 | Ethernet、ARP |\n| 物理层 | | 比特传输 | RJ45、光纤 |\n\n每层只与相邻层交互，数据向下封装，向上解封装。', 2, '0', '2026-04-21 13:22:07', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (21, 4, 'HTTP协议的状态码有哪些？常见状态码的含义？', 'HTTP状态码分类：\n\n- **1xx**：信息性状态码\n- **2xx**：成功状态码\n- **3xx**：重定向状态码\n- **4xx**：客户端错误\n- **5xx**：服务器错误\n\n**常见状态码**：\n\n| 状态码 | 含义 |\n|--------|------|\n| 200 | OK，请求成功 |\n| 301 | Moved Permanently，永久重定向 |\n| 302 | Found，临时重定向 |\n| 304 | Not Modified，缓存有效 |\n| 400 | Bad Request，请求语法错误 |\n| 401 | Unauthorized，未授权 |\n| 403 | Forbidden，禁止访问 |\n| 404 | Not Found，资源不存在 |\n| 500 | Internal Server Error，服务器内部错误 |\n| 503 | Service Unavailable，服务不可用 |', 2, '0', '2026-04-21 13:22:07', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (22, 4, '什么是滑动窗口？流量控制和拥塞控制的区别？', '滑动窗口：TCP流量控制的机制，控制发送方的发送速率。\n\n**流量控制**：\n- 目的：防止发送方发送过快导致接收方缓冲区溢出\n- 方法：接收方在ACK中通告窗口大小rwnd\n- 发送窗口 = min(rwnd, cwnd)\n\n**拥塞控制**：\n- 目的：防止过多数据注入网络导致网络拥塞\n- 方法：\n  1. **慢开始**：cwnd从1开始指数增长\n  2. **拥塞避免**：cwnd线性增长\n  3. **快重传**：收到3个重复ACK立即重传\n  4. **快恢复**：cwnd减半，直接进入拥塞避免\n\n区别：流量控制是端到端的，拥塞控制是全局的。', 4, '0', '2026-04-21 13:22:07', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (23, 1, '什么是数据（Data）？', '**定义**：数据是信息的载体，是描述客观事物的数、字符以及所有能输入到计算机中并被计算机程序识别和处理的符号集合。\n\n**特点**：\n- 数据是计算机程序加工的\"原料\"\n- 数据的含义称为数据的语义\n- 例如：整数 `42`、字符串 `\"hello\"`、学生记录 `{学号: 2021001, 姓名: \"张三\", 成绩: 85}`', 1, '0', '2026-04-22 08:22:15', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (24, 1, '什么是数据元素（Data Element）？', '**定义**：数据元素是数据的基本单位，在计算机程序中通常作为一个整体进行考虑和处理。\n\n**特点**：\n- 一个数据元素可由若干个**数据项**组成\n- 数据项是数据不可分割的最小单位\n- 例如：学生表中的一条记录是一个数据元素，学号、姓名、成绩是数据项', 1, '0', '2026-04-22 08:22:15', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (25, 1, '什么是数据对象（Data Object）？', '**定义**：数据对象是性质相同的数据元素的集合，是数据的一个子集。\n\n**特点**：\n- 数据对象中的数据元素具有相同的性质\n- 例如：整数数据对象 $N = \\{0, 1, 2, 3, \\ldots\\}$、字母字符数据对象 $C = \\{\'A\', \'B\', \'C\', \\ldots, \'Z\'\\}$', 1, '0', '2026-04-22 08:22:15', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (26, 1, '什么是数据结构（Data Structure）？', '**定义**：数据结构是相互之间存在一种或多种特定关系的数据元素的集合。\n\n**三要素**：\n1. **逻辑结构**：数据元素之间的逻辑关系\n2. **存储结构（物理结构）**：数据元素在计算机中的存储表示\n3. **数据的运算**：对数据元素施加的操作\n\n**注意**：数据结构的研究内容 = 逻辑结构 + 存储结构 + 运算', 2, '0', '2026-04-22 08:22:15', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (27, 1, '数据结构的逻辑结构有哪些类型？', '**逻辑结构的四种基本类型**：\n\n| 类型 | 描述 | 示例 |\n|------|------|------|\n| **集合结构** | 数据元素之间除了\"同属一个集合\"外无其他关系 | $\\{a, b, c, d\\}$ |\n| **线性结构** | 数据元素之间存在一对一的关系 | 线性表、栈、队列 |\n| **树形结构** | 数据元素之间存在一对多的关系 | 二叉树、B树 |\n| **图状结构/网状结构** | 数据元素之间存在多对多的关系 | 有向图、无向图 |\n\n**层次关系**：\n$$集合 \\subset 线性 \\subset 树 \\subset 图$$', 2, '0', '2026-04-22 08:22:15', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (28, 1, '数据结构的存储结构（物理结构）有哪些类型？', '**四种基本存储结构**：\n\n| 类型 | 描述 | 优缺点 |\n|------|------|--------|\n| **顺序存储** | 用连续存储单元依次存放元素，逻辑关系由存储位置体现 | 优点：随机访问 $O(1)$；缺点：插入删除需移动元素 |\n| **链式存储** | 元素存储在任意位置，用指针指示逻辑关系 | 优点：插入删除 $O(1)$；缺点：无随机访问 |\n| **索引存储** | 建立索引表，通过索引访问元素 | 优点：查找快；缺点：占用额外空间 |\n| **散列存储** | 根据关键字计算存储地址 | 优点：查找平均 $O(1)$；缺点：冲突处理复杂 |\n\n**注意**：顺序存储和链式存储是最基本的两种存储结构', 2, '0', '2026-04-22 08:22:15', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (29, 1, '顺序存储和链式存储的区别是什么？', '**对比分析**：\n\n| 特性 | 顺序存储 | 链式存储 |\n|------|----------|----------|\n| **空间分配** | 预分配，可能浪费或不足 | 动态分配，按需申请 |\n| **空间利用率** | 无额外指针开销，但可能预分配浪费 | 需要指针域，但无预分配浪费 |\n| **访问效率** | 随机访问，$O(1)$ | 只能顺序访问，$O(n)$ |\n| **插入删除** | 需移动大量元素，$O(n)$ | 只需修改指针，$O(1)$ |\n| **适用场景** | 频繁查找、静态数据 | 频繁插入删除、动态数据 |\n\n**结论**：\n- 存储密度：顺序存储 > 链式存储（顺序存储无指针开销）\n- 操作灵活性：链式存储 > 顺序存储（链式存储插入删除更高效）', 3, '0', '2026-04-22 08:22:15', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (30, 1, '什么是数据类型（Data Type）？', '**定义**：数据类型是一个值的集合和定义在此值集上的一组操作的总称。\n\n**分类**：\n- **原子类型**：不可再分的基本类型，如 `int`、`char`、`float`\n- **结构类型**：由若干成分组合而成，如数组、结构体、类\n\n**作用**：\n1. 约束变量或表达式的取值范围\n2. 约束变量或表达式能进行的操作', 1, '0', '2026-04-22 08:22:15', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (31, 1, '什么是抽象数据类型（ADT）？', '**定义**：抽象数据类型（Abstract Data Type, ADT）是指一个数学模型以及定义在该模型上的一组操作。\n\n**特点**：\n- **抽象性**：只关心逻辑特性，不关心具体实现\n- **封装性**：将数据和操作封装在一起，隐藏实现细节\n\n**ADT的三要素**：\n$$ADT = (D, S, P)$$\n- $D$：数据对象\n- $S$：$D$上的关系集\n- $P$：对$D$的基本操作集\n\n**示例定义格式**：\n```\nADT 抽象数据类型名 {\n    数据对象: <数据对象的定义>\n    数据关系: <数据关系的定义>\n    基本操作: <基本操作的定义>\n}\n```', 2, '0', '2026-04-22 08:22:15', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (32, 1, '什么是算法（Algorithm）？', '**定义**：算法是对特定问题求解步骤的一种描述，是指令的有限序列。\n\n**算法的五个重要特性**：\n1. **有穷性**：算法必须能在执行有限步后结束\n2. **确定性**：每一步必须有确切的定义，无歧义\n3. **可行性**：每一步都能通过已实现的基本操作执行\n4. **输入**：有零个或多个输入\n5. **输出**：有一个或多个输出\n\n**注意**：程序不等于算法！程序可以是无限的（如操作系统），算法必须是有穷的', 1, '0', '2026-04-22 08:22:16', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (33, 1, '什么是算法的时间复杂度？', '**定义**：算法的时间复杂度是算法执行时间的增长率，用 $T(n) = O(f(n))$ 表示。\n\n**大O表示法**：如果存在正常数 $c$ 和 $n_0$，使得对所有 $n \\geq n_0$ 都有 $T(n) \\leq c \\cdot f(n)$，则 $T(n) = O(f(n))$。\n\n**常见时间复杂度比较**：\n$$O(1) < O(\\log_2 n) < O(n) < O(n\\log_2 n) < O(n^2) < O(n^3) < O(2^n) < O(n!) < O(n^n)$$\n\n**计算方法**：\n1. 找出基本操作（最深层循环内的语句）\n2. 计算基本操作执行次数 $f(n)$\n3. 取 $f(n)$ 的最高阶项，忽略低阶项和常数系数', 2, '0', '2026-04-22 08:22:16', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (34, 1, '常见时间复杂度的含义和示例', '**时间复杂度详解**：\n\n| 复杂度 | 名称 | 典型示例 |\n|--------|------|----------|\n| $O(1)$ | 常数阶 | 访问数组元素、哈希表查找 |\n| $O(\\log_2 n)$ | 对数阶 | 二分查找、折半插入排序 |\n| $O(n)$ | 线性阶 | 顺序查找、遍历数组 |\n| $O(n\\log_2 n)$ | 线性对数阶 | 快速排序、归并排序、堆排序 |\n| $O(n^2)$ | 平方阶 | 冒泡排序、简单选择排序 |\n| $O(n^3)$ | 立方阶 | 矩阵乘法（朴素算法） |\n| $O(2^n)$ | 指数阶 | 汉诺塔问题、穷举搜索 |\n| $O(n!)$ | 排列阶 | 旅行商问题（穷举） |\n\n**递归算法时间复杂度分析**：\n```c\nvoid fun(int n) {\n    int i = 1;\n    while(i <= n) i = i * 2;\n}\n```\n循环次数 $k$：$2^k > n$，即 $k > \\log_2 n$\n时间复杂度：$T(n) = O(\\log_2 n)$', 2, '0', '2026-04-22 08:22:16', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (35, 1, '什么是算法的空间复杂度？', '**定义**：算法的空间复杂度是算法所需存储空间的增长率，用 $S(n) = O(f(n))$ 表示。\n\n**空间复杂度组成**：\n1. **固定空间**：程序代码、简单变量、常量等，与问题规模无关\n2. **动态空间**：随问题规模变化的空间，如递归栈空间、动态分配的数组\n\n**常见情况**：\n- $O(1)$：只使用固定空间，如冒泡排序\n- $O(n)$：需要与输入规模成正比的空间，如归并排序的临时数组\n- $O(\\log_2 n)$：递归深度为对数的栈空间，如快速排序平均情况\n\n**注意**：空间复杂度只考虑辅助空间，不包括输入数据占用的空间', 2, '0', '2026-04-22 08:22:16', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (36, 1, '什么是线性表？', '**定义**：线性表是具有相同数据类型的 $n$（$n \\geq 0$）个数据元素的有限序列。\n\n**特点**：\n1. **有限性**：元素个数有限\n2. **相同类型**：所有元素类型相同\n3. **有序性**：元素有先后次序\n4. **线性关系**：除首尾外，每个元素有且仅有一个前驱和一个后继\n\n**逻辑表示**：\n$$L = (a_1, a_2, a_3, \\ldots, a_n)$$\n- $a_1$：表头元素（首元素），无前驱\n- $a_n$：表尾元素（尾元素），无后继\n- $n$：表长，$n=0$ 时为空表\n\n**ADT定义**：\n```\nADT 线性表 {\n    数据对象: D = {a_i | i=1,2,...,n, n≥0}\n    数据关系: R = {<a_{i-1}, a_i> | i=2,...,n}\n    基本操作: InitList, Length, LocateElem, GetElem, Insert, Delete, ...\n}\n```', 1, '0', '2026-04-22 08:22:16', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (37, 1, '线性表的顺序存储（顺序表）的特点是什么？', '**定义**：顺序表是用一组地址连续的存储单元依次存储线性表中的数据元素。\n\n**特点**：\n1. **逻辑顺序与物理顺序一致**：元素相邻即存储位置相邻\n2. **随机存取**：可在 $O(1)$ 时间访问任意位置元素\n\n**元素地址计算**：\n$$LOC(a_i) = LOC(a_1) + (i-1) \\times L$$\n其中 $L$ 为每个元素占用的存储单元长度\n\n**顺序表的类型定义**：\n```c\n#define MAXSIZE 100\ntypedef struct {\n    ElemType data[MAXSIZE];  // 存储数组\n    int length;              // 当前长度\n} SqList;\n```', 2, '0', '2026-04-22 08:22:16', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (38, 1, '顺序表插入操作的时间复杂度分析', '**插入操作**：在第 $i$ 个位置插入新元素 $e$\n\n**算法步骤**：\n1. 检查位置合法性：$1 \\leq i \\leq n+1$\n2. 检查表是否已满\n3. 将第 $n$ 到第 $i$ 个元素依次后移一个位置\n4. 在位置 $i$ 放入新元素\n5. 表长加1\n\n**时间复杂度分析**：\n- 移动元素次数：$n - i + 1$\n- 平均移动次数（等概率插入）：\n$$E_{ins} = \\sum_{i=1}^{n+1} (n-i+1) \\times \\frac{1}{n+1} = \\frac{n}{2}$$\n\n**结论**：\n- 最好情况：在表尾插入，$O(1)$\n- 最坏情况：在表头插入，$O(n)$\n- 平均情况：$O(n)$', 3, '0', '2026-04-22 08:22:16', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (39, 1, '顺序表删除操作的时间复杂度分析', '**删除操作**：删除第 $i$ 个位置的元素\n\n**算法步骤**：\n1. 检查位置合法性：$1 \\leq i \\leq n$\n2. 将第 $i+1$ 到第 $n$ 个元素依次前移一个位置\n3. 表长减1\n\n**时间复杂度分析**：\n- 移动元素次数：$n - i$\n- 平均移动次数（等概率删除）：\n$$E_{del} = \\sum_{i=1}^{n} (n-i) \\times \\frac{1}{n} = \\frac{n-1}{2}$$\n\n**结论**：\n- 最好情况：删除表尾元素，$O(1)$\n- 最坏情况：删除表头元素，$O(n)$\n- 平均情况：$O(n)$', 3, '0', '2026-04-22 08:22:16', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (40, 1, '线性表的链式存储（单链表）的特点是什么？', '**定义**：单链表是通过一组任意的存储单元存储线性表的数据元素，用指针表示元素间的逻辑关系。\n\n**特点**：\n1. **非随机存取**：只能顺序查找，访问第 $i$ 个元素需要 $O(n)$\n2. **动态分配**：按需申请存储空间\n3. **插入删除高效**：只需修改指针，无需移动元素\n\n**结点结构**：\n```c\ntypedef struct LNode {\n    ElemType data;      // 数据域\n    struct LNode *next; // 指针域\n} LNode, *LinkList;\n```\n\n**存储密度**：\n$$存储密度 = \\frac{数据域占用空间}{结点总占用空间}$$\n单链表的存储密度 < 1（因为有指针域）', 2, '0', '2026-04-22 08:22:16', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (41, 1, '单链表的插入操作如何实现？', '**在结点 *p 之后插入新结点 *s**：\n```c\ns->next = p->next;\np->next = s;\n```\n**注意顺序**：先链接后断开，否则会丢失 `p->next`\n\n**在第 $i$ 个位置插入**：\n1. 找到第 $i-1$ 个结点 *p\n2. 在 *p 之后插入新结点\n\n**时间复杂度**：\n- 找位置：$O(n)$\n- 插入操作本身：$O(1)$\n- 总体：$O(n)$\n\n**带头结点 vs 不带头结点**：\n| 情况 | 在表头插入 | 在其他位置插入 |\n|------|-----------|---------------|\n| 带头结点 | 直接在头结点后插入 | 统一处理 |\n| 不带头结点 | 需特殊处理，修改头指针 | 需先找前驱 |\n\n**建议**：使用带头结点的单链表，简化边界情况处理', 2, '0', '2026-04-22 08:22:16', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (42, 1, '单链表的删除操作如何实现？', '**删除结点 *p 的后继结点 *q**：\n```c\np->next = q->next;\nfree(q);\n```\n\n**删除第 $i$ 个位置的结点**：\n1. 找到第 $i-1$ 个结点 *p\n2. 删除 *p 的后继结点\n\n**时间复杂度**：\n- 找位置：$O(n)$\n- 删除操作本身：$O(1)$\n- 总体：$O(n)$\n\n**删除指定结点 *p（只知道 *p 的位置）**：\n如果只知道要删除的结点 *p，无法直接删除（因为没有前驱）\n- **方法1**：从前往后找前驱，$O(n)$\n- **方法2**：将后继结点的值复制到 *p，然后删除后继，$O(1)$', 2, '0', '2026-04-22 08:22:16', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (43, 1, '什么是双向链表？', '**定义**：双向链表的每个结点有两个指针域，分别指向前驱和后继。\n\n**结点结构**：\n```c\ntypedef struct DNode {\n    ElemType data;       // 数据域\n    struct DNode *prior; // 前驱指针\n    struct DNode *next;  // 后继指针\n} DNode, *DLinkList;\n```\n\n**优点**：\n- 查找前驱结点方便，$O(1)$\n- 支持双向遍历\n\n**插入操作（在 *p 之后插入 *s）**：\n```c\ns->next = p->next;\np->next->prior = s;\ns->prior = p;\np->next = s;\n```\n\n**删除操作（删除 *p 的后继 *q）**：\n```c\np->next = q->next;\nq->next->prior = p;\nfree(q);\n```', 2, '0', '2026-04-22 08:22:16', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (44, 1, '什么是循环链表？', '**定义**：循环链表的尾结点的指针指向头结点（或首结点），形成环状结构。\n\n**循环单链表**：\n- 尾结点 `next` 指向头结点\n- 从任意结点可遍历整个链表\n- 判断表尾：`p->next == L`（头结点）\n\n**循环双链表**：\n- 尾结点 `next` 指向头结点\n- 头结点 `prior` 指向尾结点\n- 判断表尾：`p->next == L`\n- 判断表头：`p->prior == L`\n\n**优点**：\n1. 从任意结点出发可访问表中所有结点\n2. 判断空表方便：`L->next == L`\n3. 操作时无需判断是否为表尾', 2, '0', '2026-04-22 08:22:16', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (45, 1, '顺序表和链表的比较', '**对比总结**：\n\n| 特性 | 顺序表 | 链表 |\n|------|--------|------|\n| **存储分配** | 预分配连续空间 | 动态分配离散空间 |\n| **存储密度** | 1（无指针开销） | < 1（有指针开销） |\n| **存取方式** | 随机存取 $O(1)$ | 顺序存取 $O(n)$ |\n| **按值查找** | 无序$O(n)$，有序$O(\\log n)$ | $O(n)$ |\n| **插入删除** | 需移动元素 $O(n)$ | 修改指针 $O(1)$（找位置仍$O(n)$） |\n| **空间利用** | 可能预分配浪费 | 按需分配，无浪费 |\n\n**选择建议**：\n- **选顺序表**：表长可预估、主要操作是查找、很少插入删除\n- **选链表**：表长变化大、频繁插入删除、存储空间紧张', 2, '0', '2026-04-22 08:22:16', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (46, 1, '什么是栈（Stack）？', '**定义**：栈是只允许在一端进行插入和删除操作的线性表。\n\n**特点**：\n- **后进先出**（LIFO, Last In First Out）\n- **栈顶**：允许插入删除的一端\n- **栈底**：不允许操作的一端\n- **空栈**：不含任何元素的栈\n\n**逻辑表示**：\n$$S = (a_1, a_2, \\ldots, a_n)$$\n- $a_1$ 为栈底元素，$a_n$ 为栈顶元素\n- 进栈顺序：$a_1, a_2, \\ldots, a_n$\n- 出栈顺序：$a_n, a_{n-1}, \\ldots, a_1$\n\n**基本操作**：\n- `InitStack(S)`：初始化栈\n- `Push(S, x)`：进栈（入栈）\n- `Pop(S, x)`：出栈（退栈）\n- `GetTop(S)`：取栈顶元素\n- `Empty(S)`：判栈空', 1, '0', '2026-04-22 08:22:16', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (47, 1, '栈的顺序存储结构（顺序栈）如何实现？', '**定义**：顺序栈是用一组连续的存储单元存放栈元素，附设指针 `top` 指示栈顶位置。\n\n**结构定义**：\n```c\n#define MAXSIZE 100\ntypedef struct {\n    ElemType data[MAXSIZE];\n    int top;  // 栈顶指针\n} SqStack;\n```\n\n**top 的两种定义方式**：\n\n| 方式 | top初始值 | top指向 | 栈空条件 | 栈满条件 |\n|------|----------|---------|----------|----------|\n| **方式1** | `top = -1` | 栈顶元素 | `top == -1` | `top == MAXSIZE-1` |\n| **方式2** | `top = 0` | 栈顶下一位置 | `top == 0` | `top == MAXSIZE` |\n\n**进栈操作（方式1）**：\n```c\nS.data[++S.top] = x;\n```\n\n**出栈操作（方式1）**：\n```c\nx = S.data[S.top--];\n```', 2, '0', '2026-04-22 08:22:16', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (48, 1, '什么是共享栈？', '**定义**：共享栈是两个栈共享同一片存储空间的顺序栈结构。\n\n**实现方式**：\n- 两个栈的栈底分别在数组两端\n- 栈顶指针 `top1` 从左端向右增长\n- 栈顶指针 `top2` 从右端向左增长\n\n**结构定义**：\n```c\ntypedef struct {\n    ElemType data[MAXSIZE];\n    int top1;  // 左栈栈顶，初始为 -1\n    int top2;  // 右栈栈顶，初始为 MAXSIZE\n} ShareStack;\n```\n\n**栈空条件**：\n- 左栈空：`top1 == -1`\n- 右栈空：`top2 == MAXSIZE`\n\n**栈满条件**：\n- `top1 + 1 == top2`（两栈顶相邻）\n\n**优点**：\n1. 节省存储空间\n2. 降低上溢发生概率', 2, '0', '2026-04-22 08:22:16', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (49, 1, '栈的链式存储结构（链栈）如何实现？', '**定义**：链栈是用单链表实现的栈，通常带头结点。\n\n**结构定义**：\n```c\ntypedef struct SNode {\n    ElemType data;\n    struct SNode *next;\n} SNode, *LinkStack;\n```\n\n**特点**：\n- 栈顶在链表头部（便于插入删除）\n- 无栈满问题（除非内存耗尽）\n- 插入删除都在栈顶进行，$O(1)$\n\n**进栈操作**：\n```c\ns = (SNode*)malloc(sizeof(SNode));\ns->data = x;\ns->next = S->next;  // 带头结点\nS->next = s;\n```\n\n**出栈操作**：\n```c\np = S->next;\nx = p->data;\nS->next = p->next;\nfree(p);\n```', 2, '0', '2026-04-22 08:22:17', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (50, 1, '栈的应用：表达式求值（后缀表达式）', '**中缀表达式转后缀表达式**：\n\n**规则**（使用栈存放运算符）：\n1. 从左到右扫描中缀表达式\n2. 遇到数字直接输出\n3. 遈到运算符：\n   - 若栈空或栈顶为 `(` 或当前为 `(`，直接入栈\n   - 若当前为 `)`，弹出栈顶直到遇到 `(`，`(` 不输出\n   - 否则比较优先级，弹出优先级 ≥ 当前的运算符，再入栈\n4. 扫描结束，弹出栈中所有运算符\n\n**示例**：`A+B*(C-D)-E/F`\n后缀表达式：`ABCD-*+EF/-`\n\n**后缀表达式求值**：\n\n**规则**（使用栈存放操作数）：\n1. 从左到右扫描后缀表达式\n2. 遈到数字入栈\n3. 遈到运算符：弹出两个操作数，计算结果入栈\n4. 最后栈中只剩结果\n\n**示例**：`ABCD-*+EF/-`（设 A=3, B=4, C=5, D=2, E=8, F=1）\n计算过程：栈中元素依次变化，最终结果为 13', 3, '0', '2026-04-22 08:22:17', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (51, 1, '栈的应用：递归', '**递归的定义**：函数直接或间接调用自身\n\n**递归的必要条件**：\n1. 递归表达式（递归体）\n2. 递归终止条件（边界条件）\n\n**递归的实现机制**：\n- 系统使用**工作栈**保存递归调用的信息\n- 每次递归调用：保存返回地址、局部变量、参数等入栈\n- 递归返回：栈顶信息出栈，恢复现场\n\n**示例**：斐波那契数列\n$$F(n) = \\begin{cases} 1 & n=0,1 \\ F(n-1) + F(n-2) & n \\geq 2 \\end{cases}$$\n\n**递归的问题**：\n1. 效率低（重复计算）\n2. 递归深度大时可能导致栈溢出\n\n**优化方法**：将递归转化为非递归（使用栈模拟）', 2, '0', '2026-04-22 08:22:17', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (52, 1, '什么是队列（Queue）？', '**定义**：队列是只允许在一端插入、在另一端删除的线性表。\n\n**特点**：\n- **先进先出**（FIFO, First In First Out）\n- **队尾**：允许插入的一端\n- **队头**：允许删除的一端\n- **空队列**：不含任何元素的队列\n\n**逻辑表示**：\n$$Q = (a_1, a_2, \\ldots, a_n)$$\n- $a_1$ 为队头元素，$a_n$ 为队尾元素\n- 入队顺序：$a_1, a_2, \\ldots, a_n$\n- 出队顺序：$a_1, a_2, \\ldots, a_n$（与入队顺序相同）\n\n**基本操作**：\n- `InitQueue(Q)`：初始化队列\n- `EnQueue(Q, x)`：入队\n- `DeQueue(Q, x)`：出队\n- `GetHead(Q)`：取队头元素\n- `Empty(Q)`：判队空', 1, '0', '2026-04-22 08:22:17', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (53, 1, '队列的顺序存储结构（循环队列）如何实现？', '**问题**：普通顺序队列的\"假溢出\"现象\n- 队头不断出队，队尾不断入队\n- 队尾指针到达数组末端，但数组前端还有空闲空间\n\n**解决方案**：循环队列\n- 将顺序队列想象成环状结构\n- 队尾指针 `rear` 和队头指针 `front` 循环移动\n\n**指针移动规则**：\n```c\nrear = (rear + 1) % MAXSIZE;\nfront = (front + 1) % MAXSIZE;\n```\n\n**队空与队满判断**：\n\n| 方法 | 队空条件 | 队满条件 | 特点 |\n|------|----------|----------|------|\n| **牺牲一个单元** | `front == rear` | `(rear+1)%MAXSIZE == front` | 简单常用 |\n| **设置计数器** | `count == 0` | `count == MAXSIZE` | 无空间浪费 |\n| **设置标志位** | `front==rear && tag==0` | `front==rear && tag==1` | 无空间浪费 |', 3, '0', '2026-04-22 08:22:17', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (54, 1, '循环队列中元素个数如何计算？', '**循环队列元素个数计算公式**：\n\n$$元素个数 = (rear - front + MAXSIZE) \\mod MAXSIZE$$\n\n**推导**：\n- 正常情况（`rear > front`）：元素个数 = `rear - front`\n- 队尾绕过队头（`rear < front`）：元素个数 = `rear - front + MAXSIZE`\n\n**示例**：\n设 `MAXSIZE = 10`\n- `front = 2, rear = 5`：元素个数 = $(5-2+10) \\mod 10 = 3$\n- `front = 8, rear = 3`：元素个数 = $(3-8+10) \\mod 10 = 5$\n\n**注意**：\n- 使用\"牺牲一个单元\"方法时，队满时实际存储 $MAXSIZE-1$ 个元素', 3, '0', '2026-04-22 08:22:17', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (55, 1, '队列的链式存储结构（链队）如何实现？', '**定义**：链队是用单链表实现的队列，需要队头指针和队尾指针。\n\n**结构定义**：\n```c\ntypedef struct QNode {\n    ElemType data;\n    struct QNode *next;\n} QNode;\n\ntypedef struct {\n    QNode *front;  // 队头指针\n    QNode *rear;   // 队尾指针\n} LinkQueue;\n```\n\n**特点**：\n- 队头指针指向队头结点（或头结点）\n- 队尾指针指向队尾结点\n- 无队满问题（除非内存耗尽）\n\n**入队操作**：\n```c\ns = (QNode*)malloc(sizeof(QNode));\ns->data = x; s->next = NULL;\nQ.rear->next = s;\nQ.rear = s;\n```\n\n**出队操作**：\n```c\np = Q.front->next;  // 带头结点\nx = p->data;\nQ.front->next = p->next;\nif (p == Q.rear) Q.rear = Q.front;  // 最后一个元素\nfree(p);\n```', 2, '0', '2026-04-22 08:22:17', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (56, 1, '什么是双端队列？', '**定义**：双端队列是允许在两端进行插入和删除操作的线性表。\n\n**类型**：\n1. **双端队列**：两端都可插入删除\n2. **输入受限的双端队列**：只允许一端插入，两端都可删除\n3. **输出受限的双端队列**：两端都可插入，只允许一端删除\n\n**应用**：\n- 双端队列可以实现栈和队列的功能\n- 用双端队列实现栈：固定一端插入删除\n- 用双端队列实现队列：一端只插入，另一端只删除\n\n**示例判断**：\n给定输入序列 `1, 2, 3, 4`，能否输出特定序列？\n- 通过双端队列可输出的序列比栈和队列更多\n- 需要分析每个元素是从哪端进出', 3, '0', '2026-04-22 08:22:17', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (57, 1, '什么是串（String）？', '**定义**：串是由零个或多个字符组成的有限序列。\n\n**表示**：\n$$S = \"a_1 a_2 \\ldots a_n\"$$\n- $n$：串的长度，$n=0$ 时为空串\n- $a_i$：字符，可以是字母、数字或其他字符\n\n**术语**：\n- **空串**：长度为 0 的串，记为 `\"\"`\n- **空格串**：由空格字符组成的串，如 `\" \"`（长度为 1）\n- **子串**：串中任意连续字符组成的子序列\n- **主串**：包含子串的串\n- **位置**：字符在串中的序号（从 1 开始）\n\n**基本操作**：\n- `StrAssign(S, chars)`：赋值\n- `StrCopy(S, T)`：复制\n- `StrLength(S)`：求长度\n- `StrCompare(S, T)`：比较\n- `Concat(S, T)`：连接\n- `SubString(S, pos, len)`：求子串\n- `Index(S, T, pos)`：定位（模式匹配）', 1, '0', '2026-04-22 08:22:17', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (58, 1, '串的存储结构有哪些？', '**顺序存储**：\n\n**定长顺序存储**：\n```c\n#define MAXLEN 255\ntypedef struct {\n    char ch[MAXLEN];\n    int length;\n} SString;\n```\n\n**堆分配存储**（动态分配）：\n```c\ntypedef struct {\n    char *ch;\n    int length;\n} HString;\n```\n\n**链式存储**：\n- 每个结点可存储一个或多个字符\n- 存储密度问题：一个字符时密度低，多个字符时操作复杂\n\n```c\ntypedef struct Chunk {\n    char ch[4];  // 每个结点存4个字符\n    struct Chunk *next;\n} Chunk;\n\ntypedef struct {\n    Chunk *head, *tail;\n    int curlen;\n} LString;\n```', 2, '0', '2026-04-22 08:22:17', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (59, 1, '什么是朴素模式匹配算法（BF算法）？', '**定义**：从主串第一个字符开始，逐个字符与模式串匹配。\n\n**算法思想**：\n- 主串指针 `i`，模式串指针 `j`\n- 匹配成功：两指针同时后移\n- 匹配失败：`i` 回退到起始位置+1，`j` 回退到 0\n\n**时间复杂度**：\n- 最好情况：$O(m)$（模式串长度，第一次就匹配成功）\n- 最坏情况：$O(n \\times m)$（主串长度 $n$，模式串长度 $m$）\n- 平均情况：$O(n \\times m)$\n\n**示例**：\n主串 `\"ababcabcacbab\"`，模式串 `\"abcac\"`\n最坏情况需要多次回溯', 2, '0', '2026-04-22 08:22:17', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (60, 1, '什么是KMP算法？', '**定义**：KMP算法利用已匹配信息，避免主串指针回溯。\n\n**核心思想**：\n- 主串指针 `i` 不回溯\n- 模式串指针 `j` 回溯到适当位置\n- 利用 `next` 数组决定 `j` 的回溯位置\n\n**next 数组**：\n- `next[j]`：模式串第 $j$ 个字符失配时，$j$ 应回溯的位置\n- 含义：模式串前 $j-1$ 个字符中，最长相等前后缀的长度\n\n**next 数组计算规则**：\n$$next[j] = \\begin{cases} 0 & j=1 \\ \\max\\{k | p_1\\ldots p_{k-1} = p_{j-k+1}\\ldots p_{j-1}\\} & 存在相等前后缀 \\ 1 & 否则 \\end{cases}$$\n\n**时间复杂度**：$O(n + m)$\n\n**next 数组示例**：\n模式串 `\"abaabc\"` 的 next 数组：\n| j | 模式串 | next[j] |\n|---|--------|---------|\n| 1 | a | 0 |\n| 2 | b | 1 |\n| 3 | a | 1 |\n| 4 | a | 2 |\n| 5 | b | 3 |\n| 6 | c | 1 |', 4, '0', '2026-04-22 08:22:17', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (61, 1, 'next数组与nextval数组的区别', '**next数组的问题**：\n- 若 `p[j] == p[next[j]]`，失配后回溯到 `next[j]` 仍会失配\n- 造成不必要的比较\n\n**nextval数组优化**：\n- 若 `p[j] == p[next[j]]`，则 `nextval[j] = nextval[next[j]]`\n- 否则 `nextval[j] = next[j]`\n\n**计算方法**：\n```c\nvoid get_nextval(String P, int nextval[]) {\n    int j = 1, k = 0;\n    nextval[1] = 0;\n    while (j < P.length) {\n        if (k == 0 || P.ch[j] == P.ch[k]) {\n            j++; k++;\n            if (P.ch[j] != P.ch[k]) nextval[j] = k;\n            else nextval[j] = nextval[k];\n        } else {\n            k = nextval[k];\n        }\n    }\n}\n```\n\n**示例对比**：\n模式串 `\"abaabc\"`：\n| j | 模式串 | next[j] | nextval[j] |\n|---|--------|---------|-------------|\n| 1 | a | 0 | 0 |\n| 2 | b | 1 | 1 |\n| 3 | a | 1 | 0 |\n| 4 | a | 2 | 2 |\n| 5 | b | 3 | 1 |\n| 6 | c | 1 | 1 |', 4, '0', '2026-04-22 08:22:17', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (62, 1, '什么是树（Tree）？', '**定义**：树是 n≥0 个结点的有限集合。n=0 时称为空树。\n\n**特点**：有且仅有一个根结点，其余结点可分为若干互不相交的有限集合（子树）。\n\n**基本术语**：\n- 根结点：无前驱的结点\n- 叶子结点：度为0的结点\n- 结点的度：拥有的子树个数\n- 树的度：各结点度的最大值\n- 结点层次：根为第1层\n- 树的高度：最大层次', 2, '0', '2026-04-22 08:22:17', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (63, 1, '什么是二叉树？', '**定义**：每个结点最多有两个子树的有序树。\n\n**五种基本形态**：空树、仅根、根+左子树、根+右子树、根+左右子树\n\n**与度为2的树区别**：二叉树有左右之分，度为2的树无顺序要求。', 2, '0', '2026-04-22 08:22:17', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (64, 1, '什么是满二叉树和完全二叉树？', '**满二叉树**：每层都达到最大结点数，深度k有2^k-1个结点。\n\n**完全二叉树**：前k-1层满，第k层可不满但连续。\n\n**完全二叉树性质**：\n- 结点i的双亲：⌊i/2⌋\n- 结点i的左孩子：2i\n- 结点i的右孩子：2i+1', 2, '0', '2026-04-22 08:22:17', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (65, 1, '二叉树的性质：叶子与度2结点的关系', '**性质3**：对任意二叉树，若叶子结点数为n0，度为2的结点数为n2，则：\n\nn0 = n2 + 1\n\n**推导**：总边数 = n-1 = n1 + 2n2\nn = n0 + n1 + n2\n=> n0 = n2 + 1', 3, '0', '2026-04-22 08:22:17', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (66, 1, '二叉树的遍历方式有哪些？', '**四种遍历**：\n- 先序（DLR）：根→左→右\n- 中序（LDR）：左→根→右\n- 后序（LRD）：左→右→根\n- 层序：从上到下，从左到右\n\n**重建二叉树**：\n- 先序+中序：可确定\n- 后序+中序：可确定\n- 先序+后序：不可唯一确定', 2, '0', '2026-04-22 08:22:17', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (67, 1, '什么是线索二叉树？', '**定义**：利用空链域存储前驱后继指针（线索）。\n\n**目的**：加快遍历，方便查找前驱后继。\n\n**结点结构**：增加ltag和rtag区分指针(0)和线索(1)。\n\nn个结点的二叉链表有n+1个空链域。', 3, '0', '2026-04-22 08:22:17', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (68, 1, '树、森林与二叉树的转换', '**树转二叉树**：左孩子=第一个孩子，右孩子=兄弟。\n\n**森林转二叉树**：第一棵树为根及左子树，其余为右子树。\n\n**遍历对应**：\n- 树先根 = 二叉树先序\n- 树后根 = 二叉树中序', 3, '0', '2026-04-22 08:22:17', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (69, 1, '什么是哈夫曼树？', '**定义**：带权路径长度(WPL)最短的二叉树。\n\n**WPL** = Σ wi × li\n\n**构造方法**：每次选权值最小的两个结点合并。\n\n**特点**：\n- 无度为1的结点\n- n个叶子有2n-1个结点\n- 哈夫曼编码：无前缀编码', 3, '0', '2026-04-22 08:22:17', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (70, 1, '什么是图？', '**定义**：G=(V, E)，顶点集V和边集E。\n\n**基本概念**：\n- 有向图：边有方向 <v,w>\n- 无向图：边无方向 (v,w)\n- 完全图：任意两顶点都有边\n  - 有向完全图：n(n-1)条边\n  - 无向完全图：n(n-1)/2条边', 2, '0', '2026-04-22 08:22:17', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (71, 1, '图的度数与边数关系', '**无向图**：Σd(v) = 2|E|（所有度数之和=边数×2）\n\n**有向图**：Σ入度 = Σ出度 = |E|\n\n**结论**：无向图所有顶点度数之和一定是偶数。', 2, '0', '2026-04-22 08:22:17', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (72, 1, '图的连通性概念', '**连通**：两顶点间存在路径。\n\n**连通分量**：无向图的极大连通子图。\n\n**强连通**：有向图中两顶点双向连通。\n\n**强连通分量**：有向图的极大强连通子图。\n\n**生成树**：连通图的极小连通子图（n顶点n-1边）。', 2, '0', '2026-04-22 08:22:18', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (73, 1, '图的存储结构', '**邻接矩阵**：二维数组，空间O(n²)，判断有无边O(1)，适合稠密图。\n\n**邻接表**：链表数组，空间O(n+e)，适合稀疏图。\n\n**对比**：\n- 邻接矩阵：随机访问快，空间大\n- 邻接表：空间省，求入度需遍历', 3, '0', '2026-04-22 08:22:18', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (74, 1, '图的遍历：DFS和BFS', '**DFS（深度优先）**：递归/栈，邻接矩阵O(n²)，邻接表O(n+e)。\n\n**BFS（广度优先）**：队列，同DFS时间复杂度。\n\n**应用**：\n- DFS：拓扑排序、检测环\n- BFS：最短路径（无权）', 2, '0', '2026-04-22 08:22:18', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (75, 1, '最小生成树算法', '**定义**：边权值之和最小的生成树。\n\n**Prim算法**：顶点扩张，O(n²)，适合稠密图。\n\n**Kruskal算法**：边扩张，O(e log e)，适合稀疏图。\n\n**性质**：MST包含n顶点n-1边，权值唯一但树不唯一。', 3, '0', '2026-04-22 08:22:18', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (76, 1, '最短路径算法', '**Dijkstra**：单源最短路径，贪心，O(n²)，不适用负权边。\n\n**Floyd**：各顶点间最短路径，动态规划，O(n³)，可处理负权边。\n\n**选择**：单源用Dijkstra，多源用Floyd。', 3, '0', '2026-04-22 08:22:18', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (77, 1, '什么是拓扑排序？', '**定义**：DAG的顶点排序，每个顶点在前驱之后出现。\n\n**算法**：选择入度为0的顶点输出，删除其出边，重复。\n\n**时间复杂度**：O(n+e)\n\n**判断环**：输出顶点数<总顶点数则存在环。', 2, '0', '2026-04-22 08:22:18', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (78, 1, '什么是关键路径？', '**定义**：AOE网中从源点到汇点的最长路径。\n\n**关键概念**：\n- ve(v)：事件最早发生时间\n- vl(v)：事件最迟发生时间\n- 关键活动：e(a)=l(a)的活动\n\n**关键路径**：所有关键活动构成的路径。', 4, '0', '2026-04-22 08:22:18', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (79, 1, '查找的基本概念', '**ASL（平均查找长度）** = Σ Pi × Ci\n\n**静态查找表**：只查找，不修改。\n\n**动态查找表**：查找同时可插入删除。\n\n**关键字**：用于区分数据元素的数据项。', 1, '0', '2026-04-22 08:22:18', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (80, 1, '顺序查找', '**思想**：从一端开始逐个比较。\n\n**ASL成功**：(n+1)/2\n\n**ASL失败**：n+1\n\n**时间复杂度**：O(n)\n\n**优化**：哨兵、有序表提前终止、高频元素放前。', 2, '0', '2026-04-22 08:22:18', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (81, 1, '折半查找（二分查找）', '**适用条件**：顺序存储、有序、静态查找表。\n\n**ASL** ≈ log₂(n+1) - 1\n\n**时间复杂度**：O(log n)\n\n**判定树高度**：⌈log₂(n+1)⌉\n\n**缺点**：插入删除需移动元素。', 2, '0', '2026-04-22 08:22:18', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (82, 1, '分块查找', '**特点**：块间有序，块内无序。\n\n**过程**：索引表折半查找确定块，块内顺序查找。\n\n**最优块大小**：s=√n\n\n**ASL** ≈ log₂b + (s+1)/2', 2, '0', '2026-04-22 08:22:18', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (83, 1, '什么是二叉排序树（BST）？', '**定义**：左子树<根<右子树的二叉树。\n\n**性质**：中序遍历得到有序序列。\n\n**时间复杂度**：最好O(log n)，最坏O(n)。\n\n**删除**：\n- 叶子：直接删\n- 一孩子：孩子替代\n- 两孩子：中序前驱/后继替代', 2, '0', '2026-04-22 08:22:18', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (84, 1, '什么是平衡二叉树（AVL）？', '**定义**：|左子树高度-右子树高度|≤1的BST。\n\n**平衡因子BF** = h左 - h右，BF∈{-1,0,1}\n\n**旋转调整**：\n- LL型：右单旋\n- RR型：左单旋\n- LR型：先左旋后右旋\n- RL型：先右旋后左旋\n\n**查找效率**：O(log n)', 4, '0', '2026-04-22 08:22:18', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (85, 1, '什么是B树？', '**定义**：多路平衡查找树，所有结点平衡因子为0。\n\n**m阶B树性质**：\n- 根至少2个孩子\n- 非根非叶至少⌈m/2⌉个孩子\n- 有k个孩子有k-1个关键字\n- 叶子在同一层\n\n**高度**：≤log_{⌈m/2⌉}((n+1)/2) + 1', 4, '0', '2026-04-22 08:22:18', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (86, 1, '什么是B+树？', '**与B树区别**：\n- 关键字数=孩子数\n- 数据只存叶子\n- 叶子有链表\n- 查找必须到叶子\n\n**优点**：范围查询方便（叶子链表）。', 3, '0', '2026-04-22 08:22:18', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (87, 1, '什么是散列查找？', '**散列函数**：H(key)将关键字映射为地址。\n\n**冲突**：不同关键字映射同一地址。\n\n**常用方法**：\n- 除留余数法：H(key)=key mod p\n\n**冲突处理**：\n- 开放定址法\n- 链地址法\n\n**装填因子α**=n/m，越小冲突越少。', 3, '0', '2026-04-22 08:22:18', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (88, 1, '排序的基本概念', '**分类**：\n- 内部排序：数据在内存\n- 外部排序：数据需外存\n- 稳定排序：相同关键字保持原序\n\n**排序算法总览**：\n|算法|平均时间|空间|稳定|\n|直接插入|O(n²)|O(1)|√|\n|快速排序|O(nlogn)|O(logn)|×|\n|堆排序|O(nlogn)|O(1)|×|\n|归并排序|O(nlogn)|O(n)|√|', 2, '0', '2026-04-22 08:22:18', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (89, 1, '直接插入排序', '**思想**：逐个插入已排序序列。\n\n**时间复杂度**：\n- 最好O(n)（已有序）\n- 最坏O(n²)（逆序）\n- 平均O(n²)\n\n**空间复杂度**：O(1)\n\n**稳定性**：稳定', 2, '0', '2026-04-22 08:22:18', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (90, 1, '希尔排序', '**思想**：增量分组，组内插入排序，增量递减至1。\n\n**时间复杂度**：O(n^1.3)~O(n²)\n\n**空间复杂度**：O(1)\n\n**稳定性**：不稳定\n\n**特点**：不适合链表（需随机访问）。', 3, '0', '2026-04-22 08:22:18', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (91, 1, '冒泡排序', '**思想**：相邻比较交换，每趟最大元素冒泡到末尾。\n\n**时间复杂度**：\n- 最好O(n)\n- 最坏O(n²)\n\n**空间复杂度**：O(1)\n\n**稳定性**：稳定\n\n**趟数**：最好1趟，最坏n-1趟。', 2, '0', '2026-04-22 08:22:18', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (92, 1, '快速排序', '**思想**：选枢轴，分左右两部分，递归。\n\n**时间复杂度**：\n- 最好O(nlogn)\n- 最坏O(n²)（每次只划分一个）\n\n**空间复杂度**：O(logn)~O(n)\n\n**稳定性**：不稳定\n\n**优化**：随机选枢轴、三数取中。', 3, '0', '2026-04-22 08:22:18', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (93, 1, '简单选择排序', '**思想**：每趟选最小放末尾。\n\n**时间复杂度**：O(n²)（不受初始序列影响）\n\n**空间复杂度**：O(1)\n\n**稳定性**：不稳定\n\n**特点**：比较次数固定，移动次数少。', 2, '0', '2026-04-22 08:22:18', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (94, 1, '堆排序', '**堆定义**：\n- 大根堆：根≥左右孩子\n- 小根堆：根≤左右孩子\n\n**过程**：建堆→输出堆顶→调整→重复\n\n**时间复杂度**：O(nlogn)\n\n**空间复杂度**：O(1)\n\n**稳定性**：不稳定\n\n**建堆时间**：O(n)', 3, '0', '2026-04-22 08:22:18', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (95, 1, '归并排序', '**思想**：分割→两两合并。\n\n**时间复杂度**：O(nlogn)（不受初始序列影响）\n\n**空间复杂度**：O(n)\n\n**稳定性**：稳定\n\n**特点**：性能稳定，需额外空间。', 2, '0', '2026-04-22 08:22:18', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (96, 1, '基数排序', '**思想**：按关键字各位分配收集。\n\n**时间复杂度**：O(d(n+r))\n\n**空间复杂度**：O(r)\n\n**稳定性**：稳定\n\n**特点**：不比较关键字，适合整数、字符串。', 3, '0', '2026-04-22 08:22:18', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (97, 1, '排序算法对比', '**时间复杂度**：\n- O(n²)：插入、冒泡、选择\n- O(nlogn)：快排、堆排、归并\n- O(d(n+r))：基数\n\n**稳定性**：\n- 稳定：插入、冒泡、归并、基数\n- 不稳定：希尔、快排、选择、堆\n\n**空间**：\n- O(1)：插入、希尔、冒泡、选择、堆\n- O(n)：归并\n- O(logn)：快排\n\n**选择**：\n- 小规模有序：插入\n- 大规模：快排\n- 需稳定：归并\n- 空间紧张：堆排', 2, '0', '2026-04-22 08:22:18', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (98, 1, '外部排序', '**定义**：大文件排序，数据不能全装入内存。\n\n**过程**：分块→内部排序→多路归并。\n\n**提高效率**：\n- 增加归并路数\n- 置换选择排序（产生更长顺串）\n- 败者树（减少比较次数）\n\n**k路归并趟数**：S=⌈log_k m⌉', 4, '0', '2026-04-22 08:22:18', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (99, 2, '计算机的发展经历了哪些阶段？', '**计算机发展四代：**\n\n1. **第一代（1946-1957）**：电子管计算机\n   - ENIAC为代表\n   - 体积大、功耗高\n\n2. **第二代（1958-1964）**：晶体管计算机\n   - 体积减小、可靠性提高\n\n3. **第三代（1965-1971）**：集成电路计算机\n   - 中小规模集成电路\n\n4. **第四代（1972至今）**：大规模集成电路计算机\n   - 微处理器出现\n   - 个人计算机普及', 2, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (100, 2, '冯·诺依曼计算机的基本结构是什么？', '**冯·诺依曼结构五大部件：**\n\n1. **输入设备**：接收外部信息\n2. **输出设备**：输出处理结果\n3. **存储器**：存储程序和数据\n4. **运算器**：执行算术和逻辑运算\n5. **控制器**：指挥各部件协调工作\n\n**冯·诺依曼特点：**\n- 采用二进制\n- 存储程序原理\n- 指令和数据存储在同一存储器\n- 指令顺序执行', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (101, 2, '计算机的性能指标有哪些？', '**主要性能指标：**\n\n1. **主频（时钟频率）**\n   - 单位：Hz（GHz常用）\n   - 决定CPU执行速度\n\n2. **CPI（Cycle Per Instruction）**\n   - 执行一条指令所需的时钟周期数\n\n3. **IPC（Instructions Per Cycle）**\n   - 每个时钟周期执行的指令数\n   - $IPC = \\frac{1}{CPI}$\n\n4. **MIPS（Million Instructions Per Second）**\n   - 每秒执行百万指令数\n   - $MIPS = \\frac{主频}{CPI \\times 10^6}$\n\n5. **主存容量**：存储器可存储的信息总量\n\n6. **字长**：CPU一次能处理的二进制位数', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (102, 2, '什么是CPU时间？如何计算？', '**CPU时间计算公式：**\n\n$$CPU时间 = 指令数 \\times CPI \\times 时钟周期时间$$\n\n或：\n$$CPU时间 = \\frac{指令数 \\times CPI}{主频}$$\n\n**各因素影响：**\n- **指令数**：由算法和编译器决定\n- **CPI**：由计算机体系结构决定\n- **时钟周期时间**：由硬件实现决定\n\n**注意：** 降低其中一项可能导致另一项升高', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (103, 2, '计算机的字长是什么？有什么影响？', '**字长的定义：**\n字长是指CPU一次能并行处理的二进制数据的位数。\n\n**字长的影响：**\n\n1. **计算精度**\n   - 字长越长，计算精度越高\n\n2. **寻址范围**\n   - 字长决定地址总线宽度\n   - 影响$\\max$可寻址空间\n\n3. **运算速度**\n   - 字长越长，一次处理数据越多\n\n**常见字长：**\n- 32位：地址空间$2^{32}$ = 4GB\n- 64位：地址空间$2^{64}$ = 16EB', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (104, 2, '常见的进位计数制有哪些？如何转换？', '**常见进位制：**\n\n| 进制 | 基数 | 数字符号 |\n|------|------|----------|\n| 二进制 | 2 | 0, 1 |\n| 八进制 | 8 | 0-7 |\n| 十进制 | 10 | 0-9 |\n| 十六进制 | 16 | 0-9, A-F |\n\n**进制转换：**\n\n- **十进制→二进制**：除2取余法\n- **二进制→十进制**：按权展开\n  $$N = \\sum d_i \\times 2^i$$\n\n- **二进制→八进制**：3位一组\n- **二进制→十六进制**：4位一组', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (105, 2, '什么是原码、补码、反码？', '**三种机器数表示：**\n\n设字长为n位（含1位符号位）\n\n**1. 原码**\n- 最高位为符号位（0正1负）\n- 数值位为真值的绝对值\n- +5原码：0,101\n- -5原码：1,101\n\n**2. 反码**\n- 正数：与原码相同\n- 负数：符号位不变，数值位取反\n- -5反码：1,010\n\n**3. 补码**\n- 正数：与原码相同\n- 负数：反码末位加1\n- -5补码：1,011\n\n**补码重要性质：**\n$$[x]_{补} + [y]_{补} = [x+y]_{补}$$', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (106, 2, '补码有什么优势？', '**补码的优势：**\n\n1. **统一加减运算**\n   - 减法可转换为加法\n   - $A - B = A + (-B)$\n   - 只需加法器即可实现加减\n\n2. **零的表示唯一**\n   - 原码：+0（00...0）和-0（10...0）\n   - 补码：0只有一种表示（00...0）\n\n3. **符号位参与运算**\n   - 符号位与数值位统一处理\n\n4. **表示范围更宽**\n   - n位补码整数范围：$-2^{n-1}$ 到 $2^{n-1}-1$', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (107, 2, '如何求补码对应的真值？', '**补码求真值方法：**\n\n**符号位为0（正数）：**\n- 直接转换为十进制\n\n**符号位为1（负数）：**\n- 数值位取反加1，得绝对值\n- 加负号\n\n**快速方法：**\n\n对于负数补码，符号位保持不变，数值位从右向左找到第一个1，该位右边保持不变，左边取反。\n\n**示例：**\n补码 1,10110\n- 第一个1在第2位\n- 结果：-01010 = -10', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (108, 2, '什么是定点数和浮点数？', '**定点数：**\n小数点位置固定。\n\n- **定点整数**：小数点在最低位之后\n- **定点小数**：小数点在符号位之后\n\n**浮点数：**\n小数点位置浮动。\n\n$$N = M \\times 2^E$$\n\n- **M**：尾数（mantissa），表示精度\n- **E**：阶码（exponent），表示范围\n\n**特点对比：**\n\n| 特性 | 定点数 | 浮点数 |\n|------|--------|--------|\n| 范围 | 小 | 大 |\n| 精度 | 固定 | 可变 |\n| 运算 | 简单 | 复杂 |', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (109, 2, 'IEEE 754浮点数格式是怎样的？', '**IEEE 754标准浮点数格式：**\n\n$$N = (-1)^S \\times (1.M) \\times 2^{E-bias}$$\n\n**格式组成：**\n\n| 格式 | 符号位S | 阶码E | 尾数M | 总位数 |\n|------|---------|-------|-------|--------|\n| 单精度 | 1位 | 8位 | 23位 | 32位 |\n| 双精度 | 1位 | 11位 | 52位 | 64位 |\n\n**偏置值（bias）：**\n- 单精度：$bias = 127$\n- 双精度：$bias = 1023$\n\n**隐含位：**\n- 规格化浮点数尾数前隐含1\n- 实际尾数 = 1.M', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (110, 2, '浮点数的表示范围如何计算？', '**IEEE 754单精度浮点数范围：**\n\n**最大正数：**\n$$M_{max} = (1.111...1) \\times 2^{255-127} \\approx 2^{128}$$\n\n**最小正数：**\n$$M_{min} = (1.000...0) \\times 2^{1-127} = 2^{-126}$$\n\n**表示范围：**\n$$[-2^{128}, -2^{-126}] \\cup [2^{-126}, 2^{128}]$$\n\n**特殊值：**\n- 阶码全0、尾数全0：+0/-0\n- 阶码全1、尾数全0：+∞/-∞\n- 阶码全0、尾数非0：非规格化数', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (111, 2, '什么是浮点数的溢出？', '**浮点数溢出分类：**\n\n**1. 上溢（Overflow）**\n- 浡点数超过最大表示范围\n- 结果为∞或溢出异常\n\n**2. 下溢（Underflow）**\n- 浡点数小于最小表示范围\n- 非规格化数或归零\n\n**判断方法：**\n\n| 阶码状态 | 情况 |\n|----------|------|\n| 阶码 > 最大值 | 上溢 |\n| 阶码 < 最小值 | 下溢 |\n| 阶码正常 | 正常 |', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (112, 2, '什么是ALU？ALU的功能是什么？', '**ALU（算术逻辑单元）：**\n\nALU是CPU中执行算术和逻辑运算的核心部件。\n\n**主要功能：**\n\n1. **算术运算**\n   - 加、减、乘、除\n   - 加1、减1\n\n2. **逻辑运算**\n   - 与（AND）、或（OR）、非（NOT）\n   - 异或（XOR）\n\n3. **移位运算**\n   - 左移、右移\n   - 循环移位\n\n**组成：**\n- 运算电路\n- 输入数据（A、B）\n- 输出结果（F）\n- 控制信号', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (113, 2, '加法器的工作原理是什么？', '**加法器类型：**\n\n**1. 一位全加器（FA）**\n\n输入：$A_i$, $B_i$, $C_{i-1}$（低位进位）\n输出：$S_i$（本位和）, $C_i$（本位进位）\n\n$$S_i = A_i \\oplus B_i \\oplus C_{i-1}$$\n$$C_i = A_i B_i + (A_i \\oplus B_i) C_{i-1}$$\n\n**2. 串行加法器**\n- 逐位相加\n- 进位逐级传递\n- 速度慢\n\n**3. 并行加法器**\n- 多位同时相加\n- 需处理进位传递', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (114, 2, '什么是进位链？如何加速进位传递？', '**进位链：**\n加法器中进位信号从低位向高位传递的路径。\n\n**串行进位（行波进位）：**\n$$C_i = G_i + P_i C_{i-1}$$\n\n其中：\n- $G_i = A_i B_i$（进位生成）\n- $P_i = A_i \\oplus B_i$（进位传递）\n\n**问题：** 进位延迟累积\n\n**加速方法：**\n\n1. **先行进位（CLA）**\n   - 并行计算所有进位\n   - 增加硬件复杂度\n\n2. **分组先行进位**\n   - 组内CLA，组间串行\n   - 平衡速度与复杂度', 5, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (115, 2, '补码加减运算如何实现？', '**补码加减运算：**\n\n**加法：**\n$$[A+B]_{补} = [A]_{补} + [B]_{补}$$\n\n**减法：**\n$$[A-B]_{补} = [A]_{补} + [-B]_{补}$$\n\n**求[-B]补的方法：**\n[B]补连同符号位取反加1\n\n**溢出判断：**\n\n**1. 双符号位法**\n- 正数：00\n- 贌数：11\n- 结果：01或10表示溢出\n\n**2. 单符号位法**\n- 最高位进位与符号位进位不同则溢出', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (116, 2, '浮点数加减运算的步骤是什么？', '**浮点数加减运算步骤：**\n\n**1. 对阶**\n- 小阶向大阶看齐\n- 阶小的尾数右移\n\n**2. 尾数求和**\n- 对阶后尾数相加减\n\n**3. 规格化**\n- 左规：尾数最高位无效0\n- 右规：尾数溢出（双符号位）\n\n**4. 舍入**\n- 截断舍入\n- 0舍1入法\n- 恒置1法\n\n**5. 溢出判断**\n- 阶码上溢：溢出异常\n- 阶码下溢：归零处理', 5, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (117, 2, '什么是规格化浮点数？', '**规格化浮点数：**\n\n尾数最高数值位为有效值的浮点数。\n\n**规格化规则：**\n\n- **正数**：尾数最高位为1\n  - 规格化范围：$0.5 \\leq M < 1$\n  - 表示形式：$1.xxx...x$（IEEE 754隐含1）\n\n- **负数（补码）**：尾数最高位为0\n  - 规格化范围：$-1 < M \\leq -0.5$\n  - 表示形式：$1.0xx...x$\n\n**左规：** 尾数左移，阶码减1\n**右规：** 尾数右移，阶码加1', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (118, 2, '存储器的层次结构是怎样的？', '**存储器层次结构（从快到慢）：**\n\n1. **寄存器** - CPU内部，最快、最小、最贵\n2. **Cache** - CPU内部/附近\n3. **主存(RAM)** - 主板上\n4. **辅存(磁盘)** - 外部设备\n5. **远程存储** - 网络，最慢、最大、最便宜\n\n**设计目标：**\n- 速度接近Cache\n- 容量接近辅存\n- 价格接近辅存', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (119, 2, '什么是Cache？Cache的基本原理是什么？', '**Cache的定义：**\nCache是位于CPU和主存之间的高速小容量存储器。\n\n**基本原理：**\n\n**局部性原理：**\n1. **时间局部性**：最近访问的信息可能很快再次访问\n2. **空间局部性**：最近访问的信息附近的信息可能很快访问\n\n**Cache工作方式：**\n- CPU访问数据，先查Cache\n- Cache命中：直接返回数据\n- Cache缺失：从主存调入数据块\n\n**命中率：**\n$$h = \\frac{Cache命中次数}{总访问次数}$$', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (120, 2, 'Cache的命中率和平均访问时间如何计算？', '**Cache性能计算：**\n\n**命中率：**\n$$h = \\frac{N_c}{N_c + N_m}$$\n\n其中：$N_c$为Cache命中次数，$N_m$为Cache缺失次数\n\n**缺失率：**\n$$缺失率 = 1 - h$$\n\n**平均访问时间：**\n$$t_a = h \\times t_c + (1-h) \\times t_m$$\n\n其中：\n- $t_c$：Cache访问时间\n- $t_m$：主存访问时间\n\n**效率：**\n$$e = \\frac{t_c}{t_a}$$', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (121, 2, 'Cache的映射方式有哪些？', '**Cache映射方式：**\n\n**1. 直接映射**\n- 主存块固定映射到Cache某一行\n- 映射公式：$Cache行号 = 主存块号 \\mod Cache行数$\n- 简单，但冲突率高\n\n**2. 全相联映射**\n- 主存块可映射到任意Cache行\n- 灵活，命中率高\n- 但比较电路复杂\n\n**3. 组相联映射**\n- Cache分组，组内全相联\n- 折中方案\n- 映射公式：$组号 = 主存块号 \\mod 组数$\n\n**比较：**\n\n| 方式 | 灵活性 | 硬件复杂度 | 命中率 |\n|------|--------|-----------|--------|\n| 直接 | 低 | 低 | 低 |\n| 全相联 | 高 | 高 | 高 |\n| 组相联 | 中 | 中 | 中 |', 5, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (122, 2, 'Cache替换算法有哪些？', '**Cache替换算法：**\n\n**1. 随机算法（RAND）**\n- 随机选择一行替换\n- 简单，但性能差\n\n**2. 先进先出（FIFO）**\n- 替换最早进入的行\n- 简单，可能替换常用数据\n\n**3. 最近最少使用（LRU）**\n- 替换最长时间未使用的行\n- 性能好，常用\n- 需要记录使用情况\n\n**4. 最不经常使用（LFU）**\n- 替换使用次数最少的行\n\n**注意：** 直接映射无需替换算法', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (123, 2, 'Cache写策略有哪些？', '**Cache写策略：**\n\n**1. 写回法（Write-Back）**\n- 写Cache时暂不写主存\n- 替换时才写回主存\n- 减少主存写入次数\n- 需修改位标记\n\n**2. 写直达法（Write-Through）**\n- 写Cache时同时写主存\n- 主存数据始终最新\n- 增加主存写入次数\n\n**3. 写不分配（Write-No-Allocate）**\n- 写缺失时直接写主存，不调入Cache\n\n**4. 写分配（Write-Allocate）**\n- 写缺失时先调入Cache再写入\n\n**推荐搭配：**\n- 写回法 + 写分配\n- 写直达 + 写不分配', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (124, 2, '什么是虚拟存储器？', '**虚拟存储器的定义：**\n\n虚拟存储器是将主存和辅存统一编址，形成一个大范围的虚拟地址空间。\n\n**基本原理：**\n- 程序使用虚拟地址\n- 通过地址转换映射到物理地址\n- 暂时不用的部分放在辅存\n\n**实现方式：**\n\n**1. 页式虚拟存储**\n- 按页划分\n- 页表记录映射\n\n**2. 段式虚拟存储**\n- 按逻辑段划分\n- 段表记录映射\n\n**3. 段页式虚拟存储**\n- 先分段，再分页', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (125, 2, '什么是TLB（快表）？TLB的作用是什么？', '**TLB（Translation Lookaside Buffer）：**\n\nTLB是专门存放页表项的高速缓存，也叫快表。\n\n**作用：**\n- 加速虚拟地址到物理地址的转换\n- 避免每次访问都查主存中的页表\n\n**TLB与Cache的区别：**\n- TLB缓存的是页表项（地址映射）\n- Cache缓存的是数据内容\n\n**地址转换流程：**\n1. 查TLB\n2. TLB命中：直接得到物理地址\n3. TLB缺失：查主存页表\n\n**平均访存时间：**\n$$t = TLB命中率 \\times (TLB时间 + Cache时间) + ...$$', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (126, 2, '指令的格式是怎样的？', '**指令格式：**\n\n```\n┌───────────┬───────────────────┐\n│  操作码OP  │    地址码AD       │\n└───────────┴───────────────────┘\n```\n\n**操作码**：指明指令的操作功能\n\n**地址码**：指明操作数的地址\n\n**按地址码数量分类：**\n\n1. **零地址指令**：无操作数（如停机指令）\n2. **一地址指令**：单操作数（如自增指令）\n3. **二地址指令**：双操作数（如加法指令）\n4. **三地址指令**：三操作数（运算结果存入第三地址）\n5. **多地址指令**：多操作数', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (127, 2, '常见的指令寻址方式有哪些？', '**指令寻址方式：**\n\n**1. 立即寻址**\n- 操作数直接在指令中\n- 速度快，但操作数范围有限\n\n**2. 直接寻址**\n- 地址码直接给出操作数地址\n- $EA = A$（有效地址=形式地址）\n\n**3. 间接寻址**\n- 地址码给出操作数地址的地址\n- $EA = (A)$\n\n**4. 寄存器寻址**\n- 地址码给出寄存器编号\n- 操作数在寄存器中\n\n**5. 寄存器间接寻址**\n- 寄存器中存放操作数地址\n\n**6. 基址寻址**\n- $EA = (BR) + A$（基址寄存器+偏移）\n\n**7. 变址寻址**\n- $EA = (IX) + A$（变址寄存器+偏移）\n\n**8. 相对寻址**\n- $EA = (PC) + A$（PC+偏移）', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (128, 2, '基址寻址和变址寻址有什么区别？', '**基址寻址 vs 变址寻址：**\n\n**基址寻址：**\n$$EA = (BR) + A$$\n\n- 基址寄存器BR内容由OS确定\n- 面向系统，用于程序重定位\n- 实现多道程序浮动\n\n**变址寻址：**\n$$EA = (IX) + A$$\n\n- 变址寄存器IX内容由用户设定\n- 面向用户，用于数组访问\n- 实现循环程序\n\n**应用场景：**\n- 基址寻址：程序在内存中浮动定位\n- 变址寻址：数组元素访问（IX为数组下标）', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (129, 2, '什么是CISC和RISC？有什么区别？', '**CISC vs RISC：**\n\n**CISC（复杂指令集计算机）：**\n- 指令数量多（100+条）\n- 指令长度不固定\n- 寻址方式多样\n- 指令执行时间差异大\n- x86为代表\n\n**RISC（精简指令集计算机）：**\n- 指令数量少（几十条）\n- 指令长度固定\n- 寻址方式简单\n- 指令执行时间短（大多1周期）\n- ARM为代表\n\n**对比：**\n\n| 特性 | CISC | RISC |\n|------|------|------|\n| 指令数量 | 多 | 少 |\n| 指令长度 | 可变 | 固定 |\n| CPI | 大 | 小 |\n| 寄存器数量 | 少 | 多 |\n| 流水线 | 困难 | 容易 |', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (130, 2, 'CPU的基本结构是什么？', '**CPU基本结构：**\n\n**1. 运算器**\n- ALU：算术逻辑运算\n- 通用寄存器：暂存数据\n- 状态寄存器：存放状态标志\n\n**2. 控制器**\n- PC（程序计数器）：存放下一条指令地址\n- IR（指令寄存器）：存放当前指令\n- MAR（地址寄存器）：存放主存地址\n- MDR（数据寄存器）：存放主存数据\n\n**数据通路：**\nCPU内部数据传输的路径，包括寄存器之间的连接、ALU等。', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (131, 2, 'PC（程序计数器）的作用是什么？', '**PC（Program Counter）：**\n\n**定义：**\nPC存放下一条指令的地址。\n\n**功能：**\n1. 取指时：PC内容送MAR\n2. 取指后：PC自动加1（或加指令长度）\n3. 执行转移指令时：PC被新地址替换\n\n**PC自增方式：**\n- 按字节寻址：PC + 指令字节数\n- 按字寻址：PC + 1\n\n**注意：**\n- PC位数由存储器地址空间决定\n- PC不一定是字长', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (132, 2, 'MAR和MDR的作用是什么？', '**MAR（Memory Address Register）：**\n\n存放要访问的主存单元地址。\n\n**位数：** 与主存地址线宽度相同\n\n**功能：**\n- 地址总线与主存连接\n- CPU访存时地址送MAR\n\n---\n\n**MDR（Memory Data Register）：**\n\n存放从主存读出的数据或要写入主存的数据。\n\n**位数：** 与主存数据线宽度相同\n\n**功能：**\n- 数据总线与主存连接\n- 读操作：主存数据→MDR\n- 写操作：MDR数据→主存', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (133, 2, '指令执行的过程是怎样的？', '**指令执行周期：**\n\n**1. 取指周期（IF）**\n- PC→MAR→主存\n- 主存→MDR→IR\n- PC+1\n\n**2. 译码/分析周期**\n- 分析指令操作码\n- 识别寻址方式\n\n**3. 执行周期（EX）**\n- 执行指令操作\n- 不同指令执行内容不同\n\n**4. 中断周期（INT）**\n- 响应中断\n- 保存断点\n- 转中断服务程序', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (134, 2, '什么是数据通路？数据通路的基本结构是什么？', '**数据通路的定义：**\n\n数据通路是指CPU内部数据传输的路径，包括寄存器、ALU、互连线路等。\n\n**基本结构：**\n\n**1. 总线结构**\n- 单总线：所有部件共享一条总线\n- 双总线：分离数据总线\n- 三总线：最高效率\n\n**2. 专用通路结构**\n- 各部件之间有专用连接\n- 速度快，硬件复杂\n\n**数据通路操作：**\n- 寄存器之间传送\n- ALU运算\n- 与主存交互', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (135, 2, '什么是流水线技术？', '**流水线技术：**\n\n将指令执行过程分解为若干个子过程，每个子过程由独立的功能部件并行执行。\n\n**基本原理：**\n```\n时间片:  1   2   3   4   5   6   7   8\n指令1:  IF  ID  EX  WB\n指令2:      IF  ID  EX  WB\n指令3:          IF  ID  EX  WB\n指令4:              IF  ID  EX  WB\n```\n\n**流水线阶段：**\n- IF（Instruction Fetch）：取指\n- ID（Instruction Decode）：译码\n- EX（Execute）：执行\n- WB（Write Back）：写回\n\n**理想吞吐率：**\n$$TP = \\frac{n}{T}$$', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (136, 2, '流水线的性能指标有哪些？', '**流水线性能指标：**\n\n**1. 吞吐率（TP）**\n$$TP = \\frac{指令数}{执行时间}$$\n\n**2. 加速比（S）**\n$$S = \\frac{非流水线执行时间}{流水线执行时间}$$\n\n**3. 效率（E）**\n$$E = \\frac{有效时空区}{总时空区}$$\n\n**理想情况：**\n$$S = n$$（n级流水线）\n$$E \\approx 1$$\n\n**实际考虑：**\n- 流水线建立时间\n- 流水线排空时间', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (137, 2, '流水线有哪些冲突？如何解决？', '**流水线冲突（Hazard）：**\n\n**1. 结构冲突**\n- 多条指令同时使用同一硬件资源\n- 解决：资源重复配置\n\n**2. 数据冲突**\n- 后续指令需要前面指令的结果\n- 解决方法：\n  - 暂停（ Stall）\n  - 数据旁路（Forwarding）\n  - 编译优化\n\n**3. 控制冲突**\n- 转移指令改变执行顺序\n- 解决方法：\n  - 分支预测\n  - 延迟分支\n  - 预取目标指令', 5, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (138, 2, '什么是数据旁路技术？', '**数据旁路（Forwarding）：**\n\n将前一条指令的执行结果直接送到后一条指令的执行阶段，避免等待写回。\n\n**工作原理：**\n```\n指令1: IF  ID  EX  *──→ WB\n指令2:     IF  ID ←──* EX  WB\n                  (旁路连接)\n```\n\n**优点：**\n- 减少流水线停顿\n- 提高流水线效率\n\n**适用条件：**\n- RAW（Read After Write）冲突\n- 后读前写的情况', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (139, 2, '什么是超标量处理器？', '**超标量处理器：**\n\n**定义：**\n具有多条流水线，可同时发射多条指令并行执行。\n\n**特点：**\n1. 多个执行单元\n2. 多条指令并行发射\n3. 动态指令调度\n\n**与普通流水线的区别：**\n\n| 特性 | 普通流水线 | 超标量 |\n|------|-----------|--------|\n| 指令发射 | 1条/周期 | 多条/周期 |\n| 流水线数 | 1条 | 多条 |\n| 并行度 | 时间并行 | 时间+空间并行 |\n\n**例子：**\n- Intel Core系列\n- AMD Ryzen系列', 5, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (140, 2, '什么是总线？总线的分类有哪些？', '**总线的定义：**\n\n总线是连接计算机各部件的信息传输线路。\n\n**总线分类：**\n\n**按位置分类：**\n1. **片内总线**：芯片内部（如CPU内部）\n2. **系统总线**：连接CPU、主存、I/O接口\n3. **通信总线**：连接计算机与外部设备\n\n**按功能分类：**\n1. **数据总线**：传输数据\n2. **地址总线**：传输地址\n3. **控制总线**：传输控制信号\n\n**数据总线宽度：**\n- 决定一次传输的数据量\n- 与字长相关\n\n**地址总线宽度：**\n- 决定可寻址空间大小\n- n位地址总线：$2^n$地址空间', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (141, 2, '总线的主要性能指标有哪些？', '**总线性能指标：**\n\n**1. 总线宽度**\n- 数据总线位数\n- 如32位、64位\n\n**2. 总线频率**\n- 总线工作频率\n- 单位：MHz、GHz\n\n**3. 总线带宽**\n$$带宽 = \\frac{总线宽度 \\times 总线频率}{8}$$\n\n单位：MB/s 或 GB/s\n\n**4. 总线传输率**\n- 单位时间传输的数据量\n\n**示例：**\n64位总线，频率800MHz\n$$带宽 = \\frac{64 \\times 800 \\times 10^6}{8} = 6.4 GB/s$$', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (142, 2, '总线仲裁方式有哪些？', '**总线仲裁方式：**\n\n解决多个主设备同时请求总线的问题。\n\n**1. 集中仲裁**\n\n- **链式查询**：请求信号沿链传递，优先级由位置决定\n- **计数器定时查询**：计数器计数，轮流分配\n- **独立请求**：每个设备有独立请求线，仲裁器裁决\n\n**2. 分布仲裁**\n\n- 各设备自行检测总线状态\n- 自行决定是否使用\n\n**优先级策略：**\n- 固定优先级\n- 动态优先级（时间片轮转）', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (143, 2, '总线定时方式有哪些？', '**总线定时方式：**\n\n**1. 同步定时**\n\n- 所有设备按统一时钟工作\n- 简单，效率高\n- 但受最长传输延迟限制\n\n**2. 异步定时**\n\n- 不依赖统一时钟\n- 使用握手信号\n- 适应不同速度设备\n\n**异步定时握手协议：**\n\n```\n主设备              从设备\n   │                   │\n   │─── REQUEST ────→ │\n   │                   │\n   │ ←── ACKNOWLEDGE ──│\n   │                   │\n   │─── DATA ────────→ │\n   │                   │\n```', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (144, 2, 'I/O接口的功能是什么？', '**I/O接口功能：**\n\n1. **地址译码和设备选择**\n   - 识别CPU要访问的设备\n\n2. **数据缓冲**\n   - 解决速度匹配问题\n   - 数据寄存器\n\n3. **数据格式转换**\n   - 串/并行转换\n   - 电平转换\n\n4. **控制逻辑**\n   - 接收CPU命令\n   - 向CPU报告状态\n\n5. **中断请求**\n   - I/O完成后向CPU发中断', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (145, 2, 'I/O接口的编址方式有哪些？', '**I/O编址方式：**\n\n**1. 统一编址（存储器映射方式）**\n\n- I/O端口与主存单元统一编址\n- 访问I/O用访存指令\n- 无需专门I/O指令\n\n**优点：**\n- 编程方便\n- I/O端口空间大\n\n**缺点：**\n- 占用主存地址空间\n\n**2. 独立编址（I/O映射方式）**\n\n- I/O端口单独编址\n- 使用专门的I/O指令\n\n**优点：**\n- 不占用主存空间\n\n**缺点：**\n- 需专门I/O指令\n\n**x86采用独立编址，ARM采用统一编址**', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (146, 2, '程序查询方式的I/O工作原理是什么？', '**程序查询方式：**\n\nCPU不断查询I/O设备状态，直到设备准备好。\n\n**工作流程：**\n\n```\n1. CPU启动I/O设备\n2. 循环检查设备状态\n   while (状态 != 就绪) {\n       检查状态;\n   }\n3. 执行数据传输\n4. 继续其他操作\n```\n\n**特点：**\n- 简单，硬件成本低\n- CPU效率低（大部分时间在等待）\n- 适合低速设备或实时性要求不高的情况', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (147, 2, '程序中断方式的I/O工作原理是什么？', '**程序中断方式：**\n\nCPU启动I/O后继续执行其他程序，I/O完成后向CPU发中断。\n\n**工作流程：**\n\n```\n1. CPU启动I/O，继续执行程序\n2. I/O设备准备数据\n3. 数据准备好，向CPU发中断请求\n4. CPU响应中断，执行中断服务程序\n5. 处理数据，返回原程序\n```\n\n**特点：**\n- CPU与I/O并行工作\n- 提高CPU利用率\n- 需要中断机制支持\n\n**适用：** 中低速设备', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (148, 2, 'DMA方式的I/O工作原理是什么？', '**DMA（Direct Memory Access）：**\n\n数据直接在主存和I/O设备间传输，无需CPU干预。\n\n**DMA工作过程：**\n\n```\n1. CPU初始化DMA：\n   - 主存地址\n   - 传输字数\n   - 操作类型\n   - 启动DMA\n\n2. DMA接管总线控制权\n3. DMA直接控制数据传输\n4. 传输完成，向CPU发中断\n5. CPU处理DMA完成事件\n```\n\n**特点：**\n- CPU只在初始化和结束时参与\n- 传输期间CPU可执行其他程序\n- 高速数据传输\n\n**适用：** 高速块设备（如磁盘）', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (149, 2, 'DMA有哪几种传输方式？', '**DMA传输方式：**\n\n**1. 停止CPU访存**\n\n- DMA传输期间CPU停止\n- 简单，但CPU效率低\n\n**2. 周期挪用**\n\n- DMA在CPU不使用存储周期时窃用\n- CPU可能暂停一个周期\n- 效率较高\n\n**3. 交替访存**\n\n- CPU和DMA交替使用存储周期\n- 无冲突，效率最高\n- 需要特殊存储器设计\n\n**推荐：周期挪用**', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (150, 2, '中断向量是什么？中断向量表的作用是什么？', '**中断向量：**\n\n中断服务程序的入口地址。\n\n**中断向量表：**\n\n存放所有中断向量的表格。\n\n**工作原理：**\n\n```\n中断发生 → 中断类型号 → 查中断向量表 → 得到中断向量 → 转中断服务程序\n```\n\n**中断向量表位置：**\n- x86：内存低地址区（0000H开始）\n- ARM：固定地址或向量基地址寄存器\n\n**中断类型号：**\n- 每个中断源有唯一编号\n- 根据编号查表得到向量', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (151, 2, '什么是多重中断？如何实现？', '**多重中断：**\n\n在处理一个中断时，响应更高优先级的中断。\n\n**实现条件：**\n\n1. **中断优先级机制**\n   - 不同中断源有不同优先级\n\n2. **中断屏蔽**\n   - 高优先级中断可打断低优先级中断处理\n   - 通过中断屏蔽寄存器实现\n\n**工作流程：**\n\n```\nCPU执行程序\n    ↓\n中断A发生 → 处理中断A\n    ↓\n中断B发生（优先级更高） → 处理中断B\n    ↓\n中断B完成 → 继续处理中断A\n    ↓\n中断A完成 → 继续执行程序\n```', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (152, 3, '什么是操作系统？', '操作系统（Operating System, OS）是计算机系统中最基本的系统软件，是管理和控制计算机硬件与软件资源的程序集合。\n\n**主要功能：**\n- 管理硬件资源（CPU、内存、I/O设备）\n- 提供用户接口\n- 为应用程序提供运行环境', 2, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (153, 3, '操作系统的主要功能有哪些？', '**操作系统的四大基本功能：**\n\n1. **处理机管理**：进程控制、进程同步、进程通信、调度\n2. **存储器管理**：内存分配与回收、地址映射、内存保护、内存扩充\n3. **设备管理**：缓冲管理、设备分配、设备处理\n4. **文件管理**：文件存储空间管理、目录管理、文件读写管理与保护', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (154, 3, '操作系统的特征有哪些？', '**操作系统的四大特征：**\n\n1. **并发性**：两个或多个事件在同一时间间隔内发生\n2. **共享性**：系统资源可供内存中多个并发执行的进程共同使用\n3. **虚拟性**：将一个物理实体映射为若干个逻辑实体\n4. **异步性**：进程执行具有不确定性，执行顺序和速度不可预知', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (155, 3, '并发和并行有什么区别？', '**并发（Concurrency）：**\n- 单核CPU环境下，宏观上同时执行，微观上交替执行\n- 时间片轮转实现\n\n**并行（Parallelism）：**\n- 多核CPU环境下，多个程序真正同时执行\n- 需要硬件支持\n\n**关键区别：**\n- 并发是逻辑上的同时\n- 并行是物理上的同时', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (156, 3, '操作系统的发展经历了哪些阶段？', '**操作系统发展阶段：**\n\n1. **手工操作阶段**：无OS，用户直接操作硬件\n2. **批处理阶段**：单道批处理→多道批处理\n3. **分时操作系统**：时间片轮转，交互性强\n4. **实时操作系统**：实时响应，可靠性高\n5. **现代操作系统**：网络OS、分布式OS、嵌入式OS等', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (157, 3, '什么是批处理操作系统？有什么特点？', '**批处理操作系统：**\n\n将一批作业提交给操作系统，由操作系统控制自动运行。\n\n**单道批处理特点：**\n- 内存中只保持一道作业\n- 作业自动顺序执行\n- CPU与I/O串行，利用率低\n\n**多道批处理特点：**\n- 内存中同时保持多道作业\n- CPU与I/O并行，利用率高\n- 无交互能力', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (158, 3, '分时操作系统有什么特点？', '**分时操作系统特点：**\n\n1. **多路性**：多个用户同时使用一台计算机\n2. **独立性**：各用户独立操作，互不干扰\n3. **及时性**：用户请求能在短时间内得到响应\n4. **交互性**：用户可以进行人机对话\n\n**关键：** 时间片轮转技术实现', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (159, 3, '实时操作系统与分时操作系统有什么区别？', '**实时操作系统 vs 分时操作系统：**\n\n| 特性 | 实时OS | 分时OS |\n|------|--------|--------|\n| 响应时间 | 毫秒/微秒级 | 秒级 |\n| 可靠性 | 极高 | 一般 |\n| 交互性 | 弱 | 强 |\n| 应用场景 | 工业/军事控制 | 办公/学习 |\n\n**实时OS特点：**\n- 实时响应\n- 高可靠性\n- 时限约束', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (160, 3, '操作系统的运行机制有哪些？', '**操作系统的运行机制：**\n\n1. **特权指令**：只能由操作系统内核使用的指令（如I/O指令、置中断指令）\n2. **非特权指令**：用户程序可以使用的指令\n\n**处理器状态：**\n- **核心态（管态）**：可执行所有指令\n- **用户态（目态）**：只能执行非特权指令\n\n**状态切换：**\n- 用户态→核心态：通过中断/异常\n- 核心态→用户态：通过特权指令', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (161, 3, '什么是中断？中断的作用是什么？', '**中断的定义：**\n中断是指CPU对系统中或系统外发生的异步事件的响应。\n\n**中断的作用：**\n1. 实现多道程序并发执行\n2. 实现用户态与核心态的转换\n3. 实现I/O操作与CPU操作并行\n4. 实现人机交互\n\n**中断类型：**\n- **外中断（中断）**：来自CPU外部的事件\n- **内中断（异常）**：来自CPU内部的事件', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (162, 3, '中断和异常有什么区别？', '**中断 vs 异常：**\n\n| 特性 | 中断 | 异常 |\n|------|------|------|\n| 来源 | CPU外部 | CPU内部 |\n| 时机 | 异步 | 同步 |\n| 处理 | 返回下一条指令 | 可能返回当前指令 |\n\n**常见例子：**\n- **中断**：I/O中断、时钟中断\n- **异常**：除零错误、缺页异常、非法操作码', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (163, 3, '中断处理的过程是怎样的？', '**中断处理过程：**\n\n1. **中断请求**：外部设备向CPU发出中断信号\n2. **中断判优**：如果有多个中断，选择优先级最高的\n3. **中断响应**：\n   - 保存断点（PC）\n   - 保存程序状态字（PSW）\n   - 找到中断服务程序入口地址\n4. **中断处理**：执行中断服务程序\n5. **中断返回**：恢复现场，返回断点', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (164, 3, '什么是系统调用？', '**系统调用的定义：**\n系统调用是操作系统提供给应用程序的编程接口，是用户程序获得操作系统服务的唯一途径。\n\n**系统调用的过程：**\n1. 用户程序执行系统调用指令（如int 0x80）\n2. 从用户态切换到核心态\n3. 执行相应的系统调用处理程序\n4. 返回用户态\n\n**常见系统调用：**\n- 进程控制：fork, exec, exit\n- 文件操作：open, read, write\n- 进程通信：pipe, shmget', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (165, 3, '什么是进程？', '**进程的定义：**\n进程是程序的一次执行过程，是系统进行资源分配和调度的基本单位。\n\n**进程与程序的区别：**\n- 程序是静态的，进程是动态的\n- 程序是永久的，进程是暂时的\n- 一个程序可以对应多个进程\n\n**进程的特征：**\n1. 动态性\n2. 并发性\n3. 独立性\n4. 异步性\n5. 结构性', 2, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (166, 3, '进程由哪些部分组成？', '**进程的组成：**\n\n1. **PCB（进程控制块）**：进程存在的唯一标识\n   - 进程标识信息（PID）\n   - 处理机状态信息\n   - 进程调度信息\n   - 进程控制信息\n\n2. **程序段**：程序的代码部分\n\n3. **数据段**：程序处理的数据\n\n$$进程 = PCB + 程序段 + 数据段$$', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (167, 3, '进程有哪些状态？状态之间如何转换？', '**进程的五种基本状态：**\n\n1. **创建态（New）**：进程正在创建\n2. **就绪态（Ready）**：进程已准备好，等待CPU\n3. **运行态（Running）**：进程正在CPU上执行\n4. **阻塞态（Blocked/Waiting）**：进程等待某个事件\n5. **终止态（Terminated）**：进程已结束\n\n**状态转换：**\n- 就绪→运行：进程调度\n- 运行→就绪：时间片用完\n- 运行→阻塞：等待事件（如I/O请求）\n- 阻塞→就绪：事件发生（如I/O完成）', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (168, 3, '进程状态转换中，哪些是由进程主动发起的？', '**主动转换 vs 被动转换：**\n\n**进程主动发起的转换：**\n- 运行→阻塞（主动等待）\n  - 例如：进程请求I/O、等待资源\n\n**操作系统发起的转换：**\n- 就绪→运行（调度程序选择）\n- 运行→就绪（时间片用完）\n- 阻塞→就绪（I/O完成，唤醒）\n\n**关键理解：**\n进程只能\"主动让出CPU\"（阻塞自己），不能\"主动获取CPU\"。', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (169, 3, '什么是PCB？PCB包含哪些信息？', '**PCB（进程控制块）的定义：**\nPCB是进程存在的唯一标识，操作系统通过PCB来管理进程。\n\n**PCB包含的信息：**\n\n1. **进程标识信息**\n   - 进程ID（PID）\n   - 用户ID、父进程ID\n\n2. **处理机状态信息**\n   - 通用寄存器\n   - 程序计数器（PC）\n   - 程序状态字（PSW）\n   - 栈指针\n\n3. **进程调度信息**\n   - 进程状态\n   - 进程优先级\n   - 调度所需其他信息\n\n4. **进程控制信息**\n   - 程序和数据地址\n   - 进程同步与通信信息\n   - 资源清单\n   - 链接指针', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (170, 3, '进程与线程有什么区别？', '**进程 vs 线程：**\n\n| 特性 | 进程 | 线程 |\n|------|------|------|\n| 资源 | 独立地址空间 | 共享地址空间 |\n| 调度 | 资源分配基本单位 | CPU调度基本单位 |\n| 开销 | 大（切换需切换资源） | 小（只需切换少量寄存器） |\n| 通信 | 需IPC机制 | 直接读写共享变量 |\n| 安全性 | 进程间隔离 | 一个线程崩溃可能影响其他线程 |\n\n**线程的特点：**\n- 线程是轻量级进程\n- 同一进程的线程共享资源\n- 线程有自己独立的栈和寄存器', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (171, 3, '进程通信有哪些方式？', '**进程通信方式（IPC）：**\n\n1. **共享存储**\n   - 分配共享存储区\n   - 进程直接读写共享区\n   - 需要同步机制\n\n2. **消息传递**\n   - 直接通信：发送方→接收方\n   - 间接通信：通过信箱\n   - 系统调用：send()、receive()\n\n3. **管道通信**\n   - 单向数据流\n   - 大小有限\n   - 分为匿名管道和命名管道\n\n4. **信号量**\n   - 用于同步\n   - P、V操作', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (172, 3, '什么是进程调度？调度算法有哪些？', '**进程调度的定义：**\n进程调度是按某种算法从就绪队列中选择一个进程，将处理机分配给它。\n\n**调度算法：**\n\n1. **先来先服务（FCFS）**\n   - 按到达顺序调度\n   - 非抢占式\n\n2. **短作业优先（SJF）**\n   - 选择估计运行时间最短的进程\n   - 平均等待时间最短\n\n3. **时间片轮转（RR）**\n   - 分时系统常用\n   - 时间片大小影响性能\n\n4. **优先级调度**\n   - 按优先级高低调度\n   - 可抢占或非抢占\n\n5. **多级反馈队列**\n   - 结合多种算法\n   - 灵活性高', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (173, 3, 'FCFS调度算法有什么特点？', '**FCFS（先来先服务）调度算法：**\n\n**特点：**\n- 按进程到达顺序进行调度\n- 非抢占式算法\n- 实现简单\n\n**优点：**\n- 公平、简单\n- 不会导致饥饿\n\n**缺点：**\n- 平均等待时间较长\n- \"护航效应\"：短进程可能等待长进程\n- 不适合分时系统\n\n**等待时间计算：**\n等待时间 = 开始执行时间 - 到达时间', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (174, 3, '短作业优先（SJF）调度算法有什么特点？', '**SJF（短作业优先）调度算法：**\n\n**特点：**\n- 选择估计运行时间最短的进程\n- 可抢占（SRTF）或非抢占\n\n**优点：**\n- 平均等待时间最短\n- 周转时间最优\n\n**缺点：**\n- 需要预知作业运行时间\n- 长作业可能饥饿\n- 不考虑优先级\n\n**注意：**\nSRTF（最短剩余时间优先）是抢占式SJF', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (175, 3, '时间片轮转（RR）调度算法中，时间片大小如何选择？', '**时间片轮转（RR）调度算法：**\n\n**时间片选择原则：**\n\n1. **时间片太大**\n   - 退化为FCFS\n   - 响应时间变长\n\n2. **时间片太小**\n   - 频繁切换，开销大\n   - CPU利用率低\n\n3. **经验公式：**\n$$时间片大小 = \\frac{响应时间上限}{用户数}$$\n\n**理想时间片：**\n- 略大于一次典型交互所需时间\n- 使大部分进程在一个时间片内完成', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (176, 3, '多级反馈队列调度算法的工作原理是什么？', '**多级反馈队列调度算法：**\n\n**工作原理：**\n1. 设置多个就绪队列，优先级递减\n2. 第1队列优先级最高，时间片最短\n3. 新进程进入第1队列队尾\n4. 若时间片用完未完成，降入下一级队列\n5. 仅当高优先级队列为空时，才调度低优先级队列\n6. 低优先级队列采用FCFS\n\n**优点：**\n- 兼顾长、短作业\n- 不需要预知运行时间\n- 响应时间短\n- 吞吐量高', 5, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (177, 3, '什么是临界资源？什么是临界区？', '**临界资源的定义：**\n一次仅允许一个进程使用的资源。\n例如：打印机、共享变量、共享缓冲区\n\n**临界区的定义：**\n访问临界资源的那段代码。\n\n**临界区访问原则：**\n1. **空闲让进**：临界区空闲时，允许请求的进程进入\n2. **忙则等待**：临界区被占用时，其他进程必须等待\n3. **有限等待**：请求进入临界区的进程应在有限时间内进入\n4. **让权等待**：不能进入临界区的进程应释放CPU', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (178, 3, '什么是信号量？P、V操作的定义是什么？', '**信号量的定义：**\n信号量是一个整型变量，用于实现进程同步与互斥。\n\n**P操作（wait）：**\n```\nP(S):\n  S = S - 1\n  if S < 0:\n    阻塞当前进程，加入等待队列\n```\n\n**V操作（signal）：**\n```\nV(S):\n  S = S + 1\n  if S <= 0:\n    唤醒等待队列中的一个进程\n```\n\n**信号量类型：**\n- **整型信号量**：仅用于互斥\n- **记录型信号量**：包含等待队列，可避免忙等', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (179, 3, '如何使用信号量实现进程互斥？', '**使用信号量实现互斥：**\n\n设置互斥信号量 mutex，初值为1。\n\n```c\nsemaphore mutex = 1;  // 互斥信号量\n\n// 进程Pi:\nwhile (true) {\n    P(mutex);        // 申请进入临界区\n    \n    临界区;         // 访问临界资源\n    \n    V(mutex);        // 释放临界区\n    \n    剩余区;\n}\n```\n\n**注意：**\n- P、V操作必须成对出现\n- P(mutex)在临界区前，V(mutex)在临界区后', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (180, 3, '如何使用信号量实现进程同步？', '**使用信号量实现同步：**\n\n设置同步信号量，初值为0。\n\n```c\nsemaphore S = 0;  // 同步信号量\n\n// 进程P1（先执行部分）\nP1() {\n    执行操作1;\n    V(S);  // 通知P2可以执行\n}\n\n// 进程P2（后执行部分）\nP2() {\n    P(S);  // 等待P1完成\n    执行操作2;\n}\n```\n\n**原则：**\n- 前驱操作完成后执行V(S)\n- 后继操作开始前执行P(S)', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (181, 3, '生产者-消费者问题如何解决？', '**生产者-消费者问题：**\n\n```c\nsemaphore mutex = 1;    // 互斥信号量\nsemaphore empty = n;    // 空缓冲区数量\nsemaphore full = 0;     // 满缓冲区数量\n\nProducer() {\n    while (true) {\n        生产一个产品;\n        P(empty);\n        P(mutex);\n        将产品放入缓冲区;\n        V(mutex);\n        V(full);\n    }\n}\n\nConsumer() {\n    while (true) {\n        P(full);\n        P(mutex);\n        从缓冲区取出产品;\n        V(mutex);\n        V(empty);\n        消费产品;\n    }\n}\n```\n\n**注意：** P(empty/full) 和 P(mutex) 的顺序不能颠倒，否则会死锁！', 5, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (182, 3, '读者-写者问题如何解决？', '**读者-写者问题（读者优先）：**\n\n```c\nsemaphore mutex = 1;    // 保护readcount\nsemaphore wrt = 1;      // 写者互斥\nint readcount = 0;      // 读者计数\n\nReader() {\n    P(mutex);\n    readcount++;\n    if (readcount == 1)\n        P(wrt);         // 第一个读者阻塞写者\n    V(mutex);\n    \n    读取数据;\n    \n    P(mutex);\n    readcount--;\n    if (readcount == 0)\n        V(wrt);         // 最后一个读者唤醒写者\n    V(mutex);\n}\n\nWriter() {\n    P(wrt);\n    写入数据;\n    V(wrt);\n}\n```\n\n**问题：** 读者优先可能导致写者饥饿', 5, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (183, 3, '哲学家进餐问题如何解决？', '**哲学家进餐问题：**\n\n五个哲学家围坐，每人左右各一根筷子。\n\n**解决方案（限制同时就餐人数）：**\n\n```c\nsemaphore chopstick[5] = {1, 1, 1, 1, 1};\nsemaphore mutex = 1;    // 限制同时就餐人数\n\nPhilosopher(int i) {\n    while (true) {\n        思考;\n        \n        P(mutex);        // 限制就餐人数\n        P(chopstick[i]);      // 拿左筷子\n        P(chopstick[(i+1)%5]); // 拿右筷子\n        \n        进餐;\n        \n        V(chopstick[i]);\n        V(chopstick[(i+1)%5]);\n        V(mutex);\n    }\n}\n```\n\n**其他方案：**\n- 奇数号先拿左，偶数号先拿右\n- 同时拿两根筷子', 5, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (184, 3, '什么是死锁？', '**死锁的定义：**\n两个或多个进程无限期地等待永远不会发生的事件，导致进程无法继续执行。\n\n**死锁产生的必要条件（四个同时满足）：**\n\n1. **互斥条件**：资源一次只能被一个进程使用\n2. **请求与保持条件**：进程已持有资源，又请求新资源\n3. **不可剥夺条件**：进程已持有的资源不能被强制剥夺\n4. **循环等待条件**：存在进程资源的循环等待链', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (185, 3, '处理死锁有哪些方法？', '**处理死锁的方法：**\n\n1. **预防死锁**\n   - 破坏死锁的四个必要条件之一\n   - 方法：静态分配、有序分配\n\n2. **避免死锁**\n   - 允许进程动态申请资源\n   - 但在分配前检查是否安全\n   - 银行家算法\n\n3. **检测死锁**\n   - 允许死锁发生\n   - 定期检测是否存在死锁\n   - 资源分配图\n\n4. **解除死锁**\n   - 剥夺资源\n   - 撤销进程', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (186, 3, '银行家算法的原理是什么？', '**银行家算法：**\n\n**核心数据结构：**\n- Available[]：可用资源向量\n- Max[][]：最大需求矩阵\n- Allocation[][]：已分配矩阵\n- Need[][]：需求矩阵 = Max - Allocation\n\n**安全性算法：**\n1. 初始化 Work = Available, Finish[i] = false\n2. 找一个满足 Need[i] ≤ Work 且 Finish[i] = false 的进程\n3. 执行进程：Work += Allocation[i], Finish[i] = true\n4. 若所有 Finish[i] = true，则安全\n\n**请求算法：**\n1. 若 Request[i] ≤ Need[i] 且 Request[i] ≤ Available\n2. 试探分配，检查是否安全\n3. 安全则真正分配，否则等待', 5, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (187, 3, '如何预防死锁？', '**预防死锁的方法（破坏必要条件）：**\n\n1. **破坏互斥条件**\n   - 使用SPOOLing技术\n   - 不太现实（有些资源必须互斥）\n\n2. **破坏请求与保持条件**\n   - 静态分配：进程启动时申请全部资源\n   - 缺点：资源利用率低\n\n3. **破坏不可剥夺条件**\n   - 允许剥夺已分配资源\n   - 缺点：实现复杂，开销大\n\n4. **破坏循环等待条件**\n   - 有序资源分配：资源编号，按序申请\n   - 最常用的预防方法', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (188, 3, '内存管理的主要功能有哪些？', '**内存管理的主要功能：**\n\n1. **内存空间的分配与回收**\n   - 分配：为进程分配内存空间\n   - 回收：进程结束后回收内存\n\n2. **地址转换**\n   - 逻辑地址→物理地址\n   - 静态重定位/动态重定位\n\n3. **内存空间的扩充**\n   - 虚拟存储技术\n   - 覆盖与交换\n\n4. **存储保护**\n   - 防止进程间相互干扰\n   - 越界检查、存取控制', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (189, 3, '连续分配方式有哪些？', '**连续分配方式：**\n\n1. **单一连续分配**\n   - 内存分为系统区、用户区\n   - 单道程序环境\n   - 简单，但内存利用率低\n\n2. **固定分区分配**\n   - 预先将内存划分为固定大小的分区\n   - 分区大小相等或不等\n   - 内部碎片问题\n\n3. **动态分区分配**\n   - 按进程需要动态划分\n   - 外部碎片问题\n   - 需要内存紧凑\n\n**碎片类型：**\n- **内部碎片**：分配给进程的内存中，未被使用的部分\n- **外部碎片**：内存中存在的无法利用的小空闲区', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (190, 3, '动态分区分配算法有哪些？', '**动态分区分配算法：**\n\n1. **首次适应算法（First Fit）**\n   - 从头开始找，第一个足够大的空闲区\n   - 简单高效，产生大碎片在后面\n\n2. **最佳适应算法（Best Fit）**\n   - 找最小的足够大的空闲区\n   - 产生最多外部碎片\n\n3. **最坏适应算法（Worst Fit）**\n   - 找最大的空闲区\n   - 避免产生小碎片，但大进程可能无空间\n\n4. **临近适应算法（Next Fit）**\n   - 从上次分配位置开始找\n   - 分配均匀，但大碎片会被分散\n\n**推荐：首次适应算法（综合性能最好）**', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (191, 3, '什么是分页存储管理？', '**分页存储管理：**\n\n**基本概念：**\n- 将用户程序的逻辑地址空间划分为**页**（Page）\n- 将物理内存划分为**页框**（Frame）\n- 页和页框大小相等\n\n**地址结构：**\n```\n逻辑地址 = 页号P + 页内偏移量W\n\n| 页号P | 页内偏移量W |\n```\n\n**地址转换：**\n$$物理地址 = 页框号 \\times 页框大小 + 页内偏移量$$\n\n**页表：**\n记录页号到页框号的映射关系。', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (192, 3, '分页存储管理中，页大小如何选择？', '**页大小的选择：**\n\n**页太大：**\n- 页内碎片大，内存利用率低\n- 页表项少，页表小\n\n**页太小：**\n- 页内碎片小，内存利用率高\n- 页表项多，页表大\n- 页表占用内存多\n\n**典型页大小：**\n- 4KB（32位系统常用）\n- 8KB、16KB（64位系统）\n\n**权衡因素：**\n$$页大小 = \\sqrt{2 \\times 页表项大小 \\times 进程大小}$$', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (193, 3, '什么是分段存储管理？分段与分页有什么区别？', '**分段存储管理：**\n将用户程序按逻辑划分为若干段（如代码段、数据段、栈段）。\n\n**分段 vs 分页：**\n\n| 特性 | 分页 | 分段 |\n|------|------|------|\n| 划分依据 | 物理大小 | 逻辑意义 |\n| 地址空间 | 一维 | 二维 |\n| 碎片 | 内部碎片 | 外部碎片 |\n| 共享 | 困难 | 方便 |\n| 可见性 | 用户不可见 | 用户可见 |\n\n**段式地址结构：**\n```\n逻辑地址 = 段号S + 段内偏移量W\n```\n\n**段表：**\n记录段号到段起始地址、段长度的映射。', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (194, 3, '什么是缺页中断？缺页中断处理过程是什么？', '**缺页中断的定义：**\n进程访问的页面不在内存中时，产生缺页中断。\n\n**缺页中断处理过程：**\n\n1. **检查**：检查页表，发现页面不在内存\n2. **中断**：产生缺页中断，转操作系统处理\n3. **查找**：在外存找到所需页面\n4. **分配**：在内存中找空闲页框\n   - 有空闲：直接分配\n   - 无空闲：执行页面置换算法\n5. **调入**：将页面从外存调入内存\n6. **更新**：更新页表\n7. **返回**：重新执行引起缺页的指令\n\n**注意：** 缺页中断属于内中断（异常）', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (195, 3, '页面置换算法有哪些？', '**页面置换算法：**\n\n1. **最佳置换算法（OPT）**\n   - 淘汰以后永不使用或最长时间不用的页面\n   - 理论最优，无法实现\n\n2. **先进先出（FIFO）**\n   - 淘汰最早进入内存的页面\n   - 简单，但可能有Belady异常\n\n3. **最近最久未使用（LRU）**\n   - 淘汰最近最长时间未使用的页面\n   - 性能接近OPT，常用\n\n4. **时钟置换（CLOCK）**\n   - 使用访问位，循环检查\n   - 简单高效的LRU近似\n\n5. **改进型CLOCK**\n   - 增加修改位\n   - 优先淘汰未访问且未修改的页面', 5, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (196, 3, '什么是Belady异常？', '**Belady异常：**\n\n在采用FIFO页面置换算法时，有时会出现：**分配的页框数增加，缺页次数反而增加**的现象。\n\n**原因：**\nFIFO算法忽略了页面的使用情况，仅按进入顺序淘汰。\n\n**示例：**\n访问串：1, 2, 3, 4, 1, 2, 5, 1, 2, 3, 4, 5\n\n| 页框数 | 缺页次数 |\n|--------|----------|\n| 3      | 9        |\n| 4      | 10       |\n\n**注意：** LRU和OPT不会出现Belady异常。', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (197, 3, '如何计算缺页率？影响缺页率的因素有哪些？', '**缺页率计算：**\n$$缺页率 = \\frac{缺页次数}{访问页面总数}$$\n\n**影响缺页率的因素：**\n\n1. **页框数量**\n   - 页框越多，缺页率越低\n   - 但达到一定数量后，改善不明显\n\n2. **页面大小**\n   - 页面大，缺页率低\n   - 但内部碎片增加\n\n3. **页面置换算法**\n   - LRU优于FIFO\n\n4. **程序局部性**\n   - 局部性越好，缺页率越低\n\n5. **程序编制方法**\n   - 访问局部集中的数据，缺页率低', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (198, 3, 'I/O设备有哪些分类？', '**I/O设备分类：**\n\n1. **按信息交换单位**\n   - **块设备**：以数据块为单位（如磁盘）\n   - **字符设备**：以字符为单位（如键盘、打印机）\n\n2. **按传输速率**\n   - **低速设备**：键盘、鼠标\n   - **中速设备**：打印机\n   - **高速设备**：磁盘、光盘\n\n3. **按共享属性**\n   - **独占设备**：一次只允许一个进程使用\n   - **共享设备**：允许多个进程交替使用\n   - **虚拟设备**：通过SPOOLing技术将独占设备变为共享', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (199, 3, 'I/O控制方式有哪些？', '**I/O控制方式：**\n\n1. **程序直接控制方式**\n   - CPU不断查询设备状态\n   - CPU效率低\n\n2. **中断驱动方式**\n   - 设备准备好后向CPU发中断\n   - CPU可在等待时做其他事\n\n3. **DMA方式**\n   - 数据直接在内存和设备间传输\n   - 仅在开始和结束时需要CPU\n   - 适合块设备\n\n4. **通道控制方式**\n   - 独立的I/O处理器\n   - 一次可处理多个I/O操作\n   - CPU开销最小', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (200, 3, '什么是SPOOLing技术？', '**SPOOLing（假脱机）技术：**\n\n将独占设备改造成共享设备的技术。\n\n**工作原理：**\n1. 在磁盘上开辟输入井和输出井\n2. 用户进程的I/O请求先写入磁盘缓冲区\n3. 设备空闲时再从磁盘缓冲区处理\n\n**组成：**\n- **输入井/输出井**：磁盘上的缓冲区\n- **输入缓冲区/输出缓冲区**：内存中的缓冲区\n- **输入进程/输出进程**：负责数据传输\n\n**优点：**\n- 提高I/O速度\n- 将独占设备变为共享设备\n- 实现虚拟设备', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (201, 3, '磁盘调度算法有哪些？', '**磁盘调度算法：**\n\n1. **先来先服务（FCFS）**\n   - 按请求顺序处理\n   - 公平但效率低\n\n2. **最短寻道时间优先（SSTF）**\n   - 选择与当前磁头最近的请求\n   - 可能导致饥饿\n\n3. **扫描算法（SCAN/电梯算法）**\n   - 磁头单向移动，处理沿途请求\n   - 到边界后反向\n\n4. **循环扫描（C-SCAN）**\n   - 单向移动，处理请求\n   - 到边界后立即返回起点\n   - 更公平\n\n5. **LOOK/C-LOOK**\n   - 不移动到边界，到最远请求即返回\n   - 效率更高', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (202, 3, '磁盘访问时间由哪几部分组成？', '**磁盘访问时间：**\n$$T_a = T_s + T_r + T_t$$\n\n其中：\n- $T_s$：**寻道时间**，磁头移动到指定磁道所需时间\n- $T_r$：**旋转延迟时间**，扇区旋转到磁头下方所需时间\n- $T_t$：**传输时间**，传输数据所需时间\n\n**优化方向：**\n- 寻道时间可通过调度算法优化\n- 旋转延迟平均为半圈时间\n- 传输时间由磁盘物理特性决定\n\n**典型值：**\n- 寻道时间：几毫秒\n- 旋转延迟：几毫秒\n- 传输时间：不到1毫秒', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (203, 3, '文件的逻辑结构有哪些？', '**文件的逻辑结构：**\n\n1. **无结构文件（流式文件）**\n   - 文件是无结构的字节序列\n   - 如文本文件、二进制文件\n\n2. **有结构文件（记录式文件）**\n   - **顺序文件**：记录按顺序排列\n   - **索引文件**：建立索引表\n   - **索引顺序文件**：顺序+索引\n   - **直接文件/散列文件**：通过哈希函数定位\n\n**记录寻址方式：**\n- 隐式寻址：按位置\n- 显式寻址：按键值', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (204, 3, '文件的物理结构有哪些？', '**文件的物理结构：**\n\n1. **连续分配**\n   - 文件占用连续的磁盘块\n   - 优点：顺序访问快\n   - 缺点：外部碎片，文件难以扩展\n\n2. **链接分配**\n   - 文件占用不连续的磁盘块，通过指针链接\n   - 隐式链接：指针在磁盘块中\n   - 显式链接：FAT表\n   - 优点：无外部碎片\n   - 缺点：随机访问慢\n\n3. **索引分配**\n   - 每个文件有一个索引块，记录所有数据块地址\n   - 优点：支持随机访问\n   - 缺点：索引块占用空间\n\n**大文件索引方案：**\n- 多级索引\n- 混合索引（直接索引+间接索引）', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (205, 3, '什么是文件目录？目录结构有哪些？', '**文件目录：**\n文件目录是文件控制块（FCB）的集合，用于实现文件的\"按名存取\"。\n\n**目录结构：**\n\n1. **单级目录**\n   - 整个系统一张目录表\n   - 简单，但文件不能重名\n\n2. **两级目录**\n   - 主目录+用户目录\n   - 不同用户文件可重名\n\n3. **多级目录（树形目录）**\n   - 树形结构\n   - 支持文件重名，层次清晰\n   - 路径：绝对路径、相对路径\n\n4. **无环图目录**\n   - 允许共享文件\n   - 实现文件链接', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (206, 3, '磁盘空闲块管理方法有哪些？', '**磁盘空闲块管理方法：**\n\n1. **空闲表法**\n   - 记录空闲块的首块号和长度\n   - 适合连续分配\n\n2. **空闲链表法**\n   - 将空闲块链接成链表\n   - 管理简单，但效率低\n\n3. **位示图法**\n   - 每位对应一个磁盘块\n   - 0表示空闲，1表示已分配\n   - 紧凑，常用\n\n4. **成组链接法**\n   - UNIX系统采用\n   - 将空闲块分组，组间链接\n   - 适合大容量磁盘', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (207, 3, '什么是磁盘格式化？磁盘容量的计算？', '**磁盘格式化：**\n\n1. **低级格式化**\n   - 划分磁道、扇区\n   - 工厂完成\n\n2. **高级格式化**\n   - 建立文件系统\n   - 划分引导扇区、FAT、根目录等\n\n**磁盘容量计算：**\n$$容量 = 磁头数 \\times 磁道数 \\times 扇区数 \\times 扇区大小$$\n\n**格式化后可用空间：**\n$$可用空间 = 总容量 - 引导扇区 - FAT表 - 根目录$$', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (208, 4, '计算机网络的功能有哪些？', '**计算机网络主要功能：**\n\n1. **数据通信**\n   - 最基本的功能\n   - 实现计算机之间的信息传递\n\n2. **资源共享**\n   - 硬件共享（如打印机）\n   - 软件共享\n   - 数据共享\n\n3. **分布式处理**\n   - 将任务分散到多台计算机\n\n4. **提高可靠性**\n   - 多机备份，单机故障不影响整体', 2, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (209, 4, '计算机网络的分类有哪些？', '**计算机网络分类：**\n\n**按覆盖范围：**\n\n1. **广域网（WAN）**\n   - 覆盖范围：几十到几千公里\n   - 如互联网\n\n2. **城域网（MAN）**\n   - 覆盖范围：一个城市\n   - 如城市有线电视网\n\n3. **局域网（LAN）**\n   - 覆盖范围：一栋建筑或校园\n   - 如校园网\n\n4. **个人区域网（PAN）**\n   - 覆盖范围：10米左右\n   - 如蓝牙网络\n\n**按拓扑结构：**\n- 星形、环形、总线型、网状', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (210, 4, '什么是OSI参考模型？各层功能是什么？', '**OSI七层模型（从下到上）：**\n\n1. **物理层**：传输比特流\n2. **数据链路层**：传输帧，差错控制\n3. **网络层**：传输分组，路由选择\n4. **传输层**：传输报文，端到端通信\n5. **会话层**：建立、管理会话\n6. **表示层**：数据格式转换、加密\n7. **应用层**：用户应用接口\n\n**注意：** OSI是理论模型，实际使用TCP/IP模型', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (211, 4, 'TCP/IP模型的层次结构是什么？', '**TCP/IP四层模型：**\n\n1. **网络接口层**（对应OSI物理层+数据链路层）\n   - 传输比特流和帧\n\n2. **网际层（IP层）**（对应OSI网络层）\n   - 路由选择、分组转发\n   - 核心协议：IP、ICMP、ARP\n\n3. **传输层**（对应OSI传输层）\n   - 端到端通信\n   - TCP：可靠传输\n   - UDP：不可靠传输\n\n4. **应用层**（对应OSI会话层+表示层+应用层）\n   - 应用协议：HTTP、FTP、SMTP等', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (212, 4, 'OSI模型和TCP/IP模型有什么区别？', '**OSI vs TCP/IP：**\n\n| 特性 | OSI | TCP/IP |\n|------|-----|-------|\n| 层数 | 7层 | 4层 |\n| 严格性 | 严格分层 | 灵活分层 |\n| 实现难度 | 复杂 | 简单 |\n| 实际应用 | 理论模型 | 实际标准 |\n\n**对应关系：**\n- OSI物理层+数据链路层 → TCP/IP网络接口层\n- OSI网络层 → TCP/IP网际层\n- OSI传输层 → TCP/IP传输层\n- OSI会话层+表示层+应用层 → TCP/IP应用层', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (213, 4, '数据在各层是如何封装和传输的？', '**数据封装过程（从上到下）：**\n\n1. 应用层：数据加上应用层头 -> 应用层报文\n2. 传输层：报文+TCP/UDP头 -> 报文段/用户数据报\n3. 网络层：报文段+IP头 -> IP分组/数据报\n4. 数据链路层：IP分组+帧头帧尾 -> 帧\n5. 物理层：帧 -> 比特流\n\n**各层PDU名称：**\n- 应用层：报文（Message）\n- 传输层：报文段（Segment）/用户数据报\n- 网络层：分组/数据报（Packet/Datagram）\n- 数据链路层：帧（Frame）\n- 物理层：比特（Bit）', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (214, 4, '物理层的主要功能是什么？', '**物理层功能：**\n\n1. **定义物理特性**\n   - 机械特性：接口形状、尺寸\n   - 电气特性：电压范围\n   - 功能特性：信号线功能\n   - 规程特性：工作顺序\n\n2. **传输比特流**\n   - 将比特流转换为信号\n   - 在传输介质上传输\n\n3. **实现与数据链路层的接口**', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (215, 4, '什么是奈奎斯特定理？', '**奈奎斯特定理（Nyquist）：**\n\n在无噪声的理想低通信道中，极限数据传输率为：\n\n$$C = 2W \\log_2 V$$\n\n其中：\n- $C$：极限数据传输率（bps）\n- $W$：带宽（Hz）\n- $V$：信号的量化级数（离散信号状态数）\n\n**意义：**\n- 信道带宽越宽，传输率越高\n- 信号状态越多，传输率越高\n\n**注意：** 此公式仅适用于无噪声信道', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (216, 4, '什么是香农定理？', '**香农定理（Shannon）：**\n\n在有噪声的信道中，极限数据传输率为：\n\n$$C = W \\log_2 (1 + S/N)$$\n\n其中：\n- $C$：极限数据传输率（bps）\n- $W$：带宽（Hz）\n- $S/N$：信噪比（信号功率与噪声功率之比）\n\n**信噪比常用dB表示：**\n$$信噪比(dB) = 10 \\log_{10}(S/N)$$\n\n**意义：**\n- 信噪比越高，传输率越高\n- 无论用多复杂的编码，都无法超过此极限', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (217, 4, '奈奎斯特定理和香农定理有什么区别？', '**奈奎斯特 vs 香农：**\n\n| 特性 | 奈奎斯特定理 | 香农定理 |\n|------|------------|---------|\n| 适用条件 | 无噪声信道 | 有噪声信道 |\n| 影响因素 | 带宽W、量化级V | 带宽W、信噪比S/N |\n| 公式 | $C=2W\\log_2 V$ | $C=W\\log_2(1+S/N)$ |\n| 提高传输率方法 | 增加量化级 | 提高信噪比 |\n\n**实际应用：**\n- 香农定理给出理论上限\n- 奈奎斯特定理指导编码设计', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (218, 4, '常用的编码方式有哪些？', '**常用编码方式：**\n\n**1. 不归零编码（NRZ）**\n- 高电平表示1，低电平表示0\n- 简单，但无法同步时钟\n\n**2. 归零编码（RZ）**\n- 每个码元中间回到零电平\n- 可以同步，但效率低\n\n**3. 曼彻斯特编码**\n- 码元中间跳变：低→高表示1，高→低表示0\n- 或相反（取决于标准）\n- 可以自同步\n- 常用于以太网\n\n**4. 差分曼彻斯特编码**\n- 码元边界跳变表示0，不跳变表示1\n- 码元中间总有跳变（用于同步）', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (219, 4, '什么是码元？码元速率与数据传输率有什么关系？', '**码元的定义：**\n码元是数字通信中承载信息的基本单位。\n一个码元可以携带1位或多位信息。\n\n**码元速率（波特率）：**\n$$R_B = \\frac{码元数}{单位时间}$$\n单位：波特（Baud）\n\n**数据传输率（比特率）：**\n$$R_b = R_B \\times n$$\n其中 $n$ 为每个码元携带的比特数\n\n**关系：**\n$$R_b = R_B \\log_2 V$$\n其中 $V$ 为码元的状态数\n\n**注意：**\n- 二进制编码：$V=2$，比特率=波特率\n- 多进制编码：$V>2$，比特率>波特率', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (220, 4, '常见的传输介质有哪些？', '**常见传输介质：**\n\n**1. 双绞线**\n- **屏蔽双绞线（STP）**：抗干扰强\n- **无屏蔽双绞线（UTP）**：常用，成本低\n- 分类：3类、5类、6类等\n- 5类UTP：100Mbps以太网\n\n**2. 同轴电缆**\n- 基带同轴电缆：数字信号\n- 宽带同轴电缆：模拟信号\n\n**3. 光纤**\n- **单模光纤**：细芯，远距离，激光光源\n- **多模光纤**：粗芯，近距离，LED光源\n- 特点：带宽大、抗干扰、传输远\n\n**4. 无线传输**\n- 无线电波\n- 微波\n- 红外线', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (221, 4, '单模光纤和多模光纤有什么区别？', '**单模 vs 多模光纤：**\n\n| 特性 | 单模光纤 | 多模光纤 |\n|------|---------|----------|\n| 纤芯直径 | 约10μm | 约50μm |\n| 光源 | 激光 | LED |\n| 传输距离 | 远（几十公里） | 近（几公里） |\n| 成本 | 高 | 低 |\n| 带宽 | 高 | 较低 |\n\n**应用：**\n- 单模：长距离通信、骨干网\n- 多模：局域网、短距离', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (222, 4, '数据链路层的主要功能是什么？', '**数据链路层功能：**\n\n1. **帧定界**\n   - 标识帧的开始和结束\n   - 添加帧头和帧尾\n\n2. **差错控制**\n   - 检测传输错误\n   - CRC校验\n\n3. **流量控制**\n   - 控制发送方发送速率\n   - 防止接收方缓冲区溢出\n\n4. **链路管理**\n   - 建立、维护、释放数据链路\n\n5. **介质访问控制**（对于共享介质）', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (223, 4, '什么是封装成帧？常见的帧定界方法有哪些？', '**封装成帧：**\n将网络层的数据包加上帧头和帧尾，形成数据链路层的帧。\n\n**帧定界方法：**\n\n**1. 字符计数法**\n- 帧头包含帧长度\n- 简单，但一处错误导致后续帧全部出错\n\n**2. 字符填充法**\n- 使用特殊字符作为帧定界符\n- 如：SOH（帧开始）、EOT（帧结束）\n- 数据中出现定界符需转义\n\n**3. 比特填充法**\n- 使用特殊比特序列（如01111110）定界\n- 数据中每5个连续1后插入0\n\n**4. 违规编码法**\n- 使用违规编码序列定界\n- 曼彻斯特编码中不可能出现的序列', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (224, 4, '什么是CRC校验？如何计算？', '**CRC（循环冗余校验）：**\n\n一种高效的差错检测方法。\n\n**计算过程：**\n\n1. 发送方和接收方约定生成多项式$G(x)$\n2. 设$G(x)$为$r$阶，则数据帧后加$r$个0\n3. 用加$r$个0后的数据除以$G(x)$，得余数$R(x)$\n4. 将$R(x)$作为CRC码附加在数据后发送\n\n**接收方检测：**\n- 用收到的数据除以$G(x)$\n- 余数为0：无错\n- 余数非0：有错\n\n**例子：**\n数据1101，G(x)=x^3+x+1=1011\n- 1101000 ÷ 1011 = 1101...001\n- 发送帧：1101001', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (225, 4, '流量控制的方法有哪些？', '**流量控制方法：**\n\n**1. 停止-等待协议**\n- 发送一帧后等待确认\n- 收到确认后才发送下一帧\n- 简单，效率低\n\n**2. 滑动窗口协议**\n- 发送方可连续发送多帧\n- 用窗口控制发送数量\n\n**窗口机制：**\n- 发送窗口：允许发送但未确认的帧\n- 接收窗口：允许接收的帧\n\n**效率：**\n$$信道利用率 = \\frac{帧发送时间}{帧发送时间 + 传播延迟}$$', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (226, 4, '什么是可靠传输？如何实现？', '**可靠传输：**\n保证数据无差错、不丢失、不重复、按序到达。\n\n**实现机制：**\n\n**1. 确认（ACK）**\n- 接收方收到数据后发送确认\n\n**2. 超时重传**\n- 发送方超时未收到确认则重传\n\n**3. 序号**\n- 给每个帧编号\n- 保证按序到达，检测重复\n\n**4. 重传策略**\n- 超时重传时间（RTO）需合理设置\n- 太短：频繁重传\n- 太长：效率低', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (227, 4, '后退N帧协议（GBN）的工作原理是什么？', '**后退N帧协议（Go-Back-N）：**\n\n**特点：**\n- 发送窗口大小$W_T > 1$，接收窗口大小$W_R = 1$\n- 发送方可连续发送多帧\n\n**工作原理：**\n\n1. 发送方连续发送$W_T$个帧\n2. 接收方按序接收，每收到一帧发送累积确认\n3. 若某帧出错或丢失：\n   - 接收方丢弃后续所有帧\n   - 发送方超时后重传出错帧及其后所有帧\n\n**最大窗口大小：**\n$$W_T \\leq 2^n - 1$$\n\n其中$n$为序号位数', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (228, 4, '选择重传协议（SR）的工作原理是什么？', '**选择重传协议（Selective Repeat）：**\n\n**特点：**\n- 发送窗口$W_T > 1$，接收窗口$W_R > 1$\n- 只重传出错或丢失的帧\n\n**工作原理：**\n\n1. 发送方连续发送帧\n2. 接收方可接收窗口内任意帧\n3. 出错帧丢失，其他帧正常接收\n4. 发送方只重传出错的帧\n\n**最大窗口大小：**\n$$W_T = W_R \\leq 2^{n-1}$$\n\n其中$n$为序号位数\n\n**与GBN对比：**\n- SR效率更高，但实现复杂\n- GBN实现简单，但重传浪费', 5, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (229, 4, '什么是介质访问控制（MAC）？', '**介质访问控制：**\n\n控制多个节点如何共享同一传输介质，避免冲突。\n\n**分类：**\n\n**1. 静态划分信道**\n- 频分多路复用（FDM）\n- 时分多路复用（TDM）\n- 波分多路复用（WDM）\n- 码分多路复用（CDM）\n\n**2. 动态分配信道**\n- **随机访问**：CSMA/CD、CSMA/CA\n- **轮询访问**：令牌传递', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (230, 4, '什么是CSMA/CD协议？', '**CSMA/CD（载波监听多点接入/碰撞检测）：**\n\n用于以太网的介质访问控制。\n\n**工作流程：**\n\n1. **监听**：发送前先监听信道\n2. **发送**：信道空闲则发送，忙则等待\n3. **检测**：发送中持续检测是否发生碰撞\n4. **处理碰撞**：\n   - 立即停止发送\n   - 发送干扰信号（强化碰撞）\n   - 执行二进制指数退避算法\n   - 等待后重传\n\n**最小帧长：**\n$$最小帧长 = 2 \\times 传播延迟 \\times 数据传输率$$', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (231, 4, '什么是二进制指数退避算法？', '**二进制指数退避算法：**\n\n用于CSMA/CD中处理碰撞后的重传时机。\n\n**算法步骤：**\n\n1. 确定基本退避时间$2\\tau$（争用期）\n2. 第$k$次碰撞后，从集合$[0, 1, ..., 2^k-1]$中随机取数$r$\n3. 等待时间 $= r \\times 2\\tau$\n4. 重传次数达到上限（通常16次）则放弃\n\n**上限：** $k \\leq 10$，即最大等待$2^{10}-1 = 1023$个争用期\n\n**意义：**\n- 碰撞次数越多，等待时间范围越大\n- 减少再次碰撞的概率', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (232, 4, '以太网的最小帧长是多少？为什么需要最小帧长？', '**最小帧长：**\n\n**标准：** 64字节（512比特）\n\n**原因：**\n\n$$最小帧长 \\geq 2\\tau \\times 数据传输率$$\n\n其中$\\tau$为单程传播延迟\n\n**目的：**\n\n1. **检测碰撞**\n   - 确保发送方在发送完之前能检测到碰撞\n   - 如果帧太短，发送完才知道碰撞\n\n2. **争用期**\n   - $2\\tau$称为争用期（碰撞窗口）\n   - 10Mbps以太网：51.2μs\n\n**不足64字节处理：**\n填充（Padding）补足', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (233, 4, '以太网的帧格式是怎样的？', '**以太网帧格式：**\n\n**各字段：**\n\n- **前导码**：8字节，同步时钟\n- **目的地址**：6字节，接收方MAC地址\n- **源地址**：6字节，发送方MAC地址\n- **类型**：2字节，标识上层协议\n- **数据**：46~1500字节\n- **FCS**：4字节，CRC校验\n\n**帧长度范围：**\n$$64 \\sim 1518 字节$$', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (234, 4, '什么是MAC地址？', '**MAC地址：**\n\n**定义：**\n数据链路层使用的地址，用于标识网络设备。\n\n**特点：**\n\n1. **长度**：48位（6字节）\n2. **格式**：如 00:1A:2B:3C:4D:5E\n3. **唯一性**：全球唯一（厂商分配）\n4. **类型**：\n   - 单播地址：第一字节最低位为0\n   - 广播地址：FF:FF:FF:FF:FF:FF\n   - 多播地址：第一字节最低位为1\n\n**结构：**\n- 前24位：厂商ID（由IEEE分配）\n- 后24位：设备ID（厂商分配）', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (235, 4, '交换机的工作原理是什么？', '**交换机工作原理：**\n\n**自学习算法：**\n\n1. 交换机维护MAC地址表\n2. 收到帧时，记录源MAC地址和对应端口\n3. 根据目的MAC地址查表转发\n\n**转发规则：**\n\n| 目的地址 | 处理方式 |\n|----------|----------|\n| 表中有记录 | 转发到对应端口 |\n| 表中无记录 | 广播到所有端口 |\n| 广播地址 | 广播到所有端口 |\n\n**优点：**\n- 集线器：广播所有帧\n- 交换机：按MAC地址定向转发', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (236, 4, '什么是虚拟局域网（VLAN）？', '**VLAN（虚拟局域网）：**\n\n**定义：**\n将一个物理局域网划分为多个逻辑上的虚拟局域网。\n\n**特点：**\n\n1. **隔离**：不同VLAN之间通信需经过路由器\n2. **灵活**：可跨交换机划分\n3. **安全**：限制广播域，提高安全性\n\n**实现方式：**\n\n- 基于端口划分\n- 基于MAC地址划分\n- 基于协议划分\n\n**帧格式变化：**\n添加VLAN标签（4字节），标识VLAN ID', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (237, 4, '网络层的主要功能是什么？', '**网络层功能：**\n\n1. **路由选择**\n   - 为分组选择从源到目的的最佳路径\n   - 维护路由表\n\n2. **分组转发**\n   - 将分组从一个网络转发到另一个网络\n\n3. **拥塞控制**\n   - 防止网络过载\n\n4. **网络互联**\n   - 连接不同类型的网络', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (238, 4, 'IP地址的格式是怎样的？IPv4地址如何分类？', '**IP地址格式：**\n\n32位IPv4地址，分为网络号和主机号。\n\n**传统分类：**\n\n| 类别 | 网络号 | 主机号 | 网络号范围 |\n|------|--------|--------|-----------|\n| A类 | 8位 | 24位 | 1~126 |\n| B类 | 16位 | 16位 | 128~191 |\n| C类 | 24位 | 8位 | 192~223 |\n| D类 | - | - | 224~239（多播）|\n| E类 | - | - | 240~255（保留）|\n\n**特殊地址：**\n- 0.0.0.0：本机\n- 127.x.x.x：环回测试\n- 255.255.255.255：广播', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (239, 4, '什么是子网掩码？如何划分子网？', '**子网掩码：**\n\n用于区分IP地址的网络部分和主机部分。\n\n**格式：**\n网络号全1，主机号全0\n\n**子网划分：**\n\n将一个网络划分为多个更小的子网。\n\n**方法：**\n1. 从主机号借用若干位作为子网号\n2. 子网掩码相应位置变为1\n\n**计算：**\n$$子网数 = 2^{子网号位数}$$\n$$每个子网主机数 = 2^{主机号位数} - 2$$\n\n**例子：**\n192.168.1.0/24划分为4个子网\n- 借用2位：子网掩码255.255.255.192\n- 子网：192.168.1.0、.64、.128、.192', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (240, 4, '什么是CIDR？CIDR有什么优势？', '**CIDR（无分类域间路由）：**\n\n**特点：**\n- 取消A、B、C类地址分类\n- 使用斜线记法：如192.168.1.0/24\n- /24表示前24位为网络前缀\n\n**优势：**\n\n1. **地址分配灵活**\n   - 可按实际需要分配任意大小的地址块\n\n2. **路由聚合（超网）**\n   - 多个连续网络聚合为一个路由条目\n   - 减少路由表规模\n\n**路由聚合：**\n192.168.0.0/24和192.168.1.0/24\n可聚合为192.168.0.0/23', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (241, 4, '什么是NAT？NAT的作用是什么？', '**NAT（网络地址转换）：**\n\n**定义：**\n将内部私有IP地址转换为外部公有IP地址。\n\n**作用：**\n\n1. **节省IP地址**\n   - 内部使用私有地址\n   - 多个内部主机共享少量公网IP\n\n2. **隐藏内部网络**\n   - 外部无法直接访问内部主机\n   - 提高安全性\n\n**私有地址范围：**\n- A类：10.0.0.0 ~ 10.255.255.255\n- B类：172.16.0.0 ~ 172.31.255.255\n- C类：192.168.0.0 ~ 192.168.255.255\n\n**类型：**\n- 静态NAT、动态NAT、NAPT（端口转换）', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (242, 4, 'IP数据报的格式是怎样的？', '**IP数据报格式：**\n\n**首部（20字节固定部分）：**\n\n| 字段 | 长度 | 说明 |\n|------|------|------|\n| 版本 | 4位 | IPv4为4 |\n| 首部长度 | 4位 | 单位4字节 |\n| 总长度 | 16位 | 整个数据报长度 |\n| 标识 | 16位 | 分片重组用 |\n| 标志 | 3位 | DF、MF |\n| 片偏移 | 13位 | 分片位置 |\n| 生存时间 | 8位 | TTL |\n| 协议 | 8位 | 上层协议 |\n| 首部校验和 | 16位 | |\n| 源地址 | 32位 | |\n| 目的地址 | 32位 | |\n\n**TTL：** 最大255，每经过路由器减1，为0时丢弃', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (243, 4, 'IP数据报分片的过程是怎样的？', '**IP分片：**\n\n当IP数据报长度超过MTU时需要分片。\n\n**分片过程：**\n\n1. 检查DF标志位\n   - DF=1：不可分片，丢弃\n   - DF=0：可分片\n\n2. 分片计算\n   - 每片长度≤MTU-首部长度\n   - 片偏移以8字节为单位\n\n3. 设置标志\n   - MF=1：后面还有分片\n   - MF=0：最后一片\n\n**重组：**\n- 在目的主机重组\n- 根据标识、源地址、目的地址匹配\n\n**例子：**\n4000字节数据，MTU=1500\n分片：1480、1480、1040字节（数据部分）', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (244, 4, '什么是ARP协议？ARP的工作过程是怎样的？', '**ARP（地址解析协议）：**\n\n**作用：**\n将IP地址解析为MAC地址。\n\n**工作过程：**\n\n1. 查ARP缓存表\n   - 有记录：直接使用\n   - 无记录：发送ARP请求\n\n2. ARP请求\n   - 广播帧：目的MAC=FF:FF:FF:FF:FF:FF\n   - 内容：谁的IP是x.x.x.x？请告诉y.y.y.y\n\n3. ARP响应\n   - 目标主机收到请求\n   - 单播响应：我的IP是x.x.x.x，MAC是...\n\n4. 更新ARP缓存表\n\n**ARP缓存：**\n- 动态学习，定期更新', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (245, 4, '什么是DHCP协议？DHCP的工作过程是怎样的？', '**DHCP（动态主机配置协议）：**\n\n**作用：**\n自动为主机分配IP地址等网络配置。\n\n**工作过程（DORA）：**\n\n1. **Discover（发现）**\n   - 客户机广播寻找DHCP服务器\n\n2. **Offer（提供）**\n   - DHCP服务器响应，提供IP地址\n\n3. **Request（请求）**\n   - 客户机广播请求使用该地址\n\n4. **Acknowledge（确认）**\n   - DHCP服务器确认分配\n\n**分配信息：**\n- IP地址、子网掩码\n- 默认网关、DNS服务器\n- 租期（Lease）', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (246, 4, '什么是ICMP协议？ICMP有哪些应用？', '**ICMP（互联网控制报文协议）：**\n\n**作用：**\n传递差错报文和控制报文。\n\n**差错报告报文：**\n- 目的不可达\n- 时间超时（TTL=0）\n- 参数问题\n- 重定向\n\n**ICMP询问报文：**\n- 回送请求/回答（Ping使用）\n- 时间戳请求/回答\n\n**应用：**\n\n**Ping：**\n- 测试连通性\n- 使用ICMP回送请求/回答\n\n**Traceroute：**\n- 踪迹路由路径\n- 利用TTL超时报文\n- 发送TTL递增的数据报', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (247, 4, '常见的路由算法有哪些？', '**路由算法分类：**\n\n**1. 静态路由**\n- 手工配置\n- 简单，但适应性差\n\n**2. 动态路由**\n\n**距离向量算法（RIP）：**\n- 基于跳数\n- 周期性交换路由表\n- 收敛慢，可能有环路\n\n**链路状态算法（OSPF）：**\n- 基于链路状态（延迟、带宽等）\n- 每个路由器了解全网拓扑\n- 收敛快，无环路\n\n**层次化路由（BGP）：**\n- 用于自治系统之间\n- 基于策略路由', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (248, 4, 'RIP协议的特点是什么？', '**RIP（路由信息协议）：**\n\n**特点：**\n\n1. **距离向量算法**\n   - 以跳数为距离\n   - 最大跳数15（16表示不可达）\n\n2. **周期更新**\n   - 每30秒广播路由表\n\n3. **收敛问题**\n   - 可能出现路由环路\n   - 使用水平分割、毒性逆转解决\n\n**RIP报文：**\n- 封装在UDP，端口520\n\n**路由表项：**\n- 目的网络、下一跳、跳数', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (249, 4, 'OSPF协议的特点是什么？', '**OSPF（开放最短路径优先）：**\n\n**特点：**\n\n1. **链路状态算法**\n   - 基于链路状态数据库\n   - 使用Dijkstra算法计算最短路径\n\n2. **层次化**\n   - 区域（Area）划分\n   - 减少路由信息量\n\n3. **快速收敛**\n   - 链路变化立即传播\n\n4. **报文直接封装IP**\n   - 协议号89\n\n**OSPF报文类型：**\n- Hello、数据库描述、链路状态请求/更新/确认', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (250, 4, 'BGP协议的特点是什么？', '**BGP（边界网关协议）：**\n\n**特点：**\n\n1. **自治系统间路由**\n   - 用于不同AS之间\n   - AS号标识自治系统\n\n2. **路径向量算法**\n   - 记录完整路径信息\n   - 避免环路\n\n3. **基于策略**\n   - 可根据策略选择路由\n   - 非纯技术最优\n\n4. **TCP传输**\n   - 端口179\n   - 可靠传输\n\n**BGP报文：**\n- Open、Update、Keepalive、Notification', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (251, 4, '传输层的主要功能是什么？', '**传输层功能：**\n\n1. **端到端通信**\n   - 从源主机到目的主机\n   - 提供进程到进程的通信\n\n2. **端口寻址**\n   - 使用端口号标识进程\n\n3. **差错控制**\n   - 检测传输错误\n\n4. **流量控制**\n   - 防止发送方淹没接收方\n\n5. **复用和分用**\n   - 多进程共用一个传输层', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (252, 4, '什么是端口号？常见端口号有哪些？', '**端口号：**\n\n16位，范围0~65535。\n\n**分类：**\n\n1. **熟知端口（0~1023）**\n   - 由系统分配\n\n2. **登记端口（1024~49151）**\n   - IANA登记\n\n3. **动态端口（49152~65535）**\n   - 客户端临时使用\n\n**常见熟知端口：**\n\n| 协议 | 端口 |\n|------|------|\n| HTTP | 80 |\n| HTTPS | 443 |\n| FTP | 20/21 |\n| SMTP | 25 |\n| DNS | 53 |\n| SSH | 22 |\n| Telnet | 23 |', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (253, 4, 'TCP和UDP有什么区别？', '**TCP vs UDP：**\n\n| 特性 | TCP | UDP |\n|------|-----|------|\n| 连接 | 面向连接 | 无连接 |\n| 可靠性 | 可靠传输 | 不可靠 |\n| 流量控制 | 有 | 无 |\n| 拥塞控制 | 有 | 无 |\n| 传输效率 | 低 | 高 |\n| 首部开销 | 20字节 | 8字节 |\n| 传输方式 | 字节流 | 报文 |\n\n**应用：**\n- **TCP**：文件传输、邮件、网页\n- **UDP**：视频流、DNS、游戏', 3, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (254, 4, 'TCP报文段的首部格式是怎样的？', '**TCP首部（20字节固定部分）：**\n\n| 字段 | 长度 | 说明 |\n|------|------|------|\n| 源端口 | 16位 | |\n| 目的端口 | 16位 | |\n| 序号 | 32位 | 字节流编号 |\n| 确认号 | 32位 | 期望收到的序号 |\n| 数据偏移 | 4位 | 首部长度 |\n| 标志位 | 6位 | URG,ACK,PSH,RST,SYN,FIN |\n| 窗口 | 16位 | 接收窗口大小 |\n| 校验和 | 16位 | |\n| 紧急指针 | 16位 | |\n\n**重要标志位：**\n- SYN：建立连接\n- ACK：确认有效\n- FIN：释放连接', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (255, 4, 'TCP的三次握手过程是怎样的？', '**TCP三次握手：**\n\n```\n客户端                服务端\n   │                   │\n   │─── SYN ──────────→│ (1) 客户请求建立连接\n   │     seq=x         │\n   │                   │\n   │←── SYN+ACK ───────│ (2) 服务确认并请求\n   │     seq=y,ack=x+1 │\n   │                   │\n   │─── ACK ──────────→│ (3) 客户确认\n   │     ack=y+1       │\n```\n\n**状态变化：**\n- 客户端：CLOSED → SYN_SENT → ESTABLISHED\n- 服务端：CLOSED → LISTEN → SYN_RCVD → ESTABLISHED\n\n**目的：** 防止已失效的连接请求突然到达服务端', 4, '0', '2026-04-22 08:22:19', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (256, 4, 'TCP的四次挥手过程是怎样的？', '**TCP四次挥手：**\n\n1. 客户端发送FIN，请求关闭连接\n2. 服务端收到FIN，发送ACK确认\n3. 服务端发送FIN，请求关闭连接\n4. 客户端收到FIN，发送ACK确认\n\n**状态变化：**\n- 客户端：ESTABLISHED -> FIN_WAIT_1 -> FIN_WAIT_2 -> TIME_WAIT -> CLOSED\n- 服务端：ESTABLISHED -> CLOSE_WAIT -> LAST_ACK -> CLOSED\n\n**TIME_WAIT：**\n- 客户端等待2MSL（最大段生存时间）\n- 确保最后的ACK到达', 4, '0', '2026-04-22 08:22:20', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (257, 4, 'TCP的流量控制机制是怎样的？', '**TCP流量控制：**\n\n**滑动窗口机制：**\n\n- 接收方在ACK中携带窗口大小\n- 发送方根据窗口控制发送量\n\n**零窗口处理：**\n\n1. 接收方窗口为0时，发送方停止发送\n2. 发送方启动零窗口探测定时器\n3. 定时器到期发送1字节探测\n4. 接收方回复新窗口大小\n\n**窗口更新：**\n- 接收方有空间时发送窗口更新通告', 4, '0', '2026-04-22 08:22:20', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (258, 4, 'TCP的拥塞控制机制是怎样的？', '**TCP拥塞控制：**\n\n**四个阶段：**\n\n1. **慢开始**\n   - cwnd从1开始，每RTT翻倍\n   - 到慢开始门限ssthresh\n\n2. **拥塞避免**\n   - cwnd线性增长\n   - 每RTT加1\n\n3. **快重传**\n   - 收到3个重复ACK立即重传\n   - 不等超时\n\n4. **快恢复**\n   - 检测到拥塞后：\n   - ssthresh = cwnd/2\n   - cwnd = ssthresh\n   - 进入拥塞避免\n\n**超时处理：**\n- ssthresh = cwnd/2\n- cwnd = 1，慢开始', 5, '0', '2026-04-22 08:22:20', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (259, 4, 'UDP报文的首部格式是怎样的？', '**UDP首部（8字节）：**\n\n**字段说明：**\n\n- **源端口**：2字节，发送方端口\n- **目的端口**：2字节，接收方端口\n- **长度**：2字节，整个UDP报文长度\n- **校验和**：2字节，可选，检验整个报文\n\n**注意：**\n- UDP首部开销小\n- 校验和计算包含伪首部', 3, '0', '2026-04-22 08:22:20', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (260, 4, '应用层的主要功能是什么？', '**应用层功能：**\n\n1. **定义应用协议**\n   - 规定应用进程间的通信规则\n\n2. **提供网络服务接口**\n   - 为用户提供各种网络服务\n\n**常见应用协议：**\n\n- WWW：HTTP\n- 文件传输：FTP\n- 电子邮件：SMTP、POP3、IMAP\n- 域名解析：DNS\n- 远程登录：Telnet、SSH', 2, '0', '2026-04-22 08:22:20', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (261, 4, 'DNS的作用是什么？DNS的查询过程是怎样的？', '**DNS（域名系统）：**\n\n**作用：**\n将域名解析为IP地址。\n\n**DNS层次结构：**\n```\n根域名服务器\n  ↓\n顶级域名服务器（.com, .edu等）\n  ↓\n权威域名服务器\n```\n\n**查询过程：**\n\n1. 查本地DNS缓存\n2. 无记录则向本地DNS服务器查询\n3. 本地DNS服务器递归或迭代查询：\n   - **递归查询**：服务器代为查询\n   - **迭代查询**：服务器返回下一级服务器地址\n\n**DNS报文：**\n- UDP端口53（或TCP）', 4, '0', '2026-04-22 08:22:20', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (262, 4, 'HTTP协议的特点是什么？', '**HTTP（超文本传输协议）：**\n\n**特点：**\n\n1. **无状态**\n   - 服务器不保存客户状态\n   - 每次请求独立\n\n2. **基于TCP**\n   - 端口80\n   - 可靠传输\n\n**HTTP版本：**\n\n- **HTTP/1.0**：非持久连接\n- **HTTP/1.1**：持久连接（Keep-Alive）、流水线\n- **HTTP/2**：多路复用、头部压缩\n\n**请求方法：**\nGET、POST、PUT、DELETE等', 3, '0', '2026-04-22 08:22:20', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (263, 4, 'HTTP请求报文和响应报文的格式是怎样的？', '**HTTP报文格式：**\n\n**请求报文：**\n- 请求行：方法 URL 版本\n- 首部行：Header字段\n- 空行\n- 实体主体（可选）\n\n**响应报文：**\n- 状态行：版本 状态码 短语\n- 首部行：Header字段\n- 空行\n- 实体主体\n\n**常见状态码：**\n\n- **200**：成功\n- **301/302**：重定向\n- **404**：资源不存在\n- **500**：服务器内部错误', 4, '0', '2026-04-22 08:22:20', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (264, 4, 'FTP协议的工作原理是什么？', '**FTP（文件传输协议）：**\n\n**特点：**\n- 使用两个TCP连接\n\n**控制连接：**\n- 端口21\n- 传输FTP命令和响应\n- 整个会话期间保持\n\n**数据连接：**\n- 端口20（主动模式）或客户端口（被动模式）\n- 传输文件数据\n- 每传输一个文件建立一次\n\n**工作模式：**\n\n- **主动模式**：服务器主动连接客户\n- **被动模式**：客户连接服务器', 4, '0', '2026-04-22 08:22:20', NULL);
INSERT INTO `biz_card` (`card_id`, `subject_id`, `front_content`, `back_content`, `difficulty_level`, `del_flag`, `create_time`, `update_time`) VALUES (265, 4, '电子邮件系统的工作原理是什么？', '**电子邮件协议：**\n\n**发送邮件：SMTP**\n- 端口25\n- 从客户到服务器\n- 从服务器到服务器\n\n**接收邮件：**\n\n**POP3**\n- 端口110\n- 下载并删除（或保留）\n\n**IMAP**\n- 端口143\n- 在服务器管理邮件\n\n**邮件格式：**\n\n**MIME**：多用途互联网邮件扩展\n- 支持多媒体内容\n- 扩展SMTP', 4, '0', '2026-04-22 08:22:20', NULL);
COMMIT;

-- ----------------------------
-- Table structure for biz_card_tag
-- ----------------------------
DROP TABLE IF EXISTS `biz_card_tag`;
CREATE TABLE `biz_card_tag` (
  `card_id` bigint NOT NULL,
  `tag_id` bigint NOT NULL,
  PRIMARY KEY (`card_id`,`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='卡片标签关联表';

-- ----------------------------
-- Records of biz_card_tag
-- ----------------------------
BEGIN;
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (1, 1);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (1, 2);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (2, 1);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (2, 3);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (3, 4);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (4, 5);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (5, 5);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (6, 6);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (7, 10);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (8, 11);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (9, 12);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (12, 7);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (13, 8);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (14, 9);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (16, 13);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (17, 13);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (18, 13);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (18, 14);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (20, 16);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (23, 17);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (23, 18);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (23, 19);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (24, 17);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (24, 19);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (24, 20);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (24, 21);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (25, 17);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (25, 19);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (25, 22);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (26, 17);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (26, 19);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (26, 23);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (26, 24);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (27, 5);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (27, 6);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (27, 19);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (27, 25);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (27, 26);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (27, 27);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (28, 19);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (28, 28);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (28, 29);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (28, 30);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (28, 31);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (28, 32);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (29, 19);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (29, 29);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (29, 30);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (29, 33);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (30, 19);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (30, 34);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (30, 35);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (30, 36);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (31, 19);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (31, 37);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (31, 38);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (31, 39);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (31, 40);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (32, 19);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (32, 41);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (32, 42);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (32, 43);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (32, 44);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (33, 1);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (33, 19);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (33, 45);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (33, 46);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (34, 1);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (34, 19);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (34, 47);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (34, 48);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (34, 49);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (34, 50);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (35, 2);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (35, 19);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (35, 51);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (35, 52);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (36, 38);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (36, 53);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (36, 54);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (37, 29);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (37, 53);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (37, 55);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (37, 56);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (38, 1);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (38, 53);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (38, 55);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (38, 57);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (39, 1);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (39, 53);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (39, 55);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (39, 58);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (40, 30);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (40, 53);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (40, 59);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (40, 60);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (41, 53);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (41, 57);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (41, 59);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (41, 61);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (42, 53);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (42, 58);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (42, 59);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (43, 53);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (43, 57);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (43, 58);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (43, 62);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (44, 53);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (44, 63);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (44, 64);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (44, 65);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (45, 33);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (45, 53);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (45, 55);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (45, 66);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (45, 67);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (46, 54);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (46, 68);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (46, 69);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (46, 70);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (46, 71);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (46, 72);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (47, 72);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (47, 73);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (47, 74);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (47, 75);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (47, 76);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (48, 72);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (48, 77);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (48, 78);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (48, 79);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (49, 72);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (49, 75);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (49, 76);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (49, 80);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (50, 72);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (50, 81);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (50, 82);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (50, 83);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (50, 84);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (51, 72);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (51, 81);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (51, 85);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (51, 86);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (51, 87);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (52, 54);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (52, 72);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (52, 88);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (52, 89);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (52, 90);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (52, 91);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (53, 72);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (53, 92);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (53, 93);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (53, 94);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (53, 95);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (54, 72);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (54, 92);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (54, 96);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (54, 97);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (55, 72);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (55, 98);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (55, 99);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (55, 100);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (55, 101);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (55, 102);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (56, 72);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (56, 103);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (56, 104);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (56, 105);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (57, 54);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (57, 106);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (57, 107);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (57, 108);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (58, 29);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (58, 30);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (58, 106);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (58, 109);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (59, 1);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (59, 106);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (59, 110);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (59, 111);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (60, 106);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (60, 112);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (60, 113);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (60, 114);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (61, 106);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (61, 112);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (61, 113);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (61, 115);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (61, 116);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (62, 5);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (62, 117);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (62, 118);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (62, 119);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (62, 120);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (63, 120);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (63, 121);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (63, 122);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (64, 120);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (64, 123);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (64, 124);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (65, 118);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (65, 120);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (65, 125);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (65, 126);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (66, 120);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (66, 127);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (66, 128);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (66, 129);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (66, 130);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (66, 131);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (67, 120);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (67, 132);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (67, 133);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (68, 120);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (68, 134);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (68, 135);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (68, 136);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (69, 120);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (69, 137);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (69, 138);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (69, 139);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (70, 6);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (70, 140);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (70, 141);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (70, 142);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (71, 6);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (71, 143);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (71, 144);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (71, 145);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (71, 146);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (72, 6);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (72, 147);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (72, 148);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (72, 149);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (72, 150);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (73, 6);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (73, 28);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (73, 151);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (73, 152);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (74, 6);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (74, 127);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (74, 153);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (74, 154);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (75, 6);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (75, 155);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (75, 156);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (75, 157);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (76, 6);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (76, 158);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (76, 159);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (76, 160);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (77, 6);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (77, 145);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (77, 161);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (77, 162);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (78, 6);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (78, 163);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (78, 164);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (78, 165);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (79, 166);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (79, 167);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (79, 168);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (80, 166);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (80, 167);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (80, 169);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (81, 166);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (81, 170);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (81, 171);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (81, 172);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (82, 166);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (82, 173);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (82, 174);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (83, 166);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (83, 175);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (83, 176);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (84, 166);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (84, 177);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (84, 178);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (84, 179);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (85, 166);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (85, 180);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (85, 181);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (86, 166);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (86, 182);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (86, 183);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (87, 166);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (87, 184);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (87, 185);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (87, 186);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (87, 187);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (88, 188);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (88, 189);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (88, 190);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (89, 188);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (89, 191);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (89, 192);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (90, 188);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (90, 193);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (90, 194);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (90, 195);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (91, 188);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (91, 192);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (91, 196);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (92, 188);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (92, 195);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (92, 197);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (92, 198);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (93, 188);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (93, 195);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (93, 199);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (94, 188);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (94, 195);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (94, 200);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (94, 201);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (95, 2);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (95, 188);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (95, 192);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (95, 202);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (96, 188);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (96, 192);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (96, 203);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (96, 204);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (97, 1);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (97, 188);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (97, 205);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (97, 206);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (98, 188);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (98, 207);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (98, 208);
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (98, 209);
COMMIT;

-- ----------------------------
-- Table structure for biz_feedback
-- ----------------------------
DROP TABLE IF EXISTS `biz_feedback`;
CREATE TABLE `biz_feedback` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `app_user_id` bigint DEFAULT NULL COMMENT '用户ID',
  `card_id` bigint DEFAULT NULL COMMENT '关联的卡片ID（若是对具体卡片的纠错）',
  `type` varchar(20) NOT NULL COMMENT '反馈类型: SUGGESTION(建议), ERROR(纠错), FUNCTION(功能问题), OTHER(其他)',
  `rating` tinyint DEFAULT NULL COMMENT '评分（1-5星）',
  `content` text NOT NULL COMMENT '反馈详细内容',
  `contact` varchar(100) DEFAULT NULL COMMENT '用户留下的联系方式',
  `images` text COMMENT '图片附件（存储URL列表，JSON格式）',
  `status` char(1) DEFAULT '0' COMMENT '处理状态（0待处理 1已采纳 2已忽略）',
  `admin_reply` text COMMENT '管理员回复内容',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '处理时间',
  PRIMARY KEY (`id`),
  KEY `idx_card_id` (`card_id`),
  KEY `idx_status` (`status`),
  KEY `idx_app_user_id` (`app_user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户反馈表';

-- ----------------------------
-- Records of biz_feedback
-- ----------------------------
BEGIN;
INSERT INTO `biz_feedback` (`id`, `app_user_id`, `card_id`, `type`, `rating`, `content`, `contact`, `images`, `status`, `admin_reply`, `create_time`, `update_time`) VALUES (1, 2, 1, 'SUGGESTION', 2, '学不动啦各位', '1223', NULL, '1', '好', '2026-04-22 12:39:45', '2026-04-22 15:37:15');
COMMIT;

-- ----------------------------
-- Table structure for biz_major
-- ----------------------------
DROP TABLE IF EXISTS `biz_major`;
CREATE TABLE `biz_major` (
  `major_id` bigint NOT NULL AUTO_INCREMENT COMMENT '专业ID',
  `major_name` varchar(50) NOT NULL COMMENT '专业名称(如: 408计算机)',
  `description` text COMMENT '专业描述',
  `status` char(1) DEFAULT '0' COMMENT '状态',
  PRIMARY KEY (`major_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='专业信息表';

-- ----------------------------
-- Records of biz_major
-- ----------------------------
BEGIN;
INSERT INTO `biz_major` (`major_id`, `major_name`, `description`, `status`) VALUES (1, '408计算机考研', '计算机学科专业基础综合考试', '0');
COMMIT;

-- ----------------------------
-- Table structure for biz_subject
-- ----------------------------
DROP TABLE IF EXISTS `biz_subject`;
CREATE TABLE `biz_subject` (
  `subject_id` bigint NOT NULL AUTO_INCREMENT COMMENT '科目ID',
  `major_id` bigint NOT NULL COMMENT '所属专业ID',
  `subject_name` varchar(50) NOT NULL COMMENT '科目名称(如: 数据结构)',
  `icon` varchar(255) DEFAULT NULL COMMENT '科目图标',
  `order_num` int DEFAULT '0' COMMENT '排序',
  PRIMARY KEY (`subject_id`),
  KEY `idx_major_id` (`major_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='科目信息表';

-- ----------------------------
-- Records of biz_subject
-- ----------------------------
BEGIN;
INSERT INTO `biz_subject` (`subject_id`, `major_id`, `subject_name`, `icon`, `order_num`) VALUES (1, 1, '数据结构', NULL, 1);
INSERT INTO `biz_subject` (`subject_id`, `major_id`, `subject_name`, `icon`, `order_num`) VALUES (2, 1, '计算机组成原理', NULL, 2);
INSERT INTO `biz_subject` (`subject_id`, `major_id`, `subject_name`, `icon`, `order_num`) VALUES (3, 1, '操作系统', NULL, 3);
INSERT INTO `biz_subject` (`subject_id`, `major_id`, `subject_name`, `icon`, `order_num`) VALUES (4, 1, '计算机网络', NULL, 4);
COMMIT;

-- ----------------------------
-- Table structure for biz_tag
-- ----------------------------
DROP TABLE IF EXISTS `biz_tag`;
CREATE TABLE `biz_tag` (
  `tag_id` bigint NOT NULL AUTO_INCREMENT COMMENT '标签ID',
  `tag_name` varchar(50) NOT NULL COMMENT '标签名称(如:#PV操作)',
  PRIMARY KEY (`tag_id`)
) ENGINE=InnoDB AUTO_INCREMENT=210 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='标签表';

-- ----------------------------
-- Records of biz_tag
-- ----------------------------
BEGIN;
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (1, '时间复杂度');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (2, '空间复杂度');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (3, '排序算法');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (4, '查找算法');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (5, '树');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (6, '图');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (7, 'PV操作');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (8, '进程调度');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (9, '内存管理');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (10, 'Cache');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (11, '中断');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (12, 'DMA');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (13, 'TCP');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (14, 'UDP');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (15, 'IP协议');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (16, 'HTTP');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (17, '基本概念');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (18, '数据');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (19, '绪论');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (20, '数据元素');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (21, '数据项');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (22, '数据对象');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (23, '数据结构');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (24, '三要素');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (25, '逻辑结构');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (26, '集合');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (27, '线性');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (28, '存储结构');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (29, '顺序存储');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (30, '链式存储');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (31, '索引存储');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (32, '散列存储');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (33, '对比');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (34, '数据类型');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (35, '原子类型');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (36, '结构类型');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (37, '抽象数据类型');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (38, 'ADT');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (39, '抽象性');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (40, '封装性');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (41, '算法');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (42, '算法特性');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (43, '有穷性');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (44, '确定性');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (45, '大O表示法');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (46, '复杂度分析');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (47, '常数阶');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (48, '对数阶');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (49, '线性阶');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (50, '平方阶');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (51, '辅助空间');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (52, '递归栈');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (53, '线性表');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (54, '定义');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (55, '顺序表');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (56, '随机存取');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (57, '插入操作');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (58, '删除操作');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (59, '单链表');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (60, '结点结构');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (61, '头结点');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (62, '双向链表');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (63, '循环链表');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (64, '循环单链表');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (65, '循环双链表');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (66, '链表');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (67, '选择');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (68, '栈');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (69, 'LIFO');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (70, '栈顶');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (71, '栈底');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (72, '栈和队列');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (73, '顺序栈');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (74, '栈顶指针');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (75, '进栈');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (76, '出栈');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (77, '共享栈');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (78, '双向栈');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (79, '空间利用');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (80, '链栈');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (81, '栈的应用');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (82, '表达式求值');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (83, '后缀表达式');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (84, '中缀转后缀');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (85, '递归');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (86, '工作栈');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (87, '斐波那契');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (88, '队列');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (89, 'FIFO');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (90, '队头');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (91, '队尾');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (92, '循环队列');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (93, '假溢出');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (94, '队空');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (95, '队满');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (96, '元素个数');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (97, '计算公式');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (98, '链队');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (99, '入队');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (100, '出队');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (101, '队头指针');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (102, '队尾指针');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (103, '双端队列');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (104, '输入受限');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (105, '输出受限');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (106, '串');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (107, '子串');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (108, '空串');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (109, '堆分配');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (110, 'BF算法');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (111, '朴素模式匹配');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (112, 'KMP算法');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (113, 'next数组');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (114, '模式匹配');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (115, 'nextval数组');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (116, '优化');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (117, '根结点');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (118, '叶子');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (119, '度');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (120, '树与二叉树');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (121, '二叉树');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (122, '五种形态');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (123, '满二叉树');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (124, '完全二叉树');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (125, '二叉树性质');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (126, '度2结点');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (127, '遍历');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (128, '先序');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (129, '中序');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (130, '后序');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (131, '层序');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (132, '线索二叉树');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (133, '线索化');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (134, '转换');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (135, '森林');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (136, '兄弟');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (137, '哈夫曼树');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (138, 'WPL');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (139, '哈夫曼编码');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (140, '有向图');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (141, '无向图');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (142, '完全图');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (143, '度数');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (144, '边数');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (145, '入度');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (146, '出度');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (147, '连通');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (148, '连通分量');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (149, '强连通');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (150, '生成树');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (151, '邻接矩阵');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (152, '邻接表');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (153, 'DFS');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (154, 'BFS');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (155, '最小生成树');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (156, 'Prim');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (157, 'Kruskal');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (158, '最短路径');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (159, 'Dijkstra');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (160, 'Floyd');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (161, '拓扑排序');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (162, 'DAG');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (163, '关键路径');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (164, 'AOE网');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (165, '关键活动');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (166, '查找');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (167, 'ASL');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (168, '关键字');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (169, '顺序查找');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (170, '折半查找');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (171, '二分查找');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (172, '判定树');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (173, '分块查找');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (174, '索引顺序查找');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (175, '二叉排序树');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (176, 'BST');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (177, '平衡二叉树');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (178, 'AVL');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (179, '旋转');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (180, 'B树');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (181, '多路平衡');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (182, 'B+树');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (183, '范围查询');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (184, '散列查找');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (185, '哈希');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (186, '冲突');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (187, '装填因子');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (188, '排序');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (189, '稳定排序');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (190, '内部排序');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (191, '插入排序');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (192, '稳定');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (193, '希尔排序');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (194, '增量');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (195, '不稳定');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (196, '冒泡排序');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (197, '快速排序');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (198, '枢轴');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (199, '选择排序');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (200, '堆排序');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (201, '大根堆');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (202, '归并排序');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (203, '基数排序');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (204, '分配收集');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (205, '排序对比');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (206, '稳定性');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (207, '外部排序');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (208, '败者树');
INSERT INTO `biz_tag` (`tag_id`, `tag_name`) VALUES (209, '多路归并');
COMMIT;

-- ----------------------------
-- Table structure for biz_user_progress
-- ----------------------------
DROP TABLE IF EXISTS `biz_user_progress`;
CREATE TABLE `biz_user_progress` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `app_user_id` bigint DEFAULT NULL COMMENT '用户ID(游客模式下可为空)',
  `card_id` bigint NOT NULL COMMENT '卡片ID',
  `status` tinyint DEFAULT '0' COMMENT '掌握状态(0未学 1模糊 2掌握)',
  `next_review_time` datetime DEFAULT NULL COMMENT '建议下次复习时间(艾宾浩斯逻辑)',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_card` (`app_user_id`,`card_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户学习进度表';

-- ----------------------------
-- Records of biz_user_progress
-- ----------------------------
BEGIN;
INSERT INTO `biz_user_progress` (`id`, `app_user_id`, `card_id`, `status`, `next_review_time`, `update_time`) VALUES (1, 1, 1, 2, '2026-04-28 13:22:07', '2026-04-21 13:22:07');
INSERT INTO `biz_user_progress` (`id`, `app_user_id`, `card_id`, `status`, `next_review_time`, `update_time`) VALUES (2, 1, 2, 1, '2026-04-24 13:22:07', '2026-04-21 13:22:07');
INSERT INTO `biz_user_progress` (`id`, `app_user_id`, `card_id`, `status`, `next_review_time`, `update_time`) VALUES (3, 1, 3, 0, NULL, '2026-04-21 13:22:07');
INSERT INTO `biz_user_progress` (`id`, `app_user_id`, `card_id`, `status`, `next_review_time`, `update_time`) VALUES (4, 2, 1, 2, '2026-04-26 13:22:07', '2026-04-21 13:22:07');
INSERT INTO `biz_user_progress` (`id`, `app_user_id`, `card_id`, `status`, `next_review_time`, `update_time`) VALUES (5, 2, 4, 2, '2026-04-25 13:22:07', '2026-04-21 13:22:07');
INSERT INTO `biz_user_progress` (`id`, `app_user_id`, `card_id`, `status`, `next_review_time`, `update_time`) VALUES (6, 2, 5, 1, '2026-04-23 13:22:07', '2026-04-21 13:22:07');
INSERT INTO `biz_user_progress` (`id`, `app_user_id`, `card_id`, `status`, `next_review_time`, `update_time`) VALUES (7, 3, 1, 2, '2026-05-01 13:22:07', '2026-04-21 13:22:07');
INSERT INTO `biz_user_progress` (`id`, `app_user_id`, `card_id`, `status`, `next_review_time`, `update_time`) VALUES (8, 3, 16, 2, '2026-04-27 13:22:07', '2026-04-21 13:22:07');
INSERT INTO `biz_user_progress` (`id`, `app_user_id`, `card_id`, `status`, `next_review_time`, `update_time`) VALUES (9, 3, 17, 1, '2026-04-24 13:22:07', '2026-04-21 13:22:07');
INSERT INTO `biz_user_progress` (`id`, `app_user_id`, `card_id`, `status`, `next_review_time`, `update_time`) VALUES (10, NULL, 15, 1, '2026-04-25 00:15:29', '2026-04-22 00:15:29');
INSERT INTO `biz_user_progress` (`id`, `app_user_id`, `card_id`, `status`, `next_review_time`, `update_time`) VALUES (11, NULL, 1, 2, '2026-04-29 01:21:09', '2026-04-22 01:21:09');
COMMIT;

-- ----------------------------
-- Table structure for sys_app_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_app_user`;
CREATE TABLE `sys_app_user` (
  `app_user_id` bigint NOT NULL AUTO_INCREMENT COMMENT '小程序用户ID',
  `openid` varchar(100) NOT NULL COMMENT '微信OpenID',
  `unionid` varchar(100) DEFAULT NULL COMMENT '微信UnionID',
  `nickname` varchar(50) DEFAULT NULL COMMENT '昵称',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像',
  `last_login_time` datetime DEFAULT NULL COMMENT '最后登录时间',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  PRIMARY KEY (`app_user_id`),
  UNIQUE KEY `uk_openid` (`openid`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='小程序用户信息表';

-- ----------------------------
-- Records of sys_app_user
-- ----------------------------
BEGIN;
INSERT INTO `sys_app_user` (`app_user_id`, `openid`, `unionid`, `nickname`, `avatar`, `last_login_time`, `create_time`) VALUES (1, 'mock_openid_001', NULL, '考研小白', 'https://thirdwx.qlogo.cn/mmopen/vi_32/xxx', '2026-04-19 13:22:07', '2026-04-21 13:22:07');
INSERT INTO `sys_app_user` (`app_user_id`, `openid`, `unionid`, `nickname`, `avatar`, `last_login_time`, `create_time`) VALUES (2, 'mock_openid_002', NULL, '数据结构爱好者', 'https://thirdwx.qlogo.cn/mmopen/vi_32/yyy', '2026-04-20 13:22:07', '2026-04-21 13:22:07');
INSERT INTO `sys_app_user` (`app_user_id`, `openid`, `unionid`, `nickname`, `avatar`, `last_login_time`, `create_time`) VALUES (3, 'mock_openid_003', NULL, '408上岸学姐', 'https://thirdwx.qlogo.cn/mmopen/vi_32/zzz', '2026-04-21 13:22:07', '2026-04-21 13:22:07');
COMMIT;

-- ----------------------------
-- Table structure for sys_config
-- ----------------------------
DROP TABLE IF EXISTS `sys_config`;
CREATE TABLE `sys_config` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `config_key` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配置键',
  `config_value` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配置值',
  `config_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配置名称',
  `config_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'string' COMMENT '配置类型(string/number/date/boolean/json)',
  `description` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '配置描述',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_config_key` (`config_key`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统配置表';

-- ----------------------------
-- Records of sys_config
-- ----------------------------
BEGIN;
INSERT INTO `sys_config` (`id`, `config_key`, `config_value`, `config_name`, `config_type`, `description`, `create_time`, `update_time`) VALUES (1, 'sprint_exam_date', '2026-12-26', '考研倒计时日期', 'date', '考研冲刺阶段倒计时目标日期', '2026-04-22 07:11:21', '2026-04-22 07:14:30');
INSERT INTO `sys_config` (`id`, `config_key`, `config_value`, `config_name`, `config_type`, `description`, `create_time`, `update_time`) VALUES (2, 'sprint_exam_name', '2027年全国硕士研究生招生考试', '考试名称', 'string', '冲刺阶段考试名称', '2026-04-22 07:11:21', '2026-04-22 07:11:21');
INSERT INTO `sys_config` (`id`, `config_key`, `config_value`, `config_name`, `config_type`, `description`, `create_time`, `update_time`) VALUES (3, 'sprint_enabled', 'true', '冲刺模式开关', 'boolean', '是否启用冲刺模式倒计时显示', '2026-04-22 07:11:21', '2026-04-22 07:11:21');
COMMIT;

-- ----------------------------
-- Table structure for sys_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu` (
  `menu_id` bigint NOT NULL AUTO_INCREMENT COMMENT '菜单ID',
  `menu_name` varchar(50) NOT NULL COMMENT '菜单名称',
  `parent_id` bigint DEFAULT '0' COMMENT '父菜单ID',
  `order_num` int DEFAULT '0' COMMENT '显示顺序',
  `path` varchar(200) DEFAULT '' COMMENT '路由地址',
  `component` varchar(255) DEFAULT NULL COMMENT '组件路径',
  `perms` varchar(100) DEFAULT NULL COMMENT '权限标识',
  `menu_type` char(1) DEFAULT '' COMMENT '菜单类型（M目录 C菜单 F按钮）',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`menu_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='菜单权限表';

-- ----------------------------
-- Records of sys_menu
-- ----------------------------
BEGIN;
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `perms`, `menu_type`, `create_time`) VALUES (1, '系统管理', 0, 1, 'system', NULL, NULL, 'M', '2026-04-21 13:19:01');
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `perms`, `menu_type`, `create_time`) VALUES (2, '用户管理', 1, 1, 'user', 'system/user/index', NULL, 'C', '2026-04-21 13:19:01');
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `perms`, `menu_type`, `create_time`) VALUES (3, '内容管理', 0, 2, 'content', NULL, NULL, 'M', '2026-04-21 13:19:01');
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `perms`, `menu_type`, `create_time`) VALUES (4, '专业管理', 3, 1, 'major', 'content/major/index', NULL, 'C', '2026-04-21 13:19:01');
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `perms`, `menu_type`, `create_time`) VALUES (5, '科目管理', 3, 2, 'subject', 'content/subject/index', NULL, 'C', '2026-04-21 13:19:01');
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `perms`, `menu_type`, `create_time`) VALUES (6, '卡片管理', 3, 3, 'card', 'content/card/index', NULL, 'C', '2026-04-21 13:19:01');
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `perms`, `menu_type`, `create_time`) VALUES (7, '标签管理', 3, 4, 'tag', 'content/tag/index', NULL, 'C', '2026-04-21 13:19:01');
COMMIT;

-- ----------------------------
-- Table structure for sys_oper_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_oper_log`;
CREATE TABLE `sys_oper_log` (
  `oper_id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `title` varchar(50) DEFAULT '' COMMENT '模块标题',
  `business_type` int DEFAULT '0' COMMENT '业务类型（0其它 1新增 2修改 3删除）',
  `method` varchar(100) DEFAULT '' COMMENT '方法名称',
  `request_method` varchar(10) DEFAULT '' COMMENT '请求方式',
  `operator_type` int DEFAULT '0' COMMENT '操作类别（0其它 1后台用户 2手机端用户）',
  `oper_name` varchar(50) DEFAULT '' COMMENT '操作人员',
  `oper_url` varchar(255) DEFAULT '' COMMENT '请求URL',
  `oper_param` text COMMENT '请求参数',
  `json_result` text COMMENT '返回结果',
  `status` int DEFAULT '0' COMMENT '操作状态（0正常 1异常）',
  `error_msg` varchar(2000) DEFAULT '' COMMENT '错误消息',
  `oper_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (`oper_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='操作日志表';

-- ----------------------------
-- Records of sys_oper_log
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for sys_request_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_request_log`;
CREATE TABLE `sys_request_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `request_method` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '请求方法(GET/POST/PUT/DELETE)',
  `request_url` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '请求URL',
  `class_name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '类名',
  `method_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '方法名',
  `request_params` text COLLATE utf8mb4_unicode_ci COMMENT '请求参数(JSON)',
  `response_result` text COLLATE utf8mb4_unicode_ci COMMENT '响应结果(JSON)',
  `execution_time` bigint NOT NULL DEFAULT '0' COMMENT '执行耗时(毫秒)',
  `status` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '1' COMMENT '执行状态(1成功 0失败)',
  `error_msg` text COLLATE utf8mb4_unicode_ci COMMENT '错误信息',
  `ip_address` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '请求IP地址',
  `user_id` bigint DEFAULT NULL COMMENT '操作用户ID',
  `user_name` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '操作用户名',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_request_url` (`request_url`),
  KEY `idx_create_time` (`create_time`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=434 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统请求日志表';

-- ----------------------------
-- Records of sys_request_log
-- ----------------------------
COMMIT;

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role` (
  `role_id` bigint NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `role_name` varchar(30) NOT NULL COMMENT '角色名称',
  `role_key` varchar(100) NOT NULL COMMENT '角色权限字符串',
  `status` char(1) DEFAULT '0' COMMENT '角色状态（0正常 1停用）',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`role_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='角色信息表';

-- ----------------------------
-- Records of sys_role
-- ----------------------------
BEGIN;
INSERT INTO `sys_role` (`role_id`, `role_name`, `role_key`, `status`, `create_time`) VALUES (1, '超级管理员', 'admin', '0', '2026-04-21 13:19:01');
INSERT INTO `sys_role` (`role_id`, `role_name`, `role_key`, `status`, `create_time`) VALUES (2, '普通管理员', 'manager', '0', '2026-04-21 13:19:01');
INSERT INTO `sys_role` (`role_id`, `role_name`, `role_key`, `status`, `create_time`) VALUES (3, '测试人员角色', '1111', '0', '2026-04-22 13:54:05');
COMMIT;

-- ----------------------------
-- Table structure for sys_role_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_menu`;
CREATE TABLE `sys_role_menu` (
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `menu_id` bigint NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`role_id`,`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='角色和菜单关联表';

-- ----------------------------
-- Records of sys_role_menu
-- ----------------------------
BEGIN;
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 1);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 2);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 3);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 4);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 5);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 6);
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES (1, 7);
COMMIT;

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user` (
  `user_id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` varchar(50) NOT NULL COMMENT '登录账号',
  `password` varchar(100) NOT NULL COMMENT '密码',
  `nickname` varchar(50) DEFAULT NULL COMMENT '用户昵称',
  `avatar` varchar(255) DEFAULT '' COMMENT '头像地址',
  `status` char(1) DEFAULT '0' COMMENT '帐号状态（0正常 1停用）',
  `del_flag` char(1) DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='后台用户信息表';

-- ----------------------------
-- Records of sys_user
-- ----------------------------
BEGIN;
INSERT INTO `sys_user` (`user_id`, `username`, `password`, `nickname`, `avatar`, `status`, `del_flag`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES (1, 'admin', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '管理员', '', '0', '0', '', '2026-04-21 13:19:01', '', NULL);
INSERT INTO `sys_user` (`user_id`, `username`, `password`, `nickname`, `avatar`, `status`, `del_flag`, `create_by`, `create_time`, `update_by`, `update_time`) VALUES (2, 'baoyang', '$2a$10$j0baGTaTzamQ3NzAAQ7nj.jjploWRKxKY260NTvPdiyKjt9m5mlcO', 'baoyang', '', '0', '0', '', NULL, '', '2026-04-22 01:01:42');
COMMIT;

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role` (
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`user_id`,`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户和角色关联表';

-- ----------------------------
-- Records of sys_user_role
-- ----------------------------
BEGIN;
INSERT INTO `sys_user_role` (`user_id`, `role_id`) VALUES (1, 1);
COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
