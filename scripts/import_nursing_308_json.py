#!/usr/bin/env python3
"""
导入308护理综合JSON数据到数据库
根据卡片内容自动判断所属科目
"""

import json
import pymysql
import re
import os

# 数据库配置
DB_CONFIG = {
    'host': 'localhost',
    'port': 3308,
    'user': 'root',
    'password': '123456',
    'database': 'card_learn',
    'charset': 'utf8mb4'
}

# 308护理综合科目映射
SUBJECT_MAP = {
    5: '护理学导论',
    6: '基础护理学',
    7: '内科护理学',
    8: '外科护理学'
}

# 根据关键词判断科目的规则
SUBJECT_KEYWORDS = {
    # 内科护理学关键词 (subject_id=7)
    7: [
        '心力衰竭', '心肌梗死', '心律失常', '高血压', '感染性心内膜炎', '心包炎',
        '冠心病', '心绞痛', '房颤', '室性', '心脏骤停', '心肺复苏', '瓣膜病',
        '糖尿病', '肺炎', '肺结核', '哮喘', 'COPD', '慢性阻塞性肺', '肺心病',
        '肺栓塞', '肺癌', '呼吸衰竭', '支气管扩张', '胸腔积液',
        '肝硬化', '消化性溃疡', '胃炎', '上消化道出血', '肝性脑病', '胰腺炎',
        '溃疡性结肠炎', '克罗恩病', '胃食管反流', '脂肪肝',
        '肾小球肾炎', '尿路感染', '肾病综合征', '肾功能', '贫血', '出血性疾病',
        '白血病', '淋巴瘤', '血小板', '血友病',
        '类风湿', '系统性红斑狼疮', 'SLE', '痛风', '骨质疏松', '甲亢', '甲减',
        '库欣综合征', '甲状腺', '肾上腺', '垂体',
        '脑血管', '脑卒中', '癫痫', '帕金森', '头痛', '眩晕',
        '消化系统', '呼吸系统', '循环系统', '血液系统', '泌尿系统', '内分泌', '神经系统',
        '内科护理'
    ],
    # 外科护理学关键词 (subject_id=8)
    8: [
        '手术', '麻醉', '围手术期', '切口', '缝合', '引流',
        '创伤', '骨折', '烧伤', '冻伤', '咬伤', '损伤',
        '休克', '水电解质', '酸碱平衡', '输血',
        '肿瘤', '癌', '切除术', '根治术',
        '颅脑损伤', '脑肿瘤', '颅内压',
        '胸部损伤', '腹部损伤', '骨折护理',
        '关节', '脊柱', '椎间盘', '腰椎',
        '疝', '阑尾炎', '肠梗阻', '胆道', '胆囊', '胰腺癌', '肝癌',
        '甲状腺手术', '乳腺', '乳腺癌', '胃手术', '结肠癌', '直肠癌',
        '泌尿外科', '肾结石', '前列腺', '膀胱', '肾肿瘤',
        '骨科', '截肢', '关节置换', '牵引',
        '外科护理'
    ],
    # 基础护理学关键词 (subject_id=6)
    6: [
        '护理程序', '评估', '护理诊断', '护理计划', '护理评价',
        '生命体征', '体温', '脉搏', '呼吸', '血压测量',
        '清洁护理', '口腔护理', '皮肤护理', '压疮',
        '饮食护理', '营养评估', '鼻饲',
        '排泄护理', '排便', '导尿', '灌肠',
        '给药', '注射', '静脉输液', '输血',
        '氧疗', '吸氧', '雾化吸入',
        '急救', '心肺复苏基础', '止血', '包扎',
        '卧位', '体位', '翻身', '搬运',
        '消毒', '灭菌', '无菌技术', '隔离',
        '标本采集', '实验室检查',
        '健康教育', '沟通技巧', '护理文书',
        '护理伦理', '法律法规', '患者权利',
        '医院环境', '病室管理', '安全护理',
        '基础护理'
    ],
    # 护理学导论关键词 (subject_id=5)
    5: [
        '护理学概念', '护理发展史', '护理模式', '护理理论',
        '护士角色', '护理专业', '护理教育',
        '健康与疾病', '健康促进', '疾病预防',
        '需要理论', '马斯洛', '压力与适应',
        '护患关系', '沟通', '护理伦理', '法律',
        '护理评估方法', '护理诊断', 'Gordon',
        '护理程序概述', '护理计划', '护理实施', '护理评价',
        '护理学导论', '护理学基础概念'
    ]
}

