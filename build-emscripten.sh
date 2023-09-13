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

mkdir -p build
cd build
emcmake cmake ..
emmake make twgsl -j${core_count}

cd ..
rm -rf artifact
mkdir artifact
cp ./build/Core/twgsl/twgsl.js ./artifact/twgsl.js
cp ./build/Core/twgsl/twgsl.wasm ./artifact/twgsl.wasm

end_time=$(get_current_time_in_seconds)

echo -e "\033[01;32m Time Used: "$((end_time-start_time))"s  \033[1m"
echo -e "\033[01;32m ------------- END -----------------  \033[0m"