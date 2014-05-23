//
//  ShiftAddController.m
//  ShiftCal
//
//  Created by Christian Tietze on 16.08.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "ShiftModificationViewController.h"

#import "ShiftData.h"

#import "EventStoreConstants.h"

#import "DurationPickerController.h"
#import "CalendarPickerController.h"
#import "ShiftTemplateController.h"
#import "AlarmPickerViewController.h"
#import "DateIntervalTranslator.h"

#define NUM_SECTIONS           6
#define SECTION_TITLE_LOCATION 0
#define SECTION_DURATION       1
#define SECTION_CALENDAR       2
#define SECTION_ALARM          3
#define SECTION_URL            4
#define SECTION_NOTES          5

#define ROW_DURATION           1
#define ROW_DURATION_PICKER    2

// TODO refactor to NSString constants
#define CELL_TEXT_FIELD @"textfield"
#define CELL_SUBVIEW    @"sub"
#define CELL_TEXT_AREA  @"textarea"
#define CELL_TOGGLE     @"toggle"
#define CELL_PICKER     @"durationpickercell"

#define CELL_PICKER_HEIGHT 219.0f

#define COLOR_GRAYSCALE_PLACEHOLDER 0.7

#define TAG_TEXTFIELD_TITLE      100
#define TAG_TEXTFIELD_LOCATION   101
#define TAG_TEXTFIELD_URL        102
#define TAG_ALARM_FIRST          103
#define TAG_ALARM_SECOND         104
#define TAG_TEXTVIEW_NORMAL      105
#define TAG_TEXTVIEW_EDITING     106
#define TAG_TEXTVIEW_PLACEHOLDER 107

@interface ShiftModificationViewController ()
{
    ShiftData *_shiftData;
    BOOL _isNewEntry;
    DateIntervalTranslator *_dateTranslator;
    NSInteger _selectedAlarmRow;
    ShiftTemplateController *_shiftTemplateController;
    DurationPickerController *_durationController;
}

@property (nonatomic, retain) ShiftData *shiftData;
@property (nonatomic, retain) DateIntervalTranslator *dateTranslator;
@property (nonatomic, assign) NSInteger selectedAlarmRow;
@property (nonatomic, readonly) ShiftTemplateController *shiftTemplateController;

@property (nonatomic, readonly) DurationPickerController *durationController;
@property (nonatomic, readonly) UIView *durationPickerView;
@property (nonatomic, readwrite, getter = durationPickerIsShown) BOOL showDurationPicker;

- (void)invalidateCalendar:(NSNotification *)notification;
- (void)resetTextViewToPlaceholder:(UITextView *)textView;
- (void)displayAllDayInCell:(UITableViewCell *)cell;
- (void)displayDurationInCell:(UITableViewCell *)cell;
- (void)displayCalendarInCell:(UITableViewCell *)cell;
- (void)displayAlarmInCell:(UITableViewCell *)cell;
- (void)setFirstAlarmOffset:(NSNumber *)alarmOffset;
- (void)allDayChanged:(id)sender;
@end

@implementation ShiftModificationViewController

@synthesize dateTranslator = _dateTranslator;
@synthesize selectedAlarmRow = _selectedAlarmRow;

@synthesize shiftData = _shiftData;
@synthesize modificationDelegate = _modificationDelegate;
@synthesize durationController = _durationController;

- (id)init
{
    return [self initWithShift:nil];
}

- (id)initWithShift:(ShiftTemplate *)shift
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self)
    {
        if (shift)
        {
            // Loads an existing shift into the scratchpad context
            self.shiftData = [[[ShiftData alloc] initWithAttributes:[self.shiftTemplateController attributeDictionaryForShift:shift]] autorelease];
            
            _isNewEntry = NO;
        }
        else
        {
            // Creates a temporary shift into the scratchpad context
            self.shiftData = [[[ShiftData alloc] initWithAttributes:[self.shiftTemplateController defaultAttributeDictionary]] autorelease];

            _isNewEntry = YES;
        }
        
        self.dateTranslator = [[[DateIntervalTranslator alloc] init] autorelease];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(invalidateCalendar:)
                                                     name:SCStoreChangedNotification
                                                   object:[[UIApplication sharedApplication] delegate]];
        
        self.showDurationPicker = NO;
    }
    
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_shiftData release];
    [_dateTranslator release];
    [_shiftTemplateController release];
    
    [super dealloc];
}

