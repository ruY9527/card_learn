-- 模拟数据插入脚本

USE `card_learn`;

-- ----------------------------
-- 1. 标签表模拟数据（408计算机考研）
-- subject_id: 1=数据结构, 2=计算机组成原理, 3=操作系统, 4=计算机网络
-- ----------------------------
-- 数据结构科目标签 (subject_id=1)
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('时间复杂度', 1);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('空间复杂度', 1);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('排序算法', 1);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('查找算法', 1);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('树', 1);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('图', 1);
-- 计算机组成原理科目标签 (subject_id=2)
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('Cache', 2);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('中断', 2);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('DMA', 2);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('浮点数', 2);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('流水线', 2);
-- 操作系统科目标签 (subject_id=3)
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('PV操作', 3);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('进程调度', 3);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('内存管理', 3);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('死锁', 3);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('文件系统', 3);
-- 计算机网络科目标签 (subject_id=4)
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('TCP', 4);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('UDP', 4);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('IP协议', 4);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('HTTP', 4);
INSERT INTO `biz_tag` (`tag_name`, `subject_id`) VALUES ('滑动窗口', 4);

-- ----------------------------
-- 2. 知识点卡片表模拟数据 - 数据结构(subject_id=1)
-- ----------------------------
INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES 
(1, '什么是时间复杂度？如何计算算法的时间复杂度？', '时间复杂度是衡量算法运行时间随输入规模增长的变化趋势的指标。\n\n计算方法：\n1. 找出算法中的基本操作（最深层循环内的操作）\n2. 计算基本操作执行的次数与输入规模n的关系\n3. 取最高阶项，忽略低阶项和常数系数\n\n常见时间复杂度：O(1) < O(logn) < O(n) < O(nlogn) < O(n²) < O(n³) < O(2^n)', 2);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES 
(1, '快速排序的基本思想和时间复杂度是什么？', '基本思想：分治法\n1. 选取一个基准元素(pivot)\n2. 将数组分为两部分：小于pivot的放左边，大于pivot的放右边\n3. 递归地对左右两部分进行排序\n\n时间复杂度：\n- 平均情况：O(nlogn)\n- 最坏情况：O(n²)（每次选取的pivot都是最大或最小元素）\n- 最好情况：O(nlogn)\n\n空间复杂度：O(logn)（递归调用栈）', 3);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES 
(1, '什么是哈希表？如何解决哈希冲突？', '哈希表：根据关键码值(Key value)直接进行访问的数据结构，通过哈希函数将键映射到数组索引。\n\n解决哈希冲突的方法：\n1. **开放定址法**：线性探测、二次探测、双重哈希\n2. **链地址法**：将冲突的元素用链表连接\n3. **再哈希法**：使用多个哈希函数\n4. **建立公共溢出区**：将冲突元素存放到溢出区\n\n链地址法是最常用的方法，Java的HashMap就采用此方法。', 3);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES 
(1, '二叉树的遍历方式有哪些？各自的实现方式？', '四种主要遍历方式：\n\n1. **前序遍历**（根-左-右）：递归、栈实现\n2. **中序遍历**（左-根-右）：递归、栈实现\n3. **后序遍历**（左-右-根）：递归、栈实现\n4. **层序遍历**（按层次）：队列实现\n\n非递归实现关键：\n- 前序/中序：用栈，入栈顺序不同\n- 后序：需要记录上一个访问的节点\n- 层序：用队列，先进先出', 2);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES 
(1, '什么是红黑树？它的性质有哪些？', '红黑树是一种自平衡的二叉搜索树，保证在最坏情况下基本操作的时间复杂度为O(logn)。\n\n五大性质：\n1. 每个节点是红色或黑色\n2. 根节点是黑色\n3. 所有叶子节点（NIL）是黑色\n4. 红色节点的两个子节点都是黑色（不能有连续的红色节点）\n5. 从任一节点到其每个叶子的所有路径包含相同数量的黑色节点\n\n应用：Java的TreeMap、TreeSet、HashMap在链表长度>8时转为红黑树', 4);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES 
(1, '图的最短路径算法有哪些？Dijkstra算法的原理？', '最短路径算法：\n1. **Dijkstra**：单源最短路径，不含负权边\n2. **Bellman-Ford**：单源最短路径，含负权边\n3. **Floyd**：多源最短路径\n4. **SPFA**：Bellman-Ford的优化\n\nDijkstra原理：\n1. 初始化：起点距离为0，其他为无穷大\n2. 选择距离最小的未访问节点\n3. 更新其邻居节点的距离\n4. 标记该节点为已访问\n5. 重复2-4直到所有节点访问完\n\n时间复杂度：O(V²)或O(ElogV)（用优先队列优化）', 4);

