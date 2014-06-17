#include "RemindersProHeaders.h"

static NSMutableArray* formatNumbers(NSMutableArray* numbers)
{
	NSMutableArray *formatted = [[[NSMutableArray alloc] init] autorelease];

	for(NSString* number in numbers)
	{
		NSMutableString *newString = [NSMutableString stringWithString:[[number componentsSeparatedByCharactersInSet:
            	[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] 
            	componentsJoinedByString:@""]];

		if([newString length]>10)
		{
			NSInteger origCount = [newString length];

			[newString insertString:@" " atIndex:1];
			[newString insertString:@"-" atIndex:5];
			[newString insertString:@"-" atIndex:9];

			if(origCount>11)
				[newString insertString:@" x" atIndex:14];

		}

		else if([newString length]>7)
		{
			[newString insertString:@"-" atIndex:3];
			[newString insertString:@"-" atIndex:7];
		}

		else
			newString=[NSMutableString stringWithString:number];

		[formatted addObject:newString];
	}

	return formatted;
}

static NSArray* cleanString(NSString* rawText, NSInteger type)
{
	NSString *compareKey;

	switch(type)
	{
		case 1:
			compareKey = [[callKey lowercaseString] stringByAppendingString: @" "];
			break;
		case 2:
			compareKey = [[textKey lowercaseString] stringByAppendingString: @" "];
			break;
		case 3:
			compareKey = [[emailKey lowercaseString] stringByAppendingString: @" "];
			break;
		case 4:
			compareKey = [[facetimeKey lowercaseString] stringByAppendingString: @" "];
			break;
	}

	NSString *namesText = [rawText stringByReplacingOccurrencesOfString:compareKey withString:@""];

	return [NSArray arrayWithObject:namesText];
}

static bool determineNumber(ABRecordRef person, NSInteger type)
{
	NSMutableArray *phoneNumbers = [[[NSMutableArray alloc] init] autorelease];
	NSMutableArray *phoneLabels = [[[NSMutableArray alloc] init] autorelease];

	ABMultiValueRef multiPhones = ABRecordCopyValue(person,kABPersonPhoneProperty);

	for(CFIndex i=0;i<ABMultiValueGetCount(multiPhones);++i)
	{
		CFTypeRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, i);
		CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(multiPhones, i);

  		NSString *phoneLabel =(NSString*) ABAddressBookCopyLocalizedLabel(locLabel);
		NSString *phoneNumber = (NSString *)phoneNumberRef;

		[phoneLabels addObject:phoneLabel];
		[phoneNumbers addObject:phoneNumber];
	}

	if([phoneNumbers count]>1)
	{
		[currCell numberDisambiguationAlertView:phoneNumbers withLabels:phoneLabels forType:type];
		return true;
	}

	else if([phoneNumbers count]==1)
	{
		NSString *urlToSet = [phoneNumbers objectAtIndex:0];

		NSString *prefix;

		if(type==2)
			prefix = @"sms:";
		else
			prefix = @"tel:";

		NSString *withPrefix = [prefix stringByAppendingString:urlToSet];

		NSURL* actionURL = [NSURL URLWithString:[withPrefix stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

		EKEventStore *store = [[EKEventStore alloc] init];
		EKReminder *data = (EKReminder*)[store calendarItemWithIdentifier:[currReminder reminderIdentifier]];
		data.action = actionURL;
		[store saveReminder:data commit:YES error:nil];
		[store release];

		return true;
	}

	else
	{
		return false;
	}
}


static bool determineFacetime(ABRecordRef person)
{
	NSMutableArray *phoneNumbers = [[[NSMutableArray alloc] init] autorelease];
	NSMutableArray *phoneLabels = [[[NSMutableArray alloc] init] autorelease];

	ABMultiValueRef multiPhones = ABRecordCopyValue(person,kABPersonPhoneProperty);
	ABMultiValueRef multiEmails = ABRecordCopyValue(person,kABPersonEmailProperty);

	for(CFIndex i=0;i<ABMultiValueGetCount(multiPhones);++i)
	{
		CFTypeRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, i);
		CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(multiPhones, i);

  		NSString *phoneLabel =(NSString*) ABAddressBookCopyLocalizedLabel(locLabel);
		NSString *phoneNumber = (NSString *)phoneNumberRef;

		[phoneLabels addObject:phoneLabel];
		[phoneNumbers addObject:phoneNumber];
	}

	for(CFIndex i=0;i<ABMultiValueGetCount(multiEmails);++i)
	{
		CFTypeRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiEmails, i);
		CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(multiEmails, i);

  		NSString *phoneLabel =(NSString*) ABAddressBookCopyLocalizedLabel(locLabel);
		NSString *phoneNumber = (NSString *)phoneNumberRef;

		[phoneLabels addObject:phoneLabel];
		[phoneNumbers addObject:phoneNumber];
	}

	if([phoneNumbers count]>1)
	{
		[currCell numberDisambiguationAlertView:phoneNumbers withLabels:phoneLabels forType:4];
		return true;
	}

	else if([phoneNumbers count]==1)
	{
		NSString *urlToSet = [phoneNumbers objectAtIndex:0];

		NSString *prefix = @"facetime:";

		NSString *withPrefix = [prefix stringByAppendingString:urlToSet];

		NSURL* actionURL = [NSURL URLWithString:[withPrefix stringByReplacingOccurrencesOfString:@" " withString:@""]];

		EKEventStore *store = [[EKEventStore alloc] init];
		EKReminder *data = (EKReminder*)[store calendarItemWithIdentifier:[currReminder reminderIdentifier]];
		data.action = actionURL;
		[store saveReminder:data commit:YES error:nil];
		[store release];

		return true;
	}

	else
	{
		return false;
	}
}

