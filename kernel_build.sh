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

# clean up zip
echo -e ${blu}"removing privies kernel zip"${txtrst}
cd zip && rm -rf *.zip && rm -rf zImage && cd ..

# Export
export KBUILD_BUILD_HOST="shashank's buildbot"
export KBUILD_BUILD_USER="shashank"
export LOCALVERSION=_EAS_Darkphoenix
export ARCH=arm64 
export SUBARCH=arm64
PATH="/home/shashank/toolchain/clang/bin:$PATH"
export STRIP=/home/shashank/toolchain/clang/aarch64-linux-gnu/bin/strip

# Clean out folder
if [ "$CLEAN" = "yes" ]
then echo -e ${blu}"Removing existing images"${txtrst}
make clean O=out
fi

# cache
if [ "$use_ccache" = "yes" ]; 
then echo -e ${blu}"CCACHE is enabled for this build"${txtrst} 
export CCACHE_EXEC=$(which ccache) 
export USE_CCACHE=1 
export CCACHE_DIR=/home/shashank/ccache/
ccache -M 75G
fi

if [ "$use_ccache" = "clean" ]; 
then export CCACHE_EXEC=$(which ccache) 
export CCACHE_DIR=/home/shashank/ccache
ccache -C
export USE_CCACHE=1 
ccache -M 75
wait 
echo -e ${grn}"CCACHE Cleared"${txtrst};
fi

# Start compilation
make mido_defconfig O=out/
echo -e ${grn}"compilation started"${txtrst};
wait
make -j"$job" O=out \
          ARCH=arm64 \
          AR=llvm-ar \
          NM=llvm-nm \
          OBJCOPY=llvm-objcopy \
          OBJDUMP=llvm-objdump \
	  STRIP=llvm-strip \
          CC=clang \
          CLANG_TRIPLE=aarch64-linux-gnu- \
          CROSS_COMPILE=aarch64-linux-gnu- \
	  CROSS_COMPILE_ARM32=arm-linux-gnueabi-

wait 
wait
echo -e ${blu}"ziping kernel img to flasher"${txtrst};
cp out/arch/arm64/boot/Image.gz-dtb zip
cd zip
mv Image.gz-dtb zImage 
zip -r FoxKernel_4.9_"$DATE".zip *