def determine_subject(front_content, back_content):
    """根据卡片内容判断所属科目"""
    content = (front_content + ' ' + back_content).lower()
    
    # 按优先级检查关键词
    for subject_id, keywords in SUBJECT_KEYWORDS.items():
        for keyword in keywords:
            if keyword.lower() in content:
                return subject_id
    
    # 默认归入内科护理学（内科内容最多）
    return 7

def clean_content(content):
    """清理内容中的乱码和格式问题"""
    if not content:
        return ''
    
    # 移除特殊乱码字符
    content = re.sub(r'[^\w\s\u4e00-\u9fff\u0020-\u007e\u3000-\u303f\uff00-\uffef.,，。！？；：""''（）【】《》、\-\n\r\t]', '', content)
    
    # 替换多个空格为单个空格
    content = re.sub(r'\s+', ' ', content)
    
    # 替换多个换行为单个换行
    content = re.sub(r'\n+', '\n', content)
    
    # 移除行首行尾空格
    content = content.strip()
    
    return content

def load_json_files():
    """加载所有JSON文件"""
    json_dir = '/Users/baoyang/Documents/coding/github_self/card_learn/sql/json/308'
    json_files = [
        'nursing_complete.json',
        'nursing_final.json',
        'nursing_knowledge_points_clean.json',
        'nursing_knowledge_points.json'
    ]
    
    all_cards = []
    
    for json_file in json_files:
        file_path = os.path.join(json_dir, json_file)
        if os.path.exists(file_path):
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    if isinstance(data, list):
                        all_cards.extend(data)
                        print('加载 %s: %s 条记录' % (json_file, len(data)))
            except Exception as e:
                print('加载 %s 失败: %s' % (json_file, str(e)))
    
    return all_cards

def deduplicate_cards(cards):
    """去重卡片（基于front_content）"""
    seen = {}
    unique_cards = []
    
    for card in cards:
        front = card.get('front_content', '').strip()
        if front and front not in seen:
            seen[front] = True
            unique_cards.append(card)
    
    return unique_cards

def filter_valid_cards(cards):
    """过滤有效卡片"""
    valid_cards = []
    
    for card in cards:
        front = clean_content(card.get('front_content', ''))
        back = clean_content(card.get('back_content', ''))
        
        # 过滤无效内容
        if not front or len(front) < 5:
            continue
        
        # 过滤非知识点内容（如学习方法介绍等）
        if any(x in front.lower() for x in ['学习方法', '备考指南', '复习计划', '考试技巧', '做题思路', '名词解释"']):
            continue
        
        # 过滤内容过于混乱的卡片
        if len(back) < 20:
            continue
        
        valid_cards.append({
            'front_content': front,
            'back_content': back,
            'difficulty_level': card.get('difficulty_level', 3),
            'original_subject_id': card.get('subject_id', 1)
        })
    
    return valid_cards

def import_cards_to_database(cards):
    """导入卡片到数据库"""
    conn = pymysql.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    imported_count = {5: 0, 6: 0, 7: 0, 8: 0}
    skipped_count = 0
    
    # 获取已存在的卡片内容（用于去重）
    cursor.execute('SELECT front_content FROM biz_card WHERE subject_id IN (5,6,7,8)')
    existing_fronts = set(row[0] for row in cursor.fetchall())
    
    for card in cards:
        front = card['front_content']
        back = card['back_content']
        difficulty = card['difficulty_level']
        
        # 检查是否已存在
        if front in existing_fronts:
            skipped_count += 1
            continue
        
        # 判断科目
        subject_id = determine_subject(front, back)
        
        # 插入卡片
        try:
            sql = '''
                INSERT INTO biz_card 
                (subject_id, front_content, back_content, difficulty_level, audit_status, create_time)
                VALUES (%s, %s, %s, %s, '1', NOW())
            '''
            cursor.execute(sql, (subject_id, front, back, difficulty))
            imported_count[subject_id] += 1
        except Exception as e:
            print('插入失败: %s - %s' % (front[:50], str(e)))
    
    conn.commit()
    cursor.close()
    conn.close()
    
    return imported_count, skipped_count

