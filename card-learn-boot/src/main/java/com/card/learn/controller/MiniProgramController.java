package com.card.learn.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.common.Result;
import com.card.learn.dto.MiniCardDTO;
import com.card.learn.dto.MiniProgressDTO;
import com.card.learn.dto.MiniSubjectDTO;
import com.card.learn.dto.MiniMajorDTO;
import com.card.learn.entity.BizCard;
import com.card.learn.entity.BizMajor;
import com.card.learn.entity.BizSubject;
import com.card.learn.entity.BizTag;
import com.card.learn.entity.BizCardTag;
import com.card.learn.entity.BizUserProgress;
import com.card.learn.entity.SysUser;
import com.card.learn.service.IBizCardService;
import com.card.learn.service.IBizMajorService;
import com.card.learn.service.IBizSubjectService;
import com.card.learn.service.IBizTagService;
import com.card.learn.service.IBizCardTagService;
import com.card.learn.service.IBizUserProgressService;
import com.card.learn.service.ISysUserService;
import com.card.learn.util.JwtUtil;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 小程序公开接口控制器
 */
@RestController
@RequestMapping("/api/miniprogram")
@Api(tags = "小程序公开接口")
public class MiniProgramController {

    @Autowired
    private IBizMajorService majorService;

    @Autowired
    private IBizSubjectService subjectService;

    @Autowired
    private IBizCardService cardService;

    @Autowired
    private IBizTagService tagService;

    @Autowired
    private IBizCardTagService cardTagService;

    @Autowired
    private IBizUserProgressService progressService;

    @Autowired
    private ISysUserService userService;

    @Autowired
    private RedisTemplate<String, Object> redisTemplate;

    @Autowired
    private JwtUtil jwtUtil;

    private static final String CAPTCHA_PREFIX = "captcha:";

    /**
     * 小程序用户登录
     */
    @PostMapping("/login")
    @ApiOperation("小程序用户登录")
    public Result<Map<String, Object>> login(@RequestBody Map<String, String> params) {
        String username = params.get("username");
        String password = params.get("password");
        String captcha = params.get("captcha");
        String captchaKey = params.get("captchaKey");

        // 验证码校验
        if (captchaKey == null || captcha == null) {
            return Result.error("请输入验证码");
        }

        Object cachedCaptcha = redisTemplate.opsForValue().get(CAPTCHA_PREFIX + captchaKey);
        if (cachedCaptcha == null) {
            return Result.error("验证码已过期，请重新获取");
        }

        if (!cachedCaptcha.toString().equalsIgnoreCase(captcha)) {
            return Result.error("验证码错误");
        }

        // 删除验证码
        redisTemplate.delete(CAPTCHA_PREFIX + captchaKey);

        // 用户验证
        if (username == null || password == null) {
            return Result.error("请输入账号和密码");
        }

        SysUser user = userService.getByUsername(username);
        if (user == null) {
            return Result.error("用户不存在");
        }

        // 密码验证（实际应加密比对）
        if (!userService.checkPassword(user.getUserId(), password)) {
            return Result.error("密码错误");
        }

        // 状态检查
        if ("1".equals(user.getStatus())) {
            return Result.error("账号已被停用");
        }

        // 生成token
        String token = jwtUtil.generateToken(user.getUserId(), user.getUsername());

        Map<String, Object> data = new HashMap<>();
        data.put("token", token);

        Map<String, Object> userMap = new HashMap<>();
        userMap.put("userId", user.getUserId());
        userMap.put("nickname", user.getNickname() != null ? user.getNickname() : user.getUsername());
        userMap.put("avatar", user.getAvatar());
        data.put("user", userMap);

        return Result.success(data);
    }

    /**
     * 获取专业列表
     */
    @GetMapping("/majors")
    @ApiOperation("获取专业列表")
    public Result<List<MiniMajorDTO>> getMajors() {
        List<BizMajor> majors = majorService.list();
        List<MiniMajorDTO> dtoList = majors.stream().map(m -> {
            MiniMajorDTO dto = new MiniMajorDTO();
            dto.setMajorId(m.getMajorId());
            dto.setMajorName(m.getMajorName());
            dto.setDescription(m.getDescription());
            return dto;
        }).collect(Collectors.toList());
        return Result.success(dtoList);
    }

