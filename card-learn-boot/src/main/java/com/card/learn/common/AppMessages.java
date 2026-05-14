package com.card.learn.common;

/**
 * 统一消息常量（用户可见的提示信息、日志文案等）
 */
public final class AppMessages {

    private AppMessages() {}

    // ==================== 通用 ====================
    public static final String SUCCESS = "操作成功";
    public static final String FAILED = "操作失败";

    // ==================== 认证与登录 ====================
    public static final String CAPTCHA_REQUIRED = "请输入验证码";
    public static final String CAPTCHA_EXPIRED = "验证码已过期，请重新获取";
    public static final String CAPTCHA_WRONG = "验证码错误";
    public static final String USERNAME_PASSWORD_REQUIRED = "请输入账号和密码";
    public static final String USER_NOT_FOUND = "用户不存在";
    public static final String PASSWORD_WRONG = "密码错误";
    public static final String ACCOUNT_DISABLED = "账号已被停用";
    public static final String ACCOUNT_INACTIVE = "账号未激活或已停用";
    public static final String CAPTCHA_SENT = "验证码已发送";
    public static final String REGISTER_SUCCESS = "注册成功";
    public static final String REGISTER_SUCCESS_ACTIVATE = "注册成功，请查收激活邮件并在24小时内完成激活";
    public static final String ACTIVATE_SUCCESS = "激活成功";
    public static final String EMAIL_REQUIRED = "邮箱不能为空";
    public static final String PASSWORD_RESET_SUCCESS = "密码重置成功";
    public static final String PLEASE_LOGIN_FIRST = "请先登录";
    public static final String ANONYMOUS_USER = "匿名用户";

    // ==================== 邮箱认证 ====================
    public static final String SEND_TOO_FREQUENT = "发送太频繁，请60秒后重试";
    public static final String DAILY_SEND_LIMIT = "今日发送次数已用完";
    public static final String EMAIL_ALREADY_REGISTERED = "该邮箱已注册";
    public static final String EMAIL_NOT_REGISTERED = "该邮箱未注册";
    public static final String PASSWORD_FORMAT_INVALID = "密码格式不正确，需6-20位且包含字母和数字";
    public static final String ACTIVATE_LINK_EXPIRED = "激活链接已失效，请重新注册";
    public static final String ACTIVATE_LINK_INVALID = "激活链接无效";
    public static final String ACCOUNT_ALREADY_ACTIVATED = "该账号已激活，请直接登录";

    // ==================== 卡片相关 ====================
    public static final String CARD_NOT_FOUND = "卡片不存在";
    public static final String CARD_ALREADY_AUDITED = "该卡片已审批，不能重复审批";
    public static final String CARD_NO_PERMISSION_EDIT = "无权限修改此卡片";
    public static final String CARD_NO_PERMISSION_DELETE = "无权限删除此卡片";
    public static final String CARD_ONLY_PENDING_EDIT = "只有待审批状态的卡片才能修改";
    public static final String CARD_ONLY_PENDING_DELETE = "只有待审批状态的卡片才能删除";
    public static final String DRAFT_CARD_NOT_FOUND = "临时卡片不存在";
    public static final String CARD_SUBMIT_SUCCESS = "卡片提交成功，等待审核";

    // ==================== 评论与反馈 ====================
    public static final String COMMENT_NOT_FOUND = "评论不存在";
    public static final String REPLY_NOT_FOUND = "回复不存在";
    public static final String FEEDBACK_NOT_FOUND = "反馈不存在";
    public static final String FEEDBACK_TYPE_REQUIRED = "请选择反馈类型";
    public static final String FEEDBACK_CONTENT_REQUIRED = "请填写反馈内容";

    // ==================== 标签 ====================
    public static final String TAG_DUPLICATE_IN_SUBJECT = "该科目下已存在同名标签";

    // ==================== 用户 ====================
    public static final String USERNAME_ALREADY_EXISTS = "用户名已存在";

    // ==================== 系统配置 ====================
    public static final String CONFIG_NOT_FOUND = "配置不存在";
    public static final String CONFIG_VALUE_REQUIRED = "配置值不能为空";
    public static final String CONFIG_NOT_FOUND_OR_UPDATE_FAILED = "配置不存在或更新失败";
    public static final String CONFIG_KEY_REQUIRED = "配置键不能为空";
    public static final String CONFIG_UPDATE_FAILED = "更新失败";
    public static final String CONFIG_KEY_VALUE_REQUIRED = "配置键和配置值不能为空";
    public static final String CONFIG_KEY_ALREADY_EXISTS = "配置键已存在";

    // ==================== 报告与日志 ====================
    public static final String REPORT_NOT_FOUND = "报告不存在";
    public static final String LOG_NOT_FOUND = "日志不存在";

