#include "RemindersProHeaders.h"

%hook RemindersDetailEditorController
- (void)viewDidAppear:(BOOL)arg1
{
    %log;
    %orig(arg1);
    RemindersTextEditCell *notesCell = MSHookIvar<RemindersTextEditCell*>(self, "_notesCell");
    EKExpandingTextView *noteView = MSHookIvar<EKExpandingTextView*>(notesCell, "_expandingTextView");
    NSLog(@"nc: %@", notesCell);
    NSLog(@"nv: %@", noteView);

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