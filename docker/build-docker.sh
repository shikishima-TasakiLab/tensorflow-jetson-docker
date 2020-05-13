#!/bin/bash
TF_VERSION="2.0"
OPENCV_VERSION="4.3.0"
BUILD_DIR=$(dirname $(readlink -f $0))/src
USER_ID=$(id -u)

declare -ar USABLE_TF_VERSIONS=("1.13" "1.14" "1.15" "2.0")
declare -ar USABLE_CV_VERSIONS=("4.3.0" "4.2.0" "4.1.2" "4.1.1" "4.1.0" "4.0.1" "4.0.0" "3.4.10" "3.4.9" "3.4.8" "3.4.7" "3.4.6" "3.4.5" "3.4.4" "3.4.3" "3.4.2" "3.4.1" "3.4.0" "3.3.1" "3.3.0" "3.2.0" "3.1.0" "3.0.0" "off")

function usage_exit {
  cat <<_EOS_ 1>&2
  Usage: $PROG_NAME [OPTIONS...]
  OPTIONS:
    -h, --help                  このヘルプを表示
    -v, --version VERSION       TensorFlowのバージョンを指定（既定値：2.0）
    -c, --opencv {VERSION|off}  OpenCVのバージョンを指定（>=3.0.0）．インストールしない場合はoff．（既定値：4.3.0）
_EOS_
    exit 1
}

while (( $# > 0 )); do
    if [[ $1 == "--help" ]] || [[ $1 == "-h" ]]; then
        usage_exit
    elif [[ $1 == "--version" ]] || [[ $1 == "-v" ]]; then
        e="false"
        for v in ${USABLE_TF_VERSIONS[@]}; do
            if [[ $2 == ${v} ]]; then
                e="true"
            fi
        done
        if [[ ${e} == "true" ]]; then
            TF_VERSION=$2
        else
            echo "無効なパラメータ： $1 $2"
            usage_exit
        fi
        shift 2
    elif [[ $1 == "--opencv" ]] || [[ $1 == "-c" ]]; then
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

DF_TF_VERSION=$(echo ${TF_VERSION} | sed -e 's/\./-/')
TF_IMAGE_NAME="jetson/tensorflow:${TF_VERSION}-py3"

docker build \
    -t ${TF_IMAGE_NAME} \
    -f ${BUILD_DIR}/Dockerfile.py3_tf-${DF_TF_VERSION} \
    ${BUILD_DIR}

if [[ ${OPENCV_VERSION} != "off" ]]; then
    HOST_SRC=${BUILD_DIR}/opencv.sh

    DOCKER_VOLUME="${DOCKER_VOLUME} -v ${HOST_SRC}:/tmp/opencv/opencv.sh:rw"

    DOCKER_ENV="-e USER_ID=${USER_ID}"

    DOCKER_NET="host"

    CONTAINER_NAME="opencv-build"
    CONTAINER_CMD="/bin/bash /tmp/opencv/opencv.sh -v ${OPENCV_VERSION}"

    CONTAINER_EXIST=$(docker ps -a | grep ${CONTAINER_NAME})
    if [[ -n ${CONTAINER_EXIST} ]]; then
        docker rm ${CONTAINER_NAME}
    fi

    docker run \
        -it \
        --gpus all \
        --privileged \
        --name ${CONTAINER_NAME} \
        --net ${DOCKER_NET} \
        ${DOCKER_ENV} \
        ${DOCKER_VOLUME} \
        ${TF_IMAGE_NAME} \
        ${CONTAINER_CMD}

    if [[ $? != 0 ]]; then
        echo "エラーにより中断しました．"
        cd ${CURRENT_DIR}
        exit 1
    fi

    CONTAINER_ID=$(docker ps -a | grep ${TF_IMAGE_NAME} | grep ${CONTAINER_NAME})
    CONTAINER_ID=${CONTAINER_ID:0:12}

    docker commit \
        -a "shikishima-TasakiLab" \
        -m "TensorFlow and OpenCV for Jetson" \
        -c 'ENTRYPOINT ["/tmp/entrypoint.sh"]' \
        ${CONTAINER_ID} \
        ${TF_IMAGE_NAME}-ocv${OPENCV_VERSION}

    CONTAINER_EXIST=$(docker ps -a | grep ${CONTAINER_NAME})
    if [[ -n ${CONTAINER_EXIST} ]]; then
        docker rm ${CONTAINER_NAME}
    fi

fi