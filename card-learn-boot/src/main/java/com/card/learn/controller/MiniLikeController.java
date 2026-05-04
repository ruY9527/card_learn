package com.card.learn.controller;

import com.card.learn.common.Result;
import com.card.learn.service.IBizCommentLikeService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 小程序点赞Controller
 */
@RestController
@RequestMapping("/api/miniprogram/like")
@Api(tags = "小程序点赞")
public class MiniLikeController {

    @Autowired
    private IBizCommentLikeService likeService;

    /**
     * 切换评论点赞/踩状态
     * @param likeType 1=喜欢, 2=不喜欢
     * @return 0=取消, 1=喜欢, 2=不喜欢
     */
    @PostMapping("/comment/{commentId}")
    @ApiOperation("切换评论点赞状态")
    public Result<Integer> likeComment(@PathVariable Long commentId,
                                       @RequestParam Long userId,
                                       @RequestParam Integer likeType) {
        int result = likeService.toggleCommentLike(commentId, userId, likeType);
        return Result.success(result);
    }

    /**
     * 切换回复点赞/踩状态
     * @param likeType 1=喜欢, 2=不喜欢
     * @return 0=取消, 1=喜欢, 2=不喜欢
     */
    @PostMapping("/reply/{replyId}")
    @ApiOperation("切换回复点赞状态")
    public Result<Integer> likeReply(@PathVariable Long replyId,
                                     @RequestParam Long userId,
                                     @RequestParam Integer likeType) {
        int result = likeService.toggleReplyLike(replyId, userId, likeType);
        return Result.success(result);
    }
}
