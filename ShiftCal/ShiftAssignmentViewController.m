//
//  ShiftAssignmentViewController.m
//  ShiftCal
//
//  Created by Christian Tietze on 09.10.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "ShiftAssignmentViewController.h"

#define SECTION_TITLE 0
#define SECTION_STARTS_ENDS 1

#define ROW_STARTS 0
#define ROW_ENDS   1

@interface ShiftAssignmentViewController ()
{
    NSDate *_startDate;
    NSDateFormatter *_dateFormatter;
}

@property (nonatomic, retain, readwrite) ShiftTemplate *shift;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain, readonly) NSDateFormatter *dateFormatter;

- (void)save:(id)sender;
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
    
    [super dealloc];
}

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
    
    self.title = @"Assign";
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
    
    switch (section) {
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

- (void)save:(id)sender
{
    [self.delegate shiftAssignmentViewController:self didCompleteWithAction:SCAssignmentViewActionSaved];
}

- (void)cancel:(id)sender
{
    [self.delegate shiftAssignmentViewController:self didCompleteWithAction:SCAssignmentViewActionCanceled];
}

@end
