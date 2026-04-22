package com.card.learn.config;

import cn.hutool.core.util.StrUtil;
import com.alibaba.fastjson2.JSON;
import com.card.learn.entity.SysRequestLog;
import com.card.learn.service.ISysRequestLogService;
import com.card.learn.util.JwtUtil;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.List;

/**
 * 请求日志AOP切面
 * 打印请求参数和响应结果，异步写入数据库，不影响主流程业务
 */
@Slf4j
@Aspect
@Component
public class RequestLogAspect {

    @Autowired
    private ISysRequestLogService requestLogService;

    @Autowired
    private JwtUtil jwtUtil;

    /** 日志参数最大长度 */
    private static final int MAX_LOG_LENGTH = 2000;

    /**
     * 定义切点：所有Controller层的方法
     */
    @Pointcut("execution(* com.card.learn.controller..*.*(..))")
    public void controllerPointcut() {
    }

    /**
     * 环绕通知：打印请求和响应日志，异步写入数据库
     * 注意：只记录非查询类请求（POST/PUT/DELETE），GET请求不记录
     */
    @Around("controllerPointcut()")
    public Object doAround(ProceedingJoinPoint joinPoint) throws Throwable {
        long startTime = System.currentTimeMillis();

        // 获取请求信息
        ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attributes == null) {
            return joinPoint.proceed();
        }

        HttpServletRequest request = attributes.getRequest();
        String requestMethod = request.getMethod();

        // GET请求（查询类）不记录日志，直接执行目标方法
        if ("GET".equalsIgnoreCase(requestMethod)) {
            return joinPoint.proceed();
        }
        MethodSignature signature = (MethodSignature) joinPoint.getSignature();
        Method method = signature.getMethod();

        // 获取请求基本信息
        String className = joinPoint.getTarget().getClass().getName();
        String methodName = method.getName();
        String requestUrl = request.getRequestURI();
        String ipAddress = getIpAddress(request);

        // 获取用户信息
        Long userId = null;
        String userName = null;
        String token = request.getHeader("Authorization");
        if (token != null && token.startsWith("Bearer ")) {
            token = token.substring(7);
            try {
                if (jwtUtil.validateToken(token)) {
                    userName = jwtUtil.getUsernameFromToken(token);
                    // 根据用户名查询用户ID（这里简化处理，可以缓存用户信息）
                    userId = getUserIdFromToken(token);
                }
            } catch (Exception e) {
                // Token解析失败，不影响主流程
                log.debug("Token解析失败: {}", e.getMessage());
            }
        }

        // 获取请求参数
        Object[] args = joinPoint.getArgs();
        List<Object> argList = new ArrayList<>();
        for (Object arg : args) {
            // 过滤掉不需要打印的参数类型
            if (arg instanceof HttpServletRequest
                || arg instanceof HttpServletResponse
                || arg instanceof MultipartFile) {
                continue;
            }
            argList.add(arg);
        }

        String params = JSON.toJSONString(argList);
        String truncatedParams = StrUtil.sub(params, 0, MAX_LOG_LENGTH);

        // 打印请求日志
        log.info("==================== 请求开始 ====================");
        log.info("请求URL    : {} {}", requestMethod, requestUrl);
        log.info("请求方法    : {}#{}", className, methodName);
        log.info("请求参数    : {}", truncatedParams);
        log.info("请求IP      : {}", ipAddress);
        if (userName != null) {
            log.info("操作用户    : {} (ID: {})", userName, userId);
        }

        // 创建日志对象
        SysRequestLog requestLog = new SysRequestLog();
        requestLog.setRequestMethod(requestMethod);
        requestLog.setRequestUrl(requestUrl);
        requestLog.setClassName(className);
        requestLog.setMethodName(methodName);
        requestLog.setRequestParams(truncatedParams);
        requestLog.setIpAddress(ipAddress);
        requestLog.setUserId(userId);
        requestLog.setUserName(userName);

        Object result = null;
        String errorMsg = null;
        boolean success = true;

        try {
            // 执行目标方法
            result = joinPoint.proceed();
            success = true;
        } catch (Throwable e) {
            success = false;
            errorMsg = e.getMessage();
            log.error("请求执行异常: {}", errorMsg);
            throw e;
        } finally {
            // 计算执行时间
            long endTime = System.currentTimeMillis();
            long duration = endTime - startTime;

            // 设置响应结果
            requestLog.setExecutionTime(duration);
            requestLog.setStatus(success ? "1" : "0");
            requestLog.setErrorMsg(errorMsg);

            if (result != null && success) {
                String responseStr = JSON.toJSONString(result);
                String truncatedResponse = StrUtil.sub(responseStr, 0, MAX_LOG_LENGTH);
                requestLog.setResponseResult(truncatedResponse);
                
                // 打印响应日志
                log.info("响应结果    : {}", truncatedResponse);
            }

            log.info("执行耗时    : {} ms", duration);
            log.info("执行状态    : {}", success ? "成功" : "失败");
            log.info("==================== 请求结束 ====================\n");

            // 异步保存日志到数据库（不影响主业务流程）
            try {
                log.info("【AOP日志】准备异步保存日志...");
                requestLogService.saveLogAsync(requestLog);
                log.info("【AOP日志】异步保存任务已提交");
            } catch (Exception e) {
                // 异步保存失败不影响主流程，打印完整错误堆栈
                log.error("【AOP日志】异步保存日志调用失败: {}", e.getMessage(), e);
            }
        }

        return result;
    }

    /**
     * 获取请求IP地址
     */
    private String getIpAddress(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("HTTP_CLIENT_IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("HTTP_X_FORWARDED_FOR");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        // 多个代理时取第一个IP
        if (ip != null && ip.contains(",")) {
            ip = ip.split(",")[0].trim();
        }
        return ip;
    }

    /**
     * 从Token获取用户ID（简化实现）
     */
    private Long getUserIdFromToken(String token) {
        // JWT Token中通常不包含用户ID，这里返回null
        // 实际应用中可以在Token中存储用户ID，或者通过缓存获取
        return null;
    }

}