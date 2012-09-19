//
//  ShiftAddController.m
//  ShiftCal
//
//  Created by Christian Tietze on 16.08.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "ShiftAddViewController.h"

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

// TODO refactor to NSString constants
#define CELL_TEXT_FIELD @"textfield"
#define CELL_SUBVIEW    @"sub"
#define CELL_TEXT_AREA  @"textarea"

#define COLOR_GRAYSCALE_PLACEHOLDER 0.7

#define TAG_TEXTFIELD_TITLE      100
#define TAG_TEXTFIELD_LOCATION   101
#define TAG_TEXTFIELD_URL        102
#define TAG_ALARM_FIRST          103
#define TAG_ALARM_SECOND         104
#define TAG_TEXTVIEW_NORMAL      105
#define TAG_TEXTVIEW_EDITING     106
#define TAG_TEXTVIEW_PLACEHOLDER 107

@interface ShiftAddViewController ()
{
    // private instance variables
    BOOL _firstAppearance;
    DateIntervalTranslator *_dateTranslator;
    NSInteger _selectedAlarmRow;
}

// private properties
@property (nonatomic, retain) DateIntervalTranslator *dateTranslator;
@property (nonatomic, assign) NSInteger selectedAlarmRow;

// private methods
- (void)resetTextViewToPlaceholder:(UITextView *)textView;
- (void)displayDurationInCell:(UITableViewCell *)cell;
- (void)displayCalendarInCell:(UITableViewCell *)cell;
- (void)displayAlarmInCell:(UITableViewCell *)cell;
- (void)setFirstAlarm:(EKAlarm *)alarm;
@end

@implementation ShiftAddViewController

@synthesize dateTranslator = _dateTranslator;
@synthesize selectedAlarmRow = _selectedAlarmRow;

@synthesize shift = _shift;
@synthesize additionDelegate = _additionDelegate;

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self)
    {
        self.shift = [[ShiftTemplate alloc] init];
        self.dateTranslator = [[DateIntervalTranslator alloc] init];
        
        _firstAppearance = YES;
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
    [self.shift release];
    [self.dateTranslator release];
    
    [super dealloc];
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
    
    self.navigationItem.rightBarButtonItem = saveItem;
    self.navigationItem.leftBarButtonItem  = cancelItem;
    
    [saveItem release];
    [cancelItem release];
    
    self.title = @"Add Shift";
    
    self.tableView.sectionHeaderHeight = 5.0f;
    self.tableView.sectionFooterHeight = 5.0f;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 5.0)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 5.0)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_firstAppearance)
    {
        UITextField *defaultTextField = (UITextField *)[self.tableView viewWithTag:TAG_TEXTFIELD_TITLE];
        [defaultTextField becomeFirstResponder];
        
        _firstAppearance = NO;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark - Table View callbacks

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SECTION_TITLE_LOCATION:
            return 2;
        case SECTION_ALARM:
            if (self.shift.alarm)
            {
                return 2;
            }
            
            return 1;
        case SECTION_DURATION:
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
    
    switch (section) {
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
            }
            else if (row == 1)
            {
                textField.placeholder = @"Location";
                textField.tag = TAG_TEXTFIELD_LOCATION;
            }
            else {
                StupidError(@"no placeholder for row %d", row);
            }
            
            break;
        }
        case SECTION_DURATION:
            cell = [tableView dequeueReusableCellWithIdentifier:CELL_SUBVIEW];
            
            if (!cell)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                               reuseIdentifier:CELL_SUBVIEW] autorelease];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
            cell.textLabel.text = @"Duration";
            [self displayDurationInCell:cell];
            
            break;
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
                
                [self resetTextViewToPlaceholder:textView];
                
                [cell.contentView addSubview:textView];
                
                [textView release];
            }
                        
            break;
        }
        default:
            break;
    }
    
    return cell;
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
    
    return 40.0f;
}

- (void)displayDurationInCell:(UITableViewCell *)cell
{
    NSString *theText = [ShiftTemplateController durationTextForHours:self.shift.hours andMinutes:self.shift.minutes];
    
    cell.detailTextLabel.text = theText;
}

- (void)displayCalendarInCell:(UITableViewCell *)cell
{
    cell.detailTextLabel.text = self.shift.calendar.title;
}

- (void)displayAlarmInCell:(UITableViewCell *)cell
{
    NSString *text = @"None";
    EKAlarm *alarm = nil;
    
    if (TAG_ALARM_FIRST == cell.tag)
    {
        alarm = self.shift.alarm;
    }
    else if (TAG_ALARM_SECOND == cell.tag)
    {
        alarm = self.shift.secondAlarm;
    }

    if (alarm)
    {
        NSTimeInterval interval = alarm.relativeOffset;
        
        text = [self.dateTranslator humanReadableFormOfInterval:interval];
        
        // TODO refactor: dont ask model, tell it to return text!
    }
    
    cell.detailTextLabel.text = text;
}