    // ==================== 学习相关 ====================
    public static final String UNKNOWN_SUBJECT = "未知科目";
    public static final String CARD_DELETED = "卡片已删除";
    public static final String STUDY_CARD = "学习卡片";
    public static final String MASTER_CARD = "掌握卡片";
    public static final String GENERIC_TAG = "通用标签";
    public static final String NO_DATA = "无数据";

    // ==================== AI ====================
    public static final String AI_REFER_TEXTBOOK = "请参考教材解析";
    public static final String AI_GENERATED = "AI生成";

    // ==================== 冲刺 ====================
    public static final String DEFAULT_EXAM_NAME = "考研冲刺";

    // ==================== 审批 ====================
    public static final String AUDIT_APPROVED = "审批通过，已添加到知识库";
    public static final String AUDIT_REJECTED = "审批拒绝";

    // ==================== 请先登录（带操作描述） ====================
    public static final String PLEASE_LOGIN_SUBMIT_CARD = "请先登录后再提交卡片";
    public static final String PLEASE_LOGIN_VIEW_CARDS = "请先登录后再查看我的卡片";
    public static final String PLEASE_LOGIN_EDIT_CARD = "请先登录后再修改卡片";
    public static final String PLEASE_LOGIN_DELETE_CARD = "请先登录后再删除卡片";
    public static final String PLEASE_LOGIN_VIEW_STATS = "请先登录后再查看统计";
    public static final String PLEASE_LOGIN_SUBMIT_COMMENT = "请先登录后再提交评论";
    public static final String PLEASE_LOGIN_SUBMIT_FEEDBACK = "请先登录后再提交反馈";
    public static final String PLEASE_LOGIN_REPLY = "请先登录后再回复";

    // ==================== 建议（报告） ====================
    public static final String SUGGESTION_MASTERY_LOW = "掌握率偏低(%d%%)，建议加强复习";
    public static final String SUGGESTION_MASTERY_MEDIUM = "掌握率有待提高(%d%%)，建议增加练习";
    public static final String SUGGESTION_WEAK_CARD = "「%s」错误%d次，建议重新学习后重试";
    public static final String SUGGESTION_KEEP_RHYTHM = "保持当前学习节奏，连续学习有助于记忆巩固";
    public static final String SUGGESTION_LOW_FREQUENCY = "学习频率较低，建议每天保持一定的学习量";
    public static final String SUGGESTION_KEEP_HABIT = "继续保持良好的学习习惯";

    // ==================== 星期（报告） ====================
    public static final String DAY_MONDAY = "周一";
    public static final String DAY_TUESDAY = "周二";
    public static final String DAY_WEDNESDAY = "周三";
    public static final String DAY_THURSDAY = "周四";
    public static final String DAY_FRIDAY = "周五";
    public static final String DAY_SATURDAY = "周六";
    public static final String DAY_SUNDAY = "周日";

    // ==================== 等级名称（激励） ====================
    public static final String[] LEVEL_NAMES = {
        "", "入门学徒", "初出茅庐", "勤学苦练", "小有所成", "学富五车",
        "融会贯通", "登堂入室", "炉火纯青", "博学多才", "学贯中西"
    };

    // ==================== 邮件主题和模板 ====================
    public static final String EMAIL_SUBJECT_REGISTER = "【考研学习卡片】注册验证码";
    public static final String EMAIL_SUBJECT_ACTIVATE = "【考研学习卡片】邮箱激活 - 请在24小时内完成";
    public static final String EMAIL_SUBJECT_RESET = "【考研学习卡片】重置密码验证码";

    public static final String EMAIL_BODY_REGISTER_TEMPLATE =
        "您好！\n\n您的注册验证码为: %s\n验证码5分钟内有效，请勿泄露给他人。\n\n如果不是您本人操作，请忽略此邮件。";

    public static final String EMAIL_BODY_ACTIVATE_TEMPLATE =
        "您好，%s！\n\n您注册的邮箱是: %s\n请点击以下链接激活账号:\n\n%s\n链接有效期: 24小时\n\n如果无法点击，请复制链接到浏览器打开。\n\n如果不是您本人操作，请忽略此邮件。";

    public static final String EMAIL_BODY_RESET_TEMPLATE =
        "您好！\n\n您申请重置密码，验证码为: %s\n验证码5分钟内有效，请勿泄露给他人。\n\n如果不是您本人操作，请立即联系管理员。";

    // ==================== API文档 ====================
    public static final String API_DOC_TITLE = "考研知识点学习卡片系统API文档";

    // ==================== 批量操作 ====================
    public static final String BATCH_APPROVE_TEMPLATE = "批量审批完成，成功通过%d张卡片";
    public static final String BATCH_REJECT_TEMPLATE = "批量拒绝完成，成功拒绝%d张卡片";

    // ==================== 内容审核 ====================
    public static final String POOR_CONTENT_PREFIX = "用户标记为劣质内容：";

    // ==================== 标签 fallback ====================
    public static final String TAG_PREFIX = "标签";
}
