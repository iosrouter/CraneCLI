TARGET := iphone:clang:latest:15.0

export SYSROOT = $(THEOS)/sdks/iPhoneOS14.5.sdk/

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = headersaver

headersaver_FILES = Tweak.x
headersaver_CFLAGS = -fobjc-arc
headersaver_LIBRARIES = mryipc

include $(THEOS_MAKE_PATH)/tweak.mk
