package com.card.learn.dto;

import lombok.Data;

import java.io.Serializable;
import java.util.List;

/**
 * 小程序专业DTO
 */
@Data
public class MiniMajorDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long majorId;
    private String majorName;
    private String description;

}