package com.card.learn.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import com.fasterxml.jackson.annotation.JsonFormat;
import java.time.LocalDateTime;

/**
 * 操作日志表
 */
@Data
@TableName("sys_oper_log")
public class SysOperLog implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "oper_id", type = IdType.AUTO)
    private Long operId;

    /** 模块标题 */
    private String title;

    /** 业务类型（0其它 1新增 2修改 3删除） */
    private Integer businessType;

    /** 方法名称 */
    private String method;

    /** 请求方式 */
    private String requestMethod;

    /** 操作类别（0其它 1后台用户 2手机端用户） */
    private Integer operatorType;

    /** 操作人员 */
    private String operName;

    /** 请求URL */
    private String operUrl;

    /** 请求参数 */
    private String operParam;

    /** 返回结果 */
    private String jsonResult;

    /** 操作状态（0正常 1异常） */
    private Integer status;

    /** 错误消息 */
    private String errorMsg;

    /** 操作时间 */
    @TableField(fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime operTime;


    /** 创建人 */
    private Long createBy;

    /** 修改人 */
    private Long updateBy;
}
