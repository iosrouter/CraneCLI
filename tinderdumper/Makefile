TARGET := iphone:clang:latest:15.0


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TinderDumper

TinderDumper_FILES = Tweak.xm
TinderDumper_CFLAGS = -fobjc-arc
TinderDumper_LIBRARIES = mryipc

ifeq ($(THEOS_PACKAGE_SCHEME), rootless)
	$(TWEAK_NAME)_CFLAGS += -DROOTLESS
endif

include $(THEOS_MAKE_PATH)/tweak.mk
