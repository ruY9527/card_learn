#!/usr/bin/env python3
"""
数据库初始化脚本
功能：
1. 修改 biz_tag 表结构，添加 subject_id 字段
2. 清空并重新插入标签数据（按科目分类）
3. 插入 308 护理综合专业和科目数据
4. 插入 308 护理综合标签数据
5. 插入 308 护理综合卡片数据
6. 插入卡片标签关联数据
"""

import pymysql
import sys
import os

# 数据库配置（从 application.yml 读取）
DB_CONFIG = {
    'host': 'localhost',
    'port': 3308,  # 注意端口是3308
    'user': 'root',
    'password': '123456',
    'database': 'card_learn',
    'charset': 'utf8mb4'
}

def get_connection():
    """获取数据库连接"""
    return pymysql.connect(**DB_CONFIG)

def execute_sql_file(conn, filepath):
    """执行SQL文件"""
    with open(filepath, 'r', encoding='utf-8') as f:
        sql_content = f.read()
    
    # 分割SQL语句（按分号分割，但要处理存储过程等特殊情况）
    sql_statements = []
    current_stmt = []
    in_delimiter = False
    
    for line in sql_content.split('\n'):
        line = line.strip()
        if not line or line.startswith('--'):
            continue
        if line.upper().startswith('DELIMITER'):
            in_delimiter = True
            continue
        
        current_stmt.append(line)
        
        if ';' in line and not in_delimiter:
            stmt = ' '.join(current_stmt)
            if stmt and not stmt.startswith('--'):
                sql_statements.append(stmt.rstrip(';'))
            current_stmt = []
    
    # 执行每条语句
    cursor = conn.cursor()
    for stmt in sql_statements:
        if stmt.strip():
            try:
                cursor.execute(stmt)
            except pymysql.err.MySQLdbError as e:
                print(f"执行SQL出错: {e}")
                print(f"SQL: {stmt[:200]}...")
                # 某些错误可以忽略（如字段已存在）
                if 'Duplicate column name' in str(e) or 'already exists' in str(e):
                    print("忽略：字段或表已存在")
                    continue
                raise
    conn.commit()
    cursor.close()

def alter_tag_table(conn):
    """修改 biz_tag 表结构"""
    cursor = conn.cursor()
    
    # 检查 subject_id 字段是否已存在
    cursor.execute("SHOW COLUMNS FROM biz_tag LIKE 'subject_id'")
    result = cursor.fetchone()
    
    if result:
        print("✓ subject_id 字段已存在，跳过添加")
    else:
        print("→ 添加 subject_id 字段...")
        cursor.execute("ALTER TABLE biz_tag ADD COLUMN subject_id bigint(20) DEFAULT NULL COMMENT '所属科目ID(null表示通用标签)' AFTER tag_name")
        cursor.execute("ALTER TABLE biz_tag ADD INDEX idx_subject_id (subject_id)")
        conn.commit()
        print("✓ subject_id 字段添加成功")
    
    cursor.close()

def clear_and_reset_tags(conn):
    """清空并重置标签数据"""
    cursor = conn.cursor()
    
    # 清空标签关联表
    print("→ 清空 biz_card_tag 表...")
    cursor.execute("DELETE FROM biz_card_tag")
    
    # 清空标签表
    print("→ 清空 biz_tag 表...")
    cursor.execute("DELETE FROM biz_tag")
    
    conn.commit()
    cursor.close()
    print("✓ 标签数据已清空")

def insert_408_tags(conn):
    """插入 408 计算机考研标签数据"""
    cursor = conn.cursor()
    
    # 408 科目ID：数据结构=1, 计组=2, 操作系统=3, 计网=4
    tags_408 = [
        # 数据结构科目标签 (subject_id=1)
        ('时间复杂度', 1), ('空间复杂度', 1), ('排序算法', 1), ('查找算法', 1), ('树', 1), ('图', 1),
        # 计算机组成原理科目标签 (subject_id=2)
        ('Cache', 2), ('中断', 2), ('DMA', 2), ('浮点数', 2), ('流水线', 2),
        # 操作系统科目标签 (subject_id=3)
        ('PV操作', 3), ('进程调度', 3), ('内存管理', 3), ('死锁', 3), ('文件系统', 3),
        # 计算机网络科目标签 (subject_id=4)
        ('TCP', 4), ('UDP', 4), ('IP协议', 4), ('HTTP', 4), ('滑动窗口', 4),
    ]
    
    print("→ 插入 408 计算机考研标签...")
    for tag_name, subject_id in tags_408:
        cursor.execute("INSERT INTO biz_tag (tag_name, subject_id) VALUES (%s, %s)", (tag_name, subject_id))
    
    conn.commit()
    cursor.close()
    print(f"✓ 已插入 {len(tags_408)} 个 408 标签")

