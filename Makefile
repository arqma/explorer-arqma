SRC_DIR = $(CURDIR)
system := $(shell uname)

define BUILD_DIR
  mkdir -p $1 && cd $1 && $2
endef

ifneq (, $(findstring MINGW, $(system)))
  cmake_host = -G "MSYS Makefiles"
  toolchain = -D CMAKE_TOOLCHAIN_FILE=$(SRC_DIR)/cmake/win64-toolchain.cmake
  msys_folder = -D MSYS2_FOLDER=$(shell cd ${MINGW_PREFIX}/.. && pwd -W)
endif

build = build
build_cmd = cmake .. $(cmake_host) $(toolchain) $(msys_folder)

default:
	$(call BUILD_DIR,$(build),$(build_cmd)) && $(MAKE)

clean:
	@echo "WARNING: You are about to delete Built Binaries Folder!" ; \
	read -r -p "Was that intended (y/N)?: " CONTINUE; \
	[ $$CONTINUE = "y" ] || [ $$CONTINUE = "Y" ] || (echo "Exiting."; exit 1;)
	rm -rf $(build)

.PHONY: default clean
