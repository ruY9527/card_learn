package com.card.learn.vo;

import lombok.Data;

/**
 * 薄弱点VO
 */
@Data
public class WeakPointVO {

    /** 卡片ID */
    private Long cardId;

    /** 科目名称 */
    private String subjectName;

    /** 卡片正面内容(截断) */
    private String frontContent;

    /** 错误次数 */
    private Integer errorCount;

    /** 最后错误时间 */
    private String lastErrorTime;
}
