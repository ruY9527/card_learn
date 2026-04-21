package com.card.learn.controller;

import com.card.learn.common.Result;
import com.card.learn.entity.BizTag;
import com.card.learn.service.IBizTagService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 标签管理控制器
 */
@RestController
@RequestMapping("/tag")
@Api(tags = "标签管理")
public class BizTagController {

    @Autowired
    private IBizTagService tagService;

    @GetMapping("/list")
    @ApiOperation("获取标签列表")
    public Result<List<BizTag>> list() {
        return Result.success(tagService.list());
    }

    @PostMapping
    @ApiOperation("新增标签")
    public Result<Void> save(@RequestBody BizTag tag) {
        tagService.save(tag);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    @ApiOperation("删除标签")
    public Result<Void> delete(@PathVariable Long id) {
        tagService.removeById(id);
        return Result.success();
    }

}