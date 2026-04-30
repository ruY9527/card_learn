#!/bin/bash

# ============================================================================
# 启动后端服务 (card-learn-boot)
# 前台运行，先停止旧进程，重新编译，直接启动
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="${SCRIPT_DIR}/card-learn-boot"
APP_NAME="card-learn-boot"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ==================== 停止旧进程 ====================
print_info "检查是否有正在运行的 ${APP_NAME}..."
old_pids=$(pgrep -f "${APP_NAME}.*\.jar" 2>/dev/null || true)
if [ -n "$old_pids" ]; then
    print_warning "发现旧进程: $old_pids，正在停止..."
    echo "$old_pids" | xargs kill 2>/dev/null || true
    sleep 2
    echo "$old_pids" | xargs kill -9 2>/dev/null || true
    print_success "旧进程已停止"
else
    print_info "没有运行中的旧进程"
fi

# ==================== Maven 编译 ====================
print_info "开始 Maven 编译..."
cd "$APP_DIR"
mvn clean package -DskipTests
print_success "Maven 编译完成"

# ==================== 前台启动服务 ====================
jar_file=$(find "${APP_DIR}/target" -name "${APP_NAME}*.jar" -type f | grep -v '\.original' | head -1)
if [ -z "$jar_file" ]; then
    print_error "未找到编译后的 jar 文件"
    exit 1
fi

print_info "JAR 文件: $jar_file"

config_param=""
config_file="${APP_DIR}/conf/application.yml"
if [ -f "$config_file" ]; then
    config_param="--spring.config.location=file:${config_file}"
fi

jvm_opts="-Xms256m -Xmx512m -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=256m -XX:+HeapDumpOnOutOfMemoryError -Djava.security.egd=file:/dev/./urandom -Dfile.encoding=UTF-8"

print_info "启动 ${APP_NAME}..."
echo ""

java ${jvm_opts} -jar "${jar_file}" ${config_param}
