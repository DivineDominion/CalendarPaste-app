//
//  DurationSetViewController.m
//  ShiftCal
//
//  Created by Christian Tietze on 31.08.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "DurationPickerController.h"

#define CELL_ID @"duration"

#define PICKER_WIDTH (COMPONENT_HOUR_WIDTH + COMPONENT_MIN_WIDTH)
#define COMPONENT_LABEL_OFFSET 10.0f
#define COMPONENT_LABEL_Y 83.0f
#define COMPONENT_LABEL_HEIGHT 50.0f
#define COMPONENT_SUBLABEL_TAG 100

#define COMPONENT_HOUR 0
#define COMPONENT_HOUR_TAG 101
#define COMPONENT_HOUR_WIDTH 80.0f
#define COMPONENT_HOUR_X (160.0f - PICKER_WIDTH/2)
#define COMPONENT_HOUR_LABEL_WIDTH 25.0f
#define COMPONENT_HOUR_LABEL_X (COMPONENT_HOUR_X + COMPONENT_HOUR_WIDTH - COMPONENT_HOUR_LABEL_WIDTH - COMPONENT_LABEL_OFFSET)

#define COMPONENT_MIN 1
#define COMPONENT_MIN_TAG 102
#define COMPONENT_MIN_WIDTH 110.0f
#define COMPONENT_MIN_X (COMPONENT_HOUR_X + COMPONENT_HOUR_WIDTH)
#define COMPONENT_MIN_LABEL_WIDTH 50.0f
#define COMPONENT_MIN_LABEL_X (COMPONENT_MIN_X + COMPONENT_MIN_WIDTH - COMPONENT_MIN_LABEL_WIDTH - COMPONENT_LABEL_OFFSET)


@interface DurationPickerController ()
// private methods
- (UIView *)rowViewForComponent:(NSInteger)component;
@end

@implementation DurationPickerController

- (void)loadView
{
    UIView *mainView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    mainView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    _tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds] style:UITableViewStyleGrouped];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    
    [mainView addSubview:_tableView];
    
    // Visually hide down below screen bounds
    _pickerWrap = [[UIView alloc] initWithFrame:CGRectMake(0.0f, [[UIScreen mainScreen] bounds].size.height, 320.0f, 216.0f)];
    
    _pickerView = [[UIPickerView alloc] init];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    _pickerView.showsSelectionIndicator = YES;
    _pickerView.hidden = NO;
    
    UILabel *hourLabel = [[UILabel alloc] initWithFrame:CGRectMake(COMPONENT_HOUR_LABEL_X, COMPONENT_LABEL_Y, COMPONENT_HOUR_LABEL_WIDTH, COMPONENT_LABEL_HEIGHT)];
    hourLabel.text = @"h";
    hourLabel.textAlignment = UITextAlignmentRight;
    hourLabel.font = [UIFont systemFontOfSize:24.0f];
    hourLabel.backgroundColor = [UIColor clearColor];
    hourLabel.userInteractionEnabled = NO;

    UILabel *minLabel = [[UILabel alloc] initWithFrame:CGRectMake(COMPONENT_MIN_LABEL_X, COMPONENT_LABEL_Y, COMPONENT_MIN_LABEL_WIDTH, COMPONENT_LABEL_HEIGHT)];
    minLabel.text = @"min";
    minLabel.textAlignment = UITextAlignmentRight;
    minLabel.font = [UIFont systemFontOfSize:24.0f];
    minLabel.backgroundColor = [UIColor clearColor];
    minLabel.userInteractionEnabled = NO;
    
    // TODO refactor label creation

    [_pickerWrap addSubview:_pickerView];
    [_pickerWrap addSubview:hourLabel];
    [_pickerWrap addSubview:minLabel];
    
    
    [mainView addSubview:_pickerWrap];
    self.view = mainView;

    [hourLabel release];
    [minLabel release];
    
    [mainView release];
}

- (void)dealloc
{
    [_tableView setDelegate:nil];
    [_tableView setDataSource:nil];
    [_tableView release];
    
    [_pickerView setDelegate:nil];
    [_pickerView setDataSource:nil];
    [_pickerView release];
    
    [_pickerWrap release];
    
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
    _pickerWrap.frame = CGRectMake(0.0f, _pickerWrap.frame.origin.y - 216.0f - 64.0f, 320.0f, 216.0f);
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


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (component == COMPONENT_HOUR)
    {
        return COMPONENT_HOUR_WIDTH;
    }

    return COMPONENT_MIN_WIDTH;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == COMPONENT_HOUR)
    {
        return 25;
    }
    
    return 61;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UIView *rowView = nil;
    
    if ((view.tag == COMPONENT_HOUR_TAG) || (view.tag == COMPONENT_MIN_TAG))
    {
        rowView = view;
    }
    else
    {
        rowView = [self rowViewForComponent:component];
    }

    UILabel * theLabel = (UILabel *)[rowView viewWithTag:COMPONENT_SUBLABEL_TAG];
    theLabel.text = [NSString stringWithFormat:@"%d", row];
    
    return rowView;
}

- (UIView *)rowViewForComponent:(NSInteger)component
{
    UIView *rowView   = nil;
    UILabel *subLabel = nil;

    CGFloat width;
    CGRect frame;
    
    if (component == COMPONENT_HOUR)
    {
        width = COMPONENT_HOUR_WIDTH;
        frame = CGRectMake(0, 0, width, 32.0f);
        
        rowView = [[[UIView alloc] initWithFrame:frame] autorelease];
        rowView.tag = COMPONENT_HOUR_TAG;
        
        // offset for sublabel
        frame.size.width = width - COMPONENT_HOUR_LABEL_WIDTH - COMPONENT_LABEL_OFFSET;
    }
    else
    {
        width = COMPONENT_MIN_WIDTH;
        frame = CGRectMake(0, 0, width, 32.0f);
        
        rowView = [[[UIView alloc] initWithFrame:frame] autorelease];
        rowView.tag = COMPONENT_MIN_TAG;
        
        // offset for sublabel
        frame.size.width = width - COMPONENT_MIN_LABEL_WIDTH - COMPONENT_LABEL_OFFSET;
    }
    
    subLabel = [[UILabel alloc] initWithFrame:frame];
    
    subLabel.textAlignment = UITextAlignmentRight;
    subLabel.backgroundColor = [UIColor clearColor];
    subLabel.font = [UIFont systemFontOfSize:24.0];
    subLabel.userInteractionEnabled = NO;
    subLabel.tag = COMPONENT_SUBLABEL_TAG;
    
    [rowView addSubview:subLabel];
    [subLabel release];
    
    return rowView;
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
