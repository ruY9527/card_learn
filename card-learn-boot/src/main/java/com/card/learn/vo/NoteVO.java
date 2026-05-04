package com.card.learn.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 笔记视图对象
 */
@Data
public class NoteVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long commentId;

    /** 卡片ID */
    private Long cardId;

    /** 卡片正面内容 */
    private String cardFrontContent;

    /** 科目名称 */
    private String subjectName;

    /** 用户ID */
    private Long userId;

    /** 用户昵称 */
    private String userNickname;

    /** 笔记内容 */
    private String content;

    /** 评分 */
    private Integer rating;

    /** 点赞数 */
    private Integer likeCount;

    /** 回复数 */
    private Integer replyCount;

    /** 创建时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;

    /** 更新时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;
}