- (ShiftTemplateController *)shiftTemplateController
{
    if (_shiftTemplateController)
    {
        return _shiftTemplateController;
    }
    
    _shiftTemplateController = [[ShiftTemplateController alloc] init];
    return _shiftTemplateController;
}

#pragma mark - View callbacks

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *saveItem   = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                target:self
                                                                                action:@selector(save:)];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                target:self
                                                                                action:@selector(cancel:)];

    // Prevent save until title could have been entered
    saveItem.enabled = !_isNewEntry;
    
    self.navigationItem.rightBarButtonItem = saveItem;
    self.navigationItem.leftBarButtonItem  = cancelItem;
    
    [saveItem release];
    [cancelItem release];
    
    self.title = @"Add Template";

    // Enable custom title when editing
    if (self.shiftData.title.length > 0)
    {
        self.title = self.shiftData.title;
    }
    
    self.tableView.sectionHeaderHeight = 5.0f;
    self.tableView.sectionFooterHeight = 5.0f;
    self.tableView.tableHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 5.0)] autorelease];
    self.tableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 5.0)] autorelease];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_isNewEntry)
    {
        UITextField *defaultTextField = (UITextField *)[self.tableView viewWithTag:TAG_TEXTFIELD_TITLE];
        [defaultTextField becomeFirstResponder];
        
        _isNewEntry = NO;
    }
}

#pragma mark Notification callbacks

- (void)invalidateCalendar:(NSNotification *)notification
{
    if ([self.shiftData hasInvalidCalendar])
    {
        NSString *defaultCalendarIdentifer = [notification.userInfo objectForKey:NOTIFICATION_DEFAULT_CALENDAR_KEY];
        
        self.shiftData.calendarIdentifier = defaultCalendarIdentifer;
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SECTION_CALENDAR]
                      withRowAnimation:UITableViewRowAnimationNone];
        [self calloutCell:[NSIndexPath indexPathForRow:0 inSection:SECTION_CALENDAR]];
    }
}

