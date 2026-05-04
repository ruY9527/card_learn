package com.card.learn.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import com.fasterxml.jackson.annotation.JsonFormat;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 菜单权限表
 */
@Data
@TableName("sys_menu")
public class SysMenu implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "menu_id", type = IdType.AUTO)
    private Long menuId;

    private String menuName;

    /** 父菜单ID */
    private Long parentId;

    /** 显示顺序 */
    private Integer orderNum;

    /** 路由地址 */
    private String path;

    /** 组件路径 */
    private String component;

    /** 权限标识 */
    private String perms;

    /** 菜单类型（M目录 C菜单 F按钮） */
    private String menuType;

    @TableField(fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;

    /** 子菜单（非数据库字段） */
    @TableField(exist = false)
    private List<SysMenu> children;


    /** 创建人 */
    private Long createBy;

    /** 修改人 */
    private Long updateBy;
}
