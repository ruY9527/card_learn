#!/usr/bin/env python3
"""为护理学导论补充更多卡片"""

import pymysql

DB_CONFIG = {
    'host': 'localhost',
    'port': 3308,
    'user': 'root',
    'password': '123456',
    'database': 'card_learn',
    'charset': 'utf8mb4'
}

def main():
    conn = pymysql.connect(**DB_CONFIG)
    cursor = conn.cursor()

    print('=== 为护理学导论添加更多卡片 ===')

    # 获取护理学导论的subject_id
    cursor.execute('SELECT subject_id FROM biz_subject WHERE subject_name = "护理学导论" AND major_id = 2')
    subject_id = cursor.fetchone()[0]
    print(f'护理学导论 subject_id = {subject_id}')

    # 获取相关标签ID
    cursor.execute('SELECT tag_id, tag_name FROM biz_tag WHERE subject_id = %s', (subject_id,))
    tag_map = {row[1]: row[0] for row in cursor.fetchall()}
    print(f'标签: {tag_map}')

    # 新增护理学导论卡片
    cards = [
        {
            'front': '护理学的概念与发展史',
            'back': '''护理学的概念与发展：

**护理学的概念**
护理学是以自然科学和社会科学理论为基础，研究维护、促进、恢复人类健康的护理理论、知识、技能及其发展规律的综合性应用科学。

**护理学发展史**
1. 古代护理：以家庭护理为主，母亲承担护理职能
2. 中世纪护理：宗教护理时期，护理工作由修女担任
3. 近代护理：Florence Nightingale（南丁格尔）开创现代护理学
   - 1860年在英国圣托马斯医院创办世界上第一所护士学校
   - 被誉为现代护理学的奠基人

**中国护理发展**
- 1888年在福州创办中国第一所护士学校
- 1909年成立中华护士会（现中华护理学会）
- 1983年恢复高等护理教育''',
            'difficulty': 2,
            'tag': None
        },
        {
            'front': '护士的角色功能有哪些？',
            'back': '''护士的角色功能：

**1. 护理者（Caregiver）**
- 提供直接护理服务
- 执行护理计划
- 满足患者基本需要

**2. 计划者（Planner）**
- 制定护理计划
- 设定护理目标
- 选择护理措施

**3. 管理者（Manager）**
- 管理护理资源
- 协调护理工作
- 组织护理活动

**4. 教育者（Educator）**
- 健康教育
- 护理知识传授
- 患者及家属指导

**5. 协调者（Coordinator）**
- 协调医疗团队工作
- 促进医护合作
- 沟通患者信息

**6. 咨询者（Consultant）**
- 提供护理咨询
- 解答健康问题
- 指导护理决策

**7. 研究者（Researcher）**
- 护理科研
- 改进护理方法
- 发展护理理论''',
            'difficulty': 2,
            'tag': '护理程序'
        },
        {
            'front': '护理评估的方法与内容',
            'back': '''护理评估方法与内容：

**评估方法**
1. 观察：通过视觉、听觉、嗅觉等观察患者
2. 交谈：与患者交流获取主观资料
3. 体格检查：测量生命体征、检查身体各系统
4. 查阅资料：病历、检验报告等

**评估内容**
1. 一般资料：姓名、年龄、职业等基本信息
2. 病史：现病史、既往史、家族史
3. 生活状况：饮食、睡眠、排泄、活动等
4. 心理状态：情绪、认知、应对方式
5. 社会文化：文化背景、社会支持、经济状况
6. 身体评估：生命体征、各系统检查

**资料分类**
- 主观资料：患者陈述的症状和感受
- 客观资料：护士观察和测量所得的数据''',
            'difficulty': 2,
            'tag': '护理评估'
        },
        {
            'front': '护理诊断与医疗诊断的区别',
            'back': '''护理诊断与医疗诊断的区别：

| 项目 | 护理诊断 | 医疗诊断 |
|------|----------|----------|
| 侧重点 | 对健康问题的反应 | 疾病病理变化 |
| 描述内容 | 人类对疾病的反应 | 理生理改变 |
| 决策者 | 护士 | 医生 |
| 职责范围 | 护理职责 | 医疗职责 |
| 数量 | 可同时有多个 | 一般只有一个 |
| 稳定性 | 随病情变化较快 | 相对稳定 |
| 处理方法 | 护理措施 | 医疗治疗 |

**护理诊断格式（PES格式）**
P（Problem）- 问题
E（Etiology）- 原因
S（Signs/Symptoms）- 症状/体征

**示例**
- 护理诊断：清理呼吸道无效（P）：与痰液粘稠有关（E）：咳嗽无力、呼吸困难（S）
- 医疗诊断：慢性阻塞性肺疾病''',
            'difficulty': 2,
            'tag': None
        },
        {
            'front': '马斯洛需要层次理论在护理中的应用',
            'back': '''马斯洛需要层次理论在护理中的应用：

**五个层次（由低到高）**
1. 生理需要：食物、水、空气、睡眠、排泄等
2. 安全需要：安全感、稳定感、免受恐惧
3. 爱与归属需要：亲情、友情、爱情、归属感
4. 尊重需要：自尊、尊重、成就感
5. 自我实现需要：发挥潜能、实现理想

**在护理中的应用**
- 优先满足低层次需要
- 护理评估按层次进行
- 制定护理计划考虑需要优先级
- 指导健康教育内容

**护理优先级排序**
1. 首优问题：威胁生命的问题（如呼吸道阻塞）
2. 中优问题：影响健康但不直接威胁生命
3. 次优问题：对患者影响较小的问题''',
            'difficulty': 2,
            'tag': None
        },
    ]

    # 插入卡片和标签关联
    for card in cards:
        cursor.execute('''
            INSERT INTO biz_card (subject_id, front_content, back_content, difficulty_level, del_flag)
            VALUES (%s, %s, %s, %s, '0')
        ''', (subject_id, card['front'], card['back'], card['difficulty']))
        card_id = cursor.lastrowid
        print(f'已插入卡片: {card["front"][:30]}... (card_id={card_id})')

        if card['tag'] and card['tag'] in tag_map:
            cursor.execute('INSERT INTO biz_card_tag (card_id, tag_id) VALUES (%s, %s)', (card_id, tag_map[card['tag']]))

    conn.commit()

    # 验证
    cursor.execute('SELECT COUNT(*) FROM biz_card WHERE subject_id = %s AND del_flag = "0"', (subject_id,))
    count = cursor.fetchone()[0]
    print(f'\n护理学导论现有 {count} 张卡片')

    cursor.close()
    conn.close()
    print('补充完成!')

if __name__ == '__main__':
    main()