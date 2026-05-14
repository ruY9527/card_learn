package com.card.learn.controller;

import com.card.learn.common.AppMessages;
import com.card.learn.common.Result;
import com.card.learn.dto.AiConvertDTO;
import com.card.learn.dto.AiCardDTO;
import com.card.learn.entity.BizCard;
import com.card.learn.entity.BizTag;
import com.card.learn.entity.BizCardTag;
import com.card.learn.service.IBizCardService;
import com.card.learn.service.IBizTagService;
import com.card.learn.mapper.BizCardTagMapper;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * AI智能工作站控制器
 */
@RestController
@RequestMapping("/ai")
@Api(tags = "AI智能工作站")
public class AiController {

    @Autowired
    private IBizCardService cardService;

    @Autowired
    private IBizTagService tagService;

    @Autowired
    private BizCardTagMapper cardTagMapper;

    @PostMapping("/convert")
    @ApiOperation("AI文本转卡片")
    public Result<List<AiCardDTO>> convert(@RequestBody AiConvertDTO dto) {
        // 模拟AI解析结果（实际项目应调用Qwen API）
        List<AiCardDTO> cards = simulateAiConvert(dto.getContent());
        return Result.success(cards);
    }

    @PostMapping("/batchSave")
    @ApiOperation("批量保存AI生成的卡片")
    public Result<Void> batchSave(@RequestParam Long subjectId, @RequestBody List<AiCardDTO> cards) {
        for (AiCardDTO cardDto : cards) {
            // 保存卡片
            BizCard card = new BizCard();
            card.setSubjectId(subjectId);
            card.setFrontContent(cardDto.getFrontContent());
            card.setBackContent(cardDto.getBackContent());
            card.setDifficultyLevel(cardDto.getDifficultyLevel());
            cardService.save(card);

            // 处理标签
            if (cardDto.getTags() != null) {
                for (String tagName : cardDto.getTags()) {
                    // 查找或创建标签
                    BizTag tag = tagService.lambdaQuery()
                            .eq(BizTag::getTagName, tagName)
                            .one();
                    if (tag == null) {
                        tag = new BizTag();
                        tag.setTagName(tagName);
                        tagService.save(tag);
                    }
                    // 创建关联
                    BizCardTag cardTag = new BizCardTag();
                    cardTag.setCardId(card.getCardId());
                    cardTag.setTagId(tag.getTagId());
                    cardTagMapper.insert(cardTag);
                }
            }
        }
        return Result.success();
    }

    /**
     * 模拟AI转换（实际项目应调用Qwen API）
     */
    private List<AiCardDTO> simulateAiConvert(String content) {
        List<AiCardDTO> result = new ArrayList<>();
        
        // 模拟解析：根据段落分割生成卡片
        String[] paragraphs = content.split("\n\n");
        for (int i = 0; i < paragraphs.length && i < 5; i++) {
            String paragraph = paragraphs[i].trim();
            if (paragraph.isEmpty()) continue;
            
            AiCardDTO card = new AiCardDTO();
            
            // 模拟生成问题和答案
            if (paragraph.contains("?") || paragraph.contains("？")) {
                // 如果是问题格式，直接作为正面
                String[] parts = paragraph.split("[?？]");
                card.setFrontContent(parts[0] + "?");
                card.setBackContent(parts.length > 1 ? parts[1].trim() : AppMessages.AI_REFER_TEXTBOOK);
            } else {
                // 否则生成模拟问题
                card.setFrontContent("什么是" + paragraph.substring(0, Math.min(20, paragraph.length())) + "?");
                card.setBackContent(paragraph);
            }
            
            card.setDifficultyLevel(3);
            card.setTags(Arrays.asList(AppMessages.AI_GENERATED));
            result.add(card);
        }
        
        return result;
    }

}