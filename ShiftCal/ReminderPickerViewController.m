//
//  ReminderViewController.m
//  ShiftCal
//
//  Created by Christian Tietze on 14.09.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "ReminderPickerViewController.h"

@interface ReminderPickerViewController ()
{
    // private instance variables
    NSIndexPath *_selectedIndexPath;
    NSArray *_reminders;
}

// private properties
@property (nonatomic, retain) NSIndexPath *selectedIndexPath;
@property (nonatomic, copy) NSArray *reminders;
@end

@implementation ReminderPickerViewController

@synthesize delegate = _delegate;

@synthesize selectedIndexPath = _selectedIndexPath;
@synthesize reminders = _reminders;

- (id)init
{
    return [self initWithReminder:nil];
}

- (id)initWithReminder:(id)reminder
{
    return [self initWithStyle:UITableViewStyleGrouped selectedReminder:reminder];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self initWithStyle:style selectedReminder:nil];
}

- (id)initWithStyle:(UITableViewStyle)style selectedReminder:(id)reminder
{
    self = [super initWithStyle:style];
    if (self) {
        [self loadModel];
        
        self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
        if (reminder != nil)
        {
            // TODO map param to index path
        }
    }
    return self;
}

- (void)dealloc
{
    [_reminders release];
    
    [super dealloc];
}

- (void)loadModel
{
    NSArray *reminders = @[@"None", @"On date", @"5min", @"15min", @"30min", @"1h", @"2h", @"1d", @"2d"];
    
    self.reminders = reminders;
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
    
    self.title = @"Reminder";
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
    return [self.reminders count];
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
    
    cell.textLabel.text = [self.reminders objectAtIndex:row];
    
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
    
    [self.delegate reminderPicker:self didSelectReminder:reminder];
}

- (void)cancel:(id)sender
{
    [self.delegate reminderPicker:self didSelectReminder:nil];
}

@end
