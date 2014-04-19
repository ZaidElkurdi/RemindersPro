export THEOS_DEVICE_IP=128.54.249.78
export GO_EASY_ON_ME=1
export ARCHS = armv7 armv7s arm64
export TARGET = iphone:clang:7.1:7.0

include theos/makefiles/common.mk

TWEAK_NAME = Reminders_Pro
Reminders_Pro_FILES = ActionReminders.xm ClickableNotes.xm RepeatTimes.xm
Reminders_Pro_FRAMEWORKS = UIKit AddressBook EventKit

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += reminderprefs

include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	@install.exec "killall -9 SpringBoard"
