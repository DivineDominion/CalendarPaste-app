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

#define TAG_TEXT_FIELD_TITLE    100
#define TAG_TEXT_FIELD_LOCATION 101
#define TAG_TEXT_FIELD_URL      102

@interface ShiftAddViewController ()
{
    BOOL _firstAppearance;
    
    // private instance variables
    DateIntervalTranslator *_dateTranslator;
}

// private properties
@property (nonatomic, retain) DateIntervalTranslator *dateTranslator;

// private methods
- (void)resetTextViewToPlaceholder:(UITextView *)textView;
- (void)displayDurationInCell:(UITableViewCell *)cell;
@end

@implementation ShiftAddViewController

@synthesize dateTranslator = _dateTranslator;

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
    
    self.tableView.sectionFooterHeight = 0.0f;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 10.0)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_firstAppearance)
    {
        UITextField *defaultTextField = (UITextField *)[self.tableView viewWithTag:TAG_TEXT_FIELD_TITLE];
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
        case SECTION_DURATION:
        case SECTION_CALENDAR:
        case SECTION_ALARM:
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
                textField.tag = TAG_TEXT_FIELD_TITLE;
            }
            else if (row == 1)
            {
                textField.placeholder = @"Location";
                textField.tag = TAG_TEXT_FIELD_LOCATION;
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
            
            cell.textLabel.text = @"Alert";
            cell.detailTextLabel.text = @"None";
            
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
            textField.tag = TAG_TEXT_FIELD_URL;
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
                
                UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(4.0f, 10.0f, 292.0f, 90.0f)];
                textView.contentInset = UIEdgeInsetsMake(-4,0,-4,0);
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
        return 110.0f;
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
    
    if (self.shift.alarm)
    {
        NSTimeInterval interval = self.shift.alarm.relativeOffset;
        
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
            EKAlarm *alarm = self.shift.alarm;
            AlarmPickerViewController *alarmController = [[AlarmPickerViewController alloc] initWithAlarm:alarm];
            alarmController.delegate = self;
            
            modalController = alarmController;
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

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (textView.tag == 0)
    {
        textView.tag       = 1;    // Indicates 'editing'
        textView.text      = @"";
        textView.textColor = [UIColor blackColor];
    }
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if ([textView.text length] == 0)
    {
        [self resetTextViewToPlaceholder:textView];
    }
    
    return YES;
}

- (void)resetTextViewToPlaceholder:(UITextView *)textView
{
    textView.text      = @"Notes";
    textView.textColor = [UIColor lightGrayColor];
    textView.tag       = 0; // Indicates 'default/placeholder state
}

#pragma mark TextField delegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (textField.tag) {
        case TAG_TEXT_FIELD_TITLE:
            self.shift.title = textField.text;
            break;
        case TAG_TEXT_FIELD_LOCATION:
            self.shift.location = textField.text;
            break;
        case TAG_TEXT_FIELD_URL:
            self.shift.url = textField.text;
            break;
        default:
            StupidError(@"unhandled textField ended editing: %@", textField);
            break;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == TAG_TEXT_FIELD_TITLE)
    {
        [[self.tableView viewWithTag:TAG_TEXT_FIELD_LOCATION] becomeFirstResponder];
    }
    
    if (textField.tag == TAG_TEXT_FIELD_LOCATION || textField.tag == TAG_TEXT_FIELD_URL)
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

- (void)alarmPicker:(AlarmPickerViewController *)alarmPicker didSelectAlarm:(EKAlarm *)alarm
{
    if (alarm)
    {
        NSIndexPath *alarmPath     = [NSIndexPath indexPathForRow:0 inSection:SECTION_ALARM];
        UITableViewCell *alarmCell = [self.tableView cellForRowAtIndexPath:alarmPath];
        
        self.shift.alarm = alarm;
        
        [self displayAlarmInCell:alarmCell];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
