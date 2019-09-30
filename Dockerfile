FROM python:3.6.8-slim-stretch

RUN echo "build audiowaveform" \
    && apt-get update \
    && apt-get install -y \
    git \
    make \
    cmake \
    g++ \
    libboost-all-dev \
    libmad0-dev \
    libid3tag0-dev \
    libsndfile1-dev \
    libgd-dev \
    && echo "installed audiowaveform dependencies" \
    && git clone https://github.com/bbc/audiowaveform.git /audiowaveform \
    && mkdir -p /audiowaveform/build \
    && cd /audiowaveform/build \
    && cmake -D ENABLE_TESTS=0 .. \
    && make \
    && make install \
    && echo "build audiowaveform done" \
    && apt-get remove -y \
    git \
    make \
    cmake \
    g++ \
    libboost-all-dev \
    libmad0-dev \
    libid3tag0-dev \
    libsndfile1-dev \
    libgd-dev \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /audiowaveform \
    && audiowaveform --help \
    && echo "audiowaveform works"

RUN apt-get update \
    && apt-get -y install \
    curl \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid 1000 node \
    && useradd --uid 1000 --gid node --shell /bin/bash --create-home node

ENV NODE_VERSION 10.16.3

RUN ARCH= && dpkgArch="$(dpkg --print-architecture)" \
    && case "${dpkgArch##*-}" in \
    amd64) ARCH='x64';; \
    ppc64el) ARCH='ppc64le';; \
    s390x) ARCH='s390x';; \
    arm64) ARCH='arm64';; \
    armhf) ARCH='armv7l';; \
    i386) ARCH='x86';; \
    *) echo "unsupported architecture"; exit 1 ;; \
    esac \
    && set -ex \
    && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz" \
    && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
    && tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs

ENV YARN_VERSION 1.13.0

RUN set -ex \
    && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
    && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz.asc" \
    && mkdir -p /opt \
    && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/ \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg \
    && rm yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz

WORKDIR /app
