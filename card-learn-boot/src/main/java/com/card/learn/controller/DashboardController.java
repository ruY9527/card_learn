package com.card.learn.controller;

import com.card.learn.common.Result;
import com.card.learn.service.IBizMajorService;
import com.card.learn.service.IBizSubjectService;
import com.card.learn.service.IBizCardService;
import com.card.learn.service.IBizTagService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * Dashboard数据统计控制器
 */
@RestController
@RequestMapping("/dashboard")
@Api(tags = "数据看板")
public class DashboardController {

    @Autowired
    private IBizMajorService majorService;

    @Autowired
    private IBizSubjectService subjectService;

    @Autowired
    private IBizCardService cardService;

    @Autowired
    private IBizTagService tagService;

    @GetMapping("/stats")
    @ApiOperation("获取统计数据")
    public Result<Map<String, Object>> getStats() {
        Map<String, Object> data = new HashMap<>();
        data.put("majorCount", majorService.count());
        data.put("subjectCount", subjectService.count());
        data.put("cardCount", cardService.count());
        data.put("tagCount", tagService.count());
        return Result.success(data);
    }

}