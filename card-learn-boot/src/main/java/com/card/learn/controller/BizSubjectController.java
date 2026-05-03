package com.card.learn.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.common.Result;
import com.card.learn.dto.SubjectQueryDTO;
import com.card.learn.entity.BizSubject;
import com.card.learn.service.IBizSubjectService;
import com.card.learn.vo.SubjectVO;
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
    public Result<List<SubjectVO>> list(@RequestParam(required = false) Long majorId) {
        return Result.success(subjectService.listSubjectsWithMajorName(majorId));
    }

    @GetMapping("/page")
    @ApiOperation("分页查询科目列表")
    public Result<Page<SubjectVO>> page(SubjectQueryDTO queryDTO) {
        return Result.success(subjectService.pageSubjects(queryDTO));
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

    @DeleteMapping("/{id:\\d+}")
    @ApiOperation("删除科目")
    public Result<Void> delete(@PathVariable Long id) {
        subjectService.removeById(id);
        return Result.success();
    }

}
