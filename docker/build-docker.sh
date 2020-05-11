#!/bin/bash
BUILD_DIR=$(dirname $(readlink -f $0))/src
TF_VERSION="2.0"

declare -a USABLE_VERSIONS=("1.13" "1.14" "1.15" "2.0")

function usage_exit {
  cat <<_EOS_ 1>&2
  Usage: $PROG_NAME [OPTIONS...]
  OPTIONS:
    -h, --help              このヘルプを表示
    -v, --version NAME      TensorFlowのバージョンを指定（既定値：${CONTAINER_NAME}）
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
    else
        echo "無効なパラメータ： $1"
        usage_exit
    fi
done

DF_TF_VERSION=$(echo ${TF_VERSION} | sed -e 's/\./-/')

docker build \
    -t jetson/tensorflow:${TF_VERSION}-py3 \
    -f ${BUILD_DIR}/Dockerfile.py3_tf-${DF_TF_VERSION} \
    ${BUILD_DIR}