static bool determineEmail(ABRecordRef person)
{
	NSMutableArray *emailAddresses = [[[NSMutableArray alloc] init] autorelease];
	NSMutableArray *emailLabels = [[[NSMutableArray alloc] init] autorelease];

	ABMultiValueRef multiEmails = ABRecordCopyValue(person,kABPersonEmailProperty);

	for(CFIndex i=0;i<ABMultiValueGetCount(multiEmails);++i)
	{
		CFTypeRef emailRef = ABMultiValueCopyValueAtIndex(multiEmails, i);
		CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(multiEmails, i);

  		NSString *emailLabel =(NSString*) ABAddressBookCopyLocalizedLabel(locLabel);
		NSString *emailAddress = (NSString *)emailRef;

		[emailLabels addObject:emailLabel];
		[emailAddresses addObject:emailAddress];
	}

	if([emailAddresses count]>1)
	{
		[currCell numberDisambiguationAlertView:emailAddresses withLabels:emailLabels forType:3];
		return true;
	}

	else if([emailAddresses count]==1)
	{
		NSString *urlToSet = [emailAddresses objectAtIndex:0];

		NSString *prefix = @"mailto:";
		NSString *withPrefix = [prefix stringByAppendingString:urlToSet];

		NSURL* actionURL = [NSURL URLWithString:[withPrefix stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

		EKEventStore *store = [[EKEventStore alloc] init];
		EKReminder *data = (EKReminder*)[store calendarItemWithIdentifier:[currReminder reminderIdentifier]];
		data.action = actionURL;
		[store saveReminder:data commit:YES error:nil];
		[store release];

		return true;
	}

	else
	{
		return false;
	}
}

bool determinePerson(NSString* rawText, NSInteger type)
{
	if(currReminder.action==NULL)
	{
		rawText = [rawText lowercaseString];
		NSArray *names = cleanString(rawText, type);
		NSInteger numNames = [names count];

		NSString *firstName = [names objectAtIndex:0];
		NSString *lastName = NULL; 

		if(numNames>1)
			lastName = [names objectAtIndex:1];

		ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
		CFArrayRef people = ABAddressBookCopyPeopleWithName(addressBook, (CFStringRef)firstName);
		ABRecordRef thePerson = NULL;


		if(CFArrayGetCount(people)==1)
			thePerson = CFArrayGetValueAtIndex(people, 0);

		else if(CFArrayGetCount(people)>1)
		{
			NSMutableArray *peopleArray = [[[NSMutableArray alloc] init] retain];

			for (CFIndex i = 0; i < CFArrayGetCount(people); i++)
			{
			    ABRecordRef person = CFArrayGetValueAtIndex(people, i);
			    [peopleArray addObject:(id)person];
			}

			if(lastName != NULL)
			{
				for (CFIndex i = 0; i < CFArrayGetCount(people); i++)
				{
				    ABRecordRef person = CFArrayGetValueAtIndex(people, i);
				    NSString *surname = [(NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty) lowercaseString];
				    if ([lastName isEqualToString:surname])
				    {
				    	thePerson = person;
				    	break;
				    }
				}
			}

			else if(matchOnlyFirstName)
				thePerson = CFArrayGetValueAtIndex(people, 0);

			CFRelease(people);
		}

		else
			return false;

		bool hasContact;

		if(type==3)
			hasContact=determineEmail(thePerson);
		else if(type==4)
			hasContact=determineFacetime(thePerson);
		else
			hasContact=determineNumber(thePerson, type);

		CFRelease(addressBook);
		return hasContact;
	}

	return true;
}


%hook RemindersScheduledListController

- (void)setCellProperties:(RemindersCheckboxCell*)cell fromReminder:(EKReminder*)reminder ignoringTitle:(BOOL)arg3
{
	%orig(cell, reminder, arg3);
	currReminder = [reminder retain];
	currCell = cell;

	if(!currReminder.action)
	{
		objc_setAssociatedObject(cell, &reminderKey, [currReminder reminderIdentifier], OBJC_ASSOCIATION_RETAIN);


		NSString *title = MSHookIvar<NSString*>(cell, "_title");
		UILabel* &titleLabel = MSHookIvar<UILabel*>(cell, "_titleLabel");

		NSString *compareText = [title lowercaseString];

		NSString *phoneCompareKey = [[callKey lowercaseString] stringByAppendingString: @" "];
		NSString *textCompareKey = [[textKey lowercaseString] stringByAppendingString: @" "];
		NSString *emailCompareKey = [[emailKey lowercaseString] stringByAppendingString: @" "];
		NSString *facetimeCompareKey = [[facetimeKey lowercaseString] stringByAppendingString: @" "];

		if(title != NULL)
		{
			bool success=false;

			if([compareText rangeOfString:phoneCompareKey].location != NSNotFound)
			{
				objc_setAssociatedObject(cell, &typeKey, @"1", OBJC_ASSOCIATION_RETAIN);
				success = determinePerson(titleLabel.text, 1);
			}

			else if([compareText rangeOfString:textCompareKey].location != NSNotFound)
			{
				objc_setAssociatedObject(cell, &typeKey, @"2", OBJC_ASSOCIATION_RETAIN);
				success = determinePerson(titleLabel.text, 2);
			}

			else if([compareText rangeOfString:emailCompareKey].location != NSNotFound)
			{
				objc_setAssociatedObject(cell, &typeKey, @"3", OBJC_ASSOCIATION_RETAIN);
				success = determinePerson(titleLabel.text, 3);
			}


			else if([compareText rangeOfString:facetimeCompareKey].location != NSNotFound)
			{
				objc_setAssociatedObject(cell, &typeKey, @"4", OBJC_ASSOCIATION_RETAIN);
				success = determinePerson(titleLabel.text, 4);
			}

		}
	}

	else
	{
		NSURL *action = reminder.action;
		objc_setAssociatedObject(cell, &phoneKey, action, OBJC_ASSOCIATION_RETAIN);

		if(shouldLongPress)
		{
			UILongPressGestureRecognizer* &longPressRecognizer = MSHookIvar<UILongPressGestureRecognizer*>(cell, "_actionPressRecognizer");
			longPressRecognizer.minimumPressDuration = 0.5;
			[longPressRecognizer addTarget:cell action:@selector(longPress:)];
		}
	}
}
/****** END LIST CONTROLLER ********
********					*********
********					********/

%end

%hook RemindersStandardListController

- (void)setCellProperties:(RemindersCheckboxCell*)cell fromReminder:(EKReminder*)reminder ignoringTitle:(BOOL)arg3
{
	%orig(cell, reminder, arg3);
	currReminder = [reminder retain];
	currCell = cell;

	if(!currReminder.action)
	{
		objc_setAssociatedObject(cell, &reminderKey, [currReminder reminderIdentifier], OBJC_ASSOCIATION_RETAIN);
		//objc_setAssociatedObject(cell, &storeKey, currStore, OBJC_ASSOCIATION_RETAIN);


		NSString *title = MSHookIvar<NSString*>(cell, "_title");
		UILabel* &titleLabel = MSHookIvar<UILabel*>(cell, "_titleLabel");

		NSString *compareText = [title lowercaseString];

		NSString *phoneCompareKey = [[callKey lowercaseString] stringByAppendingString: @" "];
		NSString *textCompareKey = [[textKey lowercaseString] stringByAppendingString: @" "];
		NSString *emailCompareKey = [[emailKey lowercaseString] stringByAppendingString: @" "];
		NSString *facetimeCompareKey = [[facetimeKey lowercaseString] stringByAppendingString: @" "];

		if(title != NULL)
		{
			bool success=false;

			if([compareText rangeOfString:phoneCompareKey].location != NSNotFound)
			{
				objc_setAssociatedObject(cell, &typeKey, @"1", OBJC_ASSOCIATION_RETAIN);
				success = determinePerson(titleLabel.text, 1);
			}

			else if([compareText rangeOfString:textCompareKey].location != NSNotFound)
			{
				objc_setAssociatedObject(cell, &typeKey, @"2", OBJC_ASSOCIATION_RETAIN);
				success = determinePerson(titleLabel.text, 2);
			}

			else if([compareText rangeOfString:emailCompareKey].location != NSNotFound)
			{
				objc_setAssociatedObject(cell, &typeKey, @"3", OBJC_ASSOCIATION_RETAIN);
				success = determinePerson(titleLabel.text, 3);
			}


			else if([compareText rangeOfString:facetimeCompareKey].location != NSNotFound)
			{
				objc_setAssociatedObject(cell, &typeKey, @"4", OBJC_ASSOCIATION_RETAIN);
				success = determinePerson(titleLabel.text, 4);
			}

		}
	}

	else
	{
		NSURL *action = reminder.action;
		objc_setAssociatedObject(cell, &phoneKey, action, OBJC_ASSOCIATION_RETAIN);

		if(shouldLongPress)
		{
			UILongPressGestureRecognizer* &longPressRecognizer = MSHookIvar<UILongPressGestureRecognizer*>(cell, "_actionPressRecognizer");
			longPressRecognizer.minimumPressDuration = 0.5;
			[longPressRecognizer addTarget:cell action:@selector(longPress:)];
		}
	}
}
/****** END LIST CONTROLLER ********
********					*********
********					********/

%end

%ctor
{
	class_addProtocol(objc_getClass("RemindersCheckboxCell"), objc_getProtocol("UITableViewDelegate"));
	class_addProtocol(objc_getClass("RemindersCheckboxCell"), objc_getProtocol("UITableViewDataSource"));

	NSString *filePath = @"/var/mobile/Library/Preferences/com.zaid.reminderPrefs.plist";
	bool fileExists=[[NSFileManager defaultManager] fileExistsAtPath:filePath];

    if(fileExists)
    {
		NSMutableDictionary* plistDict = [[NSMutableDictionary alloc]initWithContentsOfFile:filePath];

	    callKey = [plistDict objectForKey:@"callKey"];
	    textKey = [plistDict objectForKey:@"textKey"];
	    emailKey = [plistDict objectForKey:@"emailKey"];
	    facetimeKey = [plistDict objectForKey:@"facetimeKey"];
	    shouldLongPress = [[plistDict objectForKey:@"longPressPref"] boolValue];
	    matchOnlyFirstName = [[plistDict objectForKey:@"firstNamePref"] boolValue];
	}

	if(!callKey)
    	callKey = @"Call";

    if(!textKey)
    	textKey = @"Text";

    if(!emailKey)
    	emailKey = @"Email";

    if(!facetimeKey)
    	facetimeKey = @"FaceTime";


	%init;
}


%hook RemindersCheckboxCell
%new
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSMutableArray *numbers = objc_getAssociatedObject(self, &possibleNumbers);
	NSMutableArray *labels = objc_getAssociatedObject(self, &possibleLabels);

	NSMutableArray *formattedNumbers = formatNumbers(numbers);
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"numberCell"];

	if(cell==nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"numberCell"];
	} 

	NSString *cellText = [NSString stringWithFormat:@"%@ (%@)", [formattedNumbers objectAtIndex:indexPath.row],[labels objectAtIndex:indexPath.row]];

	cell.textLabel.text = cellText;
	cell.backgroundColor = [UIColor clearColor];
    return cell;
}

