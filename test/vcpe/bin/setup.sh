#!/bin/bash

# COPYRIGHT NOTICE STARTS HERE
#
# Copyright 2019 Samsung Electronics Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# COPYRIGHT NOTICE ENDS HERE

# This script prepares the runtime environment
# for running vCPE python scripts on Ubuntu 16.04,
# 18.04 and on Centos/Rhel 7.6.

if command -v apt-get > /dev/null;
then
    apt-get update
    apt-get -y install python gcc python-dev;
fi
if command -v yum > /dev/null;
then
    yum -y install python-devel gcc;
fi

curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py
pip install -I \
    ipaddress \
    pyyaml \
    mysql-connector-python \
    progressbar2 \
    python-novaclient \
    python-openstackclient \
    python-heatclient \
    kubernetes \
    netaddr
