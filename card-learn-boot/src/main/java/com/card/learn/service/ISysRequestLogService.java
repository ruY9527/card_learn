package com.card.learn.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.card.learn.entity.SysRequestLog;

/**
 * 系统请求日志Service
 */
public interface ISysRequestLogService extends IService<SysRequestLog> {

    /**
     * 异步保存请求日志（不影响主业务流程）
     * @param log 日志对象
     */
    void saveLogAsync(SysRequestLog log);

    /**
     * 分页查询日志
     * @param pageNum 页码
     * @param pageSize 每页数量
     * @param requestMethod 请求方法
     * @param requestUrl 请求URL
     * @param status 执行状态
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @return 分页结果
     */
    Page<SysRequestLog> pageLogs(Integer pageNum, Integer pageSize, String requestMethod, 
                                  String requestUrl, String status, String startTime, String endTime);

    /**
     * 清理指定天数之前的日志
     * @param days 天数
     * @return 删除数量
     */
    int cleanLogs(int days);

}