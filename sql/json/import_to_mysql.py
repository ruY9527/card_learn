#!/usr/bin/env python3
import json
import subprocess
import sys
import os

JSON_DIR = os.path.dirname(os.path.abspath(__file__))

# 数据源配置：文件 -> subject_id
SOURCES = [
    (os.path.join(JSON_DIR, "ds/ds_all.json"), 1),           # 数据结构
    (os.path.join(JSON_DIR, "co/co_all.json"), 2),           # 计算机组成原理
    (os.path.join(JSON_DIR, "os/os_all.json"), 3),           # 操作系统
    (os.path.join(JSON_DIR, "cn/network_all_flashcards.json"), 4),  # 计算机网络
    (os.path.join(JSON_DIR, "308/nursing_knowledge_points_clean.json"), 5),  # 护理学基础
]

def clean_text(text):
    if not text:
        return None
    text = text.strip()
    # 去除控制字符
    text = ''.join(ch for ch in text if ord(ch) >= 32 or ch in '\n\r\t')
    return text if text else None

def escape_sql(text):
    if text is None:
        return "NULL"
    text = text.replace("\\", "\\\\").replace("'", "\\'")
    return f"'{text}'"

def load_and_clean(filepath, subject_id):
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)

    cards = []
    seen = set()

    for item in data:
        front = clean_text(item.get('front_content', ''))
        back = clean_text(item.get('back_content', ''))
        difficulty = item.get('difficulty_level', 1)

        if not front or not back:
            continue
        if len(front) < 2 or len(back) < 5:
            continue

        # 去重
        key = front[:100]
        if key in seen:
            continue
        seen.add(key)

        # 限制难度范围
        if not isinstance(difficulty, int) or difficulty < 1 or difficulty > 5:
            difficulty = 1

        cards.append((subject_id, front, back, difficulty))

    return cards

def main():
    all_cards = []
    seen_global = set()

    for filepath, subject_id in SOURCES:
        if not os.path.exists(filepath):
            print(f"SKIP: {filepath} not found")
            continue

        cards = load_and_clean(filepath, subject_id)

        # 全局去重
        unique = []
        for sid, front, back, diff in cards:
            key = front[:100]
            if key not in seen_global:
                seen_global.add(key)
                unique.append((sid, front, back, diff))

        all_cards.extend(unique)
        print(f"  {os.path.basename(filepath)}: {len(unique)} cards (subject_id={subject_id})")

    print(f"\nTotal: {len(all_cards)} cards to import")

    if not all_cards:
        print("No cards to import")
        return

    # 生成SQL
    sql_lines = ["USE `card_learn`;", ""]

    batch_size = 50
    for i in range(0, len(all_cards), batch_size):
        batch = all_cards[i:i+batch_size]
        sql_lines.append("INSERT INTO `biz_card` (`subject_id`, `front_content`, `back_content`, `difficulty_level`, `audit_status`, `create_by`) VALUES")
        values = []
        for sid, front, back, diff in batch:
            values.append(f"  ({sid}, {escape_sql(front)}, {escape_sql(back)}, {diff}, '1', 1)")
        sql_lines.append(",\n".join(values) + ";")
        sql_lines.append("")

    sql_file = os.path.join(JSON_DIR, "import_cards.sql")
    with open(sql_file, 'w', encoding='utf-8') as f:
        f.write("\n".join(sql_lines))

    print(f"SQL written to: {sql_file}")

    # 执行导入
    cmd = ["docker", "exec", "-i", "mysql8", "mysql", "-uroot", "-p123456"]
    with open(sql_file, 'r', encoding='utf-8') as f:
        result = subprocess.run(cmd, stdin=f, capture_output=True, text=True)

    if result.returncode == 0:
        print("Import successful!")
    else:
        print(f"Import failed: {result.stderr}")
        sys.exit(1)

if __name__ == "__main__":
    main()
