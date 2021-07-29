TARGET := iphone:clang:latest:13.0
INSTALL_TARGET_PROCESSES = ActionPotato
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ActionPotato

ActionPotato_FILES = Tweak.xm
ActionPotato_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
