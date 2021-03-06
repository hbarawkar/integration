#-
# ============LICENSE_START=======================================================
#  Copyright (C) 2020 Nordix Foundation.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0
# ============LICENSE_END=========================================================

FROM python:3.7.6-alpine3.11 as build

ARG libyang_version=v1.0-r5
ARG sysrepo_version=v0.7.9
ARG libnetconf2_version=v0.12-r2
ARG netopeer2_version=v0.7-r2

WORKDIR /usr/src

RUN set -eux \
      && apk add \
         autoconf \
         bash \
         build-base \
         cmake \
         curl-dev \
         file \
         git \
         libev-dev \
         openssh-keygen \
         openssl \
         openssl-dev \
         pcre-dev \
         pkgconfig \
         protobuf-c-dev \
         swig \
         # for troubleshooting
         the_silver_searcher \
         vim \
      # v0.9.3 has somes bugs as warned in libnetconf2/CMakeLists.txt:237
      && apk add --repository http://dl-cdn.alpinelinux.org/alpine/v3.10/main libssh-dev==0.8.8-r0

RUN git config --global advice.detachedHead false

ENV PKG_CONFIG_PATH=/opt/lib64/pkgconfig
ENV LD_LIBRARY_PATH=/opt/lib:/opt/lib64


# libyang
COPY patches/libyang/ ./patches/libyang/
RUN set -eux \
      && git clone --branch $libyang_version --depth 1 https://github.com/CESNET/libyang.git \
      && cd libyang \
      && for p in ../patches/libyang/*.patch; do patch -p1 -i $p; done \
      && mkdir build && cd build \
      && cmake -DCMAKE_BUILD_TYPE:String="Release" -DENABLE_BUILD_TESTS=OFF \
         -DCMAKE_INSTALL_PREFIX:PATH=/opt \
         -DGEN_LANGUAGE_BINDINGS=ON \
         -DPYTHON_MODULE_PATH:PATH=/opt/lib/python3.7/site-packages \
         .. \
      && make -j2 \
      && make install

RUN set -eux \
      && git clone --depth 1 https://github.com/sysrepo/libredblack.git \
      && cd libredblack \
      && ./configure --prefix=/opt --without-rbgen \
      && make \
      && make install

# sysrepo
COPY patches/sysrepo/ ./patches/sysrepo/
RUN set -eux \
      && git clone --branch $sysrepo_version --depth 1 https://github.com/sysrepo/sysrepo.git \
      && cd sysrepo \
      && for p in ../patches/sysrepo/*.patch; do patch -p1 -i $p; done \
      && mkdir build && cd build \
      && cmake -DCMAKE_BUILD_TYPE:String="Release" -DENABLE_TESTS=OFF \
         -DREPOSITORY_LOC:PATH=/opt/etc/sysrepo \
         -DCMAKE_INSTALL_PREFIX:PATH=/opt \
         -DGEN_PYTHON_VERSION=3 \
         -DPYTHON_MODULE_PATH:PATH=/opt/lib/python3.7/site-packages \
         .. \
      && make -j2 \
      && make install

# libnetconf2
COPY patches/libnetconf2/ ./patches/libnetconf2/
RUN set -eux \
      && git clone --branch $libnetconf2_version --depth 1 https://github.com/CESNET/libnetconf2.git \
      && cd libnetconf2 \
      && for p in ../patches/libnetconf2/*.patch; do patch -p1 -i $p; done \
      && mkdir build && cd build \
      && cmake -DCMAKE_BUILD_TYPE:String="Release" -DENABLE_BUILD_TESTS=OFF \
         -DCMAKE_INSTALL_PREFIX:PATH=/opt \
         -DENABLE_PYTHON=ON \
         -DPYTHON_MODULE_PATH:PATH=/opt/lib/python3.7/site-packages \
         .. \
      && make \
      && make install

# keystore
COPY patches/Netopeer2/ ./patches/Netopeer2/
RUN set -eux \
      && git clone --branch $netopeer2_version --depth 1 https://github.com/CESNET/Netopeer2.git \
      && cd Netopeer2 \
      && for p in ../patches/Netopeer2/*.patch; do patch -p1 -i $p; done \
      && cd keystored \
      && mkdir build && cd build \
      && cmake -DCMAKE_BUILD_TYPE:String="Release" \
         -DCMAKE_INSTALL_PREFIX:PATH=/opt \
         .. \
      && make -j2 \
      && make install

# netopeer2
RUN set -eux \
      && cd Netopeer2/server \
      && mkdir build && cd build \
      && cmake -DCMAKE_BUILD_TYPE:String="Release" \
         -DCMAKE_INSTALL_PREFIX:PATH=/opt \
         .. \
      && make -j2 \
      && make install

FROM python:3.7.6-alpine3.11
LABEL authors="eliezio.oliveira@est.tech"

RUN set -eux \
      && pip install supervisor \
      && apk update \
      && apk upgrade -a \
      && apk add \
         libcurl \
         libev \
         openssh-keygen \
         pcre \
         protobuf-c \
      # v0.9.3 has somes bugs as warned in libnetconf2/CMakeLists.txt:237
      && apk add --repository http://dl-cdn.alpinelinux.org/alpine/v3.10/main libssh==0.8.8-r0 \
      && rm -rf /var/cache/apk/*

COPY --from=build /opt/ /opt/

ENV LD_LIBRARY_PATH=/opt/lib:/opt/lib64

COPY config/ /config
VOLUME /config

# finish setup and add netconf user
RUN adduser --system --disabled-password --gecos 'Netconf User' netconf

ENV HOME=/home/netconf
VOLUME $HOME/.local/share/virtualenvs

# generate ssh keys for netconf user
RUN set -eux \
      && mkdir -p $HOME/.cache \
      && mkdir -p $HOME/.ssh \
      && ssh-keygen -t dsa -P '' -f $HOME/.ssh/id_dsa \
      && cat $HOME/.ssh/id_dsa.pub > $HOME/.ssh/authorized_keys

EXPOSE 830

COPY supervisord.conf /etc/supervisord.conf
RUN mkdir /etc/supervisord.d

COPY entrypoint.sh /opt/bin/

CMD /opt/bin/entrypoint.sh
