cmake_minimum_required(VERSION 3.10)
message(STATUS "CMake version: ${CMAKE_VERSION}")

list(INSERT CMAKE_MODULE_PATH 0 "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(CheckCCompilerFlag)
include(CheckCXXCompilerFlag)
include(CheckLinkerFlag)
include(CheckLibraryExists)
include(CheckFunctionExists)

set(PROJECT_NAME
        arqblocks)

project(${PROJECT_NAME}
	LANGUAGES CXX C)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(WIN32)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wa,-mbig-obj -O3")
endif()

# changed to comply with stagenet requirements
# will need to be changed on release later on
# along with other paths which had been changed as well
set(ARQMA_DIR ~/arqma)
set(ARQMA_BRANCH dev)
message(STATUS ARQMA_DIR ": ${ARQMA_DIR}")

set(ARQMA_SOURCE_DIR ${ARQMA_DIR}
        CACHE PATH "Path to the root directory for Arqma")
	
# set location of arqma build tree
set(ARQMA_BUILD_DIR ${ARQMA_SOURCE_DIR}/build/Linux/${ARQMA_BRANCH}/release
        CACHE PATH "Path to the build directory for Arqma")

set(MY_CMAKE_DIR "${CMAKE_CURRENT_LIST_DIR}/cmake"
        CACHE PATH "The path to the cmake directory of the current project")

list(APPEND CMAKE_MODULE_PATH "${MY_CMAKE_DIR}")

set(CMAKE_LIBRARY_PATH ${CMAKE_LIBRARY_PATH} "${ARQMA_BUILD_DIR}"
        CACHE PATH "Add Arqma directory for library searching")

include(MyUtils)

find_package(Arqma)

cmake_policy(SET CMP0093 NEW)

# find boost
find_package(Boost 1.62.0 QUIET REQUIRED COMPONENTS system filesystem thread date_time chrono regex serialization program_options)

#info https://github.com/arsenm/sanitizers-cmake
find_package(Sanitizers)

if(APPLE)
  include_directories(/usr/local/opt/openssl@1.1/include)
  link_directories(/usr/local/opt/openssl@1.1/lib)
  link_directories(/usr/local/lib)
endif()


if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin" OR WIN32)
  add_library(libunbound STATIC IMPORTED)
  set_property(TARGET libunbound PROPERTY IMPORTED_LOCATION ${ARQMA_BUILD_DIR}/external/unbound/libunbound.a)
endif()

# include boost headers
include_directories(SYSTEM ${Boost_INCLUDE_DIRS})

# include arqma
include_directories(${ARQMA_SOURCE_DIR}/build/Linux/${ARQMA_BRANCH})

include_directories("ext/mstch/include")
include_directories("ext/mstch/include/mstch")
include_directories("ext/crow")

# add ext/ subfolder
add_subdirectory(ext/)

# add src/ subfolder
add_subdirectory(src/)


set(SOURCE_FILES
        main.cpp)

#ADD_CUSTOM_TARGET(driver DEPENDS src/templates/index.html)

add_executable(${PROJECT_NAME}
        ${SOURCE_FILES})

add_sanitizers(${PROJECT_NAME})

create_git_version()

configure_files(${CMAKE_CURRENT_SOURCE_DIR}/src/templates ${CMAKE_CURRENT_BINARY_DIR}/templates)
configure_files(${CMAKE_CURRENT_SOURCE_DIR}/src/templates/css ${CMAKE_CURRENT_BINARY_DIR}/templates/css)
configure_files(${CMAKE_CURRENT_SOURCE_DIR}/src/templates/partials ${CMAKE_CURRENT_BINARY_DIR}/templates/partials)

set(LIBRARIES
        myxrm
        myext
        mstch
        wallet
        arqma_mq
        blockchain_db
        cryptonote_core
        cryptonote_protocol
        cryptonote_basic
        blocks
        net
        multisig
        daemonizer
        cncrypto
        lmdb
        ringct
        ringct_basic
        device
        common
        mnemonics
        easylogging
        checkpoints
        version
        epee
        randomx
        sodium
        libzmq
        ${Boost_LIBRARIES}
        libunbound
        pthread
        curl
        crypto
        ssl)

if(APPLE)
  set(LIBRARIES ${LIBRARIES} "-framework IOKit -framework Foundation")
else()
  set(LIBRARIES ${LIBRARIES} atomic)
endif()

if(NOT ${CMAKE_SYSTEM_NAME} MATCHES "Darwin" AND NOT WIN32)
  set(LIBRARIES ${LIBRARIES} unwind)
endif()

if(WIN32)
  set(LIBRARIES ${LIBRARIES} wsock32 ntdll ws2_32 Iphlpapi)
else()
  set(LIBRARIES ${LIBRARIES} dl)
endif()

find_package(HIDAPI)
set(LIBRARIES ${LIBRARIES} ${HIDAPI_LIBRARIES})

target_link_libraries(${PROJECT_NAME} ${LIBRARIES})
