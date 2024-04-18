TARGET := iphone:clang:latest:15.0

FINALPACKAGE = 1
#THEOS_PACKAGE_SCHEME=rootless
include $(THEOS)/makefiles/common.mk

TOOL_NAME = crane-cli

crane-cli_FILES = main.m
crane-cli_CFLAGS = -fobjc-arc
crane-cli_CODESIGN_FLAGS = -Sentitlements.plist
crane-cli_INSTALL_PATH = /usr/local/bin

include $(THEOS_MAKE_PATH)/tool.mk
