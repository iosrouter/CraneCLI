TARGET := iphone:clang:latest:15.0
export SYSROOT = $(THEOS)/sdks/iPhoneOS14.5.sdk/
include $(THEOS)/makefiles/common.mk

TOOL_NAME = crane-cli

crane-cli_FILES = main.m
crane-cli_CFLAGS = -fobjc-arc
crane-cli_CODESIGN_FLAGS = -Sentitlements.plist
crane-cli_INSTALL_PATH = /usr/local/bin
crane-cli_LIBRARIES = mryipc

include $(THEOS_MAKE_PATH)/tool.mk
ifeq ($(THEOS_PACKAGE_SCHEME), rootless)
SUBPROJECTS += headersaverrootless
else
SUBPROJECTS += headersaver
endif
ifeq ($(THEOS_PACKAGE_SCHEME), rootless)
	$(TWEAK_NAME)_CFLAGS += -DROOTLESS
endif
SUBPROJECTS += tinderdumper
include $(THEOS_MAKE_PATH)/aggregate.mk
