package com.card.learn.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import com.fasterxml.jackson.annotation.JsonFormat;
import java.time.LocalDateTime;

/**
 * 系统请求日志实体
 */
@Data
@TableName("sys_request_log")
public class SysRequestLog implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /** 请求方法(GET/POST/PUT/DELETE) */
    private String requestMethod;

    /** 请求URL */
    private String requestUrl;

    /** 类名 */
    private String className;

    /** 方法名 */
    private String methodName;

    /** 请求参数(JSON) */
    private String requestParams;

    /** 响应结果(JSON) */
    private String responseResult;

    /** 执行耗时(毫秒) */
    private Long executionTime;

    /** 执行状态(1成功 0失败) */
    private String status;

    /** 错误信息 */
    private String errorMsg;

    /** 请求IP地址 */
    private String ipAddress;

    /** 操作用户ID */
    private Long userId;

    /** 操作用户名 */
    private String userName;

    /** 创建时间 */
    @TableField(fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;


    /** 创建人 */
    private Long createBy;

    /** 修改人 */
    private Long updateBy;
}
