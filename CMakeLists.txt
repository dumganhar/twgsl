cmake_minimum_required(VERSION 3.16)

project(twgsl)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)


add_subdirectory(Dependencies)

#cjh target_compile_options(SPIRV-Tools-static PRIVATE -Oz)
# target_compile_options(SPIRV-Tools-opt PRIVATE -Oz)
# target_compile_options(libtint PRIVATE -Oz)

add_subdirectory(Core)
