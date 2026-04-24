package com.card.learn.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.common.Result;
import com.card.learn.entity.BizCard;
import com.card.learn.entity.BizTag;
import com.card.learn.service.IBizCardService;
import com.card.learn.service.IBizCardTagService;
import com.card.learn.vo.CardVO;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 知识点卡片控制器
 */
@RestController
@RequestMapping("/card")
@Api(tags = "知识点卡片管理")
public class BizCardController {

    @Autowired
    private IBizCardService cardService;

    @Autowired
    private IBizCardTagService cardTagService;

    @GetMapping("/page")
    @ApiOperation("分页查询卡片")
    public Result<Page<CardVO>> page(
            @RequestParam(required = false) Long subjectId,
            @RequestParam(required = false) String frontContent,
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        return Result.success(cardService.pageCardsWithSubjectName(subjectId, frontContent, pageNum, pageSize));
    }

    @GetMapping("/{id}")
    @ApiOperation("获取卡片详情")
    public Result<BizCard> getById(@PathVariable Long id) {
        return Result.success(cardService.getById(id));
    }

    @GetMapping("/{id}/tags")
    @ApiOperation("获取卡片的标签列表")
    public Result<List<BizTag>> getCardTags(@PathVariable Long id) {
        return Result.success(cardTagService.getTagsByCardId(id));
    }

    @PostMapping
    @ApiOperation("新增卡片")
    public Result<Long> save(@RequestBody BizCard card) {
        cardService.save(card);
        return Result.success(card.getCardId());
    }

    @PutMapping
    @ApiOperation("更新卡片")
    public Result<Void> update(@RequestBody BizCard card) {
        cardService.updateById(card);
        return Result.success();
    }

    @PutMapping("/{id}/tags")
    @ApiOperation("设置卡片的标签")
    public Result<Void> setCardTags(@PathVariable Long id, @RequestBody List<Long> tagIds) {
        cardTagService.setCardTags(id, tagIds);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    @ApiOperation("删除卡片")
    public Result<Void> delete(@PathVariable Long id) {
        cardService.removeById(id);
        return Result.success();
    }

}