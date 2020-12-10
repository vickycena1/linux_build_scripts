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

# bot stuff
export CHANNEL_ID="$ID" # Telegram Channel ID
export TELEGRAM_TOKEN="$BOT_API_KEY" # Bot ( admin ) on telegram channel

# zip pusher
tg_pushzip() 
{
	curl -F document=@"$ZIP"  "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendDocument" \
			-F chat_id=$CHANNEL_ID \
			-F caption="Build Finished after $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds"
}

# Expect
export CHANNEL_ID="$ID" # Telegram Channel ID
export TELEGRAM_TOKEN="$BOT_API_KEY" # Bot ( admin ) on telegram channel
export TC_PATH="$HOME/mido/toolchains" # Toolchain Directory
export ZIP_DIR="$HOME/mido/zip" # AnyKernel3 ( by osm0sis ) Directory

# clone
git clone --depth=1 https://github.com/shashank1436/kernel_xiaomi_mido mido && cd mido
git clone --depth=1 https://github.com/kdrag0n/proton-clang.git ${TC_PATH}/clang
git clone https://github.com/shashank1436/anykernel $ZIP_DIR

# Export
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$MY_DIR" ]]; then MY_DIR="$PWD"; fi
export KBUILD_BUILD_HOST="shashank's buildbot"
export KBUILD_BUILD_USER="CI"
export ARCH=arm64
export SUBARCH=arm64
PATH="${TC_PATH}"clang/bin:$PATH"
export STRIP="${TC_PATH}/clang/aarch64-linux-gnu/bin/strip"
export IMG="$MY_DIR"/out/arch/arm64/boot/Image.gz-dtb

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

if [ -f "$IMG" ]; then
echo -e "$green << Build completed in $(($Diff / 60)) minutes and $(($Diff % 60)) seconds >> \n $white"
        else
                echo -e "$red << Failed to compile the kernel , Check up to find the error >>$white"
                tg_error "error.log" "$CHATID"
                exit 1
        fi

if [ -f "$IMG" ]; then
echo -e ${blu}"ziping kernel img to flasher"${txtrst};
cp out/arch/arm64/boot/Image.gz-dtb "$ZIP_DIR"
cd "$ZIP_DIR"
mv Image.gz-dtb zImage 
zip -r FoxKernel_4.9_"$DATE".zip *
ZIP=$(echo *.zip)
tg_pushzip
fi
