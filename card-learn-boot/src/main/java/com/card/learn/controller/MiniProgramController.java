package com.card.learn.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.common.Result;
import com.card.learn.dto.MiniCardDTO;
import com.card.learn.dto.MiniProgressDTO;
import com.card.learn.dto.MiniSubjectDTO;
import com.card.learn.dto.MiniMajorDTO;
import com.card.learn.dto.SprintConfigDTO;
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
import com.card.learn.service.ISysConfigService;
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

    @Autowired
    private ISysConfigService configService;

    private static final String CAPTCHA_PREFIX = "captcha:";

    /**
     * 解析用户ID，处理 null、"null"、空字符串等无效值
     * @param userId 用户ID字符串
     * @return 用户ID Long类型，无效时返回 null
     */
    private Long parseUserId(String userId) {
        if (userId == null || userId.trim().isEmpty() || "null".equalsIgnoreCase(userId.trim())) {
            return null;
        }
        try {
            return Long.parseLong(userId.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

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
        String token = jwtUtil.generateToken(user.getUsername());

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
     * 获取科目学习统计
     */
    @GetMapping("/subjects/{subjectId}/stats")
    @ApiOperation("获取科目学习统计")
    public Result<Map<String, Object>> getSubjectStats(
            @PathVariable Long subjectId,
            @RequestParam(required = false) String userId) {
        Long parsedUserId = parseUserId(userId);
        Map<String, Object> stats = new HashMap<>();

        // 获取该科目下的所有卡片（只查询已通过审批的）ID
        List<Long> cardIds = cardService.lambdaQuery()
                .eq(BizCard::getSubjectId, subjectId)
                .list()
                .stream()
                .map(BizCard::getCardId)
                .collect(Collectors.toList());

        if (cardIds.isEmpty()) {
            stats.put("total", 0);
            stats.put("learned", 0);
            stats.put("mastered", 0);
            stats.put("review", 0);
            return Result.success(stats);
        }

        // 统计总数
        long total = cardIds.size();

        // 统计已学习（状态>=1）
        long learned = progressService.lambdaQuery()
                .eq(parsedUserId != null, BizUserProgress::getUserId, parsedUserId)
                .isNull(parsedUserId == null, BizUserProgress::getUserId)
                .in(BizUserProgress::getCardId, cardIds)
                .ge(BizUserProgress::getStatus, 1)
                .count();

        // 统计已掌握（状态=2）
        long mastered = progressService.lambdaQuery()
                .eq(parsedUserId != null, BizUserProgress::getUserId, parsedUserId)
                .isNull(parsedUserId == null, BizUserProgress::getUserId)
                .in(BizUserProgress::getCardId, cardIds)
                .eq(BizUserProgress::getStatus, 2)
                .count();

        // 统计待复习（状态=1且需要复习）
        long review = progressService.lambdaQuery()
                .eq(parsedUserId != null, BizUserProgress::getUserId, parsedUserId)
                .isNull(parsedUserId == null, BizUserProgress::getUserId)
                .in(BizUserProgress::getCardId, cardIds)
                .eq(BizUserProgress::getStatus, 1)
                .count();

        stats.put("total", total);
        stats.put("learned", learned);
        stats.put("mastered", mastered);
        stats.put("review", review);

        return Result.success(stats);
    }

    /**
     * 分页获取卡片列表
     */
    @GetMapping("/cards")
    @ApiOperation("分页获取卡片")
    public Result<Map<String, Object>> getCards(
            @RequestParam(required = false) Long subjectId,
            @RequestParam(required = false) String frontContent,
            @RequestParam(required = false) String userId,
            @RequestParam(required = false) String status,
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {

        // 解析用户ID
        final Long parsedUserId = parseUserId(userId);

        Page<BizCard> page = cardService.pageCards(subjectId, frontContent, pageNum, pageSize);

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
        final Map<Long, String> subjectNameMap;
        Set<Long> subjectIds = page.getRecords().stream()
                .map(BizCard::getSubjectId)
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());
        if (!subjectIds.isEmpty()) {
            List<BizSubject> subjects = subjectService.listByIds(subjectIds);
            subjectNameMap = subjects.stream()
                    .collect(Collectors.toMap(BizSubject::getSubjectId, BizSubject::getSubjectName));
        } else {
            subjectNameMap = new HashMap<>();
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

        // 获取用户学习进度状态和时间
        if (!cardIds.isEmpty()) {
            List<BizUserProgress> progressList = progressService.lambdaQuery()
                    .in(BizUserProgress::getCardId, cardIds)
                    .eq(parsedUserId != null, BizUserProgress::getUserId, parsedUserId)
                    .isNull(parsedUserId == null, BizUserProgress::getUserId)
                    .list();
            
            Map<Long, BizUserProgress> progressMap = progressList.stream()
                    .collect(Collectors.toMap(BizUserProgress::getCardId, p -> p, (p1, p2) -> p1));
            
            cardDTOs.forEach(dto -> {
                BizUserProgress progress = progressMap.get(dto.getCardId());
                if (progress != null) {
                    dto.setStatus(progress.getStatus() != null ? progress.getStatus() : 0);
                    dto.setUpdateTime(progress.getUpdateTime());
                }
            });
        }

        // 根据状态筛选
        if (status != null && !status.isEmpty() && !status.equals("all")) {
            cardDTOs = cardDTOs.stream().filter(dto -> {
                Integer cardStatus = dto.getStatus();
                switch (status) {
                    case "learned":
                        // 已学习：状态 >= 1（包括模糊和掌握）
                        return cardStatus != null && cardStatus >= 1;
                    case "mastered":
                        // 已掌握：状态 == 2
                        return cardStatus != null && cardStatus == 2;
                    case "review":
                        // 待复习：状态 == 1（模糊状态）
                        return cardStatus != null && cardStatus == 1;
                    case "unlearned":
                        // 未学习：状态 == 0 或 null
                        return cardStatus == null || cardStatus == 0;
                    default:
                        return true;
                }
            }).collect(Collectors.toList());
        }

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
        progress.setUserId(dto.getUserId());
        progress.setStatus(dto.getStatus());
        progress.setUpdateTime(LocalDateTime.now());

        if (dto.getStatus() != null && dto.getStatus() > 0) {
            int days = dto.getStatus() == 1 ? 3 : 7;
            progress.setNextReviewTime(LocalDateTime.now().plusDays(days));
        }

        BizUserProgress existing;
        if (dto.getUserId() != null) {
            existing = progressService.lambdaQuery()
                    .eq(BizUserProgress::getCardId, dto.getCardId())
                    .eq(BizUserProgress::getUserId, dto.getUserId())
                    .one();
        } else {
            existing = progressService.lambdaQuery()
                    .eq(BizUserProgress::getCardId, dto.getCardId())
                    .isNull(BizUserProgress::getUserId)
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
    public Result<Map<String, Object>> getStats(@RequestParam(required = false) Long userId) {
        Map<String, Object> stats = new HashMap<>();

        long learned = progressService.lambdaQuery()
                .eq(userId != null, BizUserProgress::getUserId, userId)
                .isNull(userId == null, BizUserProgress::getUserId)
                .ge(BizUserProgress::getStatus, 1)
                .count();

        long mastered = progressService.lambdaQuery()
                .eq(userId != null, BizUserProgress::getUserId, userId)
                .isNull(userId == null, BizUserProgress::getUserId)
                .eq(BizUserProgress::getStatus, 2)
                .count();

        long review = progressService.lambdaQuery()
                .eq(userId != null, BizUserProgress::getUserId, userId)
                .isNull(userId == null, BizUserProgress::getUserId)
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
    public Result<List<MiniCardDTO>> getReviewCards(@RequestParam(required = false) Long userId) {
        List<BizUserProgress> progressList = progressService.lambdaQuery()
                .eq(userId != null, BizUserProgress::getUserId, userId)
                .isNull(userId == null, BizUserProgress::getUserId)
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

    /**
     * 获取今日推荐卡片（每个科目随机2条）
     * @param majorId 专业ID（可选，不传则获取所有专业的推荐）
     */
    @GetMapping("/recommend")
    @ApiOperation("获取今日推荐卡片")
    public Result<List<MiniCardDTO>> getRecommendCards(@RequestParam(required = false) Long majorId) {
        List<MiniCardDTO> recommendList = new ArrayList<>();
        
        // 获取科目列表（根据专业筛选或获取全部）
        List<BizSubject> subjects;
        if (majorId != null) {
            subjects = subjectService.lambdaQuery()
                    .eq(BizSubject::getMajorId, majorId)
                    .list();
        } else {
            subjects = subjectService.list();
        }
        
        // 从每个科目中随机抽取2条卡片
        for (BizSubject subject : subjects) {
            // 获取该科目下的所有卡片（只查询已通过审批的）
            List<BizCard> cards = cardService.lambdaQuery()
                    .eq(BizCard::getSubjectId, subject.getSubjectId())
                    .eq(BizCard::getAuditStatus, "1") // 只查询已通过的卡片
                    .list();
            
            if (cards.size() <= 2) {
                // 如果卡片数少于等于2条，全部加入
                for (BizCard card : cards) {
                    MiniCardDTO dto = new MiniCardDTO();
                    dto.setCardId(card.getCardId());
                    dto.setSubjectId(card.getSubjectId());
                    dto.setSubjectName(subject.getSubjectName());
                    dto.setFrontContent(card.getFrontContent());
                    dto.setBackContent(card.getBackContent());
                    dto.setDifficultyLevel(card.getDifficultyLevel());
                    recommendList.add(dto);
                }
            } else {
                // 随机抽取2条（使用Collections.shuffle实现随机）
                Collections.shuffle(cards);
                for (int i = 0; i < 2; i++) {
                    BizCard card = cards.get(i);
                    MiniCardDTO dto = new MiniCardDTO();
                    dto.setCardId(card.getCardId());
                    dto.setSubjectId(card.getSubjectId());
                    dto.setSubjectName(subject.getSubjectName());
                    dto.setFrontContent(card.getFrontContent());
                    dto.setBackContent(card.getBackContent());
                    dto.setDifficultyLevel(card.getDifficultyLevel());
                    recommendList.add(dto);
                }
            }
        }
        
        return Result.success(recommendList);
    }

    /**
     * 获取冲刺配置（倒计时）
     */
    @GetMapping("/sprint-config")
    @ApiOperation("获取冲刺配置")
    public Result<SprintConfigDTO> getSprintConfig() {
        return Result.success(configService.getSprintConfig());
    }

}