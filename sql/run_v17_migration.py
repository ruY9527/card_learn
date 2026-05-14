#!/usr/bin/env python3
"""执行 V17 迁移 SQL：添加学习提醒时间字段"""

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
    # 添加提醒时间字段
    """ALTER TABLE `biz_learning_goal` ADD COLUMN `reminder_hour` INT DEFAULT NULL COMMENT '提醒小时(0-23)' AFTER `enabled`""",
    """ALTER TABLE `biz_learning_goal` ADD COLUMN `reminder_minute` INT DEFAULT NULL COMMENT '提醒分钟(0-59)' AFTER `reminder_hour`""",
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
                # Duplicate column 等可忽略
                if 'Duplicate' in str(e) or 'duplicate' in str(e):
                    print(f"[{i}/{len(SQL_STATEMENTS)}] SKIP (already exists)")
                    conn.commit()
                else:
                    print(f"[{i}/{len(SQL_STATEMENTS)}] ERROR: {e}")
                    conn.rollback()
                    raise
        conn.commit()
        print("\n✅ V17 迁移完成：已添加 reminder_hour 和 reminder_minute 字段")
    finally:
        cursor.close()
        conn.close()


if __name__ == '__main__':
    run()
