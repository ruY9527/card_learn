package com.card.learn.controller;

import com.card.learn.common.Result;
import com.card.learn.entity.BizUserProgress;
import com.card.learn.service.IBizUserProgressService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import com.card.learn.vo.ProgressStatsVO;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 用户学习进度控制器（小程序端公开接口）
 */
@RestController
@RequestMapping("/progress")
@Api(tags = "学习进度管理")
public class BizUserProgressController {

    @Autowired
    private IBizUserProgressService progressService;

    @PostMapping
    @ApiOperation("更新学习进度")
    public Result<Void> updateProgress(@RequestBody BizUserProgress progress) {
        // 设置更新时间
        progress.setUpdateTime(LocalDateTime.now());
        // 根据状态设置下次复习时间
        if (progress.getStatus() != null && progress.getStatus() > 0) {
            // 模糊状态3天后复习，掌握状态7天后复习
            int days = progress.getStatus() == 1 ? 3 : 7;
            progress.setNextReviewTime(LocalDateTime.now().plusDays(days));
        }
        
        // 查找是否已存在进度记录
        BizUserProgress existing = progressService.lambdaQuery()
                .eq(BizUserProgress::getCardId, progress.getCardId())
                .eq(BizUserProgress::getUserId, progress.getUserId())
                .one();
        
        if (existing != null) {
            // 更新已有记录
            progress.setId(existing.getId());
            progressService.updateById(progress);
        } else {
            // 新增记录
            progressService.save(progress);
        }
        
        return Result.success();
    }

    @GetMapping("/list")
    @ApiOperation("获取用户学习进度列表")
    public Result<List<BizUserProgress>> list(@RequestParam(required = false) Long userId) {
        List<BizUserProgress> list = progressService.lambdaQuery()
                .eq(userId != null, BizUserProgress::getUserId, userId)
                .list();
        return Result.success(list);
    }

    @GetMapping("/stats")
    @ApiOperation("获取学习统计数据")
    public Result<ProgressStatsVO> stats(@RequestParam(required = false) Long userId,
                                          @RequestParam(required = false) Long subjectId) {
        // 统计各状态数量
        long learnedCount = progressService.lambdaQuery()
                .eq(userId != null, BizUserProgress::getUserId, userId)
                .ge(BizUserProgress::getStatus, 1)
                .count();

        long masteredCount = progressService.lambdaQuery()
                .eq(userId != null, BizUserProgress::getUserId, userId)
                .eq(BizUserProgress::getStatus, 2)
                .count();

        long reviewCount = progressService.lambdaQuery()
                .eq(userId != null, BizUserProgress::getUserId, userId)
                .eq(BizUserProgress::getStatus, 1)
                .count();

        ProgressStatsVO stats = new ProgressStatsVO();
        stats.setLearnedCount(learnedCount);
        stats.setMasteredCount(masteredCount);
        stats.setReviewCount(reviewCount);

        return Result.success(stats);
    }

    @GetMapping("/needReview")
    @ApiOperation("获取待复习卡片列表")
    public Result<List<BizUserProgress>> needReview(@RequestParam(required = false) Long userId) {
        List<BizUserProgress> list = progressService.lambdaQuery()
                .eq(userId != null, BizUserProgress::getUserId, userId)
                .le(BizUserProgress::getNextReviewTime, LocalDateTime.now())
                .list();
        return Result.success(list);
    }

}