#pragma mark - Table View callbacks

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case SECTION_TITLE_LOCATION:
            return 2;
        case SECTION_DURATION:
            if ([self.shiftData isAllDay])
            {
                return 1;
            }
            
            if ([self durationPickerIsShown])
            {
                return 3;
            }
            
            return 2;
        case SECTION_ALARM:
            if ([self.shiftData hasFirstAlarm])
            {
                return 2;
            }
            
            return 1;
        case SECTION_CALENDAR:
        case SECTION_URL:
        case SECTION_NOTES:
            return 1;
        default:
            StupidError(@"section %d not supported", section);
            break;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    NSInteger section = [indexPath section];
    
    UITableViewCell *cell = nil;
    
    switch (section)
    {
        case SECTION_TITLE_LOCATION:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:CELL_TEXT_FIELD];
            
            if (!cell)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                               reuseIdentifier:CELL_TEXT_FIELD] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                UITextField *textField     = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 300.0f, 30.0f)];
                textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                textField.adjustsFontSizeToFitWidth = YES;
                
                [cell.contentView addSubview:textField];
                
                [textField release];
            }
            
            UITextField *textField = [[cell.contentView subviews] lastObject];
            textField.clearsOnBeginEditing = NO;
            textField.delegate = self;
            
            if (row == 0)
            {
                textField.placeholder = @"Title";
                textField.returnKeyType = UIReturnKeyNext;
                textField.tag = TAG_TEXTFIELD_TITLE;
                textField.text = self.shiftData.title;
            }
            else if (row == 1)
            {
                textField.placeholder = @"Location";
                textField.tag = TAG_TEXTFIELD_LOCATION;
                textField.text = self.shiftData.location;
            }
            else {
                StupidError(@"no placeholder for row %d", row);
            }
            
            break;
        }
        case SECTION_DURATION:
        {
            if (row == 0)
            {
                cell = [tableView dequeueReusableCellWithIdentifier:CELL_TOGGLE];
                
                if (!cell)
                {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                                   reuseIdentifier:CELL_TOGGLE] autorelease];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                    [switchView addTarget:self action:@selector(allDayChanged:) forControlEvents:UIControlEventValueChanged];
                    
                    cell.accessoryView = switchView;
                    
                    [switchView release];
                }
                
                cell.layer.zPosition = 1.0f;
                cell.textLabel.text = @"All-day";
                [self displayAllDayInCell:cell];
            }
            else if (row == 1)
            {
                cell = [tableView dequeueReusableCellWithIdentifier:CELL_SUBVIEW];
                
                if (!cell)
                {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                                   reuseIdentifier:CELL_SUBVIEW] autorelease];
                }
                
                cell.layer.zPosition = 0.5f;
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.textLabel.text = @"Duration";
                
                [self displayDurationInCell:cell];
            }
            else if (row == ROW_DURATION_PICKER)
            {
                cell = [tableView dequeueReusableCellWithIdentifier:CELL_PICKER];
                
                if (!cell)
                {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                                   reuseIdentifier:CELL_PICKER] autorelease];
                }
                
                cell.layer.zPosition = 0.0f;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                [cell addSubview:self.durationPickerView];
            }
            
            break;
        }
        case SECTION_CALENDAR:
            cell = [tableView dequeueReusableCellWithIdentifier:CELL_SUBVIEW];
            
            if (!cell)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                               reuseIdentifier:CELL_SUBVIEW] autorelease];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
            cell.textLabel.text = @"Calendar";
            [self displayCalendarInCell:cell];

            break;
        case SECTION_ALARM:
            cell = [tableView dequeueReusableCellWithIdentifier:CELL_SUBVIEW];
            
            if (!cell)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                               reuseIdentifier:CELL_SUBVIEW] autorelease];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
            NSString *labelText = @"Alert";
            
            if (row == 0)
            {
                cell.tag = TAG_ALARM_FIRST;
            }
            else
            {
                cell.tag = TAG_ALARM_SECOND;
                labelText = @"Second Alert";
            }
            
            cell.textLabel.text = labelText;
            [self displayAlarmInCell:cell];
            
            break;
        case SECTION_URL:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:CELL_TEXT_FIELD];
            
            if (!cell)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                               reuseIdentifier:CELL_TEXT_FIELD] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                UITextField *textField     = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 300.0f, 30.0f)];
                textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                textField.adjustsFontSizeToFitWidth = YES;
                cell.bounds = CGRectMake(0.0f, 0.0f, 300.0f, 110.0f);
                [cell.contentView addSubview:textField];
                
                [textField release];
            }
            
            UITextField *textField = [[cell.contentView subviews] lastObject];
            textField.clearsOnBeginEditing = NO;
            textField.placeholder = @"URL";
            textField.tag = TAG_TEXTFIELD_URL;
            textField.delegate = self;
            textField.text = self.shiftData.url;
            
            break;
        }
        case SECTION_NOTES:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:CELL_TEXT_AREA];
            
            if (!cell)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:CELL_TEXT_AREA] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(4.0f, 10.0f, 292.0f, 165.0f)];
                textView.contentInset = UIEdgeInsetsMake(-8,-2,-8,0);
                textView.backgroundColor = cell.backgroundColor;
                textView.font = [UIFont systemFontOfSize:UIFont.labelFontSize];

                [textView setDelegate:self];
                
                [cell.contentView addSubview:textView];
                
                [textView release];
            }
            
            UITextView *textView = [[cell.contentView subviews] lastObject];
            NSString *noteText   = self.shiftData.note;
            
            textView.text = noteText;
            
            if (!noteText || noteText.length == 0)
            {
                [self resetTextViewToPlaceholder:textView];
            }
            
            break;
        }
        default:
            break;
    }
    
    return cell;
}

