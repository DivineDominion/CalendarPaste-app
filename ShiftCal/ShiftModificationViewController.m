//
//  ShiftAddController.m
//  ShiftCal
//
//  Created by Christian Tietze on 16.08.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "ShiftModificationViewController.h"

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

@interface ShiftData : NSObject
{
    EKEventStore *_eventStore;
    NSDictionary *_shiftAttributes;
}

@property (nonatomic, retain) NSDictionary *shiftAttributes;

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSNumber *alarmFirstInterval;
@property (nonatomic, retain) NSNumber *alarmSecondInterval;
@property (nonatomic, retain) NSString *calendarIdentifier;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *note;

- (id)initWithAttributes:(NSDictionary *)attributes;

- (NSInteger)durationHours;
- (NSInteger)durationMinutes;
- (void)setDurationHours:(NSInteger)hours andMinutes:(NSInteger)minutes;
- (NSString *)calendarTitle;
@end

@implementation ShiftData
@synthesize shiftAttributes = _shiftAttributes;

- (id)initWithAttributes:(NSDictionary *)attributes
{
    NSAssert(attributes, @"attributes required");
    
    self = [super init];
    if (self)
    {
        self.shiftAttributes = attributes;
    }
    return self;
}

- (void)dealloc
{
    [_eventStore release];
    [_shiftAttributes release];
    
    [super dealloc];
}

- (NSString *)title
{
    NSString *title = [self.shiftAttributes objectForKey:@"title"];
    if ([title isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    return title;
}

- (void)setTitle:(NSString *)title
{
    [self.shiftAttributes setValue:title forKey:@"title"];
}

- (NSString *)location
{
    NSString *location = [self.shiftAttributes objectForKey:@"location"];
    if ([location isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    return location;
}

- (void)setLocation:(NSString *)location
{
    [self.shiftAttributes setValue:location forKey:@"location"];
}

- (NSInteger)durationHours
{
    NSNumber *durHours = [self.shiftAttributes objectForKey:@"durHours"];
    if ([durHours isKindOfClass:[NSNull class]])
    {
        return 0;
    }
    return [durHours integerValue];
}

- (NSInteger)durationMinutes
{
    NSNumber *durMinutes = [self.shiftAttributes objectForKey:@"durMinutes"];
    if ([durMinutes isKindOfClass:[NSNull class]])
    {
        return 0;
    }
    return [durMinutes integerValue];
}

- (void)setDurationHours:(NSInteger)hours andMinutes:(NSInteger)minutes
{
    [self.shiftAttributes setValue:[NSNumber numberWithInt:hours] forKey:@"durHours"];
    [self.shiftAttributes setValue:[NSNumber numberWithInt:minutes] forKey:@"durMinutes"];
}

- (NSNumber *)alarmFirstInterval
{
    NSNumber *alarmFirstInterval = [self.shiftAttributes objectForKey:@"alarmFirstInterval"];
    if ([alarmFirstInterval isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    return alarmFirstInterval;
}

- (void)setAlarmFirstInterval:(NSNumber *)alarmFirstInterval
{
    [self.shiftAttributes setValue:alarmFirstInterval forKey:@"alarmFirstInterval"];
}

- (NSNumber *)alarmSecondInterval
{
    NSNumber *alarmSecondInterval = [self.shiftAttributes objectForKey:@"alarmSecondInterval"];
    if ([alarmSecondInterval isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    return alarmSecondInterval;
}

- (void)setAlarmSecondInterval:(NSNumber *)alarmSecondInterval
{
    [self.shiftAttributes setValue:alarmSecondInterval forKey:@"alarmSecondInterval"];
}

- (BOOL)hasFirstAlarm
{
    return ([self alarmFirstInterval] != nil);
}

- (NSString *)calendarIdentifier
{
    NSString *calendarIdentifier = [self.shiftAttributes objectForKey:@"calendarIdentifier"];
    if ([calendarIdentifier isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    return calendarIdentifier;
}

- (void)setCalendarIdentifier:(NSString *)calendarIdentifier
{
    [self.shiftAttributes setValue:calendarIdentifier forKey:@"calendarIdentifier"];
}

- (EKEventStore *)eventStore
{
    if (_eventStore)
    {
        return _eventStore;
    }
    
    _eventStore = [[EKEventStore alloc] init];
    
    return _eventStore;
}

- (EKCalendar *)calendar
{
    if (self.calendarIdentifier)
    {
        return [self.eventStore calendarWithIdentifier:self.calendarIdentifier];
    }
    
    return nil;
}

- (NSString *)calendarTitle
{
    return self.calendar.title;
}

- (NSString *)url
{
    NSString *url = [self.shiftAttributes objectForKey:@"url"];
    if ([url isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    return url;
}

- (void)setUrl:(NSString *)url
{
    [self.shiftAttributes setValue:url forKey:@"url"];
}

- (NSString *)note
{
    NSString *note = [self.shiftAttributes objectForKey:@"note"];
    if ([note isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    return note;
}

- (void)setNote:(NSString *)note
{
    [self.shiftAttributes setValue:note forKey:@"note"];
}

@end

@interface ShiftModificationViewController ()
{
    // private instance variables
    ShiftData *_shiftData;
    BOOL _isNewEntry;
    DateIntervalTranslator *_dateTranslator;
    NSInteger _selectedAlarmRow;
    ShiftTemplateController *_shiftTemplateController;
}

// private properties
@property (nonatomic, retain) ShiftData *shiftData;
@property (nonatomic, retain) DateIntervalTranslator *dateTranslator;
@property (nonatomic, assign) NSInteger selectedAlarmRow;
@property (nonatomic, readonly) ShiftTemplateController *shiftTemplateController;

// private methods
- (void)resetTextViewToPlaceholder:(UITextView *)textView;
- (void)displayDurationInCell:(UITableViewCell *)cell;
- (void)displayCalendarInCell:(UITableViewCell *)cell;
- (void)displayAlarmInCell:(UITableViewCell *)cell;
- (void)setFirstAlarmOffset:(NSNumber *)alarmOffset;
@end

@implementation ShiftModificationViewController

@synthesize dateTranslator = _dateTranslator;
@synthesize selectedAlarmRow = _selectedAlarmRow;

@synthesize shiftData = _shiftData;
@synthesize modificationDelegate = _modificationDelegate;

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
            self.shiftData = [[ShiftData alloc] initWithAttributes:[self.shiftTemplateController attributeDictionaryForShift:shift]];
            
            _isNewEntry = NO;
        }
        else
        {
            // Creates a temporary shift into the scratchpad context
            self.shiftData = [[ShiftData alloc] initWithAttributes:[self.shiftTemplateController defaultAttributeDictionary]];

            _isNewEntry = YES;
        }
        
        self.dateTranslator = [[[DateIntervalTranslator alloc] init] autorelease];
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
    
    self.navigationItem.rightBarButtonItem = saveItem;
    self.navigationItem.leftBarButtonItem  = cancelItem;
    
    [saveItem release];
    [cancelItem release];
    
    self.title = @"Add Shift";

    // Enable custom title when editing
    if (self.shiftData.title.length > 0)
    {
        self.title = self.shiftData.title;
    }
    
    self.tableView.sectionHeaderHeight = 5.0f;
    self.tableView.sectionFooterHeight = 5.0f;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 5.0)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 5.0)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_isNewEntry)
    {
        // Prevent save until title could have been entered
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        UITextField *defaultTextField = (UITextField *)[self.tableView viewWithTag:TAG_TEXTFIELD_TITLE];
        [defaultTextField becomeFirstResponder];
        
        _isNewEntry = NO;
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
    switch (section)
    {
        case SECTION_TITLE_LOCATION:
            return 2;
        case SECTION_ALARM:
            if ([self.shiftData hasFirstAlarm])
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
    NSString *theText = [ShiftTemplateController durationTextForHours:self.shiftData.durationHours
                                                           andMinutes:self.shiftData.durationMinutes];
    
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
    UIViewController *modalController = nil;
    
    switch (section)
    {
        case SECTION_DURATION:
        {
            DurationPickerController *durationController = [[DurationPickerController alloc] initWithHours:self.shiftData.durationHours
                                                                                                andMinutes:self.shiftData.durationMinutes];
            durationController.delegate = self;
            
            modalController = durationController;
            
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
            
            if ([indexPath row] == 0)
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

#pragma mark - Presented view delegate

- (void)durationPicker:(id)durationPicker didSelectHours:(NSInteger)hours andMinutes:(NSInteger)minutes
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // means "Done";  both equal 0 on "Cancel"
    if (hours > 0 || minutes > 0)
    {
        NSIndexPath *durationPath     = [NSIndexPath indexPathForRow:0 inSection:SECTION_DURATION];
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

#pragma mark - Save and Cancel

- (void)save:(id)sender
{
    if (self.modificationDelegate)
    {
        // Default internally to a meaningful title
        if (self.shiftData.title.length == 0)
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
