#include "RemindersProHeaders.h"

static NSString* determineTitle(NSArray* daysOfWeek)
{
    NSMutableArray *reminderDays = [[NSMutableArray alloc] init];
    NSInteger dayNum=0; //Used with single day repeat
    for(EKRecurrenceDayOfWeek *day in daysOfWeek)
    {
        NSLog(@"Day: %ld", day.dayOfTheWeek);
        dayNum += day.dayOfTheWeek;
        [reminderDays addObject:[NSNumber numberWithLong:day.dayOfTheWeek]];
    }

    if([reminderDays count]==5)
        return @"Every Weekday";

    if([reminderDays count]==2)
        return @"Every Weekend";

    if([reminderDays count]==4)
    {
        if([reminderDays indexOfObject:[NSNumber numberWithLong:2]]==NSNotFound)
            return @"Weekdays except Monday";
        if([reminderDays indexOfObject:[NSNumber numberWithLong:3]]==NSNotFound)
            return @"Weekdays except Tuesday";
        if([reminderDays indexOfObject:[NSNumber numberWithLong:4]]==NSNotFound)
            return @"Weekdays except Wednesday";
        if([reminderDays indexOfObject:[NSNumber numberWithLong:5]]==NSNotFound)
            return @"Weekdays except Thursday";
        if([reminderDays indexOfObject:[NSNumber numberWithLong:6]]==NSNotFound)
            return @"Weekdays except Friday";
    }

    if([reminderDays count]==6)
    {
        if([reminderDays indexOfObject:[NSNumber numberWithLong:1]]==NSNotFound)
            return @"Every day except Sunday";
        if([reminderDays indexOfObject:[NSNumber numberWithLong:7]]==NSNotFound)
            return @"Every day except Saturday";
    }

    if([reminderDays count]==1)
    {
        switch(dayNum)
        {
            case 1:
                return @"Every Sunday";
                break;
            case 2:
                return @"Every Monday";
                break;
            case 3:
                return @"Every Tuesday";
                break;
            case 4:
                return @"Every Wednesday";
                break;
            case 5:
                return @"Every Thursday";
                break;
            case 6:
                return @"Every Friday";
                break;
            case 7:
                return @"Every Saturday";
                break;
        }
    }

    return @"";
}

%hook RemindersDetailEditorController
- (id)initWithReminder:(EKReminder*)arg1
{
    currReminder = [arg1 retain];
    return %orig(arg1);
}

- (id)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if(indexPath.section==1 && indexPath.row==2 && [currReminder.recurrenceRules count]>0)
    {
        UITableViewCell *cell = %orig(tableView, indexPath);
        cell.detailTextLabel.adjustsFontSizeToFitWidth = TRUE;

        NSString *title = determineTitle(((EKRecurrenceRule*)[currReminder.recurrenceRules objectAtIndex:0]).daysOfTheWeek);
        if([title isEqualToString:@""]==false)
        {
            cell.detailTextLabel.text = title;
            return cell;
        }
    }

    return %orig(tableView, indexPath);
}

- (void)viewDidAppear:(BOOL)arg1
{
    %orig(arg1);

    if([currReminder.recurrenceRules count]>0)
    {
        NSString *title = determineTitle(((EKRecurrenceRule*)[currReminder.recurrenceRules objectAtIndex:0]).daysOfTheWeek);

        if([title isEqualToString:@""]==false)
        {
            UITableView *table = MSHookIvar<UITableView*>(self, "_tableView");
            [table reloadData];
        }
    }
}
%end