-- ----------------------------
-- 3. 知识点卡片表模拟数据 - 计算机组成原理(subject_id=2)
-- ----------------------------
INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES 
(2, '什么是Cache？Cache的工作原理是什么？', 'Cache（高速缓存）是位于CPU和主存之间的小容量高速存储器。\n\n工作原理：\n1. **局部性原理**：时间局部性（最近访问的数据可能再次访问）、空间局部性（访问位置附近的数据可能被访问）\n2. CPU访问数据时，先查Cache，命中则直接获取；未命中则从主存获取并调入Cache\n\n映射方式：\n- 直接映射：每个主存块只能映射到一个特定Cache行\n- 全相联映射：主存块可映射到任意Cache行\n- 组相联映射：主存块可映射到特定组中的任意行\n\n命中率计算：命中率 = 命中次数 / 总访问次数', 3);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES 
(2, '什么是中断？中断处理的过程是怎样的？', '中断：CPU暂停当前程序，转去处理突发事件，处理完后返回继续执行。\n\n中断处理过程：\n1. **中断请求**：外设向CPU发出中断信号\n2. **中断响应**：CPU在指令周期末检查中断信号\n3. **保护现场**：保存PC、PSW等寄存器\n4. **中断识别**：确定中断源（向量中断或查询中断）\n5. **执行中断服务程序**：处理中断事件\n6. **恢复现场**：恢复保存的寄存器\n7. **中断返回**：返回原程序继续执行\n\n中断类型：硬中断（外设）、软中断（系统调用）、异常（程序错误）', 3);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES 
(2, 'DMA的工作原理是什么？与中断方式的区别？', 'DMA（直接存储器访问）：允许外设直接与主存交换数据，无需CPU干预。\n\n工作原理：\n1. CPU初始化DMA控制器（源地址、目标地址、数据量）\n2. DMA控制器接管总线，直接进行数据传输\n3. 传输完成后，DMA向CPU发送中断信号\n4. CPU处理后续工作\n\n与中断方式的区别：\n- 中断：每次传输一个数据单位就需要CPU干预\n- DMA：批量传输，CPU只需在开始和结束时干预\n\nDMA适用场景：磁盘I/O、网络传输等大量数据传输', 4);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES 
(2, '浮点数的表示方法是什么？IEEE 754标准？', '浮点数表示：N = M × 2^E\n- M：尾数（mantissa），表示精度\n- E：阶码（exponent），表示范围\n\nIEEE 754标准格式：\n- **符号位S**：1位，0正1负\n- **阶码E**：采用移码表示，偏置值=127（32位）或1023（64位）\n- **尾数M**：采用原码表示，隐含最高位1\n\n32位浮点数(float)：\n- S(1位) + E(8位) + M(23位)\n- 范围约：±3.4×10^38\n\n64位浮点数(double)：\n- S(1位) + E(11位) + M(52位)\n- 范围约：±1.8×10^308', 4);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES 
(2, '流水线技术的基本原理？流水线的性能指标？', '流水线技术：将指令执行过程分解为多个阶段，各阶段并行工作。\n\n典型5级流水线：\n1. IF（取指）\n2. ID（译码）\n3. EX（执行）\n4. MEM（访存）\n5. WB（写回）\n\n性能指标：\n- **吞吐率**：单位时间完成的指令数 TP = n / Tk\n- **加速比**：S = T顺序 / T流水\n- **效率**：E = 有效时空区 / 总时空区\n\n流水线冲突：\n1. 结构冲突：资源冲突\n2. 数据冲突：数据依赖\n3. 控制冲突：分支指令\n\n解决方法：暂停、转发、预测', 4);

