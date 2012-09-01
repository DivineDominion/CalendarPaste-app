//
//  DurationSetViewController.m
//  ShiftCal
//
//  Created by Christian Tietze on 31.08.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "DurationPickerController.h"

#define CELL_ID @"duration"

@interface DurationPickerController ()

@end

@implementation DurationPickerController

- (void)loadView
{
    _mainView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    _tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds] style:UITableViewStyleGrouped];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    
    [_mainView addSubview:_tableView];
    
    
    // Visually hide down below screen bounds
    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0f, [[UIScreen mainScreen] bounds].size.height, 320.0f, 216.0f)];
    
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    _pickerView.showsSelectionIndicator = YES;
    
    _pickerView.hidden = NO; // set it to visible and then animate it to slide up
    
    [_mainView addSubview:_pickerView];

    self.view = _mainView;
}

- (void)dealloc
{
    [_tableView setDelegate:nil];
    [_tableView setDataSource:nil];
    [_tableView release];
    
    [_pickerView setDelegate:nil];
    [_pickerView setDataSource:nil];
    [_pickerView release];
    
    [_mainView release];
    
    [super dealloc];
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

- (void)viewDidAppear:(BOOL)animated
{
    [UIView beginAnimations:@"slideIn" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    // Picker height: 216px
    // Navbar + status bar height: 64px
    _pickerView.frame = CGRectMake(0.0f, _pickerView.frame.origin.y - 216.0f - 64.0f, 320.0f, 216.0f);
    [UIView commitAnimations];
}

#pragma mark - TableView data

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section != 0)
    {
        StupidError(@"more sections asked for than set up: %d", section)
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] != 0 && [indexPath row] != 0)
    {
        StupidError(@"invalid section/row pair (%d, %d):  setup wrong", [indexPath section], [indexPath row]);
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID];

    if (!cell)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CELL_ID] autorelease];
        
        cell.detailTextLabel.text = @"Duration";
    }

    return cell;
}


#pragma mark - PickerView management

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0)
    {
        return 25;
    }
    
    return 61;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *format = @"min";
    if (component == 0)
    {
        format = @"h";
    }
    return [NSString stringWithFormat:@"%d%@", row, format];
}

#pragma mark - Save and Cancel

- (void)save:(id)sender
{    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)cancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
