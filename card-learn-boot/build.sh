#!/bin/bash

# ============================================================================
# card-learn-boot 编译脚本
# 支持 JDK 8 和 JDK 17，以 JDK 17 为主
#
# 使用方法:
#   ./build.sh            # 交互式选择
#   ./build.sh jdk17      # 编译 JDK17 版本
#   ./build.sh jdk8       # 编译 JDK8 版本
#   ./build.sh clean      # 清理
#   ./build.sh help       # 显示帮助
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="card-learn-boot"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

JDK_VERSION="${JDK_VERSION:-auto}"
JDK8_HOME="${JDK8_HOME:-}"
JDK17_HOME="${JDK17_HOME:-}"

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_header() { echo -e "${CYAN}==>${NC} $1"; }

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
    case "$version" in
        8)
            if [ -n "$JDK8_HOME" ] && [ -d "$JDK8_HOME" ]; then
                export JAVA_HOME="$JDK8_HOME"
            fi
            ;;
        17)
            if [ -n "$JDK17_HOME" ] && [ -d "$JDK17_HOME" ]; then
                export JAVA_HOME="$JDK17_HOME"
            fi
            ;;
    esac
}

get_java_cmd() {
    if [ -n "$JAVA_HOME" ] && [ -d "$JAVA_HOME" ]; then
        echo "$JAVA_HOME/bin/java"
    else
        echo "java"
    fi
}

build_jdk17() {
    print_header "使用 JDK 17 编译..."
    set_java_home 17
    local java_cmd=$(get_java_cmd)
    local java_ver=$($java_cmd -version 2>&1 | head -1 | cut -d'"' -f2)
    print_info "Java 版本: $java_ver"
    print_info "JAVA_HOME: ${JAVA_HOME:-"(系统默认)"}"

    cd "$SCRIPT_DIR"
    mvn clean package -DskipTests -Djdk.version=17

    print_success "JDK 17 编译完成!"
}

build_jdk8() {
    print_header "使用 JDK 8 编译..."
    set_java_home 8
    local java_cmd=$(get_java_cmd)
    local java_ver=$($java_cmd -version 2>&1 | head -1 | cut -d'"' -f2)
    print_info "Java 版本: $java_ver"
    print_info "JAVA_HOME: ${JAVA_HOME:-"(系统默认)"}"

    cd "$SCRIPT_DIR"
    mvn clean package -DskipTests -Djdk.version=8

    print_success "JDK 8 编译完成!"
}

build_auto() {
    local detected_ver=$(detect_jdk_version)
    print_info "自动检测到 JDK 版本: $detected_ver"

    if [ "$detected_ver" = "8" ]; then
        build_jdk8
    else
        build_jdk17
    fi
}

show_jar() {
    print_header "构建产物:"
    local jar_file=$(find "${SCRIPT_DIR}/target" -name "${APP_NAME}*.jar" -type f | grep -v '\.original' | head -1)
    if [ -n "$jar_file" ]; then
        local size=$(du -h "$jar_file" | cut -f1)
        print_success "JAR: $jar_file (${size})"
    else
        print_warning "未找到构建产物，请先编译"
    fi
}

show_java_versions() {
    print_header "可用 JDK 版本检测"

    if [ -n "$JDK17_HOME" ] && [ -d "$JDK17_HOME" ]; then
        local ver=$("$JDK17_HOME/bin/java" -version 2>&1 | head -1 | cut -d'"' -f2)
        print_success "JDK 17: $JDK17_HOME ($ver)"
    elif [ -d "/Library/Java/JavaVirtualMachines/jdk-17*" ]; then
        local jdk17=$(ls -d /Library/Java/JavaVirtualMachines/jdk-17* 2>/dev/null | head -1)
        if [ -n "$jdk17" ]; then
            local ver=$("$jdk17/Contents/Home/bin/java" -version 2>&1 | head -1 | cut -d'"' -f2)
            print_success "JDK 17: $jdk17 ($ver)"
        fi
    else
        print_warning "JDK 17: 未配置或未找到"
    fi

    if [ -n "$JDK8_HOME" ] && [ -d "$JDK8_HOME" ]; then
        local ver=$("$JDK8_HOME/bin/java" -version 2>&1 | head -1 | cut -d'"' -f2)
        print_success "JDK 8: $JDK8_HOME ($ver)"
    elif [ -d "/Library/Java/JavaVirtualMachines/jdk1.8*" ]; then
        local jdk8=$(ls -d /Library/Java/JavaVirtualMachines/jdk1.8* 2>/dev/null | head -1)
        if [ -n "$jdk8" ]; then
            local ver=$("$jdk8/Contents/Home/bin/java" -version 2>&1 | head -1 | cut -d'"' -f2)
            print_success "JDK 8: $jdk8 ($ver)"
        fi
    else
        print_warning "JDK 8: 未配置或未找到"
    fi

    local sys_java=$(java -version 2>&1 | head -1 | cut -d'"' -f2)
    print_info "系统默认: $sys_java"
}

help() {
    echo ""
    echo "=========================================="
    echo "  ${APP_NAME} 编译脚本"
    echo "=========================================="
    echo ""
    echo "用法: $0 [命令] [选项]"
    echo ""
    echo "命令:"
    echo "  jdk17       使用 JDK 17 编译 (默认)"
    echo "  jdk8        使用 JDK 8 编译"
    echo "  auto        自动检测 JDK 版本编译"
    echo "  clean       清理构建产物"
    echo "  show        显示构建产物"
    echo "  versions    显示可用 JDK 版本"
    echo "  help        显示帮助信息"
    echo ""
    echo "环境变量:"
    echo "  JDK_VERSION       指定 JDK 版本 (8 或 17, 默认: auto)"
    echo "  JDK8_HOME         JDK 8 安装路径"
    echo "  JDK17_HOME       JDK 17 安装路径"
    echo ""
    echo "示例:"
    echo "  $0 jdk17                    # 使用 JDK17 编译"
    echo "  $0 jdk8                     # 使用 JDK8 编译"
    echo "  JDK_VERSION=17 $0           # 通过环境变量指定"
    echo "  JDK17_HOME=/opt/jdk17 $0    # 指定 JDK17 路径"
    echo ""
}

case "${1:-auto}" in
    "jdk17")
        build_jdk17
        show_jar
        ;;
    "jdk8")
        build_jdk8
        show_jar
        ;;
    "auto")
        build_auto
        show_jar
        ;;
    "clean")
        print_info "清理构建产物..."
        cd "$SCRIPT_DIR"
        mvn clean -q
        print_success "清理完成"
        ;;
    "show")
        show_jar
        ;;
    "versions")
        show_java_versions
        ;;
    "help"|"-h"|"--help")
        help
        ;;
    *)
        print_error "未知命令: $1"
        echo "使用 '$0 help' 查看帮助"
        exit 1
        ;;
esac