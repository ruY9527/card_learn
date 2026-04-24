package com.card.learn.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.common.Result;
import com.card.learn.entity.BizTag;
import com.card.learn.service.IBizTagService;
import com.card.learn.vo.TagVO;
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

    @GetMapping("/page")
    @ApiOperation("分页查询标签")
    public Result<Page<TagVO>> page(
            @RequestParam(required = false) String tagName,
            @RequestParam(required = false) Long subjectId,
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        return Result.success(tagService.pageTags(tagName, subjectId, pageNum, pageSize));
    }

    @GetMapping("/list")
    @ApiOperation("获取标签列表（不分页，用于下拉选择）")
    public Result<List<BizTag>> list(@RequestParam(required = false) Long subjectId) {
        if (subjectId != null) {
            // 查询指定科目的标签 + 通用标签（subjectId为null）
            List<BizTag> subjectTags = tagService.lambdaQuery()
                    .eq(BizTag::getSubjectId, subjectId)
                    .list();
            List<BizTag> commonTags = tagService.lambdaQuery()
                    .isNull(BizTag::getSubjectId)
                    .list();
            subjectTags.addAll(commonTags);
            return Result.success(subjectTags);
        }
        return Result.success(tagService.list());
    }

    @PostMapping
    @ApiOperation("新增标签")
    public Result<Void> save(@RequestBody BizTag tag) {
        // 检查同一科目下是否已存在同名标签
        List<BizTag> existing = tagService.lambdaQuery()
                .eq(BizTag::getTagName, tag.getTagName())
                .eq(tag.getSubjectId() != null, BizTag::getSubjectId, tag.getSubjectId())
                .isNull(tag.getSubjectId() == null, BizTag::getSubjectId)
                .list();
        if (!existing.isEmpty()) {
            return Result.error("该科目下已存在同名标签");
        }
        tagService.save(tag);
        return Result.success();
    }

    @PutMapping
    @ApiOperation("更新标签")
    public Result<Void> update(@RequestBody BizTag tag) {
        // 检查同一科目下是否已存在同名标签（排除自身）
        List<BizTag> existing = tagService.lambdaQuery()
                .eq(BizTag::getTagName, tag.getTagName())
                .eq(tag.getSubjectId() != null, BizTag::getSubjectId, tag.getSubjectId())
                .isNull(tag.getSubjectId() == null, BizTag::getSubjectId)
                .ne(BizTag::getTagId, tag.getTagId())
                .list();
        if (!existing.isEmpty()) {
            return Result.error("该科目下已存在同名标签");
        }
        tagService.updateById(tag);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    @ApiOperation("删除标签")
    public Result<Void> delete(@PathVariable Long id) {
        tagService.removeById(id);
        return Result.success();
    }

}