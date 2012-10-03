//
//  AlarmViewController.m
//  ShiftCal
//
//  Created by Christian Tietze on 14.09.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "AlarmPickerViewController.h"
#import "DateIntervalTranslator.h"

#define ROW_NONE 0

#define INDEX_LABEL 0
#define INDEX_OFFSET 1

@interface AlarmPickerViewController ()
{
    // private instance variables
    NSIndexPath *_selectedIndexPath;
    NSArray *_alarms;
    UIColor *_selectionColor;
    DateIntervalTranslator *_dateTranslator;
}

// private properties
@property (nonatomic, retain) NSIndexPath *selectedIndexPath;
@property (nonatomic, copy)   NSArray *alarms;
@property (nonatomic, retain, readonly) UIColor *selectionColor;
@property (nonatomic, retain) DateIntervalTranslator *dateTranslator;

// private methods
- (NSInteger)rowForInterval:(NSTimeInterval)interval;
@end

@implementation AlarmPickerViewController

@synthesize delegate = _delegate;
@synthesize selectionColor = _selectionColor;
@synthesize dateTranslator = _dateTranslator;

@synthesize selectedIndexPath = _selectedIndexPath;
@synthesize alarms = _alarms;

- (id)init
{
    return [self initWithAlarmOffset:nil];
}

- (id)initWithAlarmOffset:(NSNumber *)alarmOffset
{
    return [self initWithStyle:UITableViewStyleGrouped selectedAlarmOffset:alarmOffset];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self initWithStyle:style selectedAlarmOffset:nil];
}

- (id)initWithStyle:(UITableViewStyle)style selectedAlarmOffset:(NSNumber *)alarmOffset
{
    self = [super initWithStyle:style];
    
    if (self)
    {
        [self loadModel];
        
        self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
        // Corresponds to checkmark color
        _selectionColor = [[UIColor colorWithRed:45/255.0 green:65/255.0 blue:115/255.0 alpha:1.0] retain];
        
        if (alarmOffset)
        {
            NSInteger row = [self rowForInterval:[alarmOffset doubleValue]];
            
            self.selectedIndexPath = [NSIndexPath indexPathForRow:row inSection:0];
        }
    }
    
    return self;
}

- (NSInteger)rowForInterval:(NSTimeInterval)interval
{
    // Since "None" is not a desired outcome (this method wouldn't be called
    // in that case), index == ROW_NONE would be illegal and can be ignored.
    NSIndexSet *indexes = [[self.alarms objectAtIndex:INDEX_OFFSET] indexesOfObjectsPassingTest:
                           ^BOOL(id intervalObj, NSUInteger index, BOOL *stop)
                           {
                               BOOL found = (interval == [intervalObj doubleValue]
                                             && index != ROW_NONE);
                               
                               *stop = found;
                               return found;
                           }];
    
    return [indexes firstIndex];
}

- (void)dealloc
{
    [_alarms release];
    [_selectionColor release];
    
    [self.selectedIndexPath release];
    [self.dateTranslator release];
    
    [super dealloc];
}

- (void)loadModel
{
    self.dateTranslator = [[[DateIntervalTranslator alloc] init] autorelease];

    NSArray *intervals = @[
        @0.0,
        @([self.dateTranslator timeIntervalForComponentDays:0 hours:0 minutes:0]),
        @([self.dateTranslator timeIntervalForComponentDays:0 hours:0 minutes:-5]),
        @([self.dateTranslator timeIntervalForComponentDays:0 hours:0 minutes:-15]),
        @([self.dateTranslator timeIntervalForComponentDays:0 hours:0 minutes:-30]),
        @([self.dateTranslator timeIntervalForComponentDays:0 hours:-1 minutes:0]),
        @([self.dateTranslator timeIntervalForComponentDays:0 hours:-2 minutes:0]),
        @([self.dateTranslator timeIntervalForComponentDays:-1 hours:0 minutes:0]),
        @([self.dateTranslator timeIntervalForComponentDays:-2 hours:0 minutes:0])];
    
    NSArray *labels = @[
        @"None",
        [self.dateTranslator humanReadableFormOfInterval:[[intervals objectAtIndex:1] doubleValue]],
        [self.dateTranslator humanReadableFormOfInterval:[[intervals objectAtIndex:2] doubleValue]],
        [self.dateTranslator humanReadableFormOfInterval:[[intervals objectAtIndex:3] doubleValue]],
        [self.dateTranslator humanReadableFormOfInterval:[[intervals objectAtIndex:4] doubleValue]],
        [self.dateTranslator humanReadableFormOfInterval:[[intervals objectAtIndex:5] doubleValue]],
        [self.dateTranslator humanReadableFormOfInterval:[[intervals objectAtIndex:6] doubleValue]],
        [self.dateTranslator humanReadableFormOfInterval:[[intervals objectAtIndex:7] doubleValue]],
        [self.dateTranslator humanReadableFormOfInterval:[[intervals objectAtIndex:8] doubleValue]]];
    
    self.alarms = @[labels, intervals];
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
    
    self.title = @"Alarm";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.alarms objectAtIndex:INDEX_LABEL] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"alert";
    
    NSInteger row = indexPath.row;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.text = [[self.alarms objectAtIndex:INDEX_LABEL] objectAtIndex:row];
    
    if ([self.selectedIndexPath isEqual:indexPath])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.textLabel.textColor = self.selectionColor;
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.selectedIndexPath isEqual:indexPath])
    {
        return;
    }
    
    UITableViewCell *oldSelection = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
    UITableViewCell *newSelection = [tableView cellForRowAtIndexPath:indexPath];
    
    [tableView beginUpdates];
    oldSelection.accessoryType = UITableViewCellAccessoryNone;
    newSelection.accessoryType = UITableViewCellAccessoryCheckmark;
    // TODO change selected font to checkmark color
    
    oldSelection.textLabel.textColor = [UIColor darkTextColor];
    newSelection.textLabel.textColor = self.selectionColor;
    
    self.selectedIndexPath = indexPath;
    [tableView endUpdates];
}

#pragma mark - Save and Cancel

- (void)save:(id)sender
{
    NSNumber *alarmOffset = nil;
    NSInteger row = [self.selectedIndexPath row];
    
    if (row != ROW_NONE)
    {
        alarmOffset = [[self.alarms objectAtIndex:INDEX_OFFSET] objectAtIndex:row];
    }
    
    [self.delegate alarmPicker:self didSelectAlarmOffset:alarmOffset canceled:NO];
}

- (void)cancel:(id)sender
{
    [self.delegate alarmPicker:self didSelectAlarmOffset:nil canceled:YES];
}

@end
