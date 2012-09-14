//
//  ReminderViewController.m
//  ShiftCal
//
//  Created by Christian Tietze on 14.09.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "AlertPickerViewController.h"

@interface AlertPickerViewController ()
{
    // private instance variables
    NSIndexPath *_selectedIndexPath;
    NSArray *_alerts;
}

// private properties
@property (nonatomic, retain) NSIndexPath *selectedIndexPath;
@property (nonatomic, copy) NSArray *alerts;
@end

@implementation AlertPickerViewController

@synthesize delegate = _delegate;

@synthesize selectedIndexPath = _selectedIndexPath;
@synthesize alerts = _alerts;

- (id)init
{
    return [self initWithAlert:nil];
}

- (id)initWithAlert:(id)alert
{
    return [self initWithStyle:UITableViewStyleGrouped selectedReminder:alert];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self initWithStyle:style selectedReminder:nil];
}

- (id)initWithStyle:(UITableViewStyle)style selectedReminder:(id)alert
{
    self = [super initWithStyle:style];
    
    if (self)
    {
        [self loadModel];
        
        self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
        if (alert)
        {
            // TODO map param to index path
        }
    }
    
    return self;
}

- (void)dealloc
{
    [_alerts release];
    
    [super dealloc];
}

- (void)loadModel
{
    NSArray *intervals = @[@"None", @"On date", @"5min", @"15min", @"30min", @"1h", @"2h", @"1d", @"2d"];
    
    self.alerts = intervals;
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
    
    self.title = @"Alert";
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
    return [self.alerts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"reminder";
    
    NSInteger row = indexPath.row;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.text = [self.alerts objectAtIndex:row];
    
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
    id reminder = nil;
    
    [self.delegate alertPicker:self didSelectAlert:reminder];
}

- (void)cancel:(id)sender
{
    [self.delegate alertPicker:self didSelectAlert:nil];
}

@end
