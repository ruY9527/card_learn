package com.card.learn.vo;

import lombok.Data;

/**
 * 与上期对比VO
 */
@Data
public class ComparisonVO {

    /** 学习卡片数变化百分比 */
    private String totalCardsChange;

    /** 新掌握卡片数变化百分比 */
    private String newMasteredChange;

    /** 遗忘卡片数变化百分比 */
    private String forgottenChange;
}
