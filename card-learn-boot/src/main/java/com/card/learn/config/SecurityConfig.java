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
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

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
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();
        // 允许所有来源
        config.addAllowedOriginPattern("*");
        // 允许所有请求头
        config.addAllowedHeader("*");
        // 允许所有请求方法
        config.addAllowedMethod("*");
        // 允许携带Cookie
        config.setAllowCredentials(true);
        // 预检请求缓存时间
        config.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            // 启用CORS
            .cors().configurationSource(corsConfigurationSource())
            .and()
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
                "/api/miniprogram/majors",
                "/api/miniprogram/subjects",
                "/api/miniprogram/cards",
                "/api/miniprogram/cards/**",
                "/api/miniprogram/progress",
                "/api/miniprogram/stats",
                "/api/miniprogram/subjects/**/stats",
                "/api/miniprogram/review",
                "/api/miniprogram/recommend",
                "/api/miniprogram/sprint-config",
                "/api/miniprogram/study-history/**",
                "/api/miniprogram/feedback/list",
                "/api/miniprogram/feedback/*",
                "/api/miniprogram/comment/**",
                "/api/miniprogram/reply/**",
                "/api/miniprogram/like/**",
                "/api/miniprogram/note/**"
            ).permitAll()
            // 放行接口 - 学习服务API
            .antMatchers(
                "/api/learning/**",
                "/api/incentive/**",
                "/api/dashboard/**"
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