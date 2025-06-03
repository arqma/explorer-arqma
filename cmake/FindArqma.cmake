#------------------------------------------------------------------------------
# CMake helper for the majority of the cpp-ethereum modules.
#
# This module defines
#     ARQMA_XXX_LIBRARIES, the libraries needed to use ethereum.
#     ARQMA_FOUND, If false, do not try to use ethereum.
#
# File addetped from cpp-ethereum
#
# The documentation for cpp-ethereum is hosted at http://cpp-ethereum.org
#
# ------------------------------------------------------------------------------
# This file is part of cpp-ethereum.
#
# cpp-ethereum is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# cpp-ethereum is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with cpp-ethereum.  If not, see <http://www.gnu.org/licenses/>
#
# (c) 2014-2016 cpp-ethereum contributors.
#------------------------------------------------------------------------------

set(LIBS common;blocks;cryptonote_basic;cryptonote_core;multisig;net;cryptonote_protocol;
         daemonizer;mnemonics;epee;lmdb;device;blockchain_db;ringct;wallet;cncrypto;
         easylogging;version;checkpoints;randomx;miniupnpc)


set(Arqma_INCLUDE_DIRS "${CPP_ARQMA_DIR}")

# if the project is a subset of main cpp-ethereum project
# use same pattern for variables as Boost uses

foreach(l ${LIBS})
  string(TOUPPER ${l} L)
  find_library(Arqma_${L}_LIBRARY
    NAMES ${l}
    PATHS ${CMAKE_LIBRARY_PATH}
    PATH_SUFFIXES "/src/${l}" "/src" "/external/lib${l}" "/lib" "/external/randomarq" "/src/crypto" "/contrib/epee/src" "/external/easylogging++" "/external/${l}" "/src/lmdb/liblmdb" "/external/miniupnp/miniupnpc"
    NO_DEFAULT_PATH)

  set(Arqma_${L}_LIBRARIES ${Arqma_${L}_LIBRARY})
  message(STATUS FindArqma " Arqma_${L}_LIBRARIES ${Arqma_${L}_LIBRARY}")
  add_library(${l} STATIC IMPORTED)
  set_property(TARGET ${l} PROPERTY IMPORTED_LOCATION ${Arqma_${L}_LIBRARIES})
endforeach()

if(EXISTS ${ARQMA_BUILD_DIR}/src/ringct/libringct_basic.a)
  message(STATUS FindArqma " found libringct_basic.a")
  add_library(ringct_basic STATIC IMPORTED)
  set_property(TARGET ringct_basic PROPERTY IMPORTED_LOCATION ${ARQMA_BUILD_DIR}/src/ringct/libringct_basic.a)
endif()

if(EXISTS ${ARQMA_BUILD_DIR}/src/cryptonote_basic/libcryptonote_format_utils_basic.a)
  message(STATUS FindArqma " found libcryptonote_format_utils_basic.a")
  add_library(cryptonote_format_utils_basic STATIC IMPORTED)
  set_property(TARGET cryptonote_format_utils_basic PROPERTY IMPORTED_LOCATION ${ARQMA_BUILD_DIR}/src/cryptonote_basic/libcryptonote_format_utils_basic.a)
endif()

if(EXISTS ${ARQMA_BUILD_DIR}/external/libzmq/lib/libzmq.a)
  message(STATUS FindArqma " found in-tree libzmq.a")
  add_library(libzmq STATIC IMPORTED)
  set_property(TARGET libzmq PROPERTY IMPORTED_LOCATION ${ARQMA_BUILD_DIR}/external/libzmq/lib/libzmq.a)
endif()

if(EXISTS ${ARQMA_BUILD_DIR}/external/unbound/libunbound.a)
  message(STATUS FindArqma " found in-tree libunbound.a")
  add_library(libunbound STATIC IMPORTED)
  set_property(TARGET libunbound PROPERTY IMPORTED_LOCATION ${ARQMA_BUILD_DIR}/external/unbound/libunbound.a)
endif()

message(STATUS ${ARQMA_SOURCE_DIR}/build/Linux/${ARQMA_BRANCH})

# include arqma headers
include_directories(
  ${ARQMA_SOURCE_DIR}/src
  ${ARQMA_SOURCE_DIR}/src/crypto
  ${ARQMA_SOURCE_DIR}/external
  ${ARQMA_SOURCE_DIR}/external/randomarq/src
  ${ARQMA_SOURCE_DIR}/build/Linux/${ARQMA_BRANCH}/release
  ${ARQMA_SOURCE_DIR}/build/Linux/${ARQMA_BRANCH}/release/external/libzmq/include
  ${ARQMA_SOURCE_DIR}/external/unbound/libunbound
  ${ARQMA_SOURCE_DIR}/external/easylogging++
  ${ARQMA_SOURCE_DIR}/contrib/epee/include
  ${ARQMA_SOURCE_DIR}/lmdb/liblmdb)
