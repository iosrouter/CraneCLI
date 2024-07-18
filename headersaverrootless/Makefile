TARGET := iphone:clang:latest:15.0

#export SYSROOT = $(THEOS)/sdks/iPhoneOS14.5.sdk/

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = headersaverrootless

headersaverrootless_FILES = Tweak.xm
headersaverrootless_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
