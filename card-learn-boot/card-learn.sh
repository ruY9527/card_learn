#!/bin/bash

# ============================================================================
# card-learn-boot 服务管理脚本
# 功能：启动、停止、重启、状态查看、日志清理
# ============================================================================

set -e

# ==================== 基础配置 ====================
APP_NAME="card-learn-boot"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_HOME="$(cd "$SCRIPT_DIR/.." && pwd)"

# 目录配置
JAR_DIR="${APP_HOME}"
CONF_DIR="${JAR_DIR}/conf"
LOG_DIR="${JAR_DIR}/logs"
PID_FILE="${JAR_DIR}/${APP_NAME}.pid"

# JVM 配置
JVM_XMS="256m"
JVM_XMX="512m"
JVM_META_SIZE="128m"
JVM_MAX_META_SIZE="256m"

# GC 配置
GC_TYPE="G1"  # 可选: G1, CMS, Parallel
GC_LOG_FILE="${LOG_DIR}/gc.log"

# 日志清理配置
LOG_RETENTION_DAYS=7
LOG_MAX_SIZE_MB=100

# ==================== 颜色输出 ====================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo "${RED}[ERROR]${NC} $1"
}

# ==================== 辅助函数 ====================

# 查找 jar 文件
find_jar() {
    local jar_file=""
    # 优先查找 target 目录（开发环境）
    if [ -d "${JAR_DIR}/target" ]; then
        jar_file=$(find "${JAR_DIR}/target" -name "${APP_NAME}*.jar" -type f | grep -v '\.original' | head -1)
    fi
    # 如果没找到，查找当前目录
    if [ -z "$jar_file" ]; then
        jar_file=$(find "${JAR_DIR}" -maxdepth 1 -name "${APP_NAME}*.jar" -type f | head -1)
    fi
    echo "$jar_file"
}

# 查找配置文件
find_config() {
    local config_file=""
    # 查找 conf 目录下的 yml 文件
    if [ -d "$CONF_DIR" ]; then
        config_file=$(find "$CONF_DIR" -name "*.yml" -o -name "*.yaml" | head -1)
    fi
    echo "$config_file"
}

# 检查服务是否运行
is_running() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            return 0
        else
            # PID 文件存在但进程不存在，清理 PID 文件
            rm -f "$PID_FILE"
            return 1
        fi
    fi
    return 1
}

# 获取进程 PID
get_pid() {
    if [ -f "$PID_FILE" ]; then
        cat "$PID_FILE"
    else
        echo ""
    fi
}

# 构建 JVM 参数
build_jvm_opts() {
    local opts=""
    
    # 内存配置
    opts="-Xms${JVM_XMS} -Xmx${JVM_XMX}"
    opts="$opts -XX:MetaspaceSize=${JVM_META_SIZE} -XX:MaxMetaspaceSize=${JVM_MAX_META_SIZE}"
    
    # GC 配置
    case "$GC_TYPE" in
        "G1")
            opts="$opts -XX:+UseG1GC"
            opts="$opts -XX:MaxGCPauseMillis=200"
            opts="$opts -XX:G1HeapRegionSize=4m"
            opts="$opts -XX:InitiatingHeapOccupancyPercent=45"
            ;;
        "CMS")
            opts="$opts -XX:+UseConcMarkSweepGC"
            opts="$opts -XX:CMSInitiatingOccupancyFraction=70"
            opts="$opts -XX:+UseCMSInitiatingOccupancyOnly"
            ;;
        "Parallel")
            opts="$opts -XX:+UseParallelGC"
            ;;
    esac
    
    # GC 日志配置 (JDK8/9+ 通用格式)
    opts="$opts -Xloggc:${GC_LOG_FILE}"
    opts="$opts -XX:+PrintGCDetails"
    opts="$opts -XX:+PrintGCDateStamps"
    opts="$opts -XX:+PrintGCTimeStamps"
    opts="$opts -XX:+PrintGCApplicationStoppedTime"
    
    # 其他优化参数
    opts="$opts -XX:+HeapDumpOnOutOfMemoryError"
    opts="$opts -XX:HeapDumpPath=${LOG_DIR}/heap_dump.hprof"
    opts="$opts -XX:ErrorFile=${LOG_DIR}/hs_err_pid%p.log"
    
    # 安全随机数生成
    opts="$opts -Djava.security.egd=file:/dev/./urandom"
    
    # 字符编码
    opts="$opts -Dfile.encoding=UTF-8"
    opts="$opts -Dsun.jnu.encoding=UTF-8"
    
    echo "$opts"
}