-- ----------------------------
-- 4. 知识点卡片表模拟数据 - 操作系统(subject_id=3)
-- ----------------------------
INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES 
(3, '什么是PV操作？如何使用PV操作实现互斥？', 'PV操作是信号量的两种基本操作，用于进程同步与互斥。\n\n**P操作（wait）**：\n- S.value--\n- 若S.value < 0，进程阻塞，放入等待队列\n\n**V操作（signal）**：\n- S.value++\n- 若S.value <= 0，唤醒等待队列中的一个进程\n\n实现互斥：\n```\nsemaphore mutex = 1;\nP1: P(mutex); 临界区; V(mutex);\nP2: P(mutex); 临界区; V(mutex);\n```\n\n注意：PV操作必须成对出现，P在临界区前，V在临界区后。', 3);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES 
(3, '进程调度算法有哪些？各自的优缺点？', '常见进程调度算法：\n\n1. **FCFS（先来先服务）**：简单但可能导致"护航效应"\n\n2. **SJF/SPF（短作业优先）**：平均等待时间最短，但需要预知作业长度\n\n3. **SRTN（最短剩余时间优先）**：SJF的抢占版本\n\n4. **RR（时间片轮转）**：公平，适合分时系统，时间片大小影响性能\n\n5. **优先级调度**：可抢占或非抢占，可能导致低优先级进程"饥饿"\n\n6. **多级反馈队列**：综合多种算法，动态调整优先级和时间片\n\n评价标准：CPU利用率、吞吐量、周转时间、等待时间、响应时间', 3);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES 
(3, '虚拟内存的基本原理？页面置换算法有哪些？', '虚拟内存：将部分进程数据装入内存，其余放在磁盘，需要时调入。\n\n基本原理：\n1. **分页**：将进程和内存划分为固定大小的页和页框\n2. **页表**：记录页与页框的映射关系\n3. **TLB**：快表，加速地址转换\n4. **缺页中断**：访问的页不在内存时触发\n\n页面置换算法：\n1. **OPT（最优）**：置换未来最长时间不使用的页（理论算法）\n2. **FIFO**：置换最早进入的页，可能出现Belady异常\n3. **LRU**：置换最近最少使用的页\n4. **Clock**：LRU的近似实现，用访问位\n5. **LFU**：置换访问次数最少的页', 4);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES 
(3, '什么是死锁？死锁的四个必要条件？如何预防？', '死锁：多个进程因争夺资源而互相等待，导致都无法继续执行。\n\n**四个必要条件**（必须同时满足）：\n1. **互斥条件**：资源不能共享\n2. **请求与保持条件**：进程持有资源同时请求新资源\n3. **不剥夺条件**：已获得的资源不能被强制抢占\n4. **循环等待条件**：存在进程资源的循环等待链\n\n**预防策略**：\n1. 破坏互斥：不易实现\n2. 破坏请求与保持：一次性申请所有资源\n3. 破坏不剥夺：资源可被抢占\n4. 破坏循环等待：资源有序分配\n\n**避免**：银行家算法\n**检测与恢复**：定期检测，剥夺资源或撤销进程', 4);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES 
(3, '文件系统的实现方式？inode是什么？', '文件系统实现方式：\n\n1. **连续分配**：文件占用连续磁盘块\n   - 优点：访问快\n   - 缺点：外部碎片、文件大小固定\n\n2. **链接分配**：每个块包含指向下一块的指针\n   - 优点：无外部碎片\n   - 缺点：随机访问慢、指针占用空间\n\n3. **索引分配**：使用索引块记录所有数据块位置\n   - 优点：支持随机访问\n   - 缺点：索引块开销\n\n**inode（索引节点）**：\n- 存储文件的元数据（权限、时间、大小等）\n- 包含指向数据块的指针\n- 文件名存储在目录项中，inode存储文件内容信息\n\nLinux中：df -i查看inode使用情况', 3);

