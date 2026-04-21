package com.card.learn.config;

import com.card.learn.filter.JwtAuthenticationFilter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

/**
 * Spring Security配置
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private JwtAuthenticationFilter jwtAuthenticationFilter;

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            // 关闭CSRF
            .csrf().disable()
            // 关闭Session
            .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            .and()
            .authorizeRequests()
            // 放行接口 - 认证相关
            .antMatchers(
                "/auth/login",
                "/auth/register",
                "/captcha/**"
            ).permitAll()
            // 放行接口 - API文档
            .antMatchers(
                "/doc.html",
                "/webjars/**",
                "/swagger-resources/**",
                "/v2/api-docs/**",
                "/v3/api-docs/**"
            ).permitAll()
            // 放行接口 - 小程序公开API（无需登录验证）
            .antMatchers(
                "/api/miniprogram/**"
            ).permitAll()
            // 其他请求需要认证
            .anyRequest().authenticated()
            .and()
            // 添加JWT认证过滤器
            .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class)
            // 禁用表单登录和HTTP Basic
            .formLogin().disable()
            .httpBasic().disable();

        return http.build();
    }

}