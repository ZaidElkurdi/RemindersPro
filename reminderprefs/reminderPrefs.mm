#import <Preferences/Preferences.h>

@interface reminderPrefsListController: PSListController {
}
@end

@implementation reminderPrefsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"reminderPrefs" target:self] retain];
	}
	return _specifiers;
}

- (void)killReminders
{
    system("killall -9 Reminders");
}

- (id)init
{
	if ((self = [super init]))
	{
        UIBarButtonItem *save = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(killReminders)] autorelease];
        [save setTitle:@"Save"];
        [[self navigationItem] setRightBarButtonItem:save];
	}
	
	return self;
}
@end

// vim:ft=objc
