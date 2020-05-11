#!/bin/bash
CONTAINER_NAME="tensorflow"
CONTAINER_CMD=""
DOCKER_ENV=""

USER_ID=$(id -u)
PROG_NAME=$(basename $0)
TF_VERSION="2.0"
declare -a USABLE_VERSIONS=("1.13" "1.14" "1.15" "2.0")

function usage_exit {
  cat <<_EOS_ 1>&2
  Usage: $PROG_NAME [OPTIONS...]
  OPTIONS:
    -h, --help              このヘルプを表示
    -v, --version           TensorFlowのバージョンを指定
    -n, --name NAME         コンテナの名前を指定（既定値：${CONTAINER_NAME}）
    -e, --env ENV=VALUE     コンテナの環境変数を指定する（複数指定可）
    -c, --command CMD       コンテナ起動時に実行するコマンドを指定
_EOS_
    exit 1
}

while (( $# > 0 )); do
    if [[ $1 == "--help" ]] || [[ $1 == "-h" ]]; then
        usage_exit
    elif [[ $1 == "--version" ]] || [[ $1 == "-v" ]]; then
        e="false"
        for v in ${USABLE_VERSIONS[@]}; do
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
    elif [[ $1 == "--name" ]] || [[ $1 == "-n" ]]; then
        if [[ $2 == -* ]] || [[ $2 == *- ]]; then
            echo "無効なパラメータ： $1 $2"
            usage_exit
        fi
        CONTAINER_NAME=$2
        shift 2
    elif [[ $1 == "--env" ]] || [[ $1 == "-e" ]]; then
        if [[ $2 == -* ]] || [[ $2 == *- ]]; then
            echo "無効なパラメータ： $1 $2"
            usage_exit
        fi
        DOCKER_ENV="${DOCKER_ENV} -e $2"
        shift 2
    elif [[ $1 == "--command" ]] || [[ $1 == "-c" ]]; then
        if [[ $2 == -* ]] || [[ $2 == *- ]]; then
            echo "無効なパラメータ"
            usage_exit
        fi
        CONTAINER_CMD=$2
        shift 2
    else
        echo "無効なパラメータ： $1"
        usage_exit
    fi
done

DOCKER_IMAGE="jetson/tensorflow:${TF_VERSION}-py3"

XSOCK="/tmp/.X11-unix"
XAUTH="/tmp/.docker.xauth"

HOST_WS=$(dirname $(dirname $(readlink -f $0)))/network

DOCKER_VOLUME="${DOCKER_VOLUME} -v ${XSOCK}:${XSOCK}:rw"
DOCKER_VOLUME="${DOCKER_VOLUME} -v ${XAUTH}:${XAUTH}:rw"
DOCKER_VOLUME="${DOCKER_VOLUME} -v ${HOST_WS}:/home/tensorflow/network:rw"

DOCKER_ENV="-e USER_ID=${USER_ID}"
DOCKER_ENV="${DOCKER_ENV} -e XAUTHORITY=${XAUTH}"
DOCKER_ENV="${DOCKER_ENV} -e DISPLAY=$DISPLAY"
DOCKER_ENV="${DOCKER_ENV} -e TERM=xterm-256color"
DOCKER_ENV="${DOCKER_ENV} -e QT_X11_NO_MITSHM=1"

DOCKER_NET="host"

touch ${XAUTH}
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f ${XAUTH} nmerge -

docker run --rm -it --gpus all --privileged --name ${CONTAINER_NAME} --net ${DOCKER_NET} ${DOCKER_ENV} ${DOCKER_VOLUME} ${DOCKER_IMAGE} ${CONTAINER_CMD}
