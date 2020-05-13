#!/bin/bash

OPENCV_VERSION="4.3.0"
declare -ar USABLE_CV_VERSIONS=("4.3.0" "4.2.0" "4.1.2" "4.1.1" "4.1.0" "4.0.1" "4.0.0" "3.4.10" "3.4.9" "3.4.8" "3.4.7" "3.4.6" "3.4.5" "3.4.4" "3.4.3" "3.4.2" "3.4.1" "3.4.0" "3.3.1" "3.3.0" "3.2.0" "3.1.0" "3.0.0")

function usage_exit {
  cat <<_EOS_ 1>&2
  Usage: $PROG_NAME [OPTIONS...]
  OPTIONS:
    -h, --help                  このヘルプを表示
    -v, --version VERSION       OpenCVのバージョンを指定（既定値：4.3.0）
_EOS_
    exit 1
}

while (( $# > 0 )); do
    if [[ $1 == "--help" ]] || [[ $1 == "-h" ]]; then
        usage_exit
    elif [[ $1 == "--version" ]] || [[ $1 == "-v" ]]; then
        e="false"
        for v in ${USABLE_CV_VERSIONS[@]}; do
            if [[ $2 == ${v} ]]; then
                e="true"
            fi
        done
        if [[ ${e} == "true" ]]; then
            OPENCV_VERSION=$2
        else
            echo "無効なパラメータ： $1 $2"
            usage_exit
        fi
        shift 2
    else
        echo "無効なパラメータ： $1"
        usage_exit
    fi
done

sudo apt-get update && \
sudo apt-get install -y \
    cmake \
    unzip \
    curl \
    libgtk2.0-dev \
    pkg-config \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    libtbb2 \
    libtbb-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libdc1394-22-dev \
    libv4l-dev \
    v4l-utils \
    qv4l2 \
    v4l2ucp && \
sudo apt-get install -y \
    libjasper-dev && \
sudo rm -rf /var/lib/apt/lists/*

USER_NAME=$(whoami)
sudo chown -R ${USER_NAME}:${USER_NAME} /tmp/opencv
cd /tmp/opencv
curl -L https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip -o opencv-${OPENCV_VERSION}.zip
curl -L https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip -o opencv_contrib-${OPENCV_VERSION}.zip
unzip opencv-${OPENCV_VERSION}.zip
unzip opencv_contrib-${OPENCV_VERSION}.zip
cd opencv-${OPENCV_VERSION}/
mkdir release
cd release/
cmake -D WITH_CUDA=ON -D CUDA_ARCH_BIN="7.2" -D CUDA_ARCH_PTX="" -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-${OPENCV_VERSION}/modules -D WITH_GSTREAMER=ON -D WITH_LIBV4L=ON -D BUILD_opencv_python2=ON -D BUILD_opencv_python3=ON -D BUILD_TESTS=OFF -D BUILD_PERF_TESTS=OFF -D BUILD_EXAMPLES=OFF -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local ..
make
sudo make install

sudo apt-get update && \
sudo apt-get install -y \
    python-opencv \
    python3-opencv && \
sudo rm -rf /var/lib/apt/lists/*

rm -rf /tmp/opencv/opencv-${OPENCV_VERSION}.zip /tmp/opencv/opencv_contrib-${OPENCV_VERSION}.zip

sudo pip3 install --no-dependencies imgaug --verbose
