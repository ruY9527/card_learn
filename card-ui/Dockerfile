# ==================== 多阶段构建 ====================

# 第一阶段：构建
FROM node:20-alpine AS builder

WORKDIR /app

# 设置 npm 镜像源（可选，国内环境加速）
RUN npm config set registry https://registry.npmmirror.com/

# 复制 package.json 和 package-lock.json
COPY package*.json ./

# 安装依赖
RUN npm ci --legacy-peer-deps

# 复制源代码
COPY . .

# 构建生产版本
RUN npm run build

# 第二阶段：生产环境
FROM nginx:alpine

LABEL maintainer="card-learn"
LABEL version="1.0.0"
LABEL description="考研知识点学习卡片管理系统前端"

# 安装 tzdata 设置时区
RUN apk add --no-cache tzdata \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && apk del tzdata

# 复制构建产物到 nginx 目录
COPY --from=builder /app/dist /usr/share/nginx/html

# 复制 nginx 配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 暴露端口
EXPOSE 80

# 启动 nginx
CMD ["nginx", "-g", "daemon off;"]