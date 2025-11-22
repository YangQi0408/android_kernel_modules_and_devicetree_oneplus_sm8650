#!/bin/bash

PROJECT_ROOT="$(pwd)"
ZIP_NAME="Anykernel3_Oneplus_Ace5_O2_$(date +%Y%m%d_%H%M).zip"

# -------------------- 工具函数 --------------------
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

export PATH="/home/yangqi/kernel/ace5/kernel_platform/prebuilts/clang/host/linux-x86/clang-r487747c/bin:$PATH"
export PATH="/home/yangqi/kernel/ace5/kernel_platform/prebuilts/kernel-build-tools/linux-x86/bin:$PATH"
export CROSS_COMPILE=aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=arm-linux-gnueabi-
export ARCH=arm64
export SUBARCH=arm64
export CC="ccache clang"
export CCACHE_DIR="$HOME/.cache/ccache_ace5kernel" 
export KBUILD_BUILD_VERSION=1
export KBUILD_BUILD_USER="build-user"
export KBUILD_BUILD_HOST="build-host"
export KBUILD_BUILD_TIMESTAMP="Wed Aug 20 00:00:00 UTC 2024"

log INFO "Clang 版本信息："
clang --version

cd "$PROJECT_ROOT/common" || log ERROR "无法进入 common 目录"

log INFO "开始编译内核..."
make ARCH=arm64 CC="ccache clang" O=out gki_defconfig
make ARCH=arm64 O=out CC="ccache clang" -j"$(nproc --all)" || log ERROR "内核编译失败"

KERNEL_IMAGE="$PROJECT_ROOT/common/out/arch/arm64/boot/Image"
if [[ -f "$KERNEL_IMAGE" ]]; then
    log INFO "内核镜像已生成：$KERNEL_IMAGE"
else
    log ERROR "未找到内核镜像：$KERNEL_IMAGE"
fi

PACK_DIR="$PROJECT_ROOT/common/out"
if [[ -d "$PACK_DIR" ]]; then
    log INFO "打包目录已存在：$PACK_DIR"
else
    log WARN "创建打包目录：$PACK_DIR"
    mkdir -p "$PACK_DIR"
fi

cd "$PACK_DIR" || log ERROR "无法进入打包目录"

ANYKERNEL_DIR="$PACK_DIR/AnyKernel3"
if [[ -d "$ANYKERNEL_DIR" ]]; then
    log INFO "AnyKernel3 已存在，跳过克隆"
else
    log WARN "正在克隆 AnyKernel3..."
    git clone https://github.com/YangQi0408/AnyKernel3.git "$ANYKERNEL_DIR" || log ERROR "克隆失败"
    rm -rf "$ANYKERNEL_DIR/.git"
fi

log INFO "复制内核镜像到 AnyKernel3..."
cp "$KERNEL_IMAGE" "$ANYKERNEL_DIR/" || log ERROR "复制失败"

log INFO "正在打包 ZIP..."
cd "$ANYKERNEL_DIR" || log ERROR "无法进入 AnyKernel3 目录"
curl -LO https://github.com/ShirkNeko/SukiSU_KernelPatch_patch/releases/download/0.12.2/patch_linux || log ERROR "下载 KPM 补丁失败。"
chmod +x patch_linux
./patch_linux
rm -f Image patch_linux
mv oImage Image
zip -r9 "../$ZIP_NAME" . || log ERROR "打包失败"
cd ..

log INFO "打包完成：$PACK_DIR/$ZIP_NAME"
log INFO "包大小：$(numfmt --to=iec-i --suffix=B -d 0 < <(stat -c%s "$PACK_DIR/$ZIP_NAME"))"