- (UIView *)durationPickerView
{
    return [self.durationController pickerView];
}

- (DurationPickerController *)durationController;
{
    if (_durationController == nil)
    {
        _durationController = [[DurationPickerController alloc] initWithHours:self.shiftData.durationHours
                                                                   andMinutes:self.shiftData.durationMinutes];
        _durationController.delegate = self;
    }

    return _durationController;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (SECTION_NOTES == [indexPath section])
    {
        return 185.0f;
    }
    
    if (SECTION_TITLE_LOCATION == [indexPath section])
    {
        return 45.0f;
    }
    
    if (SECTION_DURATION == [indexPath section]
        && ROW_DURATION_PICKER == [indexPath row])
    {
        return CELL_PICKER_HEIGHT;
    }
    
    return 40.0f;
}

- (void)displayAllDayInCell:(UITableViewCell *)cell
{
    UISwitch *switchView = (UISwitch *)cell.accessoryView;
    BOOL state = [self.shiftData isAllDay];
    
    [switchView setOn:state];
}

- (void)displayDurationInCell:(UITableViewCell *)cell
{
    NSString *theText = [self.dateTranslator humanReadableFormOfHours:self.shiftData.durationHours minutes:self.shiftData.durationMinutes];
    
    cell.detailTextLabel.text = theText;
}

- (void)displayCalendarInCell:(UITableViewCell *)cell
{
    cell.detailTextLabel.text = [self.shiftData calendarTitle];
}

- (void)displayAlarmInCell:(UITableViewCell *)cell
{
    NSString *text = @"None";
    NSNumber *alarmOffset = nil;
    
    if (TAG_ALARM_FIRST == cell.tag)
    {
        alarmOffset = self.shiftData.alarmFirstInterval;
    }
    else if (TAG_ALARM_SECOND == cell.tag)
    {
        alarmOffset = self.shiftData.alarmSecondInterval;
    }

    if (alarmOffset)
    {
        text = [self.dateTranslator humanReadableFormOfInterval:[alarmOffset doubleValue]];
        
        // TODO refactor: dont ask model, tell it to return text! -- (consider this a Helper, it's ok!)
    }
    
    cell.detailTextLabel.text = text;
}

#pragma mark TableView interaction

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row     = [indexPath row];
    UIViewController *modalController = nil;
    
    [self hideKeyboard];
    
    switch (section)
    {
        case SECTION_DURATION:
        {
            if (row == 1)
            {
                self.showDurationPicker = ![self durationPickerIsShown];
                
                //[self.tableView beginUpdates];
                //[self.tableView endUpdates];
                NSIndexPath *durationPickerPath = [NSIndexPath indexPathForRow:ROW_DURATION_PICKER inSection:SECTION_DURATION];
                
                if ([self durationPickerIsShown])
                {
                    [self.tableView insertRowsAtIndexPaths:@[durationPickerPath] withRowAnimation:UITableViewRowAnimationTop];
                }
                else
                {
                    [self.tableView deleteRowsAtIndexPaths:@[durationPickerPath] withRowAnimation:UITableViewRowAnimationTop];
                }
            }
            
            break;
        }
        case SECTION_CALENDAR:
        {
            CalendarPickerController *calendarController = [[CalendarPickerController alloc] initWithSelectedCalendarIdentifier:self.shiftData.calendarIdentifier];
            calendarController.delegate = self;
            
            modalController = calendarController;
            
            break;
        }
        case SECTION_ALARM:
        {
            NSNumber *alarmOffset = nil;
            
            if (row == 0)
            {
                alarmOffset = self.shiftData.alarmFirstInterval;
            }
            else
            {
                alarmOffset = self.shiftData.alarmSecondInterval;
            }
            
            AlarmPickerViewController *alarmController = [[AlarmPickerViewController alloc] initWithAlarmOffset:alarmOffset];
            alarmController.delegate = self;
            
            modalController = alarmController;
            
            self.selectedAlarmRow = [indexPath row];
        }
        default:
            break;
    }
    
    if (modalController)
    {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:modalController];
        
        [self presentViewController:navController animated:YES completion:nil];
        
        [modalController release];
        [navController release];
    }
    else
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}


