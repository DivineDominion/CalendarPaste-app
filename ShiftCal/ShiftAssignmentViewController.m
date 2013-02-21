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

#define SECTION_TITLE 0
#define SECTION_STARTS_ENDS 1

#define ROW_STARTS 0
#define ROW_ENDS   1

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
    float screenHeight  = screenBounds.size.height;
    
    self.tableView.autoresizingMask =  UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.scrollEnabled    = NO;
    self.tableView.sectionHeaderHeight = 5.0f;
    self.tableView.sectionFooterHeight = 5.0f;
    
    // top margin:  15px = 1/2 200px (visible content height) - 1/2 160px (cell's heights) - 5px section top margin
    float topMargin = 15.0f;
    if ([self.shift isAllDay])
    {
        // nudge down half a cell if only one is shown
        topMargin += CELL_HEIGHT_STARTS_ENDS / 2;
    }
    if (screenHeight == 568.0f)
    {
        // nudge down even further on iPhone 4-inch screens
        topMargin += 44.0f;
    }
    
    CGRect tableHeaderFrame = CGRectMake(0.0f, 0.0f, screenWidth, topMargin);
    self.tableView.tableHeaderView = [[[UIView alloc] initWithFrame:tableHeaderFrame] autorelease];
    
    CGRect pickerFrame = CGRectMake(0.0f, screenHeight, screenWidth, PICKER_HEIGHT);
    self.datePicker = [[[UIDatePicker alloc] initWithFrame:pickerFrame] autorelease];
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CGRect frame   = self.datePicker.frame;
    frame.origin.y = frame.origin.y - PICKER_HEIGHT - 64.0f; // Navbar + status bar height: 64px
    
    [UIView animateWithDuration:0.3 animations:^{
        self.datePicker.frame = frame;
    }];
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
            return 1;
        }
        
        return 2;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (SECTION_TITLE == [indexPath section])
    {
        return 62.0;
    }
    
    return CELL_HEIGHT_STARTS_ENDS;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    NSInteger section = [indexPath section];
    NSInteger row     = [indexPath row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (section)
    {
        case SECTION_TITLE:
            cell.textLabel.numberOfLines = 2;
            cell.textLabel.text = @"Title\nCalendar";
            
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
                
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
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
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SECTION_STARTS_ENDS]
                  withRowAnimation:UITableViewRowAnimationNone];
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