%new
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSMutableArray *numbers = objc_getAssociatedObject(self, &possibleNumbers);
    return [numbers count];
}

%new
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

%new
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 40;
}

%new
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSMutableArray *numbers = objc_getAssociatedObject(self, &possibleNumbers);
	NSInteger type = tableView.tag;

	NSString *ident = objc_getAssociatedObject(self, &reminderKey);

	NSString *urlToSet = [numbers objectAtIndex:indexPath.row];


	objc_setAssociatedObject(self, &phoneKey, urlToSet, OBJC_ASSOCIATION_RETAIN);

	NSString *prefix;
	switch(type)
	{
		case 1:
			prefix=@"tel:";
			break;
		case 2:
			prefix=@"sms:";
			break;
		case 3:
			prefix=@"mailto:";
			break;
		case 4:
			prefix=@"facetime:";
			break;
	}

	NSString *withPrefix = [prefix stringByAppendingString:urlToSet];

	NSURL* actionURL = [NSURL URLWithString:[withPrefix stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

	EKEventStore *store = [[EKEventStore alloc] init];

	EKReminder *data = (EKReminder*)[store calendarItemWithIdentifier:ident];

	data.action = actionURL;

	NSError *saveError = nil;
	[store saveReminder:data commit:YES error:&saveError];
	NSLog(@"Error: %@", saveError);

	[disambiguationAlert dismissWithClickedButtonIndex:0 animated:YES];
	disambiguationAlert = nil;

	[store release];
}


%new
- (void)numberDisambiguationAlertView:(NSMutableArray*)phoneNumbers withLabels:(NSMutableArray*)phoneLabels forType:(int)type
{
	objc_setAssociatedObject(self, &possibleNumbers, phoneNumbers, OBJC_ASSOCIATION_RETAIN);
	objc_setAssociatedObject(self, &possibleLabels, phoneLabels, OBJC_ASSOCIATION_RETAIN);

	if(!disambiguationAlert || disambiguationAlert==nil)
	{
		NSString *title = type==1 ? @"Which number?" : @"Which address?";
		disambiguationAlert = [[UIAlertView alloc] initWithTitle:title
	                                                    message:@"" 
	                                                    delegate:self 
	                                                    cancelButtonTitle:nil 
	                                                    otherButtonTitles:nil];

		disambiguationAlert.tag = 117;

		UITableView *myTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 250, 200)];
		myTable.backgroundColor = [UIColor clearColor];
		myTable.delegate = self;
		myTable.dataSource = self;
		myTable.tag = type;


		[disambiguationAlert setValue:myTable forKey:@"accessoryView"];
		[disambiguationAlert show];
    }
}

