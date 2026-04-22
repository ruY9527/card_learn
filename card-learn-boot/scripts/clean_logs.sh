#!/bin/bash

# ============================================================================
# card-learn-boot 日志清理定时任务脚本
# 可配合 crontab 定期执行
# 
# 使用方法:
#   1. 直接执行: ./clean_logs.sh
#   2. 配置 crontab: 
#      crontab -e
#      添加: 0 3 * * * /path/to/card-learn-boot/scripts/clean_logs.sh >> /path/to/logs/clean.log 2>&1
#      (每天凌晨3点执行)
# ============================================================================

set -e

# 配置参数
APP_HOME="$(cd "$(dirname "$0")/.." && pwd)"
LOG_DIR="${APP_HOME}/logs"

# 日志保留配置
LOG_RETENTION_DAYS=${LOG_RETENTION_DAYS:-7}       # 普通日志保留天数
GC_LOG_RETENTION_DAYS=${GC_LOG_RETENTION_DAYS:-3} # GC日志保留天数
MAX_LOG_SIZE_MB=${MAX_LOG_SIZE_MB:-100}           # 单文件最大大小(MB)
MAX_TOTAL_SIZE_MB=${MAX_TOTAL_SIZE_MB:-500}       # 日志目录最大总大小(MB)

# 日志文件
CLEAN_LOG="${LOG_DIR}/clean.log"

# ==================== 函数定义 ====================

log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1"
    if [ -d "$LOG_DIR" ]; then
        echo "[$timestamp] $1" >> "$CLEAN_LOG"
    fi
}

# 确保日志目录存在
ensure_log_dir() {
    mkdir -p "$LOG_DIR"
}

# 清理过期日志文件
clean_expired_logs() {
    log "清理超过 ${LOG_RETENTION_DAYS} 天的日志文件..."
    
    local count=0
    local size=0
    
    # 查找并删除过期日志
    while IFS= read -r -d '' file; do
        file_size=$(stat -f%z "$file" 2>/dev/null || stat --printf="%s" "$file" 2>/dev/null || echo 0)
        rm -f "$file"
        count=$((count + 1))
        size=$((size + file_size))
        log "删除: $file ($(numfmt --to=iec $file_size 2>/dev/null || echo $file_size bytes))"
    done < <(find "$LOG_DIR" -type f -name "*.log" ! -name "clean.log" -mtime +$LOG_RETENTION_DAYS -print0)
    
    log "删除过期日志: $count 个文件，释放 ~$(numfmt --to=iec $size 2>/dev/null || echo $size bytes)"
}

# 清理过期 GC 日志
clean_gc_logs() {
    log "清理超过 ${GC_LOG_RETENTION_DAYS} 天的 GC 日志..."
    
    local count=0
    
    # 清理 gc.log.* 历史文件
    while IFS= read -r -d '' file; do
        rm -f "$file"
        count=$((count + 1))
        log "删除 GC 日志: $file"
    done < <(find "$LOG_DIR" -type f \( -name "gc.log.*" -o -name "gc-*.log" \) -mtime +$GC_LOG_RETENTION_DAYS -print0)
    
    # 保留最新的 GC 日志，截断过大的
    if [ -f "${LOG_DIR}/gc.log" ]; then
        gc_size=$(stat -f%z "${LOG_DIR}/gc.log" 2>/dev/null || stat --printf="%s" "${LOG_DIR}/gc.log" 2>/dev/null || echo 0)
        if [ $gc_size -gt $((MAX_LOG_SIZE_MB * 1024 * 1024)) ]; then
            # 保留最后 10MB
            tail -c 10485760 "${LOG_DIR}/gc.log" > "${LOG_DIR}/gc.log.tmp"
            mv "${LOG_DIR}/gc.log.tmp" "${LOG_DIR}/gc.log"
            log "截断 gc.log (原大小: $(numfmt --to=iec $gc_size 2>/dev/null))"
        fi
    fi
    
    log "清理 GC 日志: $count 个文件"
}

# 清理超大日志文件
clean_large_logs() {
    log "检查超过 ${MAX_LOG_SIZE_MB}MB 的日志文件..."
    
    local count=0
    
    while IFS= read -r -d '' file; do
        # 截断到 MAX_LOG_SIZE_MB
        tail -c $((MAX_LOG_SIZE_MB * 1024 * 1024)) "$file" > "${file}.tmp"
        mv "${file}.tmp" "$file"
        count=$((count + 1))
        log "截断: $file"
    done < <(find "$LOG_DIR" -type f -name "*.log" ! -name "clean.log" -size +${MAX_LOG_SIZE_MB}M -print0)
    
    log "截断超大日志: $count 个文件"
}

# 检查日志目录总大小
check_total_size() {
    log "检查日志目录总大小..."
    
    local total_size=$(du -sb "$LOG_DIR" 2>/dev/null | cut -f1 || du -s "$LOG_DIR" | awk '{print $1 * 1024}')
    local total_size_mb=$((total_size / 1024 / 1024))
    
    log "当前日志目录总大小: ${total_size_mb}MB"
    
    if [ $total_size_mb -gt $MAX_TOTAL_SIZE_MB ]; then
        log "警告: 日志目录大小超过限制 (${MAX_TOTAL_SIZE_MB}MB)，开始强制清理..."
        
        # 按时间排序，删除最旧的文件直到满足大小限制
        local target_size=$((MAX_TOTAL_SIZE_MB * 1024 * 1024 * 80 / 100))  # 清理到80%
        
        while [ $(du -sb "$LOG_DIR" 2>/dev/null | cut -f1 || echo 0) -gt $target_size ]; do
            oldest=$(find "$LOG_DIR" -type f -name "*.log" ! -name "clean.log" -printf '%T+ %p\n' 2>/dev/null | sort | head -1 | cut -d' ' -f2-)
            if [ -z "$oldest" ]; then
                break
            fi
            rm -f "$oldest"
            log "强制删除最旧文件: $oldest"
        done
    fi
}

# 清理 heap dump 和错误日志
clean_debug_files() {
    log "清理 heap dump 和错误日志..."
    
    # 清理旧的 heap dump 文件（保留最新的2个）
    local heap_count=$(find "$LOG_DIR" -type f -name "*.hprof" | wc -l)
    if [ $heap_count -gt 2 ]; then
        find "$LOG_DIR" -type f -name "*.hprof" -printf '%T+ %p\n' | sort -r | tail -n +3 | while read line; do
            file=$(echo "$line" | cut -d' ' -f2-)
            rm -f "$file"
            log "删除 heap dump: $file"
        done
    fi
    
    # 清理旧的 JVM 错误日志（保留最新的5个）
    local err_count=$(find "$LOG_DIR" -type f -name "hs_err_pid*.log" | wc -l)
    if [ $err_count -gt 5 ]; then
        find "$LOG_DIR" -type f -name "hs_err_pid*.log" -printf '%T+ %p\n' | sort -r | tail -n +6 | while read line; do
            file=$(echo "$line" | cut -d' ' -f2-)
            rm -f "$file"
            log "删除错误日志: $file"
        done
    fi
}

# 清理清理日志本身
clean_clean_log() {
    if [ -f "$CLEAN_LOG" ]; then
        clean_size=$(stat -f%z "$CLEAN_LOG" 2>/dev/null || stat --printf="%s" "$CLEAN_LOG" 2>/dev/null || echo 0)
        if [ $clean_size -gt 1048576 ]; then  # 1MB
            tail -100 "$CLEAN_LOG" > "${CLEAN_LOG}.tmp"
            mv "${CLEAN_LOG}.tmp" "$CLEAN_LOG"
            log "截断清理日志"
        fi
    fi
}

# ==================== 主执行 ====================

log "========== 开始日志清理任务 =========="
log "配置: 保留天数=${LOG_RETENTION_DAYS}, GC保留=${GC_LOG_RETENTION_DAYS}, 单文件上限=${MAX_LOG_SIZE_MB}MB, 总上限=${MAX_TOTAL_SIZE_MB}MB"

ensure_log_dir
clean_expired_logs
clean_gc_logs
clean_large_logs
clean_debug_files
check_total_size
clean_clean_log

log "========== 日志清理任务完成 =========="

# 显示清理后的状态
log "清理后状态:"
du -sh "$LOG_DIR" 2>/dev/null || log "无法获取目录大小"
find "$LOG_DIR" -type f -name "*.log" | wc -l | xargs -I {} log "日志文件数: {}"