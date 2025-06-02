cmake_minimum_required(VERSION 3.25)

project(mstch)

#set(CMAKE_CXX_STANDARD 17)
#set(CMAKE_CXX_STANDARD_REQUIRED ON)
#set(CMAKE_CXX_EXTENSIONS OFF)

option(WITH_UNIT_TESTS "enable building unit test executable" OFF)
option(WITH_BENCHMARK "enable building benchmark executable" OFF)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_INCLUDE_CURRENT_DIR_IN_INTERFACE ON)

set(mstch_VERSION 1.0.3)

if(NOT MSVC)
  add_compile_options(-Wall -Wextra)
endif()

add_subdirectory(src)