%new
- (void)longPress:(UIButton*)sender
{
	NSURL *actionURL = objc_getAssociatedObject(self, &phoneKey);


	[[UIApplication sharedApplication] openURL:actionURL];
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // the user clicked Call
    if(alertView.tag == 1995)
    {
    	if(buttonIndex==1)
    	{
			NSURL *action = objc_getAssociatedObject(self, &phoneKey);

	    	[[UIApplication sharedApplication] openURL:action];
	    }

	    actionAlert = nil;
    }

    else if(alertView.tag==117)
    {
    	NSMutableArray *numbers = objc_getAssociatedObject(self, &possibleNumbers);
    	NSString *urlToSet;

    	if(buttonIndex==alertView.cancelButtonIndex)
    	{
    		urlToSet = @"No phone number specified";
    	}

    	else
    	{
    		urlToSet = [numbers objectAtIndex:buttonIndex-1];
    	}

		disambiguationAlert = nil;
    }

    else if(alertView.tag == 1234)
    {
    	NSString *personToSet = [alertView buttonTitleAtIndex:buttonIndex];

    	determinePerson(personToSet, true);
    }

    else
    	%orig(alertView, buttonIndex);
}


- (void)prepareForReuse
{
	%orig;
	objc_setAssociatedObject(self, &phoneKey, nil, OBJC_ASSOCIATION_RETAIN);
	objc_setAssociatedObject(self, &possibleNumbers, nil, OBJC_ASSOCIATION_RETAIN);
	objc_setAssociatedObject(self, &possibleLabels, nil, OBJC_ASSOCIATION_RETAIN);
	objc_setAssociatedObject(self, &reminderKey, nil, OBJC_ASSOCIATION_RETAIN);
}


