#!/usr/bin/env python3
"""执行 V11 迁移 SQL：多角色设计与权限分配"""

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
    # 1. 删除旧的普通管理员(role_id=2)
    """DELETE FROM `sys_role_menu` WHERE `role_id` = 2""",
    """DELETE FROM `sys_user_role` WHERE `role_id` = 2""",
    """DELETE FROM `sys_role` WHERE `role_id` = 2""",

    # 2. 插入新角色
    """INSERT IGNORE INTO `sys_role` (`role_id`, `role_name`, `role_key`, `status`) VALUES
       (3, '内容编辑员', 'content_editor', '0'),
       (4, '审核员', 'reviewer', '0'),
       (5, '数据分析师', 'data_analyst', '0'),
       (6, '系统管理员', 'system_admin', '0'),
       (7, '普通学习者', 'learner', '0'),
       (8, '高级学习者', 'premium_learner', '0')""",

    # 3. 内容编辑员(role_id=3): 首页 + 内容管理
    """INSERT IGNORE INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES
       (3, 8), (3, 3), (3, 4), (3, 5), (3, 6), (3, 7)""",

    # 4. 审核员(role_id=4): 首页 + 用户反馈
    """INSERT IGNORE INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES
       (4, 8), (4, 9), (4, 10), (4, 11), (4, 12), (4, 13)""",

    # 5. 数据分析师(role_id=5): 首页 + 数据统计
    """INSERT IGNORE INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES
       (5, 8), (5, 14), (5, 15), (5, 16), (5, 17), (5, 18)""",

    # 6. 系统管理员(role_id=6): 首页 + 系统管理
    """INSERT IGNORE INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES
       (6, 8), (6, 1), (6, 2), (6, 24), (6, 25), (6, 26), (6, 27), (6, 28)""",

    # 7. 普通学习者(role_id=7): 首页 + AI + 统计 + 激励
    """INSERT IGNORE INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES
       (7, 8), (7, 23), (7, 14), (7, 15), (7, 16), (7, 17), (7, 18),
       (7, 19), (7, 20), (7, 21), (7, 22)""",

    # 8. 高级学习者(role_id=8): 普通学习者 + 反馈管理 + 笔记管理
    """INSERT IGNORE INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES
       (8, 8), (8, 23), (8, 14), (8, 15), (8, 16), (8, 17), (8, 18),
       (8, 19), (8, 20), (8, 21), (8, 22), (8, 9), (8, 10), (8, 13)""",
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
        print("\n✅ V11 迁移完成：多角色设计与权限分配")
    finally:
        cursor.close()
        conn.close()


if __name__ == '__main__':
    run()
