cmake_minimum_required(VERSION 3.18)
message(STATUS "CMake version: ${CMAKE_VERSION}")

list(INSERT CMAKE_MODULE_PATH 0 "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(CheckCCompilerFlag)
include(CheckCXXCompilerFlag)
include(CheckLinkerFlag)
include(CheckLibraryExists)
include(CheckFunctionExists)

function(link_dep_libs target linktype libdirs)
  foreach(lib ${ARGN})
    find_library(link_lib-${lib} NAMES ${lib} PATHS ${libdirs})
    if(link_lib-${lib})
      target_link_libraries(${target} ${linktype} ${link_lib-${lib}})
    endif()
  endforeach()
endfunction()

set(PROJECT_NAME
        arqblocks)

#if(POLICY CMP0167)
#  cmake_policy(SET CMP0167 NEW)
#endif()

project(${PROJECT_NAME})

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g")

if(WIN32)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wa,-mbig-obj -O3")
endif()

# changed to comply with stagenet requirements
# will need to be changed on release later on
# along with other paths which had been changed as well
set(ARQMA_DIR ~/arqma)
set(ARQMA_BRANCH check)

message(STATUS ARQMA_DIR ": ${ARQMA_DIR}")

set(ARQMA_SOURCE_DIR ${ARQMA_DIR}
        CACHE PATH "Path to the root directory for Arqma")

# set location of arqma build tree
#set(ARQMA_BUILD_DIR ${ARQMA_SOURCE_DIR}/build/Linux/${ARQMA_BRANCH}/release
set(ARQMA_BUILD_DIR ${ARQMA_SOURCE_DIR}/build/release
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
find_package(Boost 1.68.0 QUIET REQUIRED COMPONENTS system filesystem thread date_time chrono regex serialization program_options)

#info https://github.com/arsenm/sanitizers-cmake
find_package(Sanitizers)

if(APPLE)
  include_directories(/opt/homebrew/opt/openssl/include)
  link_directories(/opt/homebrew/opt/openssl/lib)
  link_directories(/opt/homebrew/lib)
endif()

add_library(libunbound INTERFACE)
find_package(PkgConfig REQUIRED)
pkg_check_modules(UNBOUND libunbound REQUIRED IMPORTED_TARGET)
target_link_libraries(libunbound INTERFACE PkgConfig::UNBOUND)

set(sodium_USE_STATIC_LIBS ON)
pkg_check_modules(SODIUM libsodium>=1.0.18 REQUIRED)
pkg_check_modules(ZMQ libzmq>=4.3.2 REQUIRED)
pkg_check_modules(UNWIND libunwind REQUIRED)

if(UNWIND_FOUND)
  add_library(libunwind INTERFACE)
  find_library(libunwind_link_libs NAMES ${UNWIND_LIBRARIES} PATHS ${UNWIND_LIBRARY_DIRS})
  target_link_libraries(libunwind INTERFACE ${libunwind_link_libs})
  target_include_directories(libunwind INTERFACE ${UNWIND_INCLUDE_DIRS})
endif()

if(SODIUM_FOUND)
  message(STATUS "Found libsodium at ${SODIUM_LIBRARIES} with headers at ${SODIUM_INCLUDE_DIRS}")
  add_library(sodium INTERFACE)
  find_library(sodium_link_libs NAMES ${SODIUM_LIBRARIES} PATHS ${SODIUM_LIBRARY_DIRS})
  target_link_libraries(sodium INTERFACE ${sodium_link_libs})
  target_include_directories(sodium INTERFACE ${SODIUM_INCLUDE_DIRS})
else()
  message(FATAL_ERROR "libsodium not found while is REQUIRED!!! Install libsodium and re-configure them")
endif()

if(NOT ZMQ_FOUND)
  message(FATAL_ERROR "libzmq not found")
elseif(ZMQ_FOUND)
  message(STATUS "Found libzmq at ${ZMQ_LIBRARIES} with headers at ${ZMQ_INCLUDE_DIRS}")
  add_library(libzmq INTERFACE)
  find_library(libzmq_link_libs NAMES ${ZMQ_LIBRARIES} PATHS ${ZMQ_LIBRARY_DIRS})
  target_link_libraries(libzmq INTERFACE ${libzmq_link_libs} sodium)
  target_link_directories(libzmq INTERFACE ${ZMQ_INCLUDE_DIRS} ${SODIUM_INCLUDE_DIRS})
  if(MINGW OR WIN32)
    target_link_libraries(libzmq INTERFACE ws2_32 iphlpapi crypt32)
  endif()
endif()

include_directories(${ZMQ_INCLUDE_DIRS})
include_directories(${UNBOUND_INCLUDE_DIRS})

# include boost headers
include_directories(SYSTEM ${Boost_INCLUDE_DIRS})

# include arqma
include_directories(${ARQMA_SOURCE_DIR}/build) #/Linux/${ARQMA_BRANCH})

include_directories("ext/mstch/include")
include_directories("ext/mstch/include/mstch")
include_directories("ext/crow")

# add ext/ subfolder
add_subdirectory(ext)

# add src/ subfolder
add_subdirectory(src)


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
        cryptonote_core
        cryptonote_basic
        cryptonote_protocol
        cryptonote_format_utils_basic
        blockchain_db
        blocks
        net
        device
        multisig
        daemonizer
        cncrypto
        lmdb
        ringct
        ringct_basic
        randomx
        common
        mnemonics
        easylogging
        checkpoints
        miniupnpc
        version
        epee
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

if(WIN32)
  set(LIBRARIES ${LIBRARIES} wsock32 ntdll ws2_32 Iphlpapi)
else()
  set(LIBRARIES ${LIBRARIES} dl)
endif()

find_package(HIDAPI)
set(LIBRARIES ${LIBRARIES} ${HIDAPI_LIBRARIES})

target_link_libraries(${PROJECT_NAME} ${LIBRARIES} libunwind)
