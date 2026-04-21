package com.card.learn.util;

import java.awt.*;
import java.awt.image.BufferedImage;
import java.util.Random;

/**
 * 验证码生成工具类
 */
public class CaptchaUtil {

    private static final int WIDTH = 120;
    private static final int HEIGHT = 40;
    private static final int CODE_LENGTH = 4;
    private static final String CODE_CHARS = "0123456789ABCDEFGHJKLMNPQRSTUVWXYZ";

    private static final Random random = new Random();

    /**
     * 生成验证码图片
     * @param code 验证码字符串
     * @return BufferedImage 图片对象
     */
    public static BufferedImage generateImage(String code) {
        BufferedImage image = new BufferedImage(WIDTH, HEIGHT, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = image.createGraphics();

        // 设置背景色
        g.setColor(Color.WHITE);
        g.fillRect(0, 0, WIDTH, HEIGHT);

        // 绘制干扰线
        for (int i = 0; i < 8; i++) {
            g.setColor(getRandomColor(160, 200));
            g.drawLine(random.nextInt(WIDTH), random.nextInt(HEIGHT),
                       random.nextInt(WIDTH), random.nextInt(HEIGHT));
        }

        // 绘制干扰点
        for (int i = 0; i < 50; i++) {
            g.setColor(getRandomColor(120, 200));
            g.fillOval(random.nextInt(WIDTH), random.nextInt(HEIGHT), 2, 2);
        }

        // 绘制验证码字符
        Font font = new Font("Arial", Font.BOLD, 28);
        g.setFont(font);
        int x = 15;
        for (int i = 0; i < code.length(); i++) {
            g.setColor(getRandomColor(30, 150));
            g.drawString(String.valueOf(code.charAt(i)), x + i * 25, 28);
            // 随机旋转字符
            g.rotate(random.nextDouble() * 0.2 - 0.1, x + i * 25 + 12, 20);
        }

        g.dispose();
        return image;
    }

    /**
     * 生成随机验证码字符串
     */
    public static String generateCode() {
        StringBuilder code = new StringBuilder();
        for (int i = 0; i < CODE_LENGTH; i++) {
            code.append(CODE_CHARS.charAt(random.nextInt(CODE_CHARS.length())));
        }
        return code.toString();
    }

    /**
     * 获取随机颜色
     */
    private static Color getRandomColor(int min, int max) {
        int r = min + random.nextInt(max - min);
        int g = min + random.nextInt(max - min);
        int b = min + random.nextInt(max - min);
        return new Color(r, g, b);
    }

}