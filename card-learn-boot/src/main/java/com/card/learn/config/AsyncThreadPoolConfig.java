package com.card.learn.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.AsyncConfigurer;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import java.util.concurrent.Executor;
import java.util.concurrent.ThreadPoolExecutor;

/**
 * 异步线程池配置
 * 用于异步任务执行，避免无限制创建线程
 * 实现 AsyncConfigurer 接口，作为全局默认异步线程池
 */
@Slf4j
@Configuration
public class AsyncThreadPoolConfig implements AsyncConfigurer {

    /**
     * 日志异步线程池
     * 核心线程数：2（保持少量核心线程，日志写入不需要太高的并发）
     * 最大线程数：10（高峰期最多10个线程同时写入日志）
     * 队列容量：500（最多缓存500个待处理日志）
     * 拒绝策略：CallerRunsPolicy（队列满时由调用线程执行，保证日志不丢失）
     */
    @Bean("logAsyncExecutor")
    public ThreadPoolTaskExecutor logAsyncExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();

        // 核心线程数：处理器核心数 * 1，但最小为2
        int corePoolSize = Math.max(Runtime.getRuntime().availableProcessors(), 2);
        executor.setCorePoolSize(corePoolSize);

        // 最大线程数：核心线程数 * 2，但不超过10
        int maxPoolSize = Math.min(corePoolSize * 2, 10);
        executor.setMaxPoolSize(maxPoolSize);

        // 队列容量：500个待处理任务
        executor.setQueueCapacity(500);

        // 线程名称前缀：便于排查问题
        executor.setThreadNamePrefix("log-async-");

        // 线程存活时间：60秒（非核心线程空闲60秒后回收）
        executor.setKeepAliveSeconds(60);

        // 拒绝策略：CallerRunsPolicy
        // 当队列满时，由调用线程（即业务请求线程）执行任务
        // 这样既不会丢弃日志，也不会创建过多线程
        executor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy());

        // 等待所有任务完成后再关闭线程池
        executor.setWaitForTasksToCompleteOnShutdown(true);

        // 等待时间：最多等待60秒
        executor.setAwaitTerminationSeconds(60);

        executor.initialize();

        log.info("日志异步线程池初始化完成：核心线程数={}, 最大线程数={}, 队列容量={}",
                 corePoolSize, maxPoolSize, 500);

        return executor;
    }

    /**
     * 设置默认异步线程池（可选，用于没有指定线程池的@Async方法）
     */
    @Override
    public Executor getAsyncExecutor() {
        return logAsyncExecutor();
    }

}