#pragma mark - TextView delegate

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.tag == TAG_TEXTVIEW_NORMAL)
    {
        textView.tag = TAG_TEXTVIEW_EDITING;
        
        [[textView viewWithTag:TAG_TEXTVIEW_PLACEHOLDER] removeFromSuperview];
    }
    else
    {
        if ([textView.text length] == 0)
        {
            [self resetTextViewToPlaceholder:textView];
        }
        
        self.shiftData.note = textView.text;
    }
}

- (void)resetTextViewToPlaceholder:(UITextView *)textView
{
    textView.tag = TAG_TEXTVIEW_NORMAL;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 6.0, 50, 25)];
    label.tag                    = TAG_TEXTVIEW_PLACEHOLDER;
    label.text                   = @"Notes";
    label.textColor              = [UIColor colorWithWhite:COLOR_GRAYSCALE_PLACEHOLDER alpha:1.0];
    label.backgroundColor        = [UIColor clearColor];
    label.userInteractionEnabled = NO;
    
    [textView addSubview:label];
    
    [label release];
}

#pragma mark TextField delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == TAG_TEXTFIELD_TITLE)
    {
        // Enable saving
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (textField.tag)
    {
        case TAG_TEXTFIELD_TITLE:
            self.shiftData.title = textField.text;
            
            // Enable saving
            self.navigationItem.rightBarButtonItem.enabled = YES;
            
            break;
        case TAG_TEXTFIELD_LOCATION:
            self.shiftData.location = textField.text;
            break;
        case TAG_TEXTFIELD_URL:
            self.shiftData.url = textField.text;
            break;
        default:
            StupidError(@"unhandled textField ended editing: %@", textField);
            break;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == TAG_TEXTFIELD_TITLE)
    {
        [[self.tableView viewWithTag:TAG_TEXTFIELD_LOCATION] becomeFirstResponder];
    }
    
    if (textField.tag == TAG_TEXTFIELD_LOCATION || textField.tag == TAG_TEXTFIELD_URL)
    {
        [textField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - Data delegate

- (void)durationPicker:(id)durationPicker didSelectHours:(NSInteger)hours andMinutes:(NSInteger)minutes
{
    // means "Done";  both equal 0 on "Cancel"
    if (hours > 0 || minutes > 0)
    {
        NSIndexPath *durationPath     = [NSIndexPath indexPathForRow:1 inSection:SECTION_DURATION];
        UITableViewCell *durationCell = [self.tableView cellForRowAtIndexPath:durationPath];
        
        [self.shiftData setDurationHours:hours andMinutes:minutes];
        
        [self displayDurationInCell:durationCell];
    }
}

- (void)calendarPicker:(CalendarPickerController *)calendarPicker didSelectCalendarWithIdentifier:(NSString *)calendarIdentifier
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (calendarIdentifier)
    {
        NSIndexPath *calendarPath     = [NSIndexPath indexPathForRow:0 inSection:SECTION_CALENDAR];
        UITableViewCell *calendarCell = [self.tableView cellForRowAtIndexPath:calendarPath];
        
        self.shiftData.calendarIdentifier = calendarIdentifier;
        
        [self displayCalendarInCell:calendarCell];
    }
}

- (void)alarmPicker:(AlarmPickerViewController *)alarmPicker didSelectAlarmOffset:(NSNumber *)alarmOffset canceled:(BOOL)canceled
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (!canceled)
    {
        NSIndexPath *alarmPath     = [NSIndexPath indexPathForRow:self.selectedAlarmRow inSection:SECTION_ALARM];
        UITableViewCell *alarmCell = [self.tableView cellForRowAtIndexPath:alarmPath];
        
        BOOL shouldUpdateFirstAlarm = (self.selectedAlarmRow == 0);
        
        if (shouldUpdateFirstAlarm)
        {
            [self setFirstAlarmOffset:alarmOffset];
        }
        else
        {
            self.shiftData.alarmSecondInterval = alarmOffset;
        }
        
        [self displayAlarmInCell:alarmCell];
    }
}

- (void)setFirstAlarmOffset:(NSNumber *)alarmOffset
{
    NSIndexPath *secondAlarmIndexPath = [NSIndexPath indexPathForRow:1 inSection:SECTION_ALARM];
    
    BOOL hasSecondAlarm          = (self.shiftData.alarmSecondInterval != nil);
    BOOL isSecondAlarmRowVisible = ([self.tableView numberOfRowsInSection:SECTION_ALARM] == 2);
    BOOL shouldRemoveAlarm       = (alarmOffset == nil);

    if (hasSecondAlarm && shouldRemoveAlarm)
    {
        UITableViewCell *secondAlarmCell = [self.tableView cellForRowAtIndexPath:secondAlarmIndexPath];
        
        // Pop first entry, clear second alarm
        self.shiftData.alarmFirstInterval = self.shiftData.alarmSecondInterval;
        self.shiftData.alarmSecondInterval = nil;
        
        // Update second cell, too
        [self displayAlarmInCell:secondAlarmCell];
    }
    else
    {
        self.shiftData.alarmFirstInterval = alarmOffset;
        
        if (isSecondAlarmRowVisible && shouldRemoveAlarm)
        {
            // Only when there was an alarm before, remove 2nd cell upon unsetting 1st alarm
            [self.tableView deleteRowsAtIndexPaths:@[secondAlarmIndexPath]
                                  withRowAnimation:UITableViewRowAnimationTop];
        }
        else if (!isSecondAlarmRowVisible && !shouldRemoveAlarm)
        {
            [self.tableView insertRowsAtIndexPaths:@[secondAlarmIndexPath]
                                  withRowAnimation:UITableViewRowAnimationTop];
        }
    }
}

#pragma mark Switch

- (void)allDayChanged:(id)sender
{
    NSAssert(sender, @"sender required");
    NSAssert([sender isKindOfClass:[UISwitch class]], @"sender must be a UISwitch");
    
    [self hideKeyboard];
    
    UISwitch *switchView = (UISwitch *)sender;
    BOOL allDayHasBeenEnabled = switchView.on;
    
    NSIndexPath *durationPath = [NSIndexPath indexPathForRow:ROW_DURATION inSection:SECTION_DURATION];
    NSIndexPath *durationPickerPath = [NSIndexPath indexPathForRow:ROW_DURATION_PICKER inSection:SECTION_DURATION];

    NSArray *paths = @[durationPath];
    
    if ([self durationPickerIsShown])
    {
        paths = @[durationPickerPath, durationPath];
    }
    
    if (allDayHasBeenEnabled)
    {
        [self.shiftData setAllDay:YES];
        self.showDurationPicker = NO;
        
        [self.tableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
    }
    else
    {
        [self.shiftData setAllDay:NO];
        [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
    }
}

#pragma mark - Save and Cancel

- (void)hideKeyboard
{
    // Unfocus text fields
    [[self.tableView viewWithTag:TAG_TEXTFIELD_TITLE] resignFirstResponder];
    [[self.tableView viewWithTag:TAG_TEXTFIELD_LOCATION] resignFirstResponder];
    [[self.tableView viewWithTag:TAG_TEXTFIELD_URL] resignFirstResponder];
}

- (void)save:(id)sender
{
    // Safely unfocus any text field so it doesn't reset
    // the title again upon view disposal; also save changes.
    [self.tableView endEditing:YES];
    
    if (self.modificationDelegate)
    {
        // Default internally to a meaningful title
        if (self.shiftData.title == nil || self.shiftData.title.length == 0)
        {
            self.shiftData.title = @"New Shift";
        }
        
        [self.modificationDelegate shiftModificationViewController:self modifiedShiftAttributes:self.shiftData.shiftAttributes];
    }
}

- (void)cancel:(id)sender
{
    if (self.modificationDelegate)
    {
        [self.modificationDelegate shiftModificationViewController:self modifiedShiftAttributes:nil];
    }
}

@end
