package com.card.learn.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 小程序用户信息表
 */
@Data
@TableName("sys_app_user")
public class SysAppUser implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "app_user_id", type = IdType.AUTO)
    private Long appUserId;

    private String openid;

    private String unionid;

    private String nickname;

    private String avatar;

    private LocalDateTime lastLoginTime;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

}