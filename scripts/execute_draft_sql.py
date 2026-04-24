#!/usr/bin/env python3
"""
SQL脚本执行工具 - 执行临时表创建脚本
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
        
        # 分割SQL语句
        sql_statements = []
        current_statement = []
        
        for line in sql_content.split('\n'):
            stripped_line = line.strip()
            if not stripped_line or stripped_line.startswith('--'):
                continue
            
            current_statement.append(line)
            
            if stripped_line.endswith(';'):
                full_statement = '\n'.join(current_statement)
                if full_statement.strip():
                    sql_statements.append(full_statement)
                current_statement = []
        
        for statement in sql_statements:
            try:
                print(f"执行: {statement[:80]}...")
                cursor.execute(statement)
                connection.commit()
                print("  ✓ 成功")
            except mysql.connector.Error as err:
                if err.errno == 1050:  # Table already exists
                    print(f"  ⚠ 表已存在，跳过")
                else:
                    print(f"  ✗ 错误: {err}")
                    raise err
        
        cursor.close()
        connection.close()
        
        print(f"\n✓ SQL文件执行完成")
        return True
        
    except Exception as e:
        print(f"\n✗ 执行错误: {e}")
        return False

def main():
    project_root = Path(__file__).parent.parent
    sql_file = project_root / 'sql' / 'V3_20260424_card_draft.sql'
    
    print("=" * 60)
    print("创建用户录入卡片临时表")
    print("=" * 60)
    
    if execute_sql_file(sql_file):
        # 验证表结构
        print("\n验证表结构...")
        try:
            connection = mysql.connector.connect(**DB_CONFIG)
            cursor = connection.cursor()
            
            cursor.execute("SHOW TABLES LIKE 'biz_card%'")
            tables = cursor.fetchall()
            print("\n相关表:")
            for t in tables:
                print(f"  ✓ {t[0]}")
            
            cursor.close()
            connection.close()
            print("\n" + "=" * 60)
            print("数据库变更完成!")
            print("=" * 60)
        except Exception as e:
            print(f"验证错误: {e}")
    else:
        sys.exit(1)

if __name__ == '__main__':
    main()