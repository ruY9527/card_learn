#!/bin/bash

# ============================================================================
# 启动前端服务 (card-ui)
# 先停止旧进程再启动
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="${SCRIPT_DIR}/card-ui"
PID_FILE="${APP_DIR}/dev.pid"
LOG_FILE="${APP_DIR}/dev.log"

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
stop_old() {
    print_info "检查是否有正在运行的 card-ui 开发服务..."

    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            print_warning "发现旧进程 (PID: $pid)，正在停止..."
            kill "$pid" 2>/dev/null || true
            sleep 2
            if ps -p "$pid" > /dev/null 2>&1; then
                kill -9 "$pid" 2>/dev/null || true
                sleep 1
            fi
            print_success "旧进程已停止"
        fi
        rm -f "$PID_FILE"
    fi

    # 清理残留的 vite/node 进程
    local pids=$(pgrep -f "vite.*${APP_DIR}" 2>/dev/null || true)
    if [ -n "$pids" ]; then
        print_warning "发现残留进程: $pids，正在清理..."
        echo "$pids" | xargs kill 2>/dev/null || true
        sleep 2
        echo "$pids" | xargs kill -9 2>/dev/null || true
        print_success "残留进程已清理"
    fi
}

# ==================== 安装依赖 ====================
install_deps() {
    if [ ! -d "${APP_DIR}/node_modules" ]; then
        print_info "首次运行，安装依赖..."
        cd "$APP_DIR"
        npm install
        print_success "依赖安装完成"
    fi
}

# ==================== 启动服务 ====================
start() {
    print_info "启动 card-ui 开发服务..."
    cd "$APP_DIR"

    nohup npx vite --host > "$LOG_FILE" 2>&1 &
    local pid=$!
    echo $pid > "$PID_FILE"

    sleep 3

    if ps -p "$pid" > /dev/null 2>&1; then
        # 从日志中获取端口
        local port=$(grep -o 'http://[^ ]*' "$LOG_FILE" | head -1)
        print_success "card-ui 启动成功!"
        echo ""
        echo "  PID: $pid"
        echo "  地址: ${port:-http://localhost:5173}"
        echo "  日志: $LOG_FILE"
        echo ""
        print_info "查看日志: tail -f $LOG_FILE"
    else
        print_error "card-ui 启动失败，请查看日志:"
        echo "  cat $LOG_FILE"
        exit 1
    fi
}

# ==================== 主流程 ====================
echo ""
echo "=========================================="
echo "  card-ui 前端服务启动"
echo "=========================================="
echo ""

stop_old
install_deps
start

echo ""
print_success "完成!"