    /**
     * 获取科目列表
     */
    @GetMapping("/subjects")
    @ApiOperation("获取科目列表")
    public Result<List<MiniSubjectDTO>> getSubjects(@RequestParam(required = false) Long majorId) {
        List<BizSubject> subjects;
        if (majorId != null) {
            subjects = subjectService.lambdaQuery()
                    .eq(BizSubject::getMajorId, majorId)
                    .list();
        } else {
            subjects = subjectService.list();
        }

        List<MiniSubjectDTO> dtoList = subjects.stream().map(s -> {
            MiniSubjectDTO dto = new MiniSubjectDTO();
            dto.setSubjectId(s.getSubjectId());
            dto.setMajorId(s.getMajorId());
            dto.setSubjectName(s.getSubjectName());
            dto.setIcon(s.getIcon());
            dto.setOrderNum(s.getOrderNum());
            return dto;
        }).collect(Collectors.toList());
        return Result.success(dtoList);
    }

    /**
     * 分页获取卡片列表
     */
    @GetMapping("/cards")
    @ApiOperation("分页获取卡片")
    public Result<Map<String, Object>> getCards(
            @RequestParam(required = false) Long subjectId,
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {

        Page<BizCard> page = cardService.pageCards(subjectId, pageNum, pageSize);

        // 获取卡片标签关联
        List<Long> cardIds = page.getRecords().stream()
                .map(BizCard::getCardId)
                .collect(Collectors.toList());

        Map<Long, List<String>> cardTagsMap = new HashMap<>();
        if (!cardIds.isEmpty()) {
            List<BizCardTag> cardTags = cardTagService.lambdaQuery()
                    .in(BizCardTag::getCardId, cardIds)
                    .list();

            Set<Long> tagIds = cardTags.stream()
                    .map(BizCardTag::getTagId)
                    .collect(Collectors.toSet());

            if (!tagIds.isEmpty()) {
                List<BizTag> tags = tagService.listByIds(tagIds);
                Map<Long, String> tagNameMap = tags.stream()
                        .collect(Collectors.toMap(BizTag::getTagId, BizTag::getTagName));

                cardTags.forEach(ct -> {
                    cardTagsMap.computeIfAbsent(ct.getCardId(), k -> new ArrayList<>())
                            .add(tagNameMap.get(ct.getTagId()));
                });
            }
        }

        // 获取科目名称
        Map<Long, String> subjectNameMap = new HashMap<>();
        Set<Long> subjectIds = page.getRecords().stream()
                .map(BizCard::getSubjectId)
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());
        if (!subjectIds.isEmpty()) {
            List<BizSubject> subjects = subjectService.listByIds(subjectIds);
            subjectNameMap = subjects.stream()
                    .collect(Collectors.toMap(BizSubject::getSubjectId, BizSubject::getSubjectName));
        }

        // 转换为DTO
        List<MiniCardDTO> cardDTOs = page.getRecords().stream().map(c -> {
            MiniCardDTO dto = new MiniCardDTO();
            dto.setCardId(c.getCardId());
            dto.setSubjectId(c.getSubjectId());
            dto.setSubjectName(subjectNameMap.get(c.getSubjectId()));
            dto.setFrontContent(c.getFrontContent());
            dto.setBackContent(c.getBackContent());
            dto.setDifficultyLevel(c.getDifficultyLevel());
            dto.setTags(cardTagsMap.get(c.getCardId()));
            return dto;
        }).collect(Collectors.toList());

        Map<String, Object> result = new HashMap<>();
        result.put("records", cardDTOs);
        result.put("total", page.getTotal());
        result.put("pageNum", page.getCurrent());
        result.put("pageSize", page.getSize());

        return Result.success(result);
    }

    /**
     * 获取卡片详情
     */
    @GetMapping("/cards/{id}")
    @ApiOperation("获取卡片详情")
    public Result<MiniCardDTO> getCardById(@PathVariable Long id) {
        BizCard card = cardService.getById(id);
        if (card == null) {
            return Result.error("卡片不存在");
        }

        // 获取科目名称
        String subjectName = null;
        if (card.getSubjectId() != null) {
            BizSubject subject = subjectService.getById(card.getSubjectId());
            if (subject != null) {
                subjectName = subject.getSubjectName();
            }
        }

        // 获取卡片标签
        List<BizCardTag> cardTags = cardTagService.lambdaQuery()
                .eq(BizCardTag::getCardId, id)
                .list();

        List<String> tagNames = new ArrayList<>();
        if (!cardTags.isEmpty()) {
            List<Long> tagIds = cardTags.stream()
                    .map(BizCardTag::getTagId)
                    .collect(Collectors.toList());
            List<BizTag> tags = tagService.listByIds(tagIds);
            tagNames = tags.stream()
                    .map(BizTag::getTagName)
                    .collect(Collectors.toList());
        }

        MiniCardDTO dto = new MiniCardDTO();
        dto.setCardId(card.getCardId());
        dto.setSubjectId(card.getSubjectId());
        dto.setSubjectName(subjectName);
        dto.setFrontContent(card.getFrontContent());
        dto.setBackContent(card.getBackContent());
        dto.setDifficultyLevel(card.getDifficultyLevel());
        dto.setTags(tagNames);

        return Result.success(dto);
    }

