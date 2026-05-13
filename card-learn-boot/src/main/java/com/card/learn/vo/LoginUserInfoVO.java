package com.card.learn.vo;

import com.card.learn.entity.SysMenu;
import lombok.Data;

import java.io.Serializable;
import java.util.List;

/**
 * 登录用户信息VO
 */
@Data
public class LoginUserInfoVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long userId;
    private String username;
    private String nickname;
    private String email;
    private String avatar;
    private List<String> roles;
    private List<SysMenu> menus;
}
