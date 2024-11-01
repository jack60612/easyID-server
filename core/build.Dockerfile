ARG BUILD_IMAGE
FROM ${BUILD_IMAGE:-python:3.11-slim-bullseye} AS build_step

RUN apt-get update && apt-get install -y build-essential cmake git wget unzip \
        curl yasm pkg-config libswscale-dev libtbb2 libtbb-dev libjpeg-dev \
        libpng-dev libtiff-dev libavformat-dev libpq-dev libfreeimage3 python3-opencv \
        libaec-dev libblosc-dev libbrotli-dev libbz2-dev libgif-dev libopenjp2-7-dev \
        liblcms2-dev libcharls-dev libjxr-dev liblz4-dev libcfitsio-dev libsnappy-dev \
        libwebp-dev libzopfli-dev libzstd-dev \
    && rm -rf /var/lib/apt/lists/*

# Dependencies for imagecodecs
WORKDIR /tmp

# brunsli
RUN git clone --depth=1 --shallow-submodules --recursive -b v0.1 https://github.com/google/brunsli && \
	cd brunsli && \
	cmake -DCMAKE_BUILD_TYPE=Release . && \
	make -j$(nproc) install && \
	rm -rf /tmp/brunsli

# libjxl
RUN git clone --depth=1 --shallow-submodules --recursive -b v0.7.0 https://github.com/libjxl/libjxl && \
	cd libjxl && \
	cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF . && \
	make -j$(nproc) install && \
	rm -rf /tmp/libjxl

# zfp
RUN git clone --depth=1 -b 0.5.5 https://github.com/LLNL/zfp && \
	cd zfp && \
	mkdir build && \
	cd build && \
	cmake -DCMAKE_BUILD_TYPE=Release .. && \
	make -j$(nproc) install && \
	rm -rf /tmp/zfp
# End imagecodecs dependencies

# clone compreface (we need only embedding-calculator)
RUN echo "Cloning compreface"
RUN git clone --depth=1 --shallow-submodules --recursive https://github.com/jack60612/CompreFace.git compreface

# install common python packages
SHELL ["/bin/bash", "-c"]
WORKDIR /app/ml
#COPY requirements.txt .
RUN cp /tmp/compreface/embedding-calculator/requirements.txt .
RUN pip --no-cache-dir install -r requirements.txt
