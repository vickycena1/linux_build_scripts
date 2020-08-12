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
# github ssh key generator script


ssh-keygen -t rsa -b 4096 -C "9945shashank@gmail.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
cat .ssh/id_rsa.pub
