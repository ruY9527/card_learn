package com.card.learn.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.common.Result;
import com.card.learn.entity.BizCardComment;
import com.card.learn.mapper.CommentStats;
import com.card.learn.service.IBizCardCommentService;
import com.card.learn.vo.CommentVO;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 小程序评论Controller
 */
@RestController
@RequestMapping("/api/miniprogram/comment")
@Api(tags = "小程序评论")
public class MiniCommentController {

    @Autowired
    private IBizCardCommentService commentService;

    /**
     * 提交评论
     */
    @PostMapping("/submit")
    @ApiOperation("提交评论")
    public Result<Long> submit(@RequestBody BizCardComment comment) {
        if (comment.getUserId() == null) {
            return Result.error("请先登录后再提交评论");
        }

        BizCardComment saved = commentService.submitComment(comment);
        return Result.success(saved.getCommentId());
    }

    /**
     * 获取卡片评论列表
     */
    @GetMapping("/list/{cardId}")
    @ApiOperation("获取卡片评论列表")
    public Result<Page<CommentVO>> list(
            @PathVariable Long cardId,
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        return Result.success(commentService.pageComments(cardId, null, "0", pageNum, pageSize));
    }

    /**
     * 获取卡片评论统计
     */
    @GetMapping("/stats/{cardId}")
    @ApiOperation("获取卡片评论统计")
    public Result<CommentStats> stats(@PathVariable Long cardId) {
        return Result.success(commentService.getCommentStats(cardId));
    }

    private Long parseUserId(String userId) {
        if (userId == null || userId.isEmpty()) {
            return null;
        }
        try {
            return Long.parseLong(userId);
        } catch (NumberFormatException e) {
            return null;
        }
    }
}