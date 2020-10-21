add_library(randomarq_crypto
  STATIC
    randomarq_code/rx-slow-hash.c)

add_library(myxrm
  STATIC
    MicroCore.cpp
    tools.cpp
    CmdLineOptions.cpp
    page.h
    rpccalls.cpp
    version.h.in
    CurrentBlockchainStatus.cpp
    MempoolStatus.cpp)

target_link_libraries(myxrm PUBLIC randomarq_crypto)
