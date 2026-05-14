package com.card.learn.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.common.AppMessages;
import com.card.learn.common.Result;
import com.card.learn.dto.RequestLogQueryDTO;
import com.card.learn.entity.SysRequestLog;
import com.card.learn.service.ISysRequestLogService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import com.card.learn.vo.PageResultVO;
import com.card.learn.vo.RequestLogStatsVO;

/**
 * 系统请求日志管理Controller
 */
@RestController
@RequestMapping("/system/request-log")
@Api(tags = "请求日志管理")
public class SysRequestLogController {

    @Autowired
    private ISysRequestLogService requestLogService;

    /**
     * 分页查询日志列表
     */
    @GetMapping("/list")
    @ApiOperation("分页查询日志列表")
    public Result<PageResultVO<SysRequestLog>> pageLogs(RequestLogQueryDTO queryDTO) {
        Page<SysRequestLog> page = requestLogService.pageLogs(queryDTO);

        PageResultVO<SysRequestLog> result = new PageResultVO<>(page.getRecords(), page.getTotal(), page.getCurrent(), page.getSize());
        return Result.success(result);
    }

    /**
     * 查询日志详情
     */
    @GetMapping("/{id}")
    @ApiOperation("查询日志详情")
    public Result<SysRequestLog> getLogById(@PathVariable Long id) {
        SysRequestLog log = requestLogService.getById(id);
        if (log == null) {
            return Result.error(AppMessages.LOG_NOT_FOUND);
        }
        return Result.success(log);
    }

    /**
     * 清理历史日志
     */
    @PostMapping("/clean")
    @ApiOperation("清理历史日志")
    public Result<Integer> cleanLogs(@RequestParam(defaultValue = "30") Integer days) {
        int count = requestLogService.cleanLogs(days);
        return Result.success(count);
    }

    /**
     * 获取日志统计信息
     */
    @GetMapping("/stats")
    @ApiOperation("获取日志统计信息")
    public Result<RequestLogStatsVO> getStats() {
        RequestLogStatsVO stats = new RequestLogStatsVO();

        // 总日志数
        stats.setTotal(requestLogService.count());

        // 成功日志数
        long successCount = requestLogService.lambdaQuery()
                .eq(SysRequestLog::getStatus, "1")
                .count();
        stats.setSuccess(successCount);

        // 失败日志数
        long failCount = requestLogService.lambdaQuery()
                .eq(SysRequestLog::getStatus, "0")
                .count();
        stats.setFail(failCount);

        // 今日日志数
        long todayCount = requestLogService.lambdaQuery()
                .ge(SysRequestLog::getCreateTime, java.time.LocalDateTime.now().toLocalDate().atStartOfDay())
                .count();
        stats.setToday(todayCount);

        return Result.success(stats);
    }

}