package com.card.learn.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.common.AppMessages;
import com.card.learn.common.Result;
import com.card.learn.entity.BizCardReply;
import com.card.learn.service.IBizCardReplyService;
import com.card.learn.vo.ReplyVO;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 小程序回复Controller
 */
@RestController
@RequestMapping("/api/miniprogram/reply")
@Api(tags = "小程序回复")
public class MiniReplyController {

    @Autowired
    private IBizCardReplyService replyService;

    /**
     * 提交回复
     */
    @PostMapping("/{commentId}")
    @ApiOperation("提交回复")
    public Result<Long> submit(@PathVariable Long commentId, @RequestBody BizCardReply reply) {
        if (reply.getUserId() == null) {
            return Result.error(AppMessages.PLEASE_LOGIN_REPLY);
        }
        reply.setCommentId(commentId);
        BizCardReply saved = replyService.submitReply(reply);
        return Result.success(saved.getReplyId());
    }

    /**
     * 获取评论的回复列表（懒加载）
     */
    @GetMapping("/list/{commentId}")
    @ApiOperation("获取回复列表")
    public Result<Page<ReplyVO>> list(@PathVariable Long commentId,
                                      @RequestParam(required = false) Long userId,
                                      @RequestParam(defaultValue = "1") Integer pageNum,
                                      @RequestParam(defaultValue = "10") Integer pageSize) {
        return Result.success(replyService.pageReplies(commentId, userId, pageNum, pageSize));
    }

    /**
     * 获取子回复列表
     */
    @GetMapping("/children/{parentReplyId}")
    @ApiOperation("获取子回复列表")
    public Result<List<ReplyVO>> children(@PathVariable Long parentReplyId,
                                          @RequestParam(required = false) Long userId) {
        return Result.success(replyService.getChildrenReplies(parentReplyId, userId));
    }

    /**
     * 删除回复
     */
    @DeleteMapping("/{replyId}")
    @ApiOperation("删除回复")
    public Result<Void> delete(@PathVariable Long replyId, @RequestParam Long userId) {
        replyService.deleteReply(replyId, userId);
        return Result.success();
    }
}
