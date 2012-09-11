//
//  CalendarPickerController.m
//  ShiftCal
//
//  Created by Christian Tietze on 04.09.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "CalendarPickerController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>

#define TAG_ACTIONPANEL 102

#define CELL_WIDTH 300.0f
#define CELL_HEIGHT 44.0f

#define ACTION_PANEL_CORNER_RADIUS 10.0f
#define ACTION_PANEL_HEIGHT 43.0f


@interface CalendarPickerController ()
{
    NSIndexPath *_defaultCellIndexPath;
    NSIndexPath *_selectedCellIndexPath;
}

// private properties
@property (nonatomic, retain) NSIndexPath *defaultCellIndexPath;
@property (nonatomic, retain) NSIndexPath *selectedCellIndexPath;

// private methods
- (UIView *)actionPanelForIndexPath:(NSIndexPath *)indexPath andTableView:(UITableView *)tableView;
- (void)animateActionPanelHeight:(NSInteger)height forIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView;
- (void)showActionPanelForIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView;
- (void)hideActionPanelForIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView;
- (void)makeDefault:(id)sender;
@end

@interface UITableViewCellFixed : UITableViewCell
@end
@implementation UITableViewCellFixed
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textLabel.frame = CGRectMake(10.0f, 0.0f, self.textLabel.frame.size.width, 43.0f);
    self.accessoryView.frame = CGRectMake(self.accessoryView.frame.origin.x, 0.0f,
                                          self.accessoryView.frame.size.width, 43.0f);
}
@end

@interface UIButtonTool : UIButton
@end
@implementation UIButtonTool
- (void)setHighlighted:(BOOL)highlighted
{
    return;
    //[super setHighlighted:bHighlighted];
    
    //if (bHighlighted) {
    //    [self.titleLabel setTextColor:[UIColor whiteColor]];
    //} else {
    //    [self.titleLabel setTextColor:[UIColor blackColor]];
    //}
    //[self.titleLabel setTextColor:[UIColor blackColor]];
}
@end

@implementation CalendarPickerController

@synthesize eventStore = _eventStore;
@synthesize defaultCellIndexPath = _defaultCellIndexPath;
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
        
        self.defaultCellIndexPath  = defaultPath;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:self.selectedCellIndexPath] && ![indexPath isEqual:self.defaultCellIndexPath])
    {
        return 88.0f;
    }
    
    return 44.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.eventStore.calendars.count;
}

- (UIView *)actionPanelForIndexPath:(NSIndexPath *)indexPath andTableView:(UITableView *)tableView
{
    NSInteger row     = [indexPath row];
    BOOL hideToolView = ![self.selectedCellIndexPath isEqual:indexPath] || [self.defaultCellIndexPath isEqual:indexPath];

    CGRect actionButtonFrame   = CGRectMake(0.0f, 0.0f, CELL_WIDTH, ACTION_PANEL_HEIGHT);
    CGRect actionPanelFrame    = actionButtonFrame;
    actionPanelFrame.origin.y  = CELL_HEIGHT;  // Top margin = cell height
    
    UIView *view           = [[UIView alloc] initWithFrame:actionPanelFrame];
    UIButton *actionButton = [UIButtonTool buttonWithType:UIButtonTypeCustom];

    // Setup wrapping view
    view.tag                 = TAG_ACTIONPANEL;
    view.layer.masksToBounds = YES;
    
    // Setup Action Panel
    actionButton.frame               = actionButtonFrame;
    actionButton.tag                 = row;
    actionButton.autoresizingMask    = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    actionButton.backgroundColor     = [UIColor grayColor];
    actionButton.layer.masksToBounds = YES;
    
    [actionButton setTitle:@"make default" forState:UIControlStateNormal];
    actionButton.titleLabel.font      = [UIFont boldSystemFontOfSize:actionButton.titleLabel.font.pointSize];
    actionButton.titleLabel.textColor = [UIColor whiteColor];
    
    [actionButton addTarget:self action:@selector(makeDefault:) forControlEvents:UIControlEventTouchDown];
    
    // Round bottom corners when in last cell's row
    if (row == [self numberOfSectionsInTableView:tableView])
    {
        CGRect frame              = actionButton.bounds;
        UIBezierPath *roundedPath = nil;
        CAShapeLayer *maskLayer   = [CAShapeLayer layer];
        
        maskLayer.frame = frame;
        
        roundedPath = [UIBezierPath bezierPathWithRoundedRect:maskLayer.bounds
                                            byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight
                                                  cornerRadii:CGSizeMake(ACTION_PANEL_CORNER_RADIUS, ACTION_PANEL_CORNER_RADIUS)];
        
        maskLayer.fillColor       = [[UIColor whiteColor] CGColor];
        maskLayer.backgroundColor = [[UIColor clearColor] CGColor];
        maskLayer.path            = [roundedPath CGPath];
        
        actionButton.layer.mask = maskLayer;
    }
    
    [view addSubview:actionButton];
    
    if (hideToolView)
    {
        CGRect frame = view.frame;
        frame.size.height = 0.0f;
        
        view.frame = frame;
    }
    
    return view;
}

- (NSString *)defaultTextForCellAt:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:self.defaultCellIndexPath])
    {
        return @"default";
    }
    
    // Not nil to prevent strange animation on updates
    return @" ";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSInteger row = [indexPath row];
    
    if (!cell)
    {
        cell = [[[UITableViewCellFixed alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        cell.layer.masksToBounds = YES;
    }
    
    EKCalendar *calendar = [self.eventStore.calendars objectAtIndex:row];
    cell.textLabel.text = calendar.title;
    
    cell.detailTextLabel.text = [self defaultTextForCellAt:indexPath];
        
    if ([indexPath isEqual:self.selectedCellIndexPath])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    UIView *actionPanelView = [self actionPanelForIndexPath:indexPath andTableView:tableView];
    [cell.contentView addSubview:actionPanelView];
    
    return cell;
}

#pragma mark Table view delegate

- (void)animateActionPanelHeight:(NSInteger)height forIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView
{
    UITableViewCell *cell   = [tableView cellForRowAtIndexPath:indexPath];
    UIView *actionPanelView = [cell.contentView viewWithTag:TAG_ACTIONPANEL];
    
    CGRect frame      = actionPanelView.frame;
    frame.size.height = height;
    
    [UIView animateWithDuration:0.3 animations:^{
        actionPanelView.frame = frame;
    }];
}

- (void)showActionPanelForIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView
{
    [self animateActionPanelHeight:ACTION_PANEL_HEIGHT forIndexPath:indexPath inTableView:tableView];
}

- (void)hideActionPanelForIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView
{
    [self animateActionPanelHeight:0 forIndexPath:indexPath inTableView:tableView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([indexPath isEqual:self.selectedCellIndexPath])
    {
        return;
    }
    
    // Animate action panels
    [self hideActionPanelForIndexPath:self.selectedCellIndexPath inTableView:tableView];
    
    if (![indexPath isEqual:self.defaultCellIndexPath])
    {
        [self showActionPanelForIndexPath:indexPath inTableView:tableView];
    }
        
    // Update accessory views
    [tableView beginUpdates];
    [tableView cellForRowAtIndexPath:self.selectedCellIndexPath].accessoryType = UITableViewCellAccessoryNone;
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        
    self.selectedCellIndexPath = indexPath;
    [tableView endUpdates];
}

#pragma mark - Default calendar actions

- (void)makeDefault:(id)sender
{
    UIButton *actionButton = (UIButton *)sender;
    if (actionButton)
    {
        NSInteger row = actionButton.tag;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        NSIndexPath *oldDefaultIndexPath = [self.defaultCellIndexPath copy];
        
        [self.tableView beginUpdates];
        self.defaultCellIndexPath = indexPath;
        
        [self.tableView cellForRowAtIndexPath:oldDefaultIndexPath].detailTextLabel.text = [self defaultTextForCellAt:oldDefaultIndexPath];
        [self.tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text = [self defaultTextForCellAt:indexPath];
        
        [self hideActionPanelForIndexPath:indexPath inTableView:self.tableView];
        [self.tableView endUpdates];
        // TODO store defaults permanently
    }
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
