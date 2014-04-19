#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <EventKit/EKEventStore.h>
#import <EventKit/EKRecurrenceRule.h>
#import <EventKit/EKCalendarItem.h>
#import <objc/runtime.h>

@interface RemindersCheckboxCell : UITableViewCell<UITableViewDelegate, UITableViewDataSource>
{
    NSURL *_actionURL;
}
- (void)numberDisambiguationAlertView:(NSMutableArray*)phoneNumbers withLabels:(NSMutableArray*)phoneLabels forType:(int)type;
@end

@interface RemindersScheduledListController : NSObject
- (id)reminderAtIndexPath:(id)arg1;
@end

@interface EKExpandingTextView : UITextView
{
    UILabel *_placeholderLabel;
    NSString *_title;
}
@end

@interface EKRecurrenceRule (privateAdditions)
@property(readonly, nonatomic) NSArray *daysOfTheWeek;
@end

@interface RemindersRecurrenceTypeViewController : UIViewController
@property(retain, nonatomic) EKReminder *reminder;
@end

@interface RemindersTextEditCell : UITableViewCell
{
    EKExpandingTextView *_expandingTextView;
    float _verticalPadding;
    float _minimumHeight;
}
@end

@interface RemindersApp : UIApplication <UIApplicationDelegate, UIAlertViewDelegate>
@end



@interface EKReminder : EKCalendarItem
- (void)setFont:(id)arg1;
- (id)description;
- (id)reminderIdentifier;
- (id)externalURI;
- (id)_persistentReminder;
@property(copy, nonatomic) NSURL *action;
@property(copy, nonatomic) NSDateComponents *dueDateComponents;
@property(readonly, nonatomic) NSDate *dueDate;
@property(copy, nonatomic) NSDateComponents *startDateComponents;
@end

static char phoneKey;
static char possibleNumbers;
static char possibleLabels;
static char reminderKey;
static char storeKey;
static char typeKey;

static UIAlertView *disambiguationAlert;
static UIAlertView *actionAlert;


static RemindersCheckboxCell *currCell;
static EKReminder *currReminder;
static EKEventStore *currStore;
static UITextView *interceptView;

static bool shouldLongPress=false;
static bool matchOnlyFirstName=true;
static NSString *callKey;
static NSString *textKey;
static NSString *emailKey;
static NSString *facetimeKey;