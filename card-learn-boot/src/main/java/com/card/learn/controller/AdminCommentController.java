package com.card.learn.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.common.Result;
import com.card.learn.dto.CommentQueryDTO;
import com.card.learn.service.IBizCardCommentService;
import com.card.learn.vo.CommentVO;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 评论管理Controller（管理员）
 */
@RestController
@RequestMapping("/admin/comment")
@Api(tags = "评论管理")
public class AdminCommentController {

    @Autowired
    private IBizCardCommentService commentService;

    /**
     * 分页查询评论列表
     */
    @GetMapping("/page")
    @ApiOperation("分页查询评论列表")
    public Result<Page<CommentVO>> page(CommentQueryDTO queryDTO) {
        return Result.success(commentService.pageComments(queryDTO));
    }

    /**
     * 管理员回复评论
     */
    @PostMapping("/reply/{commentId}")
    @ApiOperation("管理员回复评论")
    public Result<Void> reply(@PathVariable Long commentId, @RequestBody String reply) {
        commentService.adminReply(commentId, reply);
        return Result.success();
    }

    /**
     * 处理评论
     */
    @PostMapping("/handle/{commentId}")
    @ApiOperation("处理评论")
    public Result<Void> handle(@PathVariable Long commentId, @RequestParam String status) {
        commentService.handleComment(commentId, status);
        return Result.success();
    }

    /**
     * 删除评论
     */
    @DeleteMapping("/{commentId}")
    @ApiOperation("删除评论")
    public Result<Void> delete(@PathVariable Long commentId) {
        commentService.removeById(commentId);
        return Result.success();
    }
}