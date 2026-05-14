package com.card.learn.common;

/**
 * 业务常量（枚举替代不了的魔法字符串统一维护）
 */
public final class AppConstants {

    private AppConstants() {}

    // ==================== 学习来源 ====================
    public static final String SOURCE_WEB = "web";
    public static final String SOURCE_IOS = "ios";
    public static final String SOURCE_MINI = "mini";

    // ==================== 卡片状态筛选 ====================
    public static final String STATUS_ALL = "all";
    public static final String STATUS_LEARNED = "learned";
    public static final String STATUS_MASTERED = "mastered";
    public static final String STATUS_REVIEW = "review";
    public static final String STATUS_UNLEARNED = "unlearned";

    // ==================== 审批状态 ====================
    public static final String AUDIT_PENDING = "0";
    public static final String AUDIT_APPROVED = "1";
    public static final String AUDIT_REJECTED = "2";

    // ==================== 用户状态 ====================
    public static final String USER_ACTIVE = "0";
    public static final String USER_INACTIVE = "1";

    // ==================== 邮箱验证码类型 ====================
    public static final String EMAIL_TYPE_REGISTER = "register";
    public static final String EMAIL_TYPE_RESET = "reset";

    // ==================== 激励 - 每日计数类型 ====================
    public static final String COUNT_TYPE_LEARN = "learn";
    public static final String COUNT_TYPE_MASTER = "master";
    public static final String COUNT_TYPE_REVIEW = "review";

    // ==================== 激励 - 经验来源类型 ====================
    public static final String EXP_SOURCE_STUDY = "STUDY";
    public static final String EXP_SOURCE_MASTER = "MASTER";
    public static final String EXP_SOURCE_REVIEW = "REVIEW";
    public static final String EXP_SOURCE_ACHIEVEMENT = "ACHIEVEMENT";

    // ==================== 激励 - 成就分类 ====================
    public static final String ACHIEVEMENT_CATEGORY_COUNT = "count";
    public static final String ACHIEVEMENT_CATEGORY_STREAK = "streak";
    public static final String ACHIEVEMENT_CATEGORY_SOCIAL = "social";
    public static final String ACHIEVEMENT_CATEGORY_SUBJECT = "subject";

    // ==================== 激励 - 目标类型 ====================
    public static final String GOAL_TYPE_DAILY_LEARN = "daily_learn";
    public static final String GOAL_TYPE_DAILY_MASTER = "daily_master";

    // ==================== 激励 - 成就编码 ====================
    public static final String ACHIEVE_FIRST_LEARN = "FIRST_LEARN";
    public static final String ACHIEVE_FIRST_MASTER = "FIRST_MASTER";
    public static final String ACHIEVE_FIRST_REVIEW = "FIRST_REVIEW";
    public static final String ACHIEVE_LEARN_50 = "LEARN_50";
    public static final String ACHIEVE_LEARN_100 = "LEARN_100";
    public static final String ACHIEVE_LEARN_300 = "LEARN_300";
    public static final String ACHIEVE_LEARN_500 = "LEARN_500";
    public static final String ACHIEVE_LEARN_1000 = "LEARN_1000";
    public static final String ACHIEVE_MASTER_10 = "MASTER_10";
    public static final String ACHIEVE_MASTER_50 = "MASTER_50";
    public static final String ACHIEVE_MASTER_100 = "MASTER_100";
    public static final String ACHIEVE_MASTER_300 = "MASTER_300";
    public static final String ACHIEVE_MASTER_500 = "MASTER_500";
    public static final String ACHIEVE_STREAK_3 = "STREAK_3";
    public static final String ACHIEVE_STREAK_7 = "STREAK_7";
    public static final String ACHIEVE_STREAK_14 = "STREAK_14";
    public static final String ACHIEVE_STREAK_30 = "STREAK_30";
    public static final String ACHIEVE_STREAK_60 = "STREAK_60";
    public static final String ACHIEVE_STREAK_100 = "STREAK_100";
    public static final String ACHIEVE_FIRST_COMMENT = "FIRST_COMMENT";
    public static final String ACHIEVE_FIRST_CONTRIBUTE = "FIRST_CONTRIBUTE";

    // ==================== 激励 - 成就分类别名 ====================
    public static final String ACHIEVE_ALIAS_COMMENT = "comment";
    public static final String ACHIEVE_ALIAS_CONTRIBUTE = "contribute";

    // ==================== 弱项状态 ====================
    public static final String WEAK_POINT_ACTIVE = "active";
    public static final String WEAK_POINT_REVIEWED = "reviewed";

    // ==================== 报告类型 ====================
    public static final String REPORT_TYPE_WEEKLY = "weekly";
    public static final String REPORT_TYPE_MONTHLY = "monthly";

    // ==================== 建议类型 ====================
    public static final String SUGGESTION_TYPE_SUBJECT = "subject";
    public static final String SUGGESTION_TYPE_CARD = "card";
    public static final String SUGGESTION_TYPE_HABIT = "habit";

    // ==================== 建议优先级 ====================
    public static final String PRIORITY_HIGH = "high";
    public static final String PRIORITY_MEDIUM = "medium";
    public static final String PRIORITY_LOW = "low";

    // ==================== 评论类型 ====================
    public static final String COMMENT_TYPE_POOR = "POOR";

    // ==================== 反馈类型 ====================
    public static final String FEEDBACK_TYPE_ERROR = "ERROR";

    // ==================== 默认密码 ====================
    public static final String DEFAULT_PASSWORD = "123456";

    // ==================== 排名类型 ====================
    public static final String RANK_TYPE_TOTAL = "total";
}
