//
//  CalendarPickerController.m
//  ShiftCal
//
//  Created by Christian Tietze on 04.09.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "CalendarPickerController.h"

@interface CalendarPickerController ()

@end

@implementation CalendarPickerController

@synthesize eventStore = _eventStore;
@synthesize selectedCellIndexPath = _selectedCellIndexPath;
@synthesize delegate = _delegate;

- (id)init
{
    return [self initWithStyle:UITableViewStyleGrouped];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self initWithSelectedCalendar:nil withStyle:style];
}

- (id)initWithSelectedCalendar:(EKCalendar *)calendar
{
    return [self initWithSelectedCalendar:calendar withStyle:UITableViewStyleGrouped];
}

- (id)initWithSelectedCalendar:(EKCalendar *)calendar withStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    
    if (self)
    {
        self.eventStore = [[EKEventStore alloc] init];
        
        NSIndexPath *defaultPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
        if (calendar) {
            NSInteger index = [self.eventStore.calendars indexOfObject:calendar];
            defaultPath = [NSIndexPath indexPathForRow:index inSection:0];
        }
        
        self.selectedCellIndexPath = defaultPath;
    }
    
    return self;
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
    return self.eventStore.calendars.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSInteger row = [indexPath row];
    
    if (!cell)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    EKCalendar *calendar = [self.eventStore.calendars objectAtIndex:row];
    cell.textLabel.text = calendar.title;
    
    if ([indexPath isEqual:self.selectedCellIndexPath])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([indexPath isEqual:self.selectedCellIndexPath])
    {
        return;
    }
    
    [tableView cellForRowAtIndexPath:self.selectedCellIndexPath].accessoryType = UITableViewCellAccessoryNone;
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    
    self.selectedCellIndexPath = indexPath;
}

#pragma mark - Save and Cancel

- (void)save:(id)sender
{
    NSInteger row = self.selectedCellIndexPath.row;
    EKCalendar *calendar = [self.eventStore.calendars objectAtIndex:row];
    
    [self.delegate calendarPicker:self didSelectCalendar:calendar];
}

- (void)cancel:(id)sender
{
    [self.delegate calendarPicker:self didSelectCalendar:nil];
}

@end
