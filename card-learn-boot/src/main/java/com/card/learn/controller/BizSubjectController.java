package com.card.learn.controller;

import com.card.learn.common.Result;
import com.card.learn.entity.BizSubject;
import com.card.learn.service.IBizSubjectService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 科目管理控制器
 */
@RestController
@RequestMapping("/subject")
@Api(tags = "科目管理")
public class BizSubjectController {

    @Autowired
    private IBizSubjectService subjectService;

    @GetMapping("/list")
    @ApiOperation("获取科目列表")
    public Result<List<BizSubject>> list(@RequestParam(required = false) Long majorId) {
        return Result.success(subjectService.list());
    }

    @PostMapping
    @ApiOperation("新增科目")
    public Result<Void> save(@RequestBody BizSubject subject) {
        subjectService.save(subject);
        return Result.success();
    }

    @PutMapping
    @ApiOperation("更新科目")
    public Result<Void> update(@RequestBody BizSubject subject) {
        subjectService.updateById(subject);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    @ApiOperation("删除科目")
    public Result<Void> delete(@PathVariable Long id) {
        subjectService.removeById(id);
        return Result.success();
    }

}