- (void)_tap:(id)arg1
{
	if(actionAlert == nil || !actionAlert)
	{
		NSURL *action = MSHookIvar<NSURL*>(self, "_actionURL");
		NSString *actionString = [action absoluteString];
		actionString = [actionString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		NSArray *myWords = [actionString componentsSeparatedByString:@":"];
		NSString *title = [myWords objectAtIndex:1];
		title = [title stringByReplacingOccurrencesOfString:@"/" withString:@""];
		NSArray *formatted = formatNumbers([NSArray arrayWithObject:title]);
		title = [formatted objectAtIndex:0];

		NSString *actionTitle = [myWords objectAtIndex:0];
		if ([actionTitle rangeOfString:@"tel"].location != NSNotFound)
			actionTitle = @"Call";
		else if ([actionTitle rangeOfString:@"sms"].location != NSNotFound)
			actionTitle = @"Text";
		else if ([actionTitle rangeOfString:@"mailto"].location != NSNotFound)
			actionTitle = @"Email";
		else if ([actionTitle rangeOfString:@"facetime"].location != NSNotFound)
			actionTitle = @"Facetime";

		actionAlert = [[UIAlertView alloc] initWithTitle:title
		                                                    message:@"" 
		                                                    delegate:self 
		                                                    cancelButtonTitle:@"Cancel" 
		                                                    otherButtonTitles:actionTitle, nil];
		actionAlert.tag = 1995;
		[actionAlert show];
	}
}


%end

%hook RemindersDetailEditorController
- (void)viewDidAppear:(BOOL)arg1
{
	%log;
	%orig(arg1);
	RemindersTextEditCell *notesCell = MSHookIvar<RemindersTextEditCell*>(self, "_notesCell");
	EKExpandingTextView *noteView = MSHookIvar<EKExpandingTextView*>(notesCell, "_expandingTextView");

	interceptView = [[UITextView alloc] initWithFrame:noteView.frame];
	UITapGestureRecognizer *tapDetect = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(makeEditable:)];
	interceptView.selectable = TRUE;
	interceptView.editable = FALSE;
	interceptView.scrollEnabled=FALSE;
	interceptView.font = noteView.font;
	interceptView.text = noteView.text;
	interceptView.dataDetectorTypes = UIDataDetectorTypeAll;
	[interceptView addGestureRecognizer:tapDetect];

	[noteView.superview addSubview:interceptView];
}

