package com.card.learn.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.common.Result;
import com.card.learn.entity.BizCard;
import com.card.learn.service.IBizCardService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 知识点卡片控制器
 */
@RestController
@RequestMapping("/card")
@Api(tags = "知识点卡片管理")
public class BizCardController {

    @Autowired
    private IBizCardService cardService;

    @GetMapping("/page")
    @ApiOperation("分页查询卡片")
    public Result<Page<BizCard>> page(
            @RequestParam(required = false) Long subjectId,
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        return Result.success(cardService.pageCards(subjectId, pageNum, pageSize));
    }

    @GetMapping("/{id}")
    @ApiOperation("获取卡片详情")
    public Result<BizCard> getById(@PathVariable Long id) {
        return Result.success(cardService.getById(id));
    }

    @PostMapping
    @ApiOperation("新增卡片")
    public Result<Void> save(@RequestBody BizCard card) {
        cardService.save(card);
        return Result.success();
    }

    @PutMapping
    @ApiOperation("更新卡片")
    public Result<Void> update(@RequestBody BizCard card) {
        cardService.updateById(card);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    @ApiOperation("删除卡片")
    public Result<Void> delete(@PathVariable Long id) {
        cardService.removeById(id);
        return Result.success();
    }

}