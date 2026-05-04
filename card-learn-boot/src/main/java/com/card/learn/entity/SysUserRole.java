package com.card.learn.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;

/**
 * 用户和角色关联表
 */
@Data
@TableName("sys_user_role")
public class SysUserRole implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 使用userId作为虚拟主键（实际为复合主键）
     * 设置为INPUT类型，不自动生成
     */
    @TableId(type = IdType.INPUT)
    private Long userId;

    private Long roleId;


    /** 创建人 */
    private Long createBy;

    /** 修改人 */
    private Long updateBy;
}
