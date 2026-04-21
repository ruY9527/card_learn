package com.card.learn.controller;

import com.card.learn.common.Result;
import com.card.learn.util.CaptchaUtil;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

/**
 * 验证码控制器
 */
@RestController
@RequestMapping("/captcha")
@Api(tags = "验证码管理")
public class CaptchaController {

    @Autowired
    private RedisTemplate<String, Object> redisTemplate;

    private static final String CAPTCHA_PREFIX = "captcha:";
    private static final long CAPTCHA_EXPIRE = 120L; // 验证码有效期120秒

    /**
     * 生成验证码
     */
    @GetMapping("/generate")
    @ApiOperation("生成验证码")
    public Result<Map<String, String>> generate() {
        // 生成验证码字符串
        String code = CaptchaUtil.generateCode();
        // 生成唯一key
        String key = UUID.randomUUID().toString().replace("-", "");
        // 存入Redis
        redisTemplate.opsForValue().set(CAPTCHA_PREFIX + key, code, CAPTCHA_EXPIRE, TimeUnit.SECONDS);
        // 生成图片
        BufferedImage image = CaptchaUtil.generateImage(code);
        // 转为Base64
        String base64Image = imageToBase64(image);

        Map<String, String> data = new HashMap<>();
        data.put("key", key);
        data.put("image", "data:image/png;base64," + base64Image);
        return Result.success(data);
    }

    /**
     * 图片转Base64
     */
    private String imageToBase64(BufferedImage image) {
        try {
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            ImageIO.write(image, "png", baos);
            byte[] bytes = baos.toByteArray();
            return Base64.getEncoder().encodeToString(bytes);
        } catch (Exception e) {
            e.printStackTrace();
            return "";
        }
    }

}