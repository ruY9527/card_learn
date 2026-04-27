package com.card.learn.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.common.Result;
import com.card.learn.entity.BizFeedback;
import com.card.learn.service.IBizFeedbackService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 小程序端反馈控制器（需要登录）
 */
@RestController
@RequestMapping("/api/miniprogram/feedback")
@Api(tags = "小程序反馈接口（需登录）")
public class MiniFeedbackController {

    @Autowired
    private IBizFeedbackService feedbackService;

    /**
     * 提交反馈
     */
    @PostMapping
    @ApiOperation("提交反馈")
    public Result<Void> submitFeedback(@RequestBody BizFeedback feedback) {
        if (feedback.getUserId() == null) {
            return Result.error("请先登录后再提交反馈");
        }
        if (feedback.getType() == null || feedback.getType().isEmpty()) {
            return Result.error("请选择反馈类型");
        }
        if (feedback.getContent() == null || feedback.getContent().isEmpty()) {
            return Result.error("请填写反馈内容");
        }
        feedback.setStatus("0"); // 默认待处理
        feedbackService.save(feedback);
        return Result.success();
    }

    /**
     * 获取用户自己的反馈列表
     */
    @GetMapping("/list")
    @ApiOperation("获取用户反馈列表")
    public Result<Page<BizFeedback>> getUserFeedbackList(
            @RequestParam Long userId,
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        Page<BizFeedback> page = feedbackService.pageUserFeedback(userId, pageNum, pageSize);
        return Result.success(page);
    }

    /**
     * 获取反馈详情
     */
    @GetMapping("/{id}")
    @ApiOperation("获取反馈详情")
    public Result<BizFeedback> getFeedbackDetail(@PathVariable Long id) {
        BizFeedback feedback = feedbackService.getById(id);
        if (feedback == null) {
            return Result.error("反馈不存在");
        }
        return Result.success(feedback);
    }

}