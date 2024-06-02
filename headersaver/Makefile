TARGET := iphone:clang:latest:7.0


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = headersaver

headersaver_FILES = Tweak.x
headersaver_CFLAGS = -fobjc-arc
headersaver_LIBRARIES = mryipc

include $(THEOS_MAKE_PATH)/tweak.mk
