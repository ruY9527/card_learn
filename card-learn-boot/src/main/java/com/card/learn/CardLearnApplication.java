package com.card.learn;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;

/**
 * 408知识点学习卡片系统启动类
 */
@SpringBootApplication
@MapperScan("com.card.learn.mapper")
@EnableAsync
public class CardLearnApplication {

    public static void main(String[] args) {
        SpringApplication.run(CardLearnApplication.class, args);
    }

}