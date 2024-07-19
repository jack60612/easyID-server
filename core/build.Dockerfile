FROM tensorflow/tensorflow:2.12.0-gpu AS gpu_step

ENV DEBIAN_FRONTEND=noninteractive
ENV CUDA=11.8

# Run install steps from python image
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        software-properties-common \
		curl \
		pkg-config \
		unzip \
    	python3-dev \
    	python3-distutils \
        libnccl2 \
		python3-libnvinfer \
    && rm -rf /var/lib/apt/lists/*

# See http://bugs.python.org/issue19846
ENV LANG C.UTF-8

RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && python3 get-pip.py
RUN python3 -m pip --no-cache-dir install --upgrade pip setuptools wheel
# end python install steps

# Some TF tools expect a "python" binary
RUN ln -s $(which python3) /usr/local/bin/python

# Variables for Tensorflow
ENV TF_FORCE_GPU_ALLOW_GROWTH=true

# Variables for MXNET
ENV MXNET_CPU_WORKER_NTHREADS=24
ENV MXNET_ENGINE_TYPE=ThreadedEnginePerDevice MXNET_CUDNN_AUTOTUNE_DEFAULT=0

# No access to GPU devices in the build stage, so skip tests
ENV SKIP_TESTS=1

# The number of processes depends on GPU memory.
# Keep in mind that one uwsgi process with InsightFace consumes about 2.5GB memory
LABEL org.opencontainers.image.source=https://github.com/jack60612/easyID-server
LABEL org.opencontainers.image.description="Custom Image for GPU Builds"


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
