#!/usr/bin/env python3
"""执行 V18 迁移 SQL：学习历史表添加学习来源字段"""

import mysql.connector

DB_CONFIG = {
    'host': 'localhost',
    'port': 3306,
    'user': 'root',
    'password': '123456',
    'database': 'card_learn',
    'charset': 'utf8mb4',
}

SQL_STATEMENTS = [
    # 添加学习来源字段
    """ALTER TABLE `biz_study_history` ADD COLUMN `source` VARCHAR(20) DEFAULT NULL COMMENT '学习来源: web/ios/mini' AFTER `status`""",
]


def run():
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    try:
        for i, sql in enumerate(SQL_STATEMENTS, 1):
            try:
                cursor.execute(sql)
                print(f"[{i}/{len(SQL_STATEMENTS)}] OK  ({cursor.rowcount} rows affected)")
            except mysql.connector.Error as e:
                if 'Duplicate' in str(e) or 'duplicate' in str(e):
                    print(f"[{i}/{len(SQL_STATEMENTS)}] SKIP (already exists)")
                    conn.commit()
                else:
                    print(f"[{i}/{len(SQL_STATEMENTS)}] ERROR: {e}")
                    conn.rollback()
                    raise
        conn.commit()
        print("\n✅ V18 迁移完成：已添加 source 学习来源字段")
    finally:
        cursor.close()
        conn.close()


if __name__ == '__main__':
    run()