def insert_308_nursing_data(conn):
    """插入 308 护理综合数据"""
    cursor = conn.cursor()
    
    # 1. 检查并插入专业
    cursor.execute("SELECT major_id FROM biz_major WHERE major_name = '308护理综合考研'")
    result = cursor.fetchone()
    
    if result:
        nursing_major_id = result[0]
        print(f"✓ 308护理综合专业已存在，major_id={nursing_major_id}")
    else:
        print("→ 插入 308护理综合专业...")
        cursor.execute("""
            INSERT INTO biz_major (major_name, description, status) 
            VALUES ('308护理综合考研', '护理学专业综合考试，包含护理学基础、内科护理学、外科护理学三大科目', '0')
        """)
        conn.commit()
        nursing_major_id = cursor.lastrowid
        print(f"✓ 专业已插入，major_id={nursing_major_id}")
    
    # 2. 检查并插入科目
    subjects_308 = [
        ('护理学导论', 1),
        ('基础护理学', 2),
        ('内科护理学', 3),
        ('外科护理学', 4),
    ]
    
    nursing_subject_ids = {}
    for subject_name, order_num in subjects_308:
        cursor.execute("SELECT subject_id FROM biz_subject WHERE major_id = %s AND subject_name = %s",
                       (nursing_major_id, subject_name))
        result = cursor.fetchone()
        
        if result:
            nursing_subject_ids[subject_name] = result[0]
            print(f"✓ 科目 {subject_name} 已存在，subject_id={result[0]}")
        else:
            cursor.execute("""
                INSERT INTO biz_subject (major_id, subject_name, order_num) 
                VALUES (%s, %s, %s)
            """, (nursing_major_id, subject_name, order_num))
            nursing_subject_ids[subject_name] = cursor.lastrowid
            print(f"→ 科目 {subject_name} 已插入，subject_id={cursor.lastrowid}")
    
    conn.commit()
    
    # 获取408标签的最大ID，用于计算308标签ID
    cursor.execute("SELECT MAX(tag_id) FROM biz_tag")
    max_tag_id = cursor.fetchone()[0] or 0
    
    # 3. 插入 308 护理综合标签
    # 护理学导论科目标签
    intro_tags = ['护理程序', '护理评估']
    # 基础护理学科目标签
    base_tags = [
        '生命体征', '无菌技术', '给药护理', '静脉输液', '压疮预防',
        '心肺复苏', '疼痛护理', '卧位与翻身'
    ]
    # 内科护理学科目标签
    internal_tags = [
        '健康教育', '糖尿病护理', '高血压护理', '冠心病护理', '脑卒中护理',
        '呼吸系统', '消化系统', '泌尿系统', '血液系统', '循环系统', '神经系统'
    ]
    # 外科护理学科目标签
    surgical_tags = ['术前准备', '术后护理', '伤口护理', '引流管护理', '运动系统']
    # 通用标签
    common_tags = ['急救护理', '心理护理', '营养支持', '肿瘤护理']
    
    print("→ 插入 308 护理综合标签...")
    nursing_tag_ids = {}

    # 护理学导论标签
    for tag_name in intro_tags:
        cursor.execute("INSERT INTO biz_tag (tag_name, subject_id) VALUES (%s, %s)",
                       (tag_name, nursing_subject_ids['护理学导论']))
        nursing_tag_ids[tag_name] = cursor.lastrowid

    # 基础护理学标签
    for tag_name in base_tags:
        cursor.execute("INSERT INTO biz_tag (tag_name, subject_id) VALUES (%s, %s)",
                       (tag_name, nursing_subject_ids['基础护理学']))
        nursing_tag_ids[tag_name] = cursor.lastrowid

    # 内科护理学标签
    for tag_name in internal_tags:
        cursor.execute("INSERT INTO biz_tag (tag_name, subject_id) VALUES (%s, %s)",
                       (tag_name, nursing_subject_ids['内科护理学']))
        nursing_tag_ids[tag_name] = cursor.lastrowid

    # 外科护理学标签
    for tag_name in surgical_tags:
        cursor.execute("INSERT INTO biz_tag (tag_name, subject_id) VALUES (%s, %s)",
                       (tag_name, nursing_subject_ids['外科护理学']))
        nursing_tag_ids[tag_name] = cursor.lastrowid

    # 通用标签 (subject_id = NULL)
    for tag_name in common_tags:
        cursor.execute("INSERT INTO biz_tag (tag_name, subject_id) VALUES (%s, NULL)",
                       (tag_name,))
        nursing_tag_ids[tag_name] = cursor.lastrowid

    conn.commit()
    print(f"✓ 已插入 {len(intro_tags) + len(base_tags) + len(internal_tags) + len(surgical_tags) + len(common_tags)} 个 308 标签")
    
    # 4. 插入 308 护理综合卡片数据
    print("→ 插入 308 护理综合卡片...")

    # 护理学导论卡片
    intro_cards = [
        ('护理程序的基本步骤有哪些？', '护理程序的五个基本步骤...', 2, ['护理程序', '护理评估']),
        ('护理学的概念与发展史', '护理学发展史...', 2, None),
        ('护士的角色功能', '护士角色...', 2, ['护理程序']),
        ('护理评估的方法与内容', '护理评估方法...', 2, ['护理评估']),
        ('马斯洛需要层次理论', '马斯洛需要层次...', 2, None),
    ]

    # 基础护理学卡片
    base_cards = [
        ('生命体征的正常范围', '生命体征四大指标及正常范围...', 2, ['生命体征']),
        ('无菌技术操作原则', '无菌技术六大基本原则...', 3, ['无菌技术']),
        ('给药原则与三查七对', '给药五大原则...', 3, ['给药护理']),
        ('静脉输液的并发症及处理', '静脉输液常见并发症...', 4, ['静脉输液']),
        ('压疮的分期与预防', '压疮分期及预防措施...', 3, ['压疮预防', '卧位与翻身']),
        ('心肺复苏操作步骤', '心肺复苏（CPR）操作...', 4, ['心肺复苏', '急救护理']),
        ('疼痛评估与护理', '疼痛评估方法...', 3, ['疼痛护理']),
    ]

    # 内科护理学卡片
    internal_cards = [
        ('糖尿病的诊断标准与护理', '糖尿病诊断标准...', 4, ['糖尿病护理', '健康教育']),
        ('高血压分级标准与护理', '高血压分级...', 3, ['高血压护理', '循环系统']),
        ('冠心病类型与心梗鉴别', '冠心病分类...', 4, ['冠心病护理', '循环系统']),
        ('肺炎的分类与护理', '肺炎分类...', 3, ['呼吸系统']),
        ('脑卒中类型与护理', '脑卒中分类...', 4, ['脑卒中护理', '神经系统']),
    ]

    # 外科护理学卡片
    surgical_cards = [
        ('手术前准备', '手术前准备内容...', 3, ['术前准备']),
        ('手术后护理要点', '手术后护理...', 3, ['术后护理']),
        ('伤口愈合类型与护理', '伤口愈合类型...', 3, ['伤口护理']),
        ('外科常见引流管护理', '外科常见引流管...', 4, ['引流管护理']),
        ('急腹症护理评估', '急腹症评估...', 4, ['消化系统', '急救护理']),
    ]
    
    nursing_card_ids = []

    # 插入护理学导论卡片
    for front, back, difficulty, tags in intro_cards:
        cursor.execute("""
            INSERT INTO biz_card (subject_id, front_content, back_content, difficulty_level, del_flag)
            VALUES (%s, %s, %s, %s, '0')
        """, (nursing_subject_ids['护理学导论'], front, back, difficulty))
        card_id = cursor.lastrowid
        nursing_card_ids.append((card_id, tags))

    # 插入基础护理学卡片
    for front, back, difficulty, tags in base_cards:
        cursor.execute("""
            INSERT INTO biz_card (subject_id, front_content, back_content, difficulty_level, del_flag)
            VALUES (%s, %s, %s, %s, '0')
        """, (nursing_subject_ids['基础护理学'], front, back, difficulty))
        card_id = cursor.lastrowid
        nursing_card_ids.append((card_id, tags))

    # 插入内科护理学卡片
    for front, back, difficulty, tags in internal_cards:
        cursor.execute("""
            INSERT INTO biz_card (subject_id, front_content, back_content, difficulty_level, del_flag)
            VALUES (%s, %s, %s, %s, '0')
        """, (nursing_subject_ids['内科护理学'], front, back, difficulty))
        card_id = cursor.lastrowid
        nursing_card_ids.append((card_id, tags))

    # 插入外科护理学卡片
    for front, back, difficulty, tags in surgical_cards:
        cursor.execute("""
            INSERT INTO biz_card (subject_id, front_content, back_content, difficulty_level, del_flag)
            VALUES (%s, %s, %s, %s, '0')
        """, (nursing_subject_ids['外科护理学'], front, back, difficulty))
        card_id = cursor.lastrowid
        nursing_card_ids.append((card_id, tags))

    conn.commit()
    print(f"✓ 已插入 {len(nursing_card_ids)} 个 308 卡片")
    
    # 5. 插入卡片标签关联
    print("→ 插入卡片标签关联...")
    for card_id, tag_names in nursing_card_ids:
        for tag_name in tag_names:
            tag_id = nursing_tag_ids.get(tag_name)
            if tag_id:
                cursor.execute("INSERT INTO biz_card_tag (card_id, tag_id) VALUES (%s, %s)", (card_id, tag_id))
    
    conn.commit()
    print("✓ 卡片标签关联已插入")
    
    cursor.close()

