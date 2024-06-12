TARGET := iphone:clang:latest:15.0


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = headersaverrootless

headersaver_FILES = Tweak.x
headersaver_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