# 确保目录存在
ensure_dirs() {
    mkdir -p "$LOG_DIR"
    mkdir -p "$CONF_DIR"
}

# ==================== 主要功能 ====================

# 启动服务
start() {
    print_info "正在启动 ${APP_NAME}..."
    
    if is_running; then
        print_warning "${APP_NAME} 已经在运行中，PID: $(get_pid)"
        return 1
    fi
    
    ensure_dirs
    
    # 查找 jar 文件
    local jar_file=$(find_jar)
    if [ -z "$jar_file" ]; then
        print_error "未找到 jar 文件"
        return 1
    fi
    print_info "JAR 文件: $jar_file"
    
    # 查找配置文件
    local config_file=$(find_config)
    local config_param=""
    if [ -n "$config_file" ]; then
        config_param="--spring.config.location=file:${config_file}"
        print_info "配置文件: $config_file"
    else
        print_warning "未找到配置文件，使用默认配置"
    fi
    
    # 构建 JVM 参数
    local jvm_opts=$(build_jvm_opts)
    
    # 启动命令
    local start_cmd="java ${jvm_opts} -jar ${jar_file} ${config_param}"
    
    print_info "启动命令: $start_cmd"
    
    # 后台启动
    nohup $start_cmd > "${LOG_DIR}/console.log" 2>&1 &
    
    local pid=$!
    echo $pid > "$PID_FILE"
    
    # 等待启动
    sleep 3
    
    if is_running; then
        print_success "${APP_NAME} 启动成功，PID: $pid"
        print_info "日志目录: $LOG_DIR"
        print_info "控制台日志: ${LOG_DIR}/console.log"
        print_info "GC 日志: ${GC_LOG_FILE}"
        return 0
    else
        print_error "${APP_NAME} 启动失败，请检查日志"
        cat "${LOG_DIR}/console.log" | tail -50
        return 1
    fi
}

# 停止服务
stop() {
    print_info "正在停止 ${APP_NAME}..."
    
    if ! is_running; then
        print_warning "${APP_NAME} 未运行"
        return 0
    fi
    
    local pid=$(get_pid)
    
    # 尝试优雅关闭
    print_info "发送 SIGTERM 信号到进程 $pid"
    kill $pid
    
    # 等待进程结束
    local count=0
    local max_wait=30
    while is_running && [ $count -lt $max_wait ]; do
        sleep 1
        count=$((count + 1))
        print_info "等待进程结束... ($count/$max_wait)"
    done
    
    if is_running; then
        print_warning "进程未响应 SIGTERM，强制终止..."
        kill -9 $pid
        sleep 2
    fi
    
    if is_running; then
        print_error "无法停止进程 $pid"
        return 1
    else
        rm -f "$PID_FILE"
        print_success "${APP_NAME} 已停止"
        return 0
    fi
}

# 重启服务
restart() {
    print_info "正在重启 ${APP_NAME}..."
    
    stop
    sleep 2
    start
}

# 查看状态
status() {
    print_info "${APP_NAME} 服务状态:"
    echo ""
    
    if is_running; then
        local pid=$(get_pid)
        print_success "运行中 - PID: $pid"
        
        # 显示进程信息
        echo ""
        echo "进程信息:"
        ps -p $pid -o pid,ppid,user,%cpu,%mem,vsz,rss,etime,cmd | head -2
        
        # 显示端口监听
        echo ""
        echo "端口监听:"
        netstat -tlnp 2>/dev/null | grep $pid || ss -tlnp | grep $pid || print_warning "无法获取端口信息"
        
        # 显示 JVM 内存使用（如果 jstat 可用）
        if command -v jstat &> /dev/null; then
            echo ""
            echo "JVM 内存使用:"
            jstat -gc $pid 2>/dev/null || print_warning "无法获取 JVM 统计信息"
        fi
        
    else
        print_warning "未运行"
    fi
    
    # 显示日志目录状态
    echo ""
    echo "日志目录: $LOG_DIR"
    if [ -d "$LOG_DIR" ]; then
        local log_count=$(find "$LOG_DIR" -type f -name "*.log" | wc -l)
        local log_size=$(du -sh "$LOG_DIR" 2>/dev/null | cut -f1)
        echo "日志文件数: $log_count"
        echo "日志总大小: $log_size"
    fi
    
    # 显示配置文件状态
    echo ""
    echo "配置目录: $CONF_DIR"
    if [ -d "$CONF_DIR" ] && [ "$(ls -A $CONF_DIR 2>/dev/null)" ]; then
        ls -la "$CONF_DIR"
    else
        print_warning "配置目录为空或不存在"
    fi
}

