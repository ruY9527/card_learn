# ==================== 多阶段构建 ====================

# 第一阶段：构建
FROM maven:3.8.6-openjdk-8-slim AS builder

WORKDIR /build

# 配置 Maven 阿里云镜像源
RUN mkdir -p /root/.m2 && \
    echo '<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" \
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" \
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd"> \
          <mirrors> \
            <mirror> \
              <id>aliyunmaven</id> \
              <mirrorOf>*</mirrorOf> \
              <name>阿里云公共仓库</name> \
              <url>https://maven.aliyun.com/repository/public</url> \
            </mirror> \
          </mirrors> \
        </settings>' > /root/.m2/settings.xml

# 复制pom.xml并下载依赖（利用Docker缓存层）
COPY pom.xml .
RUN mvn dependency:go-offline -B

# 复制源代码并构建
COPY src ./src
RUN mvn clean package -DskipTests -B

# 第二阶段：运行
FROM eclipse-temurin:8-jre-alpine

LABEL maintainer="card-learn"
LABEL version="1.0.0"
LABEL description="考研知识点学习卡片系统后端"

WORKDIR /app

# 安装必要工具
RUN apk add --no-cache tzdata curl bash \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && apk del tzdata

# 从构建阶段复制jar包
COPY --from=builder /build/target/*.jar app.jar

# 创建日志目录
RUN mkdir -p /app/logs

# 暴露端口
EXPOSE 8080

# 设置环境变量
ENV JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC"
ENV SPRING_PROFILES_ACTIVE="docker"

# 启动命令
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -Dspring.profiles.active=$SPRING_PROFILES_ACTIVE -jar app.jar"]