%hook RemindersRecurrenceTypeViewController
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0 && indexPath.row==0 && [currReminder.recurrenceRules count]>0)
    {
        NSString *title = determineTitle(((EKRecurrenceRule*)[currReminder.recurrenceRules objectAtIndex:0]).daysOfTheWeek);
        if([title isEqualToString:@""]==false)
        {
            UITableViewCell *cell = %orig(tableView,indexPath);
            cell.textLabel.text = title;
            return cell;
        }

        return %orig(tableView,indexPath);
    }

    if(indexPath.row < 6)
        return %orig(tableView,indexPath);

    else
    {
        NSString *AutoCompleteRowIdentifier = @"recurrenceCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
        if(cell == nil)
        {
            cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier];
        }

        NSString *cellTitle;

        /* Determine title for cell, this probably could have been done with an array... */
        switch(indexPath.row)
        {
            case 6:
                cellTitle = @"Every Monday";
                break;
            case 7:
                cellTitle = @"Every Tuesday";
                break;
            case 8:
                cellTitle = @"Every Wednesday";
                break;
            case 9:
                cellTitle = @"Every Thursday";
                break;
            case 10:
                cellTitle = @"Every Friday";
                break;
            case 11:
                cellTitle = @"Every Saturday";
                break;
            case 12:
                cellTitle = @"Every Sunday";
                break;
            case 13:
                cellTitle = @"Every Weekday";
                break;
            case 14:
                cellTitle = @"Every Weekend";
                break;
            case 15:
                cellTitle = @"Weekdays except Monday";
                break;
            case 16:
                cellTitle = @"Weekdays except Tuesday";
                break;
            case 17:
                cellTitle = @"Weekdays except Wednesday";
                break;
            case 18:
                cellTitle = @"Weekdays except Thursday";
                break;
            case 19:
                cellTitle = @"Weekdays except Friday";
                break;
            case 20:
                cellTitle = @"Every day except Saturday";
                break;
            case 21:
                cellTitle = @"Every day except Sunday";
                break;
        }

        cell.textLabel.text = cellTitle;

        return cell;
    }
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    /* Don't change the stock 6 options */
    if(indexPath.row < 6)
        %orig;

    /* Add the new options */
    else
    {
        NSArray *days;
        switch(indexPath.row)
        {
            case 6:
                days = [NSArray arrayWithObjects:[EKRecurrenceDayOfWeek dayOfWeek:2],nil];
                break;
            case 7:
                days = [NSArray arrayWithObjects:[EKRecurrenceDayOfWeek dayOfWeek:3],nil];
                break;
            case 8:
                days = [NSArray arrayWithObjects:[EKRecurrenceDayOfWeek dayOfWeek:4],nil];
                break;
            case 9:
                days = [NSArray arrayWithObjects:[EKRecurrenceDayOfWeek dayOfWeek:5],nil];
                break;
            case 10:
                days = [NSArray arrayWithObjects:[EKRecurrenceDayOfWeek dayOfWeek:6],nil];
                break;
            case 11:
                days = [NSArray arrayWithObjects:[EKRecurrenceDayOfWeek dayOfWeek:7],nil];
                break;
            case 12:
                days = [NSArray arrayWithObjects:[EKRecurrenceDayOfWeek dayOfWeek:1],nil];
                break;
            case 13:
                days = [NSArray arrayWithObjects:[EKRecurrenceDayOfWeek dayOfWeek:2],[EKRecurrenceDayOfWeek dayOfWeek:3],[EKRecurrenceDayOfWeek dayOfWeek:4],[EKRecurrenceDayOfWeek dayOfWeek:5],[EKRecurrenceDayOfWeek dayOfWeek:6],nil];
                break;
            case 14:
                days = [NSArray arrayWithObjects:[EKRecurrenceDayOfWeek dayOfWeek:1],[EKRecurrenceDayOfWeek dayOfWeek:7],nil];
                break;
            case 15:
                days = [NSArray arrayWithObjects:[EKRecurrenceDayOfWeek dayOfWeek:3],[EKRecurrenceDayOfWeek dayOfWeek:4],[EKRecurrenceDayOfWeek dayOfWeek:5],[EKRecurrenceDayOfWeek dayOfWeek:6],nil];
                break;
            case 16:
                days = [NSArray arrayWithObjects:[EKRecurrenceDayOfWeek dayOfWeek:2],[EKRecurrenceDayOfWeek dayOfWeek:4],[EKRecurrenceDayOfWeek dayOfWeek:5],[EKRecurrenceDayOfWeek dayOfWeek:6],nil];;
                break;
            case 17:
                days = [NSArray arrayWithObjects:[EKRecurrenceDayOfWeek dayOfWeek:2],[EKRecurrenceDayOfWeek dayOfWeek:3],[EKRecurrenceDayOfWeek dayOfWeek:5],[EKRecurrenceDayOfWeek dayOfWeek:6],nil];;
                break;
            case 18:
                days = [NSArray arrayWithObjects:[EKRecurrenceDayOfWeek dayOfWeek:2],[EKRecurrenceDayOfWeek dayOfWeek:3],[EKRecurrenceDayOfWeek dayOfWeek:4],[EKRecurrenceDayOfWeek dayOfWeek:6],nil];
                break;
            case 19:
                days = [NSArray arrayWithObjects:[EKRecurrenceDayOfWeek dayOfWeek:2],[EKRecurrenceDayOfWeek dayOfWeek:3],[EKRecurrenceDayOfWeek dayOfWeek:4],[EKRecurrenceDayOfWeek dayOfWeek:5],nil];
                break;
            case 20:
                days = [NSArray arrayWithObjects:[EKRecurrenceDayOfWeek dayOfWeek:1],[EKRecurrenceDayOfWeek dayOfWeek:2],[EKRecurrenceDayOfWeek dayOfWeek:3],[EKRecurrenceDayOfWeek dayOfWeek:4],[EKRecurrenceDayOfWeek dayOfWeek:5],[EKRecurrenceDayOfWeek dayOfWeek:6],nil];
                break;
            case 21:
                days = [NSArray arrayWithObjects:[EKRecurrenceDayOfWeek dayOfWeek:2],[EKRecurrenceDayOfWeek dayOfWeek:3],[EKRecurrenceDayOfWeek dayOfWeek:4],[EKRecurrenceDayOfWeek dayOfWeek:5],[EKRecurrenceDayOfWeek dayOfWeek:6],[EKRecurrenceDayOfWeek dayOfWeek:7],nil];
                break;
        }

        /* Create the recurrence rule to add to the reminder */
        EKRecurrenceRule *rule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyDaily
         interval:1
         daysOfTheWeek:days
         daysOfTheMonth:nil
         monthsOfTheYear:nil 
         weeksOfTheYear:nil 
         daysOfTheYear:nil 
         setPositions:nil 
         end:nil
        ];

        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];

        /* Set the Reminder's properties */
        EKEventStore *store = [[EKEventStore alloc] init];
        currReminder = [(EKReminder*)[store calendarItemWithIdentifier:[currReminder reminderIdentifier]] retain];

        if(currReminder.dueDate==nil)
            currReminder.dueDateComponents = components;

        if([currReminder.recurrenceRules count]>0)
            [currReminder removeRecurrenceRule:[currReminder.recurrenceRules objectAtIndex:0]];

        [currReminder addRecurrenceRule:rule];

        NSError *saveError = nil;
        [store saveReminder:currReminder commit:YES error:&saveError];

        //currReminder = [(EKReminder*)[store calendarItemWithIdentifier:[rowReminder reminderIdentifier]] retain];
        NSIndexPath *checkedPath = MSHookIvar<NSIndexPath*>(self, "_checkedItem");
        NSLog(@"After change! %@ and %@",currReminder.recurrenceRules,checkedPath);

        [self.navigationController popViewControllerAnimated:YES];

    }
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    /* Already a custom repeat time set*/
    if(tableView.numberOfSections==2)
    {
        if(section==1)
            return %orig+16;

        return %orig;
    }

    /* No custom repeat time set, just add space for new repeat times */
    return %orig+16;
}
%end