# 清理日志
clean_logs() {
    print_info "正在清理日志文件..."
    ensure_dirs
    
    local cleaned_count=0
    local cleaned_size=0
    
    # 清理过期日志（按天数）
    if [ "$LOG_RETENTION_DAYS" -gt 0 ]; then
        print_info "清理超过 ${LOG_RETENTION_DAYS} 天的日志..."
        local old_logs=$(find "$LOG_DIR" -type f -name "*.log" -mtime +$LOG_RETENTION_DAYS)
        if [ -n "$old_logs" ]; then
            for log in $old_logs; do
                local size=$(stat -f%z "$log" 2>/dev/null || stat --printf="%s" "$log" 2>/dev/null)
                rm -f "$log"
                cleaned_count=$((cleaned_count + 1))
                cleaned_size=$((cleaned_size + size))
                print_info "删除: $log"
            done
        fi
    fi
    
    # 清理超大日志文件
    if [ "$LOG_MAX_SIZE_MB" -gt 0 ]; then
        print_info "检查超过 ${LOG_MAX_SIZE_MB}MB 的日志..."
        local large_logs=$(find "$LOG_DIR" -type f -name "*.log" -size +${LOG_MAX_SIZE_MB}M)
        if [ -n "$large_logs" ]; then
            for log in $large_logs; do
                # 截断日志而不是删除
                local size=$(stat -f%z "$log" 2>/dev/null || stat --printf="%s" "$log" 2>/dev/null)
                tail -c ${LOG_MAX_SIZE_MB}000000 "$log" > "${log}.tmp"
                mv "${log}.tmp" "$log"
                print_info "截断: $log (原大小: $size bytes)"
            done
        fi
    fi
    
    # 清理 GC 日志历史文件
    local gc_logs=$(find "$LOG_DIR" -type f -name "gc.log.*" | sort -r | tail -n +10)
    if [ -n "$gc_logs" ]; then
        for log in $gc_logs; do
            rm -f "$log"
            print_info "删除历史 GC 日志: $log"
        done
    fi
    
    # 清理 heap dump 文件（保留最新的）
    local heap_dumps=$(find "$LOG_DIR" -type f -name "heap_dump*.hprof" | sort -r | tail -n +3)
    if [ -n "$heap_dumps" ]; then
        for dump in $heap_dumps; do
            rm -f "$dump"
            print_info "删除历史 heap dump: $dump"
        done
    fi
    
    # 清理错误日志（保留最新的）
    local err_logs=$(find "$LOG_DIR" -type f -name "hs_err_pid*.log" | sort -r | tail -n +5)
    if [ -n "$err_logs" ]; then
        for log in $err_logs; do
            rm -f "$log"
            print_info "删除历史错误日志: $log"
        done
    fi
    
    if [ $cleaned_count -gt 0 ]; then
        local cleaned_size_mb=$((cleaned_size / 1024 / 1024))
        print_success "清理完成，删除 $cleaned_count 个文件，释放 ${cleaned_size_mb}MB"
    else
        print_info "无需清理"
    fi
    
    # 显示当前日志目录大小
    local current_size=$(du -sh "$LOG_DIR" 2>/dev/null | cut -f1)
    print_info "当前日志目录大小: $current_size"
}

# 查看日志
view_logs() {
    local log_type=${1:-"console"}
    
    case "$log_type" in
        "console")
            local log_file="${LOG_DIR}/console.log"
            ;;
        "gc")
            local log_file="${GC_LOG_FILE}"
            ;;
        *)
            local log_file="${LOG_DIR}/${log_type}.log"
            ;;
    esac
    
    if [ -f "$log_file" ]; then
        print_info "查看日志: $log_file"
        tail -100 "$log_file"
    else
        print_error "日志文件不存在: $log_file"
    fi
}

