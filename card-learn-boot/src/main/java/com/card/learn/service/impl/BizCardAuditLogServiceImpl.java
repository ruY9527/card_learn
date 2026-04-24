package com.card.learn.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.card.learn.entity.BizCardAuditLog;
import com.card.learn.mapper.BizCardAuditLogMapper;
import com.card.learn.service.IBizCardAuditLogService;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

/**
 * 卡片审批历史日志Service实现
 */
@Service
public class BizCardAuditLogServiceImpl extends ServiceImpl<BizCardAuditLogMapper, BizCardAuditLog> implements IBizCardAuditLogService {

    @Override
    public void saveAuditLog(Long draftId, Long cardId, String auditStatus, Long auditUserId, String auditRemark) {
        BizCardAuditLog log = new BizCardAuditLog();
        log.setDraftId(draftId);
        log.setCardId(cardId);
        log.setAuditStatus(auditStatus);
        log.setAuditUserId(auditUserId);
        log.setAuditRemark(auditRemark);
        log.setAuditTime(LocalDateTime.now());
        
        save(log);
    }

}