GO_EASY_ON_ME=1
ARCHS = armv7 armv7s arm64
TARGET = iphone:clang:7.1:7.0

include theos/makefiles/common.mk

BUNDLE_NAME = reminderPrefs
reminderPrefs_FILES = reminderPrefs.mm
reminderPrefs_INSTALL_PATH = /Library/PreferenceBundles
reminderPrefs_FRAMEWORKS = UIKit
reminderPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/reminderPrefs.plist$(ECHO_END)