#pragma mark TableView interaction

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    UIViewController *modalController = nil;
    
    switch (section) {
        case SECTION_DURATION:
        {
            DurationPickerController *durationController = [[DurationPickerController alloc] initWithHours:self.shift.hours andMinutes:self.shift.minutes];
            durationController.delegate = self;
            
            modalController = durationController;
            
            break;
        }
        case SECTION_CALENDAR:
        {
            EKCalendar *calendar = self.shift.calendar;
            CalendarPickerController *calendarController = [[CalendarPickerController alloc] initWithSelectedCalendar:calendar];
            calendarController.delegate = self;
            
            modalController = calendarController;
            
            break;
        }
        case SECTION_ALARM:
        {
            EKAlarm *alarm = nil;
            
            if ([indexPath row] == 0)
            {
                alarm = self.shift.alarm;
            }
            else
            {
                alarm = self.shift.secondAlarm;
            }
            
            AlarmPickerViewController *alarmController = [[AlarmPickerViewController alloc] initWithAlarm:alarm];
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
        
        [self presentModalViewController:navController animated:YES];
        
        [modalController release];
        [navController release];
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
    else if ([textView.text length] == 0)
    {
        [self resetTextViewToPlaceholder:textView];
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

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (textField.tag) {
        case TAG_TEXTFIELD_TITLE:
            self.shift.title = textField.text;
            break;
        case TAG_TEXTFIELD_LOCATION:
            self.shift.location = textField.text;
            break;
        case TAG_TEXTFIELD_URL:
            self.shift.url = textField.text;
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

#pragma mark - Presented view delegate

- (void)durationPicker:(id)durationPicker didSelectHours:(NSInteger)hours andMinutes:(NSInteger)minutes
{
    // means "Done";  both equal 0 on "Cancel"
    if (hours > 0 || minutes > 0)
    {
        NSIndexPath *durationPath     = [NSIndexPath indexPathForRow:0 inSection:SECTION_DURATION];
        UITableViewCell *durationCell = [self.tableView cellForRowAtIndexPath:durationPath];
        
        [self.shift setDurationHours:hours andMinutes:minutes];
        
        [self displayDurationInCell:durationCell];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)calendarPicker:(CalendarPickerController *)calendarPicker didSelectCalendar:(EKCalendar *)calendar
{
    if (calendar)
    {
        NSIndexPath *calendarPath     = [NSIndexPath indexPathForRow:0 inSection:SECTION_CALENDAR];
        UITableViewCell *calendarCell = [self.tableView cellForRowAtIndexPath:calendarPath];
        
        self.shift.calendar = calendar;
        
        [self displayCalendarInCell:calendarCell];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)alarmPicker:(AlarmPickerViewController *)alarmPicker didSelectAlarm:(EKAlarm *)alarm canceled:(BOOL)canceled
{
    if (!canceled) {
        NSIndexPath *alarmPath     = [NSIndexPath indexPathForRow:self.selectedAlarmRow inSection:SECTION_ALARM];
        UITableViewCell *alarmCell = [self.tableView cellForRowAtIndexPath:alarmPath];
        
        BOOL shouldUpdateFirstAlarm = (self.selectedAlarmRow == 0);
        
        if (shouldUpdateFirstAlarm)
        {
            [self setFirstAlarm:alarm];
        }
        else
        {
            self.shift.secondAlarm = alarm;
        }
        
        [self displayAlarmInCell:alarmCell];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setFirstAlarm:(EKAlarm *)alarm
{
    NSIndexPath *secondAlarmIndexPath = [NSIndexPath indexPathForRow:1 inSection:SECTION_ALARM];
    
    BOOL hasSecondAlarm = (self.shift.secondAlarm != nil);
    BOOL isSecondAlarmRowVisible = ([self.tableView numberOfRowsInSection:SECTION_ALARM] == 2);
    BOOL shouldRemoveAlarm = (alarm == nil);

    if (hasSecondAlarm && shouldRemoveAlarm)
    {
        UITableViewCell *secondAlarmCell = [self.tableView cellForRowAtIndexPath:secondAlarmIndexPath];
        
        // Pop first entry, clear second alarm
        self.shift.alarm = self.shift.secondAlarm;
        self.shift.secondAlarm = nil;
        
        // Update second cell, too
        [self displayAlarmInCell:secondAlarmCell];
    }
    else
    {
        self.shift.alarm = alarm;
        
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

#pragma mark - Save and Cancel

- (void)save:(id)sender
{
    if (self.additionDelegate) {
        ShiftTemplate *shift = nil;
        
        [self.additionDelegate shiftAddViewController:self didAddShift:shift];
    }
}

- (void)cancel:(id)sender
{
    if (self.additionDelegate) {
        [self.additionDelegate shiftAddViewController:self didAddShift:nil];
    }
}

@end
