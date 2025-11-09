#!/bin/bash

PROJECT_ROOT="$(pwd)"

ZIP_NAME="Anykernel3_Oneplus_Ace5_O2_$(date +%Y%m%d_%H%M).zip"

log() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local color_reset='\033[0m'
    local color_green='\033[0;32m'
    local color_yellow='\033[0;33m'
    local color_red='\033[0;31m'

    case "$level" in
        INFO)
            echo -e "${color_green}[$timestamp] INFO: ${message}${color_reset}"
            ;;
        WARN)
            echo -e "${color_yellow}[$timestamp] WARN: ${message}${color_reset}"
            ;;
        ERROR)
            echo -e "${color_red}[$timestamp] ERROR: ${message}${color_reset}"
            exit 1
            ;;
        *)
            echo -e "[$timestamp] UNKNOWN: ${message}"
            ;;
    esac
}

for cmd in curl zip git; do
    if ! command -v "$cmd" &>/dev/null; then
        log ERROR "缺少依赖命令: $cmd"
    fi
done

log INFO "正在构建内核..."
tools/bazel build --config=fast //common:kernel_aarch64_dist || log ERROR "内核构建失败。"
log INFO "内核构建成功。"

log INFO "正在检查内核镜像文件是否存在..."
KERNEL_IMAGE="$PROJECT_ROOT/bazel-bin/common/kernel_aarch64/Image"
if [[ -f "$KERNEL_IMAGE" ]]; then
    log INFO "内核镜像文件存在。"
else
    log ERROR "内核镜像文件不存在: $KERNEL_IMAGE"
fi

log INFO "正在检查打包目录是否存在..."
PACK_DIR="$PROJECT_ROOT/packup"
if [[ -d "$PACK_DIR" ]]; then
    log INFO "打包目录已存在，跳过创建。"
else
    log WARN "打包目录不存在，正在创建..."
    mkdir -p "$PACK_DIR" || log ERROR "创建打包目录失败。"
fi

log INFO "正在转移到打包目录..."
cd "$PACK_DIR" || log ERROR "无法进入打包目录。"

log INFO "正在检查 Anykernel 目录是否存在..."
ANYKERNEL_DIR="$PACK_DIR/AnyKernel3"
if [[ -d "$ANYKERNEL_DIR" ]]; then
    log INFO "Anykernel 已存在，跳过克隆。"
else
    log WARN "Anykernel 不存在，正在克隆..."
    git clone https://github.com/YangQi0408/AnyKernel3.git "$ANYKERNEL_DIR" || log ERROR "克隆 Anykernel 失败。"
    rm -rf "$ANYKERNEL_DIR/.git"
fi

log INFO "正在复制内核镜像..."
cp "$KERNEL_IMAGE" "$ANYKERNEL_DIR/" || log ERROR "复制内核镜像失败。"

log INFO "正在打包内核..."
cd "$ANYKERNEL_DIR" || log ERROR "无法进入 AnyKernel3 目录。"
zip -r9 ../"$ZIP_NAME" . || log ERROR "打包内核失败。"
cd ..
log INFO "内核打包完成，文件位于：$PACK_DIR/$ZIP_NAME"
log INFO "包大小：$(numfmt --to=iec-i --suffix=B -d 0 < <(stat -c%s "$PACK_DIR/$ZIP_NAME"))"