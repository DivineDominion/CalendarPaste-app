//
//  DurationSetViewController.m
//  ShiftCal
//
//  Created by Christian Tietze on 31.08.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "DurationPickerController.h"
#import "ShiftTemplateController.h"
#import "DateIntervalTranslator.h"

#define CELL_ID @"duration"
#define CELL_LABEL_TAG 104

#define PICKER_WIDTH (2 * COMPONENT_WIDTH)
#define PICKER_HEIGHT 216.0f
#define COMPONENT_WIDTH 148.0f
#define COMPONENT_LABEL_OFFSET 10.0f
#define COMPONENT_ROW_WIDTH 42.0f
#define COMPONENT_LABEL_Y 83.0f
#define COMPONENT_LABEL_HEIGHT 50.0f
#define COMPONENT_SUBLABEL_TAG 100

#define COMPONENT_HOUR 0
#define COMPONENT_HOUR_TAG 101
#define COMPONENT_HOUR_X (COMPONENT_WIDTH - COMPONENT_HOUR_LABEL_WIDTH - COMPONENT_LABEL_OFFSET - COMPONENT_ROW_WIDTH)
#define COMPONENT_HOUR_LABEL_TAG 103
#define COMPONENT_HOUR_LABEL_WIDTH 80.0f
#define COMPONENT_HOUR_LABEL_X (160.0f - COMPONENT_HOUR_LABEL_WIDTH - COMPONENT_LABEL_OFFSET)

#define COMPONENT_MIN 1
#define COMPONENT_MIN_TAG 102
#define COMPONENT_MIN_X (COMPONENT_WIDTH - COMPONENT_MIN_LABEL_WIDTH - COMPONENT_LABEL_OFFSET - COMPONENT_ROW_WIDTH)
#define COMPONENT_MIN_LABEL_TAG 104
#define COMPONENT_MIN_LABEL_WIDTH 76.0f
#define COMPONENT_MIN_LABEL_X (160.0f + 2 + COMPONENT_WIDTH - COMPONENT_MIN_LABEL_WIDTH - COMPONENT_LABEL_OFFSET)


@interface DurationPickerController ()
{
    UIPickerView *_pickerView;
    UIView *_pickerWrap;
    DateIntervalTranslator *_dateIntervalTranslator;
}

@property (nonatomic, retain) DateIntervalTranslator *timeTranslator;

+ (UILabel *)createLabelForComponet:(NSInteger)component;

- (UIView *)rowViewForComponent:(NSInteger)component;
- (void)updateCellForHoursAndMinutes;
- (NSString *)textForUserSelection;
@end

@implementation DurationPickerController

@synthesize hours    = _hours;
@synthesize minutes  = _minutes;
@synthesize delegate = _delegate;
@synthesize timeTranslator = _dateIntervalTranslator;

- (id)init
{
    return [self initWithHours:0 andMinutes:0];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self initWithHours:0 andMinutes:0 withStyle:style];
}

- (id)initWithHours:(NSInteger)hours andMinutes:(NSInteger)minutes
{
    return [self initWithHours:hours andMinutes:minutes withStyle:UITableViewStyleGrouped];
}

- (id)initWithHours:(NSInteger)hours andMinutes:(NSInteger)minutes withStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    
    if (self)
    {
        self.hours = hours;
        self.minutes = minutes;
        
        self.timeTranslator = [[[DateIntervalTranslator alloc] init] autorelease];
    }
    
    return self;
}

- (void)loadView
{
    [super loadView];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    float screenWidth   = screenBounds.size.width;
    float screenHeight  = screenBounds.size.height;
    
    // top margin:  67px = 1/2 200px (visible content height) - 1/2 46px (cell height) - 10px table margin
    float topMargin = 67.0f;
    if (screenHeight == 568.0f)
    {
        topMargin += 44.0f; // iPhone 4-inch
    }
    
    CGRect tableHeaderFrame = CGRectMake(0.0f, 0.0f, screenWidth, topMargin);
    
    self.tableView.autoresizingMask =  UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.tableHeaderView  = [[[UIView alloc] initWithFrame:tableHeaderFrame] autorelease];
    self.tableView.scrollEnabled    = NO;
    
    // Visually hide down below screen bounds
    _pickerWrap = [[UIView alloc] initWithFrame:CGRectMake(0.0f, screenHeight, screenWidth, PICKER_HEIGHT)];
    
    _pickerView = [[UIPickerView alloc] init];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    _pickerView.showsSelectionIndicator = YES;
    _pickerView.hidden = NO;
    
    UILabel *hourLabel = [self.class createLabelForComponet:COMPONENT_HOUR];
    UILabel *minLabel  = [self.class createLabelForComponet:COMPONENT_MIN];

    [_pickerWrap addSubview:_pickerView];
    [_pickerWrap addSubview:hourLabel];
    [_pickerWrap addSubview:minLabel];
    
    
    [self.tableView addSubview:_pickerWrap];
}

+ (UILabel *)createLabelForComponet:(NSInteger)component
{
    UILabel *theLabel = nil;
    CGRect labelFrame;
    NSString *labelText = nil;
    NSInteger labelTag = 0;
    
    if (component == COMPONENT_HOUR)
    {
        labelFrame = CGRectMake(COMPONENT_HOUR_LABEL_X, COMPONENT_LABEL_Y+2, COMPONENT_HOUR_LABEL_WIDTH, COMPONENT_LABEL_HEIGHT);
        labelText  = @"hours";
        labelTag   = COMPONENT_HOUR_LABEL_TAG;
    }
    else // assuming: component == COMPONENT_MIN
    {
        labelFrame = CGRectMake(COMPONENT_MIN_LABEL_X, COMPONENT_LABEL_Y+2, COMPONENT_MIN_LABEL_WIDTH, COMPONENT_LABEL_HEIGHT);
        labelText  = @"mins";
        labelTag   = COMPONENT_MIN_LABEL_TAG;
    }
    
    theLabel = [[UILabel alloc] initWithFrame:labelFrame];
    theLabel.tag = labelTag;
    theLabel.text = labelText;
    theLabel.textAlignment = UITextAlignmentLeft;
    theLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    theLabel.textColor = [UIColor colorWithWhite:0.25 alpha:1.0];
    theLabel.shadowColor = [UIColor colorWithWhite:0.8 alpha:0.8];
    theLabel.shadowOffset = CGSizeMake(0, 1.0f);
    theLabel.backgroundColor = [UIColor clearColor];
    theLabel.userInteractionEnabled = NO;

    return [theLabel autorelease];
}

- (void)dealloc
{    
    [_pickerView setDelegate:nil];
    [_pickerView setDataSource:nil];
    [_pickerView release];
    
    [_pickerWrap release];
    [_dateIntervalTranslator release];
    
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
    
    self.title = @"Duration";
}

- (void)viewDidAppear:(BOOL)animated
{
    CGRect frame = _pickerWrap.frame;
    frame.origin.y = frame.origin.y - PICKER_HEIGHT - 64.0f; // Navbar + status bar height: 64px
    
    [UIView animateWithDuration:0.3 animations:^{
        _pickerWrap.frame = frame;
    }];
    
    [_pickerView selectRow:self.hours   inComponent:COMPONENT_HOUR animated:NO];
    [_pickerView selectRow:self.minutes inComponent:COMPONENT_MIN  animated:NO];
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CELL_ID] autorelease];
        
        cell.textLabel.text = @"Duration";
        cell.detailTextLabel.text = [self textForUserSelection];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (NSString *)textForUserSelection
{
    return [self.timeTranslator humanReadableFormOfHours:self.hours minutes:self.minutes];
}

- (void)updateCellForHoursAndMinutes
{
    UITableViewCell *cell  = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.detailTextLabel.text = [self textForUserSelection];
}

#pragma mark - PickerView
#pragma mark PickerView delegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.hours   = [pickerView selectedRowInComponent:COMPONENT_HOUR];
    self.minutes = [pickerView selectedRowInComponent:COMPONENT_MIN];
    
    // Don't allow both 0h and 0min -- select '1' for the opposite component
    if (self.hours == 0 && self.minutes == 0)
    {
        if (component == COMPONENT_HOUR)
        {
            self.minutes = 1;
            [_pickerView selectRow:self.minutes inComponent:COMPONENT_MIN animated:YES];
        }
        else if (component == COMPONENT_MIN)
        {
            self.hours = 1;
            [_pickerView selectRow:self.hours inComponent:COMPONENT_HOUR animated:YES];
        }
        
    }
    
    // Update view
    [self updateCellForHoursAndMinutes];
}

#pragma mark PickerView data source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return COMPONENT_WIDTH;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == COMPONENT_HOUR)
    {
        return 24;
    }
    
    return 60;
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

    // rows display just their own count
    NSString *theText = [NSString stringWithFormat:@"%d", row];
    
    UILabel * theLabel = (UILabel *)[rowView viewWithTag:COMPONENT_SUBLABEL_TAG];
    theLabel.text = theText;
    
    return rowView;
}

- (UIView *)rowViewForComponent:(NSInteger)component
{
    UIView *rowView   = nil;
    UILabel *subLabel = nil;

    CGRect frame;
    
    if (component == COMPONENT_HOUR)
    {
        frame = CGRectMake(0, 0, COMPONENT_WIDTH, 32.0f);
        
        rowView = [[[UIView alloc] initWithFrame:frame] autorelease];
        rowView.tag = COMPONENT_HOUR_TAG;
        
        // offset for sublabel
        frame.origin.x = COMPONENT_HOUR_X;
    }
    else
    {
        frame = CGRectMake(0, 0, COMPONENT_WIDTH, 32.0f);
        
        rowView = [[[UIView alloc] initWithFrame:frame] autorelease];
        rowView.tag = COMPONENT_MIN_TAG;
        
        // offset for sublabel
        frame.origin.x = COMPONENT_MIN_X;
    }
    
    frame.size.width = COMPONENT_ROW_WIDTH;
    
    subLabel = [[UILabel alloc] initWithFrame:frame];
    
    subLabel.textAlignment = UITextAlignmentRight;
    subLabel.backgroundColor = [UIColor clearColor];
    subLabel.font = [UIFont boldSystemFontOfSize:24.0];
    subLabel.userInteractionEnabled = NO;
    subLabel.tag = COMPONENT_SUBLABEL_TAG;
    
    [rowView addSubview:subLabel];
    [subLabel release];
    
    return rowView;
}

#pragma mark - Save and Cancel

- (void)save:(id)sender
{
    [self.delegate durationPicker:self didSelectHours:self.hours andMinutes:self.minutes];
}

- (void)cancel:(id)sender
{
    [self.delegate durationPicker:self didSelectHours:0 andMinutes:0];
}

@end
