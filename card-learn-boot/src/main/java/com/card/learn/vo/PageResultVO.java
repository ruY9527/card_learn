package com.card.learn.vo;

import lombok.Data;

import java.io.Serializable;
import java.util.List;

/**
 * 通用分页结果VO
 */
@Data
public class PageResultVO<T> implements Serializable {

    private static final long serialVersionUID = 1L;

    private List<T> records;
    private Long total;
    private Long current;
    private Long size;

    public PageResultVO() {}

    public PageResultVO(List<T> records, Long total, Long current, Long size) {
        this.records = records;
        this.total = total;
        this.current = current;
        this.size = size;
    }
}
