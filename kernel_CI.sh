#!/usr/bin/env bash
#
# Copyright (C) 2020 Shashank's build script.
#
# Licensed under the General Public License.
# This program is free software; you can redistribute it and/or modify
# in the hope that it will be useful, but WITHOUT ANY WARRANTY;
#
#
# kernel building script.

DATE=$(TZ=Asia/Kolkata date +"%Y%m%d-%T")

# Colors makes things beautiful
export TERM=xterm

    red=$(tput setaf 1)             #  red
    grn=$(tput setaf 2)             #  green
    blu=$(tput setaf 4)             #  blue
    cya=$(tput setaf 6)             #  cyan
    txtrst=$(tput sgr0)             #  Reset

# Expect
export CHANNEL_ID="$ID" # Telegram Channel ID
export TELEGRAM_TOKEN="$BOT_API_KEY" # Bot ( admin ) on telegram channel
export TC_PATH="$HOME/toolchains" # Toolchain Directory
export ZIP_DIR="$HOME/zip" # AnyKernel3 ( by osm0sis ) Directory

# clone
git clone --depth=1 https://github.com/kdrag0n/proton-clang.git ${TC_PATH}/clang
rm -rf $ZIP_DIR && git clone https://github.com/shashank1436/anykernel $ZIP_DIR

# Export
export KBUILD_BUILD_HOST="shashank's buildbot"
export KBUILD_BUILD_USER="shashank"
export ARCH=arm64 
export SUBARCH=arm64
PATH="${TC_PATH}"clang/bin:$PATH"
export STRIP="${TC_PATH}/clang/aarch64-linux-gnu/bin/strip"

# Start compilation
make mido_defconfig O=out/
echo -e ${grn}"compilation started"${txtrst};
wait
make -j"$job" O=out \
	ARCH=arm64 \
	CC="ccache clang" \
	AR=llvm-ar \
	NM=llvm-nm \
	LD=ld.lld \
	STRIP=llvm-strip \
	OBJCOPY=llvm-objcopy \
	OBJDUMP=llvm-objdump \
	OBJSIZE=llvm-size \
	READELF=llvm-readelf \
	HOSTCC=clang \
	HOSTCXX=clang++ \
	HOSTAR=llvm-ar \
	HOSTLD=ld.lld \
	CROSS_COMPILE=aarch64-linux-gnu- \
	CROSS_COMPILE_ARM32=arm-linux-gnueabi- 

wait 
wait
echo -e ${blu}"ziping kernel img to flasher"${txtrst};
cp out/arch/arm64/boot/Image.gz-dtb "$ZIP_DIR"
cd "$ZIP_DIR"
mv Image.gz-dtb zImage 
zip -r FoxKernel_4.9_"$DATE".zip *