- (id)initWithReminder:(EKReminder*)arg1
{
	currReminder = arg1;
	return %orig(arg1);
}

%new
- (void)textViewDidEndEditing:(UITextView *)textView
{
	interceptView.hidden = FALSE;
}

%new
- (void)makeEditable:(id)sender
{
	RemindersTextEditCell *notesCell = MSHookIvar<RemindersTextEditCell*>(self, "_notesCell");
	EKExpandingTextView *noteView = MSHookIvar<EKExpandingTextView*>(notesCell, "_expandingTextView");

	interceptView.hidden = TRUE;
	[noteView becomeFirstResponder];
}

- (void)textViewDidChange:(id)arg1
{
	%orig(arg1);
	RemindersTextEditCell *notesCell = MSHookIvar<RemindersTextEditCell*>(self, "_notesCell");
	EKExpandingTextView *noteView = MSHookIvar<EKExpandingTextView*>(notesCell, "_expandingTextView");

	interceptView.text  = noteView.text;
}

%end

%hook RemindersRecurrenceTypeViewController
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.row < 6)
		return %orig;
	else
	{
		NSString *AutoCompleteRowIdentifier = @"recurrenceCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
		if(cell == nil)
		{
			cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier];
		}

		NSString *cellTitle;
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
				cellTitle = @"Weekdays except Saturday";
				break;
			case 21:
				cellTitle = @"Weekdays except Sunday";
				break;
		}

		cell.textLabel.text = cellTitle;

		return cell;
	}
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	if(indexPath.row < 6)
		%orig;

	else
	{
		EKReminder *rowReminder = currReminder;

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

			EKRecurrenceRule *rule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyDaily 
			 interval:3 
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
            EKReminder *data = (EKReminder*)[store calendarItemWithIdentifier:[rowReminder reminderIdentifier]];

            if(data.dueDate==nil)
            	data.dueDateComponents = components;

            if([data.recurrenceRules count]>0)
            	[data removeRecurrenceRule:[data.recurrenceRules objectAtIndex:0]];

            [data addRecurrenceRule:rule];

            NSError *saveError = nil;
            [store saveReminder:data commit:YES error:&saveError];

            NSLog(@"Error: %@", saveError);

            [store release];

		}
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	if(tableView.numberOfSections==2)
	{
		if(section==1)
			return %orig+16;

		return %orig;
	}

	return %orig+16;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return %orig;
}

- (void)_checkItemAtIndexPath:(NSIndexPath*)arg1
{
	%log;
	%orig(arg1);
}
%end