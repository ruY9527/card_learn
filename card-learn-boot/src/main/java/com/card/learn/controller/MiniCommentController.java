package com.card.learn.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.common.AppMessages;
import com.card.learn.common.Result;
import com.card.learn.dto.CommentQueryDTO;
import com.card.learn.dto.NoteQueryDTO;
import com.card.learn.entity.BizCardComment;
import com.card.learn.mapper.CommentStats;
import com.card.learn.service.IBizCardCommentService;
import com.card.learn.vo.CommentVO;
import com.card.learn.vo.NoteVO;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 小程序评论/笔记Controller
 */
@RestController
@RequestMapping("/api/miniprogram")
@Api(tags = "小程序评论/笔记")
public class MiniCommentController {

    @Autowired
    private IBizCardCommentService commentService;

    /**
     * 提交评论（可同时标记为笔记）
     */
    @PostMapping("/comment/submit")
    @ApiOperation("提交评论")
    public Result<Long> submit(@RequestBody BizCardComment comment) {
        if (comment.getUserId() == null) {
            return Result.error(AppMessages.PLEASE_LOGIN_SUBMIT_COMMENT);
        }
        BizCardComment saved = commentService.submitComment(comment);
        return Result.success(saved.getCommentId());
    }

    /**
     * 获取卡片评论列表
     */
    @GetMapping("/comment/list/{cardId}")
    @ApiOperation("获取卡片评论列表")
    public Result<Page<CommentVO>> list(@PathVariable Long cardId, CommentQueryDTO queryDTO,
                                        @RequestParam(required = false) Long userId) {
        queryDTO.setCardId(cardId);
        queryDTO.setStatus("0");
        return Result.success(commentService.pageComments(queryDTO, userId));
    }

    /**
     * 获取卡片评论统计
     */
    @GetMapping("/comment/stats/{cardId}")
    @ApiOperation("获取卡片评论统计")
    public Result<CommentStats> stats(@PathVariable Long cardId) {
        return Result.success(commentService.getCommentStats(cardId));
    }

    /**
     * 获取我的笔记列表
     */
    @GetMapping("/note/my")
    @ApiOperation("获取我的笔记列表")
    public Result<Page<NoteVO>> myNotes(NoteQueryDTO queryDTO) {
        if (queryDTO.getUserId() == null) {
            return Result.error(AppMessages.PLEASE_LOGIN_FIRST);
        }
        return Result.success(commentService.pageMyNotes(queryDTO));
    }

    /**
     * 编辑笔记
     */
    @PutMapping("/note/{noteId}")
    @ApiOperation("编辑笔记")
    public Result<Void> editNote(@PathVariable Long noteId, @RequestParam Long userId, @RequestBody String content) {
        commentService.editNote(noteId, userId, content);
        return Result.success();
    }

    /**
     * 删除笔记
     */
    @DeleteMapping("/note/{noteId}")
    @ApiOperation("删除笔记")
    public Result<Void> deleteNote(@PathVariable Long noteId, @RequestParam Long userId) {
        commentService.deleteNote(noteId, userId);
        return Result.success();
    }

    /**
     * 导出笔记
     */
    @GetMapping("/note/export")
    @ApiOperation("导出笔记")
    public Result<String> exportNotes(NoteQueryDTO queryDTO) {
        if (queryDTO.getUserId() == null) {
            return Result.error(AppMessages.PLEASE_LOGIN_FIRST);
        }
        queryDTO.setPageSize(1000);
        Page<NoteVO> page = commentService.pageMyNotes(queryDTO);
        StringBuilder sb = new StringBuilder();
        for (NoteVO note : page.getRecords()) {
            sb.append("## ").append(note.getCardFrontContent()).append("\n\n");
            sb.append(note.getContent()).append("\n\n");
            sb.append("---\n\n");
        }
        return Result.success(sb.toString());
    }
}
