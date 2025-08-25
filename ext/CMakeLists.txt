# first build mstch template library
add_subdirectory("mstch")

set(SOURCE_HEADERS
        minicsv.h
        fmt/format.h)

set(SOURCE_FILES
        fmt/format.cc
        fmt/ostream.cc)

# make static library called libmyxrm
# that we are going to link to
# in the root CMakeLists.txt file
add_library(myext STATIC ${SOURCE_FILES})
