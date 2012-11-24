//
//  ShiftAssignmentViewController.m
//  ShiftCal
//
//  Created by Christian Tietze on 09.10.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "ShiftAssignmentViewController.h"

#define PICKER_HEIGHT 216.0f

#define SECTION_TITLE 0
#define SECTION_STARTS_ENDS 1

#define ROW_STARTS 0
#define ROW_ENDS   1

@interface ShiftAssignmentViewController ()
{
    NSDate *_startDate;
    NSDateFormatter *_dateFormatter;
    
    UIDatePicker *_datePicker;
}

@property (nonatomic, retain, readwrite) ShiftTemplate *shift;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain, readonly) NSDateFormatter *dateFormatter;

- (NSDate *)endDate;

- (void)done:(id)sender;
- (void)cancel:(id)sender;

+ (NSDate *)roundedDate;
@end

@implementation ShiftAssignmentViewController
@synthesize delegate = _delegate;
@synthesize shift = _shift;
@synthesize startDate = _startDate;

- (id)init
{
    return [self initWithShift:nil];
}

- (id)initWithShift:(ShiftTemplate *)shift
{
    return [self initWithStyle:UITableViewStyleGrouped andShift:shift];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self initWithStyle:style andShift:nil];
}

- (id)initWithStyle:(UITableViewStyle)style andShift:(ShiftTemplate *)shift
{
    NSAssert(shift, @"shift required");
    
    self = [super initWithStyle:style];
    
    if (self) {
        self.shift = shift;
        self.startDate = [ShiftAssignmentViewController roundedDate];
    }
    
    return self;
}

- (void)dealloc
{
    [_shift release];
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
    if (screenHeight == 568.0f)
    {
        topMargin += 44.0f; // center on iPhone 4-inch
    }
    
    CGRect tableHeaderFrame = CGRectMake(0.0f, 0.0f, screenWidth, topMargin);
    self.tableView.tableHeaderView = [[[UIView alloc] initWithFrame:tableHeaderFrame] autorelease];
    
    CGRect pickerFrame = CGRectMake(0.0f, screenHeight, screenWidth, PICKER_HEIGHT);
    _datePicker = [[UIDatePicker alloc] initWithFrame:pickerFrame];
    [_datePicker addTarget:self action:@selector(datePickerChanged:) forControlEvents:UIControlEventValueChanged];
    
    [_datePicker setDate:self.startDate];
    
    [self.tableView addSubview:_datePicker];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *saveItem   = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(done:)];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                target:self
                                                                                action:@selector(cancel:)];
    
    self.navigationItem.rightBarButtonItem = saveItem;
    self.navigationItem.leftBarButtonItem  = cancelItem;
    
    [saveItem release];
    [cancelItem release];
    
    self.title = @"Paste";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CGRect frame   = _datePicker.frame;
    frame.origin.y = frame.origin.y - PICKER_HEIGHT - 64.0f; // Navbar + status bar height: 64px
    
    [UIView animateWithDuration:0.3 animations:^{
        _datePicker.frame = frame;
    }];
}

- (NSDateFormatter *)dateFormatter
{
    if (_dateFormatter)
    {
        return _dateFormatter;
    }
    
    NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"EdMMM  jm" options:0
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
    
    return 42.0;
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
                cell.textLabel.text = @"Starts";
                
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
    self.startDate = _datePicker.date;
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SECTION_STARTS_ENDS]
                  withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark Navigation Buttons

- (void)done:(id)sender
{
    EKEventStore *eventStore = self.shift.eventStore;
    EKEvent *event           = [[self.shift event] retain];
    
    event.startDate = self.startDate;
    event.endDate   = [self endDate];
    
    NSError *error = nil;
    
    BOOL success = [eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&error];
    NSAssert(success, @"saving the event failed: %@", error);
    
    [event release];
    
    [self.delegate shiftAssignmentViewController:self didCompleteWithAction:SCAssignmentViewActionSaved];
}

- (void)cancel:(id)sender
{
    [self.delegate shiftAssignmentViewController:self didCompleteWithAction:SCAssignmentViewActionCanceled];
}

#pragma mark Utility methods

+ (NSDate *)roundedDate
{
    static NSUInteger kDateComponents = (NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSEraCalendarUnit | NSYearCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit);
    
    NSCalendar *calendar   = [NSCalendar currentCalendar];
    NSDate *now            = [NSDate date];
    NSDateComponents *comp = [calendar components:kDateComponents fromDate:now];
    
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
