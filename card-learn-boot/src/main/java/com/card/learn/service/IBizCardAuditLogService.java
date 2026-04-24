package com.card.learn.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.card.learn.entity.BizCardAuditLog;

/**
 * 卡片审批历史日志Service
 */
public interface IBizCardAuditLogService extends IService<BizCardAuditLog> {

    /**
     * 记录审批日志
     */
    void saveAuditLog(Long draftId, Long cardId, String auditStatus, Long auditUserId, String auditRemark);

}