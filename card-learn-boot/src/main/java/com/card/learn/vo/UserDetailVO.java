package com.card.learn.vo;

import com.card.learn.entity.SysRole;
import com.card.learn.entity.SysUser;
import lombok.Data;

import java.io.Serializable;
import java.util.List;

/**
 * 用户详情VO（包含角色信息）
 */
@Data
public class UserDetailVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private SysUser user;
    private List<SysRole> roles;
}
