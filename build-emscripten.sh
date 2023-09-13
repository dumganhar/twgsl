#!/usr/bin/env bash

set -e

echo -e "\033[01;32m --------------- START -------------------- \033[0m"

get_current_time_in_seconds() {
    local now=$(date +'%Y-%m-%d %H:%M:%S')
    local total_seconds
    if [[ "$OSTYPE" == "darwin"* ]]; then
        total_seconds=$(date -j -f "%Y-%m-%d %H:%M:%S" "$now" "+%s")
    else
        total_seconds=$(date --date="$now" +%s)
    fi
    echo "$total_seconds"
}

start_time=$(get_current_time_in_seconds)

core_count=$(nproc)
echo "CPU core count：$core_count"

current_dir=$(pwd)
echo "current dir: ${current_dir}"

function build() {
    BUILD_TYPE=$1
    BUILD_OUT="build-${BUILD_TYPE}"
    echo -e "\033[01;32m ------------- BUILD (${BUILD_TYPE}) -----------------  \033[0m"

    CMAKE_BUILD_TYPE="Release"
    if [[ "${BUILD_TYPE}" == "debug" ]]; then
        CMAKE_BUILD_TYPE="Debug"
    fi

    rm -rf ${BUILD_OUT}
    mkdir -p ${BUILD_OUT}
    cd ${BUILD_OUT}
    emcmake cmake -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} ..
    emmake make twgsl -j${core_count} #VERBOSE=1 
    cd ..

    echo -e "\033[01;32m ------------- COLLECTING ALL .a FILES (${BUILD_TYPE}) -----------------  \033[0m"
    
    mkdir -p artifact/${BUILD_TYPE}/tmp

    find ./${BUILD_OUT} -type f -name "*.a" -print0 | xargs -0 -I {} cp {} ./artifact/${BUILD_TYPE}/tmp
    cp ./Core/twgsl/*.js ./artifact/${BUILD_TYPE}/
    cp ./Core/twgsl/Source/*.js ./artifact/${BUILD_TYPE}/

    ls -l ./artifact/${BUILD_TYPE}/tmp

    echo -e "\033[01;32m ------------- BUILD A FAT .a (${BUILD_TYPE}) -----------------  \033[0m"

    pushd ./artifact/${BUILD_TYPE}/tmp

    find . -type f -name "*.a" -print0 | xargs -0 -I {} emar -x {}

    emar -rcs libtwgsl-fat.${BUILD_TYPE}.a *.o
    cp libtwgsl-fat.${BUILD_TYPE}.a ..
    cd ..
    rm -rf ./tmp

    popd
}

rm -rf artifact
# build "debug"
build "release"


end_time=$(get_current_time_in_seconds)

echo -e "\033[01;32m Time Used: "$((end_time-start_time))"s  \033[1m"
echo -e "\033[01;32m ------------- END -----------------  \033[0m"