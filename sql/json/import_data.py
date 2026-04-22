#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
408知识点卡片数据导入脚本
将sql/json/all目录下的JSON数据导入到MySQL数据库
"""

import json
import pymysql
import os
from datetime import datetime

# MySQL连接配置（从application.yml获取）
DB_CONFIG = {
    'host': 'localhost',
    'port': 3308,
    'user': 'root',
    'password': '123456',
    'database': 'card_learn',
    'charset': 'utf8mb4'
}

# JSON文件映射：文件名 -> 科目名称
JSON_FILES = {
    'ds_all.json': '数据结构',
    'co_all.json': '计算机组成原理',
    'os_all.json': '操作系统',
    'cn_all.json': '计算机网络'
}

# JSON文件目录
JSON_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'all')


def get_connection():
    """获取数据库连接"""
    return pymysql.connect(**DB_CONFIG)


def get_subject_id_map(conn):
    """获取科目ID映射：科目名称 -> subject_id"""
    with conn.cursor() as cursor:
        cursor.execute("SELECT subject_id, subject_name FROM biz_subject")
        rows = cursor.fetchall()
        return {row[1]: row[0] for row in rows}


def get_existing_cards(conn):
    """获取已存在的卡片（用于去重，根据正面内容判断）"""
    with conn.cursor() as cursor:
        cursor.execute("SELECT card_id, front_content FROM biz_card")
        rows = cursor.fetchall()
        return {row[1]: row[0] for row in rows}


def get_existing_tags(conn):
    """获取已存在的标签：标签名称 -> tag_id"""
    with conn.cursor() as cursor:
        cursor.execute("SELECT tag_id, tag_name FROM biz_tag")
        rows = cursor.fetchall()
        return {row[1]: row[0] for row in rows}


def get_card_tags(conn, card_id):
    """获取卡片已有的标签ID列表"""
    with conn.cursor() as cursor:
        cursor.execute("SELECT tag_id FROM biz_card_tag WHERE card_id = %s", (card_id,))
        rows = cursor.fetchall()
        return [row[0] for row in rows]


def insert_card(conn, subject_id, front_content, back_content, difficulty_level):
    """插入卡片，返回卡片ID"""
    with conn.cursor() as cursor:
        sql = """
        INSERT INTO biz_card (subject_id, front_content, back_content, difficulty_level, del_flag)
        VALUES (%s, %s, %s, %s, '0')
        """
        cursor.execute(sql, (subject_id, front_content, back_content, difficulty_level))
        conn.commit()
        return cursor.lastrowid


def insert_or_get_tag(conn, tag_name, existing_tags):
    """插入标签或获取已存在的标签ID"""
    if tag_name in existing_tags:
        return existing_tags[tag_name]
    
    with conn.cursor() as cursor:
        cursor.execute("INSERT INTO biz_tag (tag_name) VALUES (%s)", (tag_name,))
        conn.commit()
        tag_id = cursor.lastrowid
        existing_tags[tag_name] = tag_id
        return tag_id


def insert_card_tag(conn, card_id, tag_id):
    """插入卡片-标签关联"""
    with conn.cursor() as cursor:
        try:
            cursor.execute(
                "INSERT INTO biz_card_tag (card_id, tag_id) VALUES (%s, %s)",
                (card_id, tag_id)
            )
            conn.commit()
        except pymysql.IntegrityError:
            # 已存在关联，忽略
            pass


def load_json_file(file_path):
    """加载JSON文件"""
    with open(file_path, 'r', encoding='utf-8') as f:
        return json.load(f)


def import_cards_data(conn, json_file, subject_name, subject_id_map, existing_cards, existing_tags):
    """导入单个JSON文件的卡片数据"""
    
    subject_id = subject_id_map.get(subject_name)
    if subject_id is None:
        print(f"  ❌ 科目 '{subject_name}' 在数据库中不存在，跳过")
        return 0
    
    print(f"  📚 科目 '{subject_name}' (subject_id={subject_id})")
    
    # 加载JSON数据
    json_path = os.path.join(JSON_DIR, json_file)
    if not os.path.exists(json_path):
        print(f"  ❌ 文件 {json_file} 不存在，跳过")
        return 0
    
    cards_data = load_json_file(json_path)
    print(f"  📄 加载 {len(cards_data)} 条卡片数据")
    
    imported_count = 0
    skipped_count = 0
    
    for card in cards_data:
        front_content = card.get('front_content', '')
        back_content = card.get('back_content', '')
        difficulty_level = card.get('difficulty_level', 1)
        tags = card.get('tags', [])
        chapter = card.get('chapter', '')
        
        # 根据正面内容判断是否已存在
        if front_content in existing_cards:
            skipped_count += 1
            continue
        
        # 插入卡片
        card_id = insert_card(conn, subject_id, front_content, back_content, difficulty_level)
        existing_cards[front_content] = card_id
        imported_count += 1
        
        # 处理标签
        all_tags = list(tags)
        if chapter and chapter not in all_tags:
            all_tags.append(chapter)  # 将章节也作为标签
        
        for tag_name in all_tags:
            if tag_name:
                tag_id = insert_or_get_tag(conn, tag_name, existing_tags)
                insert_card_tag(conn, card_id, tag_id)
    
    print(f"  ✅ 导入 {imported_count} 条新卡片，跳过 {skipped_count} 条已存在卡片")
    return imported_count


def main():
    """主函数"""
    print("=" * 60)
    print("408知识点卡片数据导入脚本")
    print("=" * 60)
    print(f"时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"数据库: {DB_CONFIG['database']} @ {DB_CONFIG['host']}:{DB_CONFIG['port']}")
    print()
    
    try:
        conn = get_connection()
        print("✅ 数据库连接成功")
        
        # 获取现有数据
        subject_id_map = get_subject_id_map(conn)
        print(f"📚 现有科目: {list(subject_id_map.keys())}")
        
        existing_cards = get_existing_cards(conn)
        print(f"📝 现有卡片: {len(existing_cards)} 条")
        
        existing_tags = get_existing_tags(conn)
        print(f"🏷️ 现有标签: {len(existing_tags)} 个")
        print()
        
        # 导入各科目数据
        total_imported = 0
        for json_file, subject_name in JSON_FILES.items():
            print(f"处理 {json_file} ({subject_name}):")
            imported = import_cards_data(
                conn, json_file, subject_name,
                subject_id_map, existing_cards, existing_tags
            )
            total_imported += imported
            print()
        
        # 统计最终数据
        print("=" * 60)
        print("导入完成！")
        print(f"本次导入卡片: {total_imported} 条")
        print(f"卡片总数: {len(existing_cards)} 条")
        print(f"标签总数: {len(existing_tags)} 个")
        print("=" * 60)
        
        conn.close()
        
    except Exception as e:
        print(f"❌ 错误: {e}")
        raise


if __name__ == '__main__':
    main()