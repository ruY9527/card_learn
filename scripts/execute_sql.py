#!/usr/bin/env python3
"""
SQL脚本执行工具
用于执行数据库变更脚本
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
        # 连接数据库
        connection = mysql.connector.connect(**DB_CONFIG)
        cursor = connection.cursor()
        
        # 读取SQL文件
        with open(sql_file_path, 'r', encoding='utf-8') as f:
            sql_content = f.read()
        
        # 分割SQL语句（按分号分割，处理多条语句）
        sql_statements = []
        current_statement = []
        
        for line in sql_content.split('\n'):
            #  Skip empty lines and comments
            stripped_line = line.strip()
            if not stripped_line or stripped_line.startswith('--'):
                continue
            
            current_statement.append(line)
            
            # 检查是否是语句结束
            if stripped_line.endswith(';'):
                full_statement = '\n'.join(current_statement)
                if full_statement.strip():
                    sql_statements.append(full_statement)
                current_statement = []
        
        # 执行每条SQL语句
        for statement in sql_statements:
            try:
                print(f"执行: {statement[:100]}...")
                cursor.execute(statement)
                connection.commit()
                print("  ✓ 成功")
            except mysql.connector.Error as err:
                # 检查是否是列已存在的错误（可忽略）
                if err.errno == 1060:  # Duplicate column name
                    print(f"  ⚠ 列已存在，跳过: {err.msg}")
                elif err.errno == 1061:  # Duplicate key name
                    print(f"  ⚠ 索引已存在，跳过: {err.msg}")
                else:
                    print(f"  ✗ 错误: {err}")
                    raise err
        
        cursor.close()
        connection.close()
        
        print(f"\n✓ SQL文件执行完成: {sql_file_path}")
        return True
        
    except mysql.connector.Error as err:
        print(f"\n✗ 数据库连接错误: {err}")
        return False
    except FileNotFoundError:
        print(f"\n✗ SQL文件不存在: {sql_file_path}")
        return False
    except Exception as e:
        print(f"\n✗ 执行错误: {e}")
        return False

def verify_table_structure():
    """验证表结构变更"""
    print("\n验证biz_card表结构...")
    
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        cursor = connection.cursor()
        
        # 查询表结构
        cursor.execute("DESCRIBE biz_card")
        columns = cursor.fetchall()
        
        # 检查新增字段
        expected_columns = ['audit_status', 'create_user_id', 'audit_user_id', 'audit_time', 'audit_remark']
        existing_columns = [col[0] for col in columns]
        
        print("\n新增字段检查:")
        for col in expected_columns:
            if col in existing_columns:
                print(f"  ✓ {col} 已添加")
            else:
                print(f"  ✗ {col} 未找到")
        
        # 查询索引
        cursor.execute("SHOW INDEX FROM biz_card")
        indexes = cursor.fetchall()
        index_names = [idx[2] for idx in indexes]
        
        print("\n新增索引检查:")
        expected_indexes = ['idx_audit_status', 'idx_create_user_id']
        for idx in expected_indexes:
            if idx in index_names:
                print(f"  ✓ {idx} 已添加")
            else:
                print(f"  ✗ {idx} 未找到")
        
        # 统计数据
        cursor.execute("SELECT audit_status, COUNT(*) FROM biz_card GROUP BY audit_status")
        status_counts = cursor.fetchall()
        
        print("\n审批状态统计:")
        for status, count in status_counts:
            status_text = {'0': '待审批', '1': '已通过', '2': '已拒绝'}.get(status, status)
            print(f"  {status_text}: {count}条")
        
        cursor.close()
        connection.close()
        
        return True
        
    except mysql.connector.Error as err:
        print(f"验证错误: {err}")
        return False

def main():
    """主函数"""
    # 获取SQL文件路径
    project_root = Path(__file__).parent.parent
    sql_file = project_root / 'sql' / 'V2_20260424_add_card_audit.sql'
    
    print("=" * 60)
    print("知识卡片审批功能 - 数据库变更脚本执行")
    print("=" * 60)
    
    # 执行SQL
    if execute_sql_file(sql_file):
        # 验证变更
        verify_table_structure()
        print("\n" + "=" * 60)
        print("数据库变更完成!")
        print("=" * 60)
    else:
        print("\n执行失败，请检查错误信息")
        sys.exit(1)

if __name__ == '__main__':
    main()