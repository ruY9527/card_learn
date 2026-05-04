package com.card.learn.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.common.Result;
import com.card.learn.dto.AdminReviewPlanQueryDTO;
import com.card.learn.dto.DeviceRegisterDTO;
import com.card.learn.dto.SimpleReviewDTO;
import com.card.learn.dto.SM2ReviewDTO;
import com.card.learn.service.ILearningService;
import com.card.learn.vo.*;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 学习服务Controller（SM-2、复习计划、统计）
 */
@RestController
@RequestMapping("/api/learning")
@Api(tags = "学习服务")
public class LearningController {

    @Autowired
    private ILearningService learningService;

    @GetMapping("/sm2/progress")
    @ApiOperation("获取用户SM-2进度")
    public Result<SM2ProgressVO> getSM2Progress(@RequestParam Long userId, @RequestParam Long cardId) {
        return Result.success(learningService.getSM2Progress(userId, cardId));
    }

    @PostMapping("/review")
    @ApiOperation("提交复习结果")
    public Result<Void> submitReview(@Validated @RequestBody SM2ReviewDTO dto) {
        learningService.submitReview(dto);
        return Result.success();
    }

    @PostMapping("/review/simple")
    @ApiOperation("简化复习提交（服务端自动计算SM-2）")
    public Result<ReviewResultVO> submitSimpleReview(@Validated @RequestBody SimpleReviewDTO dto) {
        return Result.success(learningService.submitSimpleReview(dto));
    }

    @GetMapping("/plan")
    @ApiOperation("获取复习计划")
    public Result<List<ReviewPlanVO>> getReviewPlan(@RequestParam Long userId) {
        return Result.success(learningService.getReviewPlan(userId));
    }

    @GetMapping("/subject-progress")
    @ApiOperation("获取科目进度")
    public Result<List<SubjectProgressVO>> getSubjectProgress(@RequestParam Long userId) {
        return Result.success(learningService.getSubjectProgress(userId));
    }

    @GetMapping("/stats")
    @ApiOperation("获取学习统计")
    public Result<UserStreakVO> getLearningStats(@RequestParam Long userId) {
        return Result.success(learningService.getLearningStats(userId));
    }

    @PostMapping("/device/register")
    @ApiOperation("注册设备")
    public Result<Void> registerDevice(@Validated @RequestBody DeviceRegisterDTO dto) {
        learningService.registerDevice(dto);
        return Result.success();
    }

    @GetMapping("/admin/review-plan")
    @ApiOperation("管理端-查询复习计划")
    public Result<Page<AdminReviewPlanVO>> getAdminReviewPlan(AdminReviewPlanQueryDTO queryDTO) {
        return Result.success(learningService.getAdminReviewPlan(queryDTO));
    }
}
