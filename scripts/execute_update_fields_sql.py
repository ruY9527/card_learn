#!/usr/bin/env python3
"""
SQL脚本执行工具 - 添加更新时间和更新人字段
"""

import mysql.connector
import os
import sys
from pathlib import Path

# 数据库配置
DB_CONFIG = {
    'host': 'localhost',
    'port': 3308,
    'user': 'root',
    'password': '123456',
    'database': 'card_learn',
    'charset': 'utf8mb4'
}

def execute_sql_file(sql_file_path):
    """执行SQL文件"""
    print(f"正在执行SQL文件: {sql_file_path}")
    
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        cursor = connection.cursor()
        
        with open(sql_file_path, 'r', encoding='utf-8') as f:
            sql_content = f.read()
        
        # 分割SQL语句（按分号分割，忽略注释）
        sql_statements = []
        current_statement = []
        
        for line in sql_content.split('\n'):
            stripped_line = line.strip()
            # 跳过空行和注释
            if not stripped_line or stripped_line.startswith('--'):
                continue
            
            current_statement.append(line)
            
            # 如果行以分号结尾，则是一个完整的语句
            if stripped_line.endswith(';'):
                full_statement = '\n'.join(current_statement)
                if full_statement.strip():
                    sql_statements.append(full_statement)
                current_statement = []
        
        success_count = 0
        for statement in sql_statements:
            try:
                # 提取表名用于显示
                if 'ALTER TABLE' in statement:
                    table_name = statement.split('ALTER TABLE')[1].split('ADD')[0].strip().replace('`', '')
                    print(f"  执行: ALTER TABLE {table_name}...")
                else:
                    print(f"  执行: {statement[:60]}...")
                
                cursor.execute(statement)
                connection.commit()
                print("  ✓ 成功")
                success_count += 1
            except mysql.connector.Error as err:
                if err.errno == 1060:  # Duplicate column name
                    print(f"  ⚠ 字段已存在，跳过")
                else:
                    print(f"  ✗ 错误: {err}")
                    # 继续执行其他语句
        
        cursor.close()
        connection.close()
        
        print(f"\n✓ SQL文件执行完成，成功 {success_count} 条语句")
        return True
        
    except Exception as e:
        print(f"\n✗ 执行错误: {e}")
        return False

def verify_table_structure():
    """验证表结构"""
    print("\n验证表结构...")
    
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        cursor = connection.cursor()
        
        tables_to_check = [
            'biz_card', 'biz_card_draft', 'biz_card_audit_log', 
            'biz_card_tag', 'biz_subject', 'biz_major',
            'sys_user', 'sys_app_user', 'biz_feedback'
        ]
        
        all_ok = True
        for table in tables_to_check:
            cursor.execute(f"DESCRIBE {table}")
            columns = cursor.fetchall()
            
            update_time_exists = False
            update_user_exists = False
            
            for col in columns:
                field = col[0]
                if 'update_time' in field.lower():
                    update_time_exists = True
                if 'update_user_id' in field.lower():
                    update_user_exists = True
            
            status = "✓" if (update_time_exists and update_user_exists) else "⚠"
            print(f"  {status} {table}: update_time={update_time_exists}, update_user_id={update_user_exists}")
            
            if not (update_time_exists and update_user_exists):
                all_ok = False
        
        cursor.close()
        connection.close()
        
        return all_ok
        
    except Exception as e:
        print(f"验证错误: {e}")
        return False

def main():
    project_root = Path(__file__).parent.parent
    sql_file = project_root / 'sql' / 'V4_20260424_add_update_fields.sql'
    
    print("=" * 60)
    print("添加更新时间和更新人字段")
    print("=" * 60)
    
    if execute_sql_file(sql_file):
        if verify_table_structure():
            print("\n" + "=" * 60)
            print("数据库变更完成，所有表字段检查通过!")
            print("=" * 60)
        else:
            print("\n部分表字段检查未通过，请检查")
    else:
        sys.exit(1)

if __name__ == '__main__':
    main()