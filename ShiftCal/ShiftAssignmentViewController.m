//
//  ShiftAssignmentViewController.m
//  ShiftCal
//
//  Created by Christian Tietze on 09.10.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "ShiftAssignmentViewController.h"

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
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
@property (nonatomic, retain, readonly) UIDatePicker *datePicker;

- (void)done:(id)sender;
- (void)cancel:(id)sender;
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
        self.startDate = [NSDate date]; // TODO round to quarter hours
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
    
    self.tableView.autoresizingMask =  UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.scrollEnabled    = NO;
    self.tableView.sectionHeaderHeight = 5.0f;
    self.tableView.sectionFooterHeight = 5.0f;
    
    // top margin:  22px = 1/2 200px (visible content height) - 1/2 146px (cell's heights) - 5px section top margin
    CGRect tableHeaderFrame = CGRectMake(0.0f, 0.0f, SCREEN_WIDTH, 22.0f);
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:tableHeaderFrame];
    
    [self.datePicker setDate:self.startDate];
    [self.tableView addSubview:self.datePicker];
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
    
    self.title = @"Assign";
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
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"EEE, d MMM  HH:mm"];
    
    return _dateFormatter;
}

- (UIDatePicker *)datePicker
{
    if (_datePicker)
    {
        return _datePicker;
    }
    
    CGRect pickerFrame   = CGRectMake(0.0f, SCREEN_HEIGHT, SCREEN_WIDTH, PICKER_HEIGHT);
    _datePicker = [[UIDatePicker alloc] initWithFrame:pickerFrame];
    
    return _datePicker;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    NSInteger section = [indexPath section];
    NSInteger row     = [indexPath row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.textLabel.textColor = [UIColor grayColor];
        cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    switch (section)
    {
        case SECTION_TITLE:
            cell.textLabel.text = @"Title";
            cell.detailTextLabel.text = self.shift.title;
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
                
                NSTimeInterval interval = self.shift.durationAsTimeInterval;
                NSDate *endDate = [NSDate dateWithTimeInterval:interval sinceDate:self.startDate];
                
                cell.detailTextLabel.text = [self.dateFormatter stringFromDate:endDate];
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

#pragma mark - Navigation Buttons

- (void)done:(id)sender
{
    [self.delegate shiftAssignmentViewController:self didCompleteWithAction:SCAssignmentViewActionSaved];
}

- (void)cancel:(id)sender
{
    [self.delegate shiftAssignmentViewController:self didCompleteWithAction:SCAssignmentViewActionCanceled];
}

@end