    /**
     * 更新学习进度
     */
    @PostMapping("/progress")
    @ApiOperation("更新学习进度")
    public Result<Void> updateProgress(@RequestBody MiniProgressDTO dto) {
        BizUserProgress progress = new BizUserProgress();
        progress.setCardId(dto.getCardId());
        progress.setAppUserId(dto.getAppUserId());
        progress.setStatus(dto.getStatus());
        progress.setUpdateTime(LocalDateTime.now());

        if (dto.getStatus() != null && dto.getStatus() > 0) {
            int days = dto.getStatus() == 1 ? 3 : 7;
            progress.setNextReviewTime(LocalDateTime.now().plusDays(days));
        }

        BizUserProgress existing;
        if (dto.getAppUserId() != null) {
            existing = progressService.lambdaQuery()
                    .eq(BizUserProgress::getCardId, dto.getCardId())
                    .eq(BizUserProgress::getAppUserId, dto.getAppUserId())
                    .one();
        } else {
            existing = progressService.lambdaQuery()
                    .eq(BizUserProgress::getCardId, dto.getCardId())
                    .isNull(BizUserProgress::getAppUserId)
                    .one();
        }

        if (existing != null) {
            progress.setId(existing.getId());
            progressService.updateById(progress);
        } else {
            progressService.save(progress);
        }

        return Result.success();
    }

    /**
     * 获取学习统计
     */
    @GetMapping("/stats")
    @ApiOperation("获取学习统计")
    public Result<Map<String, Object>> getStats(@RequestParam(required = false) Long appUserId) {
        Map<String, Object> stats = new HashMap<>();

        long learned = progressService.lambdaQuery()
                .eq(appUserId != null, BizUserProgress::getAppUserId, appUserId)
                .isNull(appUserId == null, BizUserProgress::getAppUserId)
                .ge(BizUserProgress::getStatus, 1)
                .count();

        long mastered = progressService.lambdaQuery()
                .eq(appUserId != null, BizUserProgress::getAppUserId, appUserId)
                .isNull(appUserId == null, BizUserProgress::getAppUserId)
                .eq(BizUserProgress::getStatus, 2)
                .count();

        long review = progressService.lambdaQuery()
                .eq(appUserId != null, BizUserProgress::getAppUserId, appUserId)
                .isNull(appUserId == null, BizUserProgress::getAppUserId)
                .eq(BizUserProgress::getStatus, 1)
                .count();

        stats.put("learned", learned);
        stats.put("mastered", mastered);
        stats.put("review", review);

        return Result.success(stats);
    }

    /**
     * 获取待复习卡片
     */
    @GetMapping("/review")
    @ApiOperation("获取待复习卡片")
    public Result<List<MiniCardDTO>> getReviewCards(@RequestParam(required = false) Long appUserId) {
        List<BizUserProgress> progressList = progressService.lambdaQuery()
                .eq(appUserId != null, BizUserProgress::getAppUserId, appUserId)
                .isNull(appUserId == null, BizUserProgress::getAppUserId)
                .le(BizUserProgress::getNextReviewTime, LocalDateTime.now())
                .list();

        if (progressList.isEmpty()) {
            return Result.success(new ArrayList<>());
        }

        List<Long> cardIds = progressList.stream()
                .map(BizUserProgress::getCardId)
                .collect(Collectors.toList());

        List<BizCard> cards = cardService.listByIds(cardIds);

        List<MiniCardDTO> dtoList = cards.stream().map(c -> {
            MiniCardDTO dto = new MiniCardDTO();
            dto.setCardId(c.getCardId());
            dto.setSubjectId(c.getSubjectId());
            dto.setFrontContent(c.getFrontContent());
            dto.setBackContent(c.getBackContent());
            dto.setDifficultyLevel(c.getDifficultyLevel());
            return dto;
        }).collect(Collectors.toList());

        return Result.success(dtoList);
    }

}