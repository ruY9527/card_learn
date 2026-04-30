#!/bin/bash

# ============================================================================
# 编译并运行 card-learn-boot
# 功能：杀死旧进程 -> Maven 编译 -> 启动新服务
# ============================================================================

set -e

# 配置
APP_NAME="card-learn-boot"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
JAR_DIR="${SCRIPT_DIR}/target"
PID_FILE="${SCRIPT_DIR}/${APP_NAME}.pid"
LOG_DIR="${SCRIPT_DIR}/logs"
LOG_FILE="${LOG_DIR}/console.log"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ==================== 步骤1: 停止旧进程 ====================
stop_old_process() {
    print_info "检查是否有正在运行的 ${APP_NAME} 进程..."

    # 方法1: 通过 PID 文件查找
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            print_warning "发现旧进程 (PID: $pid)，正在停止..."
            kill "$pid" 2>/dev/null || true

            # 等待进程结束
            local count=0
            while ps -p "$pid" > /dev/null 2>&1 && [ $count -lt 15 ]; do
                sleep 1
                count=$((count + 1))
            done

            # 如果还没结束，强制杀死
            if ps -p "$pid" > /dev/null 2>&1; then
                print_warning "进程未响应，强制终止..."
                kill -9 "$pid" 2>/dev/null || true
                sleep 1
            fi

            print_success "旧进程已停止"
        fi
        rm -f "$PID_FILE"
    fi

    # 方法2: 通过进程名查找（防止 PID 文件丢失）
    local pids=$(pgrep -f "${APP_NAME}.*\.jar" 2>/dev/null || true)
    if [ -n "$pids" ]; then
        print_warning "发现残留进程: $pids，正在清理..."
        echo "$pids" | xargs kill 2>/dev/null || true
        sleep 2
        echo "$pids" | xargs kill -9 2>/dev/null || true
        print_success "残留进程已清理"
    fi
}

# ==================== 步骤2: Maven 编译 ====================
build_project() {
    print_info "开始 Maven 编译..."
    cd "$SCRIPT_DIR"

    # 跳过测试进行编译
    mvn clean package -DskipTests -q

    if [ $? -eq 0 ]; then
        print_success "Maven 编译成功"
    else
        print_error "Maven 编译失败"
        exit 1
    fi
}

# ==================== 步骤3: 启动新服务 ====================
start_service() {
    print_info "启动 ${APP_NAME}..."

    # 查找 jar 文件
    local jar_file=$(find "$JAR_DIR" -name "${APP_NAME}*.jar" -type f | grep -v '\.original' | head -1)

    if [ -z "$jar_file" ]; then
        print_error "未找到编译后的 jar 文件"
        exit 1
    fi

    print_info "JAR 文件: $jar_file"

    # 确保日志目录存在
    mkdir -p "$LOG_DIR"

    # 查找配置文件
    local config_param=""
    local config_file="${SCRIPT_DIR}/conf/application.yml"
    if [ -f "$config_file" ]; then
        config_param="--spring.config.location=file:${config_file}"
        print_info "配置文件: $config_file"
    fi

    # JVM 参数
    local jvm_opts="-Xms256m -Xmx512m"
    jvm_opts="$jvm_opts -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=256m"
    jvm_opts="$jvm_opts -XX:+UseG1GC"
    jvm_opts="$jvm_opts -XX:+HeapDumpOnOutOfMemoryError"
    jvm_opts="$jvm_opts -XX:HeapDumpPath=${LOG_DIR}/heap_dump.hprof"
    jvm_opts="$jvm_opts -Djava.security.egd=file:/dev/./urandom"
    jvm_opts="$jvm_opts -Dfile.encoding=UTF-8"

    # 后台启动
    nohup java ${jvm_opts} -jar "${jar_file}" ${config_param} > "${LOG_FILE}" 2>&1 &
    local pid=$!
    echo $pid > "$PID_FILE"

    # 等待启动
    print_info "等待服务启动..."
    sleep 5

    if ps -p "$pid" > /dev/null 2>&1; then
        print_success "${APP_NAME} 启动成功!"
        echo ""
        echo "  PID:      $pid"
        echo "  日志:     $LOG_FILE"
        echo "  PID文件:  $PID_FILE"
        echo ""
        print_info "使用以下命令查看日志:"
        echo "  tail -f $LOG_FILE"
    else
        print_error "${APP_NAME} 启动失败，请查看日志:"
        echo "  tail -50 $LOG_FILE"
        exit 1
    fi
}

# ==================== 主流程 ====================
main() {
    echo ""
    echo "=========================================="
    echo "  ${APP_NAME} 编译并运行"
    echo "=========================================="
    echo ""

    stop_old_process
    build_project
    start_service

    echo ""
    print_success "完成!"
}

main
