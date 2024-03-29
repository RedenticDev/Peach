ARCHS = arm64 arm64e
TARGET = iphone:clang:13.5:11.2

INSTALL_TARGET_PROCESSES = Fruitz

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Peach
$(TWEAK_NAME)_FILES = Tweak.xm $(shell find . -type f -name "*.m")
$(TWEAK_NAME)_EXTRA_FRAMEWORKS += Cephei
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
Tweak.xm_CFLAGS = -std=c++11

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += Assets

include $(THEOS_MAKE_PATH)/aggregate.mk
