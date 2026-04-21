package com.card.learn.config;

import cn.hutool.core.util.StrUtil;
import com.alibaba.fastjson2.JSON;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.aspectj.lang.reflect.MethodSignature;
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
 * 打印请求参数和响应结果，不影响主流程业务
 */
@Slf4j
@Aspect
@Component
public class RequestLogAspect {

    /**
     * 定义切点：所有Controller层的方法
     */
    @Pointcut("execution(* com.card.learn.controller..*.*(..))")
    public void controllerPointcut() {
    }

    /**
     * 环绕通知：打印请求和响应日志
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
        MethodSignature signature = (MethodSignature) joinPoint.getSignature();
        Method method = signature.getMethod();
        
        // 打印请求信息
        String className = joinPoint.getTarget().getClass().getName();
        String methodName = method.getName();
        String requestMethod = request.getMethod();
        String requestUrl = request.getRequestURI();
        
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
        
        // 打印请求日志
        log.info("==================== 请求开始 ====================");
        log.info("请求URL    : {} {}", requestMethod, requestUrl);
        log.info("请求方法    : {}#{}", className, methodName);
        log.info("请求参数    : {}", StrUtil.sub(params, 0, 500));
        
        // 执行目标方法
        Object result = joinPoint.proceed();
        
        // 计算执行时间
        long endTime = System.currentTimeMillis();
        long duration = endTime - startTime;
        
        // 打印响应日志
        String responseStr = JSON.toJSONString(result);
        log.info("响应结果    : {}", StrUtil.sub(responseStr, 0, 500));
        log.info("执行耗时    : {} ms", duration);
        log.info("==================== 请求结束 ====================\n");
        
        return result;
    }

}