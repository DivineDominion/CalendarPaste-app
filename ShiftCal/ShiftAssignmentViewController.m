//
//  ShiftAssignmentViewController.m
//  ShiftCal
//
//  Created by Christian Tietze on 09.10.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "ShiftAssignmentViewController.h"
#import "NSDate+Tomorrow.h"

#define PICKER_HEIGHT 216.0f
#define PICKER_TAG 123

#define SECTION_TITLE 0
#define SECTION_STARTS_ENDS 1

#define ROW_STARTS 0
#define ROW_PICKER 1
#define ROW_ENDS   2

static NSString *kCellInfo = @"otherCell";
static NSString *kCellDate = @"dateCell";
static NSString *kCellPicker = @"datePicker";

#define CELL_HEIGHT_STARTS_ENDS 42.0

@interface ShiftAssignmentViewController ()
{
    NSDate *_startDate;
    NSDateFormatter *_dateFormatter;
    
    UIDatePicker *_datePicker;
    ShiftTemplateController *_shiftTemplateController;
}

@property (nonatomic, retain, readwrite) ShiftTemplate *shift;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain, readonly) NSDateFormatter *dateFormatter;
@property (nonatomic, retain) ShiftTemplateController *shiftTemplateController;
@property (nonatomic, retain) UIDatePicker *datePicker;

- (NSDate *)endDate;

- (void)done:(id)sender;
- (void)cancel:(id)sender;

+ (NSDateComponents *)dateComponentsForNowFrom:(NSCalendar *)calendar;
+ (NSDate *)roundedDate;
+ (NSDate *)nextDateWithHour:(NSUInteger)hour andMinute:(NSUInteger)minute;
@end

@implementation ShiftAssignmentViewController
@synthesize delegate = _delegate;
@synthesize shift = _shift;
@synthesize shiftTemplateController = _shiftTemplateController;
@synthesize startDate = _startDate;
@synthesize datePicker = _datePicker;

- (id)init
{
    return [self initWithShift:nil shiftTemplateController:nil];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self initWithStyle:style shift:nil shiftTemplateController:nil];
}

- (id)initWithShift:(ShiftTemplate *)shift shiftTemplateController:(ShiftTemplateController *)shiftTemplateController
{
    return [self initWithStyle:UITableViewStyleGrouped shift:shift shiftTemplateController:shiftTemplateController];
}

- (id)initWithStyle:(UITableViewStyle)style shift:(ShiftTemplate *)shift shiftTemplateController:(ShiftTemplateController *)shiftTemplateController
{
    NSAssert(shift, @"shift required");
    NSAssert(shiftTemplateController, @"shiftTemplateController required");
    
    self = [super initWithStyle:style];
    
    if (self) {
        self.shift = shift;
        self.shiftTemplateController = shiftTemplateController;
        
        NSDate *startDate = nil;
        
        if ([shift isAllDay])
        {
            startDate = [NSDate tomorrow];
        }
        else if ([shift wasAlreadyPasted])
        {
            startDate = [ShiftAssignmentViewController nextDateWithHour:[shift.lastPasteHours integerValue]
                                                              andMinute:[shift.lastPasteMins integerValue]];
        }
        else
        {
            startDate = [ShiftAssignmentViewController roundedDate];
        }
        
        self.startDate = startDate;
    }
    
    return self;
}

- (void)dealloc
{
    [_shift release];
    [_shiftTemplateController release];
    
    [_startDate release];
    [_dateFormatter release];
    [_datePicker release];
    
    [super dealloc];
}

- (void)loadView
{
    [super loadView];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    float screenWidth   = screenBounds.size.width;
    
    self.tableView.autoresizingMask =  UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.scrollEnabled    = NO;
    
    CGRect pickerFrame = CGRectMake(0.0f, 0.0f, screenWidth - 20, PICKER_HEIGHT);
    self.datePicker = [[[UIDatePicker alloc] initWithFrame:pickerFrame] autorelease];
    self.datePicker.tag = PICKER_TAG;
    [self.datePicker addTarget:self action:@selector(datePickerChanged:) forControlEvents:UIControlEventValueChanged];
    
    UIDatePickerMode pickerMode = UIDatePickerModeDateAndTime;

    if ([self.shift isAllDay])
    {
        pickerMode = UIDatePickerModeDate;
    }
    
    [self.datePicker setDate:self.startDate];
    self.datePicker.datePickerMode = pickerMode;
    
    [self.tableView addSubview:self.datePicker];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UIBarButtonItem *saveItem   = [[UIBarButtonItem alloc] initWithTitle:@"Paste"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(done:)];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                target:self
                                                                                action:@selector(cancel:)];
    
    self.navigationItem.rightBarButtonItem = saveItem;
    self.navigationItem.leftBarButtonItem  = cancelItem;
    
    [saveItem release];
    [cancelItem release];
    
    self.title = @"Pick a Time";
}

- (NSDateFormatter *)dateFormatter
{
    if (_dateFormatter)
    {
        return _dateFormatter;
    }
    
    NSString *template = @"EdMMM  jm";
    
    if ([self.shift isAllDay])
    {
        template = @"EdMMM";
    }
    
    NSString *formatString = [NSDateFormatter dateFormatFromTemplate:template options:0
                                                              locale:[NSLocale currentLocale]];    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:formatString];
    
    return _dateFormatter;
}

- (NSDate *)endDate
{
    return [NSDate dateWithTimeInterval:self.shift.durationAsTimeInterval
                              sinceDate:self.startDate];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SECTION_TITLE)
    {
        return 1;
    }
    else if (section == SECTION_STARTS_ENDS)
    {
        if ([self.shift isAllDay])
        {
            return 2;
        }
        
        return 3;
    }
    
    return 0;
}

- (BOOL)indexPathIsInfo:(NSIndexPath *)indexPath {
    return SECTION_TITLE == [indexPath section];
}

- (BOOL)indexPathIsPicker:(NSIndexPath *)indexPath {
    return SECTION_STARTS_ENDS == [indexPath section] && ROW_PICKER == [indexPath row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self indexPathIsInfo:indexPath])
    {
        return 62.0;
    }
    else if ([self indexPathIsPicker:indexPath])
    {
        return PICKER_HEIGHT;
    }
    
    return CELL_HEIGHT_STARTS_ENDS;
}

- (NSString *)cellIdForIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = kCellDate;
    
    if ([self indexPathIsPicker:indexPath])
    {
        cellId = kCellPicker;
    }
    
    if ([self indexPathIsInfo:indexPath])
    {
        cellId = kCellInfo;
    }
    
    return cellId;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row     = [indexPath row];

    NSString *cellId = [self cellIdForIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId] autorelease];
    }
    
    cell.textLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (section)
    {
        case SECTION_TITLE:
            cell.textLabel.numberOfLines = 2;
            cell.textLabel.text = @"Event Title\nCalendar";
            
            cell.detailTextLabel.numberOfLines = 2;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@", self.shift.title, self.shift.calendarTitle];
            
            break;
        case SECTION_STARTS_ENDS:
        {
            if (row == ROW_STARTS)
            {
                cell.textLabel.textColor = [UIColor darkTextColor];
                
                if ([self.shift isAllDay])
                {
                    cell.textLabel.text = @"On";
                }
                else
                {
                    cell.textLabel.text = @"Starts";
                }
                
                
                cell.detailTextLabel.textColor = [UIColor darkTextColor];
                cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.startDate];
            }
            else if (row == ROW_PICKER)
            {
                if ([cell viewWithTag:PICKER_TAG] == nil)
                {
                    [cell addSubview:self.datePicker];
                }
            }
            else if (row == ROW_ENDS)
            {
                cell.textLabel.text = @"Ends";
                
                cell.detailTextLabel.text = [self.dateFormatter stringFromDate:[self endDate]];
            }
            break;
        }
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UI Interaction

- (void)datePickerChanged:(id)sender
{
    self.startDate = self.datePicker.date;
    
    NSIndexPath *startCellIndexPath = [NSIndexPath indexPathForRow:ROW_STARTS inSection:SECTION_STARTS_ENDS];
    UITableViewCell *startCell = [self.tableView cellForRowAtIndexPath:startCellIndexPath];
    
    startCell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.startDate];
    
    if (![self.shift isAllDay]) {
        NSIndexPath *endCellIndexPath = [NSIndexPath indexPathForRow:ROW_ENDS inSection:SECTION_STARTS_ENDS];
        UITableViewCell *endCell = [self.tableView cellForRowAtIndexPath:endCellIndexPath];
        
        endCell.detailTextLabel.text = [self.dateFormatter stringFromDate:[self endDate]];
    }
}

#pragma mark Navigation Buttons

- (void)done:(id)sender
{
    EKEventStore *eventStore = self.shift.eventStore;
    EKEvent *event           = [[self.shift event] retain];
    
    event.allDay = [self.shift isAllDay];
    
    event.startDate = self.startDate;
    event.endDate   = [self endDate];
    
    NSError *error = nil;
    
    BOOL success = [eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&error];
    NSAssert(success, @"saving the event failed: %@", error);
    
    [event release];
    
    if (success)
    {
        if ([self.shift isAllDay] == NO)
        {
            [self.shift setLastPaste:self.startDate];
            [self.shiftTemplateController saveManagedObjectContext];
        }
        
        [self.delegate shiftAssignmentViewController:self didCompleteWithAction:SCAssignmentViewActionSaved];
    }
    else
    {
        [self.delegate shiftAssignmentViewController:self didCompleteWithAction:SCAssignmentViewActionCanceled];
    }
}

- (void)cancel:(id)sender
{
    [self.delegate shiftAssignmentViewController:self didCompleteWithAction:SCAssignmentViewActionCanceled];
}

#pragma mark Utility methods

+ (NSDateComponents *)dateComponentsForNowFrom:(NSCalendar *)calendar
{
    static NSUInteger kDateComponents = (NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSEraCalendarUnit | NSYearCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit);
    
    NSDate *now            = [NSDate date];
    NSDateComponents *comp = [calendar components:kDateComponents fromDate:now];
    
    return comp;
}

+ (NSDate *)nextDateWithHour:(NSUInteger)hour andMinute:(NSUInteger)minute
{
    NSCalendar *calendar   = [NSCalendar currentCalendar];
    NSDateComponents *comp = [ShiftAssignmentViewController dateComponentsForNowFrom:calendar];
    
    if (comp.hour > hour)
    {
        [comp setDay:comp.day + 1];
    }
    
    [comp setHour:hour];
    [comp setMinute:minute];
    [comp setSecond:0];
    
    return [calendar dateFromComponents:comp];
}

+ (NSDate *)roundedDate
{
    NSCalendar *calendar   = [NSCalendar currentCalendar];
    NSDateComponents *comp = [ShiftAssignmentViewController dateComponentsForNowFrom:calendar];
    
    [comp setSecond:0];
    
    if (comp.minute >= 45)
    {
        [comp setMinute:0];
        [comp setHour:comp.hour + 1];
    }
    else if (comp.minute >= 30)
    {
        [comp setMinute:45];
    }
    else if (comp.minute >= 15)
    {
        [comp setMinute:30];
    }
    else if (comp.minute >= 0)
    {
        [comp setMinute:15];
    }
    
    return [calendar dateFromComponents:comp];
}
@end
