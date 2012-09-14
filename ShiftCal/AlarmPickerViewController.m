//
//  AlarmViewController.m
//  ShiftCal
//
//  Created by Christian Tietze on 14.09.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "AlarmPickerViewController.h"

@interface AlarmPickerViewController ()
{
    // private instance variables
    NSIndexPath *_selectedIndexPath;
    NSArray *_alarms;
}

// private properties
@property (nonatomic, retain) NSIndexPath *selectedIndexPath;
@property (nonatomic, copy) NSArray *alarms;
@end

@implementation AlarmPickerViewController

@synthesize delegate = _delegate;

@synthesize selectedIndexPath = _selectedIndexPath;
@synthesize alarms = _alarms;

- (id)init
{
    return [self initWithAlarm:nil];
}

- (id)initWithAlarm:(id)alarm
{
    return [self initWithStyle:UITableViewStyleGrouped selectedAlarm:alarm];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self initWithStyle:style selectedAlarm:nil];
}

- (id)initWithStyle:(UITableViewStyle)style selectedAlarm:(id)alarm
{
    self = [super initWithStyle:style];
    
    if (self)
    {
        [self loadModel];
        
        self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
        if (alarm)
        {
            // TODO map param to index path
        }
    }
    
    return self;
}

- (void)dealloc
{
    [_alarms release];
    
    [super dealloc];
}

- (void)loadModel
{
    NSArray *intervals = @[@"None", @"On date", @"5min", @"15min", @"30min", @"1h", @"2h", @"1d", @"2d"];
    
    self.alarms = intervals;
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
    return [self.alarms count];
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
    
    cell.textLabel.text = [self.alarms objectAtIndex:row];
    
    if ([self.selectedIndexPath isEqual:indexPath])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
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
    
    self.selectedIndexPath = indexPath;
    [tableView endUpdates];
}

#pragma mark - Save and Cancel

- (void)save:(id)sender
{
    id alarm = nil;
    
    [self.delegate alarmPicker:self didSelectAlarm:alarm];
}

- (void)cancel:(id)sender
{
    [self.delegate alarmPicker:self didSelectAlarm:nil];
}

@end