def create_tags_for_subjects():
    """为各科目创建标签"""
    conn = pymysql.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    # 定义各科目的常见标签
    subject_tags = {
        5: ['护理理论', '护理程序', '护士角色', '健康概念', '护理评估'],
        6: ['基础护理', '生命体征', '给药护理', '饮食护理', '清洁护理', '安全护理', '消毒隔离', '健康教育'],
        7: ['循环系统', '呼吸系统', '消化系统', '泌尿系统', '血液系统', '内分泌', '神经系统', '内科护理', 
             '心力衰竭', '高血压', '糖尿病', '肺炎', '肺结核', '哮喘', '肝硬化', '贫血'],
        8: ['外科护理', '围手术期', '麻醉护理', '创伤护理', '骨科护理', '肿瘤护理', '休克', '水电解质']
    }
    
    created_count = 0
    
    for subject_id, tags in subject_tags.items():
        for tag_name in tags:
            # 检查是否已存在
            cursor.execute('SELECT tag_id FROM biz_tag WHERE tag_name = %s AND subject_id = %s', (tag_name, subject_id))
            if cursor.fetchone():
                continue
            
            # 创建标签
            cursor.execute('INSERT INTO biz_tag (tag_name, subject_id, create_time) VALUES (%s, %s, NOW())', (tag_name, subject_id))
            created_count += 1
    
    conn.commit()
    cursor.close()
    conn.close()
    
    return created_count

def assign_tags_to_cards():
    """为卡片分配标签"""
    conn = pymysql.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    # 获取所有标签
    cursor.execute('SELECT tag_id, tag_name, subject_id FROM biz_tag WHERE subject_id IN (5,6,7,8)')
    tags = cursor.fetchall()
    tag_map = {}  # {subject_id: {tag_name: tag_id}}
    for tag_id, tag_name, subject_id in tags:
        if subject_id not in tag_map:
            tag_map[subject_id] = {}
        tag_map[subject_id][tag_name] = tag_id
    
    # 获取新导入的卡片
    cursor.execute('''
        SELECT card_id, subject_id, front_content, back_content 
        FROM biz_card 
        WHERE subject_id IN (5,6,7,8) 
        AND create_time > DATE_SUB(NOW(), INTERVAL 1 HOUR)
    ''')
    cards = cursor.fetchall()
    
    assigned_count = 0
    
    for card_id, subject_id, front, back in cards:
        content = (front + ' ' + back).lower()
        
        if subject_id not in tag_map:
            continue
        
        # 匹配标签
        matched_tags = []
        for tag_name, tag_id in tag_map[subject_id].items():
            if tag_name.lower() in content:
                matched_tags.append(tag_id)
        
        # 分配标签（最多3个）
        for tag_id in matched_tags[:3]:
            try:
                cursor.execute('INSERT INTO biz_card_tag (card_id, tag_id) VALUES (%s, %s)', (card_id, tag_id))
                assigned_count += 1
            except:
                pass  # 忽略重复
    
    conn.commit()
    cursor.close()
    conn.close()
    
    return assigned_count

def main():
    print('='*60)
    print('308护理综合JSON数据导入')
    print('='*60)
    
    # 1. 加载JSON文件
    print('\n[1] 加载JSON文件...')
    all_cards = load_json_files()
    print('总计加载: %s 条记录' % len(all_cards))
    
    # 2. 去重
    print('\n[2] 去重卡片...')
    unique_cards = deduplicate_cards(all_cards)
    print('去重后: %s 条记录' % len(unique_cards))
    
    # 3. 过滤有效卡片
    print('\n[3] 过滤有效卡片...')
    valid_cards = filter_valid_cards(unique_cards)
    print('有效卡片: %s 条' % len(valid_cards))
    
    # 4. 导入到数据库
    print('\n[4] 导入卡片到数据库...')
    imported_count, skipped_count = import_cards_to_database(valid_cards)
    
    print('\n导入结果:')
    for subject_id, count in imported_count.items():
        print('  %s (subject_id=%s): %s 张新卡片' % (SUBJECT_MAP[subject_id], subject_id, count))
    print('  跳过重复: %s 张' % skipped_count)
    
    # 5. 创建标签
    print('\n[5] 创建科目标签...')
    created_tags = create_tags_for_subjects()
    print('创建标签: %s 个' % created_tags)
    
    # 6. 为卡片分配标签
    print('\n[6] 为新卡片分配标签...')
    assigned_tags = assign_tags_to_cards()
    print('分配标签关联: %s 条' % assigned_tags)
    
    # 7. 统计最终数据
    print('\n[7] 最终统计...')
    conn = pymysql.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    for subject_id, subject_name in SUBJECT_MAP.items():
        cursor.execute('SELECT COUNT(*) FROM biz_card WHERE subject_id = %s AND audit_status = "1"' % subject_id)
        card_count = cursor.fetchone()[0]
        cursor.execute('SELECT COUNT(*) FROM biz_tag WHERE subject_id = %s' % subject_id)
        tag_count = cursor.fetchone()[0]
        print('  %s: %s张卡片, %s个标签' % (subject_name, card_count, tag_count))
    
    cursor.close()
    conn.close()
    
    print('\n' + '='*60)
    print('导入完成!')
    print('='*60)

if __name__ == '__main__':
    main()