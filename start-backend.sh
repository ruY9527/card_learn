#!/bin/bash

# ============================================================================
# 启动后端服务 (card-learn-boot)
# 前台运行，先停止旧进程，重新编译，直接启动
# 支持 JDK 8 和 JDK 17
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="${SCRIPT_DIR}/card-learn-boot"
APP_NAME="card-learn-boot"

JDK_VERSION="${JDK_VERSION:-auto}"
JDK8_HOME="${JDK8_HOME:-}"
JDK17_HOME="${JDK17_HOME:-}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

detect_jdk_version() {
    if [ "$JDK_VERSION" != "auto" ]; then
        echo "$JDK_VERSION"
        return
    fi

    local version=$(java -version 2>&1 | head -1 | cut -d'"' -f2 | cut -d'.' -f1)
    if [ "$version" = "1" ]; then
        java -version 2>&1 | head -1 | cut -d'"' -f2 | cut -d'.' -f2
    else
        echo "$version"
    fi
}

set_java_home() {
    local version=$1

    if [ "$version" = "8" ]; then
        if [ -n "$JDK8_HOME" ] && [ -d "$JDK8_HOME" ]; then
            JAVA_HOME="$JDK8_HOME"
        elif [ -n "$JAVA_HOME" ]; then
            :
        else
            JAVA_HOME=""
        fi
    elif [ "$version" = "17" ]; then
        if [ -n "$JDK17_HOME" ] && [ -d "$JDK17_HOME" ]; then
            JAVA_HOME="$JDK17_HOME"
        elif [ -n "$JAVA_HOME" ]; then
            :
        else
            JAVA_HOME=""
        fi
    else
        JAVA_HOME=""
    fi

    if [ -n "$JAVA_HOME" ]; then
        JAVA_CMD="$JAVA_HOME/bin/java"
        export JAVA_HOME
    else
        JAVA_CMD="java"
    fi
}

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

# ==================== 检测 JDK 版本 ====================
JDK_VER=$(detect_jdk_version)
print_info "JDK 版本: ${JDK_VER} (设置: ${JDK_VERSION})"

set_java_home "$JDK_VER"

# ==================== Maven 编译 ====================
print_info "开始 Maven 编译 (JDK ${JDK_VER})..."
cd "$APP_DIR"

if [ "$JDK_VER" = "17" ]; then
    mvn clean package -DskipTests -Djdk.version=17
else
    mvn clean package -DskipTests -Djdk.version=8
fi
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

jvm_opts="-Xms256m -Xmx512m"

if [ "$JDK_VER" -ge 17 ]; then
    jvm_opts="$jvm_opts -XX:+UseG1GC"
    jvm_opts="$jvm_opts -XX:MaxGCPauseMillis=200"
    jvm_opts="$jvm_opts -XX:+UseStringDeduplication"
else
    jvm_opts="$jvm_opts -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=256m"
    jvm_opts="$jvm_opts -XX:+UseG1GC"
fi

jvm_opts="$jvm_opts -XX:+HeapDumpOnOutOfMemoryError"
jvm_opts="$jvm_opts -Djava.security.egd=file:/dev/./urandom"
jvm_opts="$jvm_opts -Dfile.encoding=UTF-8"

print_info "启动 ${APP_NAME} (JDK ${JDK_VER})..."
echo ""

${JAVA_CMD} ${jvm_opts} -jar "${jar_file}" ${config_param}
