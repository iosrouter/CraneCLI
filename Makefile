TARGET := iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

TOOL_NAME = crane-cli

crane-cli_FILES = main.m
crane-cli_CFLAGS = -fobjc-arc
crane-cli_CODESIGN_FLAGS = -Sentitlements.plist
crane-cli_INSTALL_PATH = /usr/local/bin
crane-cli_LIBRARIES = mryipc

include $(THEOS_MAKE_PATH)/tool.mk
ifdef ROOTLESS
$(info Add proper projects for rootless)
SUBPROJECTS += headersaverrootless
endif
ifdef ROOTFUL
$(info Add proper projects for rootful)
SUBPROJECTS += headersaver
endif
SUBPROJECTS += tinderdumper
include $(THEOS_MAKE_PATH)/aggregate.mk
