package com.card.learn.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;

/**
 * 角色和菜单关联表
 */
@Data
@TableName("sys_role_menu")
public class SysRoleMenu implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 使用roleId作为虚拟主键（实际为复合主键）
     * 设置为INPUT类型，不自动生成
     */
    @TableId(type = IdType.INPUT)
    private Long roleId;

    private Long menuId;

}