# 实时查看日志
tail_logs() {
    local log_type=${1:-"console"}
    
    case "$log_type" in
        "console")
            local log_file="${LOG_DIR}/console.log"
            ;;
        "gc")
            local log_file="${GC_LOG_FILE}"
            ;;
        *)
            local log_file="${LOG_DIR}/${log_type}.log"
            ;;
    esac
    
    if [ -f "$log_file" ]; then
        print_info "实时查看日志: $log_file (Ctrl+C 退出)"
        tail -f "$log_file"
    else
        print_error "日志文件不存在: $log_file"
    fi
}

# 设置 JVM 参数
set_jvm() {
    print_info "当前 JVM 配置:"
    echo "  XMS: ${JVM_XMS}"
    echo "  XMX: ${JVM_XMX}"
    echo "  MetaSize: ${JVM_META_SIZE}"
    echo "  MaxMetaSize: ${JVM_MAX_META_SIZE}"
    echo "  GC Type: ${GC_TYPE}"
    echo ""
    print_info "可通过环境变量修改配置:"
    echo "  export JVM_XMS=512m"
    echo "  export JVM_XMX=1024m"
    echo "  export GC_TYPE=G1"
}

# 帮助信息
help() {
    echo "用法: $0 <命令> [参数]"
    echo ""
    echo "命令:"
    echo "  start       启动服务"
    echo "  stop        停止服务"
    echo "  restart     重启服务"
    echo "  status      查看服务状态"
    echo "  clean       清理过期和超大日志文件"
    echo "  logs [type] 查看最近日志 (console/gc/自定义)"
    echo "  tail [type] 实时查看日志 (console/gc/自定义)"
    echo "  jvm         显示 JVM 配置信息"
    echo "  help        显示帮助信息"
    echo ""
    echo "环境变量配置:"
    echo "  JVM_XMS         初始堆内存大小 (默认: 256m)"
    echo "  JVM_XMX         最大堆内存大小 (默认: 512m)"
    echo "  JVM_META_SIZE   元空间初始大小 (默认: 128m)"
    echo "  JVM_MAX_META_SIZE 元空间最大大小 (默认: 256m)"
    echo "  GC_TYPE         GC类型 (G1/CMS/Parallel, 默认: G1)"
    echo "  LOG_RETENTION_DAYS 日志保留天数 (默认: 7)"
    echo "  LOG_MAX_SIZE_MB   单个日志最大大小MB (默认: 100)"
    echo ""
    echo "目录结构:"
    echo "  ${APP_HOME}/"
    echo "    ${APP_NAME}.jar      # jar 文件"
    echo "    conf/               # 配置文件目录"
    echo "      application.yml   # Spring 配置文件"
    echo "    logs/               # 日志目录"
    echo "      console.log       # 控制台日志"
    echo "      gc.log            # GC 日志"
    echo "    ${APP_NAME}.pid     # PID 文件"
}

# ==================== 主入口 ====================

# 读取环境变量覆盖默认配置
if [ -n "$JVM_XMS" ]; then JVM_XMS=$JVM_XMS; fi
if [ -n "$JVM_XMX" ]; then JVM_XMX=$JVM_XMX; fi
if [ -n "$JVM_META_SIZE" ]; then JVM_META_SIZE=$JVM_META_SIZE; fi
if [ -n "$JVM_MAX_META_SIZE" ]; then JVM_MAX_META_SIZE=$JVM_MAX_META_SIZE; fi
if [ -n "$GC_TYPE" ]; then GC_TYPE=$GC_TYPE; fi
if [ -n "$LOG_RETENTION_DAYS" ]; then LOG_RETENTION_DAYS=$LOG_RETENTION_DAYS; fi
if [ -n "$LOG_MAX_SIZE_MB" ]; then LOG_MAX_SIZE_MB=$LOG_MAX_SIZE_MB; fi

case "$1" in
    "start")
        start
        ;;
    "stop")
        stop
        ;;
    "restart")
        restart
        ;;
    "status")
        status
        ;;
    "clean")
        clean_logs
        ;;
    "logs")
        view_logs "$2"
        ;;
    "tail")
        tail_logs "$2"
        ;;
    "jvm")
        set_jvm
        ;;
    "help"|"-h"|"--help")
        help
        ;;
    *)
        print_error "未知命令: $1"
        help
        exit 1
        ;;
esac