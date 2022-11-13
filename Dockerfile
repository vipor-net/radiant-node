# The Radiant Blockchain Developers
# The purpose of this image is to be able to host Radiant Node (RADN) and electrumx
# Build with: `docker build .`
# Public images at: https://hub.docker.com/repository/docker/radiantblockchain
FROM ubuntu:20.04 as BUILDER

LABEL maintainer="iotapi322@vipor.net"
LABEL version="1.2.0"
LABEL description="Docker image for radiantd node"



RUN \
   --mount=sharing=locked,type=cache,target=/var/lib/apt/ \
   --mount=sharing=locked,type=cache,target=/var/cache/apt \
   apt-get update && apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN \
   --mount=sharing=locked,type=cache,target=/var/lib/apt/ \
   --mount=sharing=locked,type=cache,target=/var/cache/apt \
   DEBIAN_FRONTEND=nointeractive apt-get install -y nodejs



ENV PACKAGES="\
  build-essential \
  libcurl4-openssl-dev \
  software-properties-common \
  ubuntu-drivers-common \
  pkg-config \
  libtool \
  git \
  clinfo \
  autoconf \
  automake \
  libjansson-dev \
  libevent-dev \
  uthash-dev \
  nodejs \
  vim \
  libboost-chrono-dev \
  libboost-filesystem-dev \
  libboost-test-dev \
  libboost-thread-dev \
  libevent-dev \
  libminiupnpc-dev \
  libssl-dev \
  libzmq3-dev \ 
  help2man \
  ninja-build \
  python3 \
  libdb++-dev \
  wget \
  cmake \
"
# Note can remove the opencl and ocl packages above when not building on a system for GPU/mining
# Included only for reference purposes if this container would be used for mining as well.

RUN \
   --mount=sharing=locked,type=cache,target=/var/lib/apt/ \
   --mount=sharing=locked,type=cache,target=/var/cache/apt \
   DEBIAN_FRONTEND=nointeractive \
   apt update && apt install --no-install-recommends -y   \
    build-essential \
    libcurl4-openssl-dev \
    software-properties-common \
    ubuntu-drivers-common \
    pkg-config \
    libtool \
    clinfo \
    autoconf \
    automake \
    libjansson-dev \
    libevent-dev \
    uthash-dev \
    nodejs \
    vim \
    libboost-chrono-dev \
    libboost-filesystem-dev \
    libboost-test-dev \
    libboost-thread-dev \
    libevent-dev \
    libminiupnpc-dev \
    libssl-dev \
    libzmq3-dev \
    help2man \
    ninja-build \
    python3 \
    libdb++-dev \
    wget \
    cmake \
     && \
    rm -rf /var/lib/apt/lists/* && \
    apt clean

 
# Install radiant-node
WORKDIR /root
COPY . /root/radiant-node/
RUN mkdir /root/radiant-node/build
WORKDIR /root/radiant-node/build
RUN cmake -DCMAKE_INSTALL_PREFIX=/build -j -GNinja .. -DBUILD_RADIANT_QT=OFF
RUN ninja -j0
RUN ninja install 

FROM ubuntu:20.04


WORKDIR /usr/local/
COPY --from=BUILDER /build/ /usr/local/


RUN \
   --mount=sharing=locked,type=cache,target=/var/lib/apt/ \
   --mount=sharing=locked,type=cache,target=/var/cache/apt \
   apt-get update && apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN \
   --mount=sharing=locked,type=cache,target=/var/lib/apt/ \
   --mount=sharing=locked,type=cache,target=/var/cache/apt \
   DEBIAN_FRONTEND=nointeractive apt-get install -y nodejs


RUN \
   --mount=sharing=locked,type=cache,target=/var/lib/apt/ \
   --mount=sharing=locked,type=cache,target=/var/cache/apt \
   DEBIAN_FRONTEND=nointeractive \
   apt update && apt install --no-install-recommends -y   \
  libcurl4-openssl-dev \
  software-properties-common \
  ubuntu-drivers-common \
  clinfo \
  libjansson-dev \
  libevent-dev \
  uthash-dev \
  vim \
  libboost-chrono-dev \
  libboost-filesystem-dev \
  libboost-test-dev \
  libboost-thread-dev \
  libevent-dev \
  libminiupnpc-dev \
  libssl-dev \
  libzmq3-dev \ 
  help2man \
  python3 \
  libdb++-dev \
  wget 

VOLUME ["/data","/root/.radiant/radiant.conf"]

# The config file needs to have the block chain sent to /data


EXPOSE 7332 7333 17332 29000
 
ENTRYPOINT ["radiantd","-conf=/root/.radiant/radiant.conf","-zmqpubhashblock=tcp://127.0.0.1:29000"]
  
