package com.card.learn.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.common.Result;
import com.card.learn.dto.MajorQueryDTO;
import com.card.learn.entity.BizMajor;
import com.card.learn.service.IBizMajorService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 专业管理控制器
 */
@RestController
@RequestMapping("/major")
@Api(tags = "专业管理")
public class BizMajorController {

    @Autowired
    private IBizMajorService majorService;

    @GetMapping("/list")
    @ApiOperation("获取专业列表")
    public Result<List<BizMajor>> list() {
        return Result.success(majorService.list());
    }

    @GetMapping("/page")
    @ApiOperation("分页查询专业列表")
    public Result<Page<BizMajor>> page(MajorQueryDTO queryDTO) {
        return Result.success(majorService.pageMajors(queryDTO));
    }

    @PostMapping
    @ApiOperation("新增专业")
    public Result<Void> save(@RequestBody BizMajor major) {
        majorService.save(major);
        return Result.success();
    }

    @PutMapping
    @ApiOperation("更新专业")
    public Result<Void> update(@RequestBody BizMajor major) {
        majorService.updateById(major);
        return Result.success();
    }

    @DeleteMapping("/{id:\\d+}")
    @ApiOperation("删除专业")
    public Result<Void> delete(@PathVariable Long id) {
        majorService.removeById(id);
        return Result.success();
    }

}
