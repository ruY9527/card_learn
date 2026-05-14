package com.card.learn.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.common.AppMessages;
import com.card.learn.common.Result;
import com.card.learn.dto.FeedbackQueryDTO;
import com.card.learn.entity.BizFeedback;
import com.card.learn.service.IBizFeedbackService;
import com.card.learn.vo.FeedbackVO;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 管理端反馈控制器
 */
@RestController
@RequestMapping("/feedback")
@Api(tags = "反馈管理")
public class AdminFeedbackController {

    @Autowired
    private IBizFeedbackService feedbackService;

    /**
     * 分页查询反馈列表
     */
    @GetMapping("/page")
    @ApiOperation("分页查询反馈")
    public Result<Page<FeedbackVO>> page(FeedbackQueryDTO queryDTO) {
        return Result.success(feedbackService.pageFeedback(queryDTO));
    }

    /**
     * 获取反馈详情
     */
    @GetMapping("/{id}")
    @ApiOperation("获取反馈详情")
    public Result<BizFeedback> getById(@PathVariable Long id) {
        BizFeedback feedback = feedbackService.getById(id);
        if (feedback == null) {
            return Result.error(AppMessages.FEEDBACK_NOT_FOUND);
        }
        return Result.success(feedback);
    }

    /**
     * 处理反馈（更新状态和回复）
     */
    @PutMapping("/{id}/process")
    @ApiOperation("处理反馈")
    public Result<Void> processFeedback(
            @PathVariable Long id,
            @RequestParam String status,
            @RequestParam(required = false) String adminReply) {
        feedbackService.processFeedback(id, status, adminReply);
        return Result.success();
    }

    /**
     * 删除反馈
     */
    @DeleteMapping("/{id}")
    @ApiOperation("删除反馈")
    public Result<Void> delete(@PathVariable Long id) {
        feedbackService.removeById(id);
        return Result.success();
    }

    /**
     * 获取待处理反馈数量
     */
    @GetMapping("/pending/count")
    @ApiOperation("获取待处理反馈数量")
    public Result<Long> getPendingCount() {
        long count = feedbackService.lambdaQuery()
                .eq(BizFeedback::getStatus, "0")
                .count();
        return Result.success(count);
    }

}