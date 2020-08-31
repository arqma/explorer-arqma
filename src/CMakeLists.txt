cmake_minimum_required(VERSION 3.12.0)

project(myxrm)

set(SOURCE_HEADERS
  MicroCore.h
  tools.h
  arqma_headers.h
  CurrentBlockchainStatus.h)

set(SOURCE_FILES
  MicroCore.cpp
  tools.cpp
  CmdLineOptions.cpp
  page.h
  rpccalls.cpp
  rpccalls.h
  version.h.in
  CurrentBlockchainStatus.cpp
  MempoolStatus.cpp
  MempoolStatus.h)

add_subdirectory(randomarq_code)

add_library(myxrm STATIC ${SOURCE_FILES})

target_link_libraries(myxrm randomarq_crypto)
