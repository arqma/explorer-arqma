cmake_minimum_required(VERSION 3.12.0)

project(randomarq_crypto)

set(SOURCE_FILES rx-slow-hash.c)

add_library(randomarq_crypto STATIC ${SOURCE_FILES})
