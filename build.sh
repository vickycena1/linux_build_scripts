#!/usr/bin/env bash
#
# Copyright (C) 2019 PixysOS project.
# Copyright (C) 2020 Shashank patil custom script.
#
# Licensed under the General Public License.
# This program is free software; you can redistribute it and/or modify
# in the hope that it will be useful, but WITHOUT ANY WARRANTY;
#
#
# ROM building script.

# Colors makes things beautiful
export TERM=xterm

    red=$(tput setaf 1)             #  red
    grn=$(tput setaf 2)             #  green
    blu=$(tput setaf 4)             #  blue
    cya=$(tput setaf 6)             #  cyan
    txtrst=$(tput sgr0)             #  Reset

# CCACHE UMMM!!! Cooks my builds fast
export CCACHE_EXEC=$(which ccache)
export USE_CCACHE=1
export CCACHE_DIR=/home/shashank/ccache
ccache -M 75G

# Its Clean Time
make clean && make clobber

# Build ROM
source build/envsetup.sh
export username=shashank
export TEMPORARY_DISABLE_PATH_RESTRICTIONS=true
export KBUILD_BUILD_HOST="shashank'sBuildBot"
export KBUILD_BUILD_USER="shashank"
lunch dot_mido-eng
make bacon -j16
