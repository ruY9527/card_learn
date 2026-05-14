package com.card.learn.vo;

import lombok.Data;

import java.io.Serializable;
import java.util.List;

/**
 * 某日学习详情VO
 */
@Data
public class DayLearnDetailVO implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 日期 (yyyy-MM-dd) */
    private String date;

    /** 当日学习总次数 */
    private Integer totalCount;

    /** 掌握数量 */
    private Integer masteredCount;

    /** 模糊数量 */
    private Integer fuzzyCount;

    /** 不熟数量 */
    private Integer againCount;

    /** 当日学习的卡片列表 */
    private List<DayCardItem> cards;

    /**
     * 当日学习的单张卡片信息
     */
    @Data
    public static class DayCardItem implements Serializable {

        private static final long serialVersionUID = 1L;

        private Long cardId;
        private String frontContent;
        private String subjectName;
        /** 状态 0未学/1模糊/2掌握 */
        private Integer status;
        /** 学习来源: web/ios/mini */
        private String source;
        /** 学习时间 HH:mm */
        private String studyTime;
    }
}