-- ----------------------------
-- 5. 知识点卡片表模拟数据 - 计算机网络(subject_id=4)
-- ----------------------------
INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES 
(4, 'TCP三次握手的过程？为什么需要三次握手？', 'TCP三次握手过程：\n\n1. **第一次**：客户端发送SYN=1，seq=x，进入SYN_SENT状态\n2. **第二次**：服务器回复SYN=1，ACK=1，seq=y，ack=x+1，进入SYN_RCVD状态\n3. **第三次**：客户端发送ACK=1，seq=x+1，ack=y+1，双方进入ESTABLISHED状态\n\n**为什么需要三次握手**：\n1. 防止已失效的连接请求突然到达服务器，导致错误建立连接\n2. 同步双方的初始序列号\n3. 确认双方的接收和发送能力\n\n如果是两次握手，服务器无法确认客户端是否收到自己的SYN。', 3);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES 
(4, 'TCP四次挥手的过程？为什么需要四次？', 'TCP四次挥手过程：\n\n1. **第一次**：客户端发送FIN=1，seq=u，进入FIN_WAIT_1状态\n2. **第二次**：服务器回复ACK=1，ack=u+1，进入CLOSE_WAIT状态；客户端进入FIN_WAIT_2\n3. **第三次**：服务器发送FIN=1，seq=w，进入LAST_ACK状态\n4. **第四次**：客户端回复ACK=1，ack=w+1，进入TIME_WAIT状态（等待2MSL后关闭）；服务器关闭\n\n**为什么需要四次挥手**：\n- TCP是全双工通信，每个方向的关闭需要单独进行\n- 服务器收到FIN后可能还有数据要发送，不能立即关闭\n\n**TIME_WAIT作用**：\n1. 确保ACK到达服务器\n2. 等待旧连接的数据在网络中消失', 3);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES 
(4, 'TCP与UDP的区别？各自的适用场景？', 'TCP vs UDP区别：\n\n| 特性 | TCP | UDP |\n|------|-----|-----|\n| 连接 | 面向连接 | 无连接 |\n| 可靠性 | 可靠传输 | 尽力交付 |\n| 流量控制 | 有（滑动窗口） | 无 |\n| 拥塞控制 | 有 | 无 |\n| 传输方式 | 字节流 | 报文 |\n| 首部开销 | 20字节 | 8字节 |\n| 速度 | 较慢 | 较快 |\n\n**TCP适用场景**：需要可靠传输的应用\n- HTTP、FTP、SMTP、SSH\n\n**UDP适用场景**：实时性强、容忍少量丢包的应用\n- DNS、DHCP、TFTP\n- 视频会议、直播、游戏\n- SNMP', 2);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES 
(4, 'OSI七层模型和TCP/IP四层模型的对应关系？', 'OSI七层模型与TCP/IP四层模型：\n\n| OSI七层 | TCP/IP四层 | 功能 | 协议示例 |\n|---------|------------|------|----------|\n| 应用层 | 应用层 | 用户交互 | HTTP、FTP、DNS |\n| 表示层 | | 数据格式转换 | SSL/TLS |\n| 会话层 | | 会话管理 | RPC |\n| 传输层 | 传输层 | 端到端通信 | TCP、UDP |\n| 网络层 | 网络层 | 路由选择 | IP、ICMP |\n| 数据链路层 | 网络接口层 | 帧传输 | Ethernet、ARP |\n| 物理层 | | 比特传输 | RJ45、光纤 |\n\n每层只与相邻层交互，数据向下封装，向上解封装。', 2);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES 
(4, 'HTTP协议的状态码有哪些？常见状态码的含义？', 'HTTP状态码分类：\n\n- **1xx**：信息性状态码\n- **2xx**：成功状态码\n- **3xx**：重定向状态码\n- **4xx**：客户端错误\n- **5xx**：服务器错误\n\n**常见状态码**：\n\n| 状态码 | 含义 |\n|--------|------|\n| 200 | OK，请求成功 |\n| 301 | Moved Permanently，永久重定向 |\n| 302 | Found，临时重定向 |\n| 304 | Not Modified，缓存有效 |\n| 400 | Bad Request，请求语法错误 |\n| 401 | Unauthorized，未授权 |\n| 403 | Forbidden，禁止访问 |\n| 404 | Not Found，资源不存在 |\n| 500 | Internal Server Error，服务器内部错误 |\n| 503 | Service Unavailable，服务不可用 |', 2);

INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`) VALUES 
(4, '什么是滑动窗口？流量控制和拥塞控制的区别？', '滑动窗口：TCP流量控制的机制，控制发送方的发送速率。\n\n**流量控制**：\n- 目的：防止发送方发送过快导致接收方缓冲区溢出\n- 方法：接收方在ACK中通告窗口大小rwnd\n- 发送窗口 = min(rwnd, cwnd)\n\n**拥塞控制**：\n- 目的：防止过多数据注入网络导致网络拥塞\n- 方法：\n  1. **慢开始**：cwnd从1开始指数增长\n  2. **拥塞避免**：cwnd线性增长\n  3. **快重传**：收到3个重复ACK立即重传\n  4. **快恢复**：cwnd减半，直接进入拥塞避免\n\n区别：流量控制是端到端的，拥塞控制是全局的。', 4);

-- ----------------------------
-- 6. 卡片标签关联表模拟数据
-- 标签ID对应关系（按科目分类后）：
-- 数据结构(1-6): 1=时间复杂度, 2=空间复杂度, 3=排序算法, 4=查找算法, 5=树, 6=图
-- 计组(7-11): 7=Cache, 8=中断, 9=DMA, 10=浮点数, 11=流水线
-- 操作系统(12-16): 12=PV操作, 13=进程调度, 14=内存管理, 15=死锁, 16=文件系统
-- 计网(17-21): 17=TCP, 18=UDP, 19=IP协议, 20=HTTP, 21=滑动窗口
-- ----------------------------
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (1, 1);  -- 时间复杂度-时间复杂度
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (1, 2);  -- 时间复杂度-空间复杂度
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (2, 3);  -- 快速排序-排序算法
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (2, 1);  -- 快速排序-时间复杂度
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (3, 4);  -- 哈希表-查找算法
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (4, 5);  -- 二叉树遍历-树
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (5, 5);  -- 红黑树-树
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (6, 6);  -- 最短路径-图
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (7, 7);  -- Cache-Cache
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (8, 8);  -- 中断-中断
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (9, 9);  -- DMA-DMA
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (10, 10); -- 浮点数-浮点数
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (11, 11); -- 流水线-流水线
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (12, 12); -- PV操作-PV操作
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (13, 13); -- 进程调度-进程调度
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (14, 14); -- 虚拟内存-内存管理
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (15, 15); -- 死锁-死锁
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (16, 17); -- TCP三次握手-TCP
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (17, 17); -- TCP四次挥手-TCP
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (18, 17); -- TCP vs UDP-TCP
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (18, 18); -- TCP vs UDP-UDP
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (19, 19); -- OSI模型-IP协议
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (20, 20); -- HTTP状态码-HTTP
INSERT INTO `biz_card_tag` (`card_id`, `tag_id`) VALUES (21, 21); -- 滑动窗口-滑动窗口

-- ----------------------------
-- 7. 小程序用户表模拟数据
-- ----------------------------
INSERT INTO `sys_app_user` (`openid`, `nickname`, `avatar`, `last_login_time`) VALUES 
('mock_openid_001', '考研小白', 'https://thirdwx.qlogo.cn/mmopen/vi_32/xxx', NOW() - INTERVAL 2 DAY);

INSERT INTO `sys_app_user` (`openid`, `nickname`, `avatar`, `last_login_time`) VALUES 
('mock_openid_002', '数据结构爱好者', 'https://thirdwx.qlogo.cn/mmopen/vi_32/yyy', NOW() - INTERVAL 1 DAY);

INSERT INTO `sys_app_user` (`openid`, `nickname`, `avatar`, `last_login_time`) VALUES 
('mock_openid_003', '408上岸学姐', 'https://thirdwx.qlogo.cn/mmopen/vi_32/zzz', NOW());

-- ----------------------------
-- 8. 用户学习进度表模拟数据
-- ----------------------------
INSERT INTO `biz_user_progress` (`user_id`, `card_id`, `status`, `next_review_time`) VALUES 
(1, 1, 2, NOW() + INTERVAL 7 DAY);   -- 已掌握，7天后复习
INSERT INTO `biz_user_progress` (`user_id`, `card_id`, `status`, `next_review_time`) VALUES 
(1, 2, 1, NOW() + INTERVAL 3 DAY);   -- 模糊，3天后复习
INSERT INTO `biz_user_progress` (`user_id`, `card_id`, `status`, `next_review_time`) VALUES 
(1, 3, 0, NULL);                      -- 未学
INSERT INTO `biz_user_progress` (`user_id`, `card_id`, `status`, `next_review_time`) VALUES 
(2, 1, 2, NOW() + INTERVAL 5 DAY);
INSERT INTO `biz_user_progress` (`user_id`, `card_id`, `status`, `next_review_time`) VALUES 
(2, 4, 2, NOW() + INTERVAL 4 DAY);
INSERT INTO `biz_user_progress` (`user_id`, `card_id`, `status`, `next_review_time`) VALUES 
(2, 5, 1, NOW() + INTERVAL 2 DAY);
INSERT INTO `biz_user_progress` (`user_id`, `card_id`, `status`, `next_review_time`) VALUES 
(3, 1, 2, NOW() + INTERVAL 10 DAY);
INSERT INTO `biz_user_progress` (`user_id`, `card_id`, `status`, `next_review_time`) VALUES 
(3, 16, 2, NOW() + INTERVAL 6 DAY);   -- TCP三次握手已掌握
INSERT INTO `biz_user_progress` (`user_id`, `card_id`, `status`, `next_review_time`) VALUES 
(3, 17, 1, NOW() + INTERVAL 3 DAY);   -- TCP四次挥手模糊