def insert_408_card_tags(conn):
    """插入 408 卡片标签关联"""
    cursor = conn.cursor()
    
    # 获取408标签ID映射
    cursor.execute("SELECT tag_id, tag_name FROM biz_tag WHERE subject_id IN (1, 2, 3, 4)")
    tag_map = {row[1]: row[0] for row in cursor.fetchall()}
    
    # 408 卡片标签关联（根据 mock_data.sql）
    card_tag_relations = [
        # 数据结构卡片 (card_id 1-6)
        (1, ['时间复杂度', '空间复杂度']),
        (2, ['排序算法', '时间复杂度']),
        (3, ['查找算法']),
        (4, ['树']),
        (5, ['树']),
        (6, ['图']),
        # 计组卡片 (card_id 7-11)
        (7, ['Cache']),
        (8, ['中断']),
        (9, ['DMA']),
        (10, ['浮点数']),
        (11, ['流水线']),
        # 操作系统卡片 (card_id 12-15)
        (12, ['PV操作']),
        (13, ['进程调度']),
        (14, ['内存管理']),
        (15, ['死锁']),
        # 计网卡片 (card_id 16-21)
        (16, ['TCP']),
        (17, ['TCP']),
        (18, ['TCP', 'UDP']),
        (19, ['IP协议']),
        (20, ['HTTP']),
        (21, ['滑动窗口']),
    ]
    
    print("→ 插入 408 卡片标签关联...")
    for card_id, tag_names in card_tag_relations:
        for tag_name in tag_names:
            tag_id = tag_map.get(tag_name)
            if tag_id:
                cursor.execute("INSERT INTO biz_card_tag (card_id, tag_id) VALUES (%s, %s)", (card_id, tag_id))
    
    conn.commit()
    print(f"✓ 408 卡片标签关联已插入")
    cursor.close()

def verify_data(conn):
    """验证数据"""
    cursor = conn.cursor()
    
    print("\n========== 数据验证 ==========")
    
    # 统计专业
    cursor.execute("SELECT COUNT(*) FROM biz_major")
    print(f"专业数量: {cursor.fetchone()[0]}")
    
    # 统计科目
    cursor.execute("SELECT COUNT(*) FROM biz_subject")
    print(f"科目数量: {cursor.fetchone()[0]}")
    
    # 统计标签
    cursor.execute("SELECT COUNT(*) FROM biz_tag")
    print(f"标签数量: {cursor.fetchone()[0]}")
    
    # 按科目统计标签
    cursor.execute("""
        SELECT s.subject_name, COUNT(t.tag_id) as tag_count
        FROM biz_subject s
        LEFT JOIN biz_tag t ON s.subject_id = t.subject_id
        GROUP BY s.subject_id, s.subject_name
        ORDER BY s.subject_id
    """)
    print("\n按科目统计标签:")
    for row in cursor.fetchall():
        print(f"  {row[0]}: {row[1]} 个标签")
    
    # 统计通用标签
    cursor.execute("SELECT COUNT(*) FROM biz_tag WHERE subject_id IS NULL")
    print(f"\n通用标签数量: {cursor.fetchone()[0]}")
    
    # 统计卡片
    cursor.execute("SELECT COUNT(*) FROM biz_card WHERE del_flag = '0'")
    print(f"\n卡片数量: {cursor.fetchone()[0]}")
    
    # 统计卡片标签关联
    cursor.execute("SELECT COUNT(*) FROM biz_card_tag")
    print(f"卡片标签关联数: {cursor.fetchone()[0]}")
    
    cursor.close()

def main():
    """主函数"""
    print("=" * 50)
    print("开始执行数据库初始化...")
    print("=" * 50)
    
    try:
        conn = get_connection()
        print("✓ 数据库连接成功")
        
        # 1. 修改表结构
        alter_tag_table(conn)
        
        # 2. 清空标签数据
        clear_and_reset_tags(conn)
        
        # 3. 插入 408 标签
        insert_408_tags(conn)
        
        # 4. 插入 408 卡片标签关联
        insert_408_card_tags(conn)
        
        # 5. 插入 308 护理综合数据
        insert_308_nursing_data(conn)
        
        # 6. 验证数据
        verify_data(conn)
        
        conn.close()
        print("\n" + "=" * 50)
        print("✓ 数据库初始化完成!")
        print("=" * 50)
        
    except Exception as e:
        print(f"\n✗ 执行出错: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == '__main__':
    main()