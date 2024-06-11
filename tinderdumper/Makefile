TARGET := iphone:clang:latest:15.0


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TinderDumper

TinderDumper_FILES = Tweak.x
TinderDumper_CFLAGS = -fobjc-arc
TinderDumper_LIBRARIES = mryipc

include $(THEOS_MAKE_PATH)/tweak.mk
