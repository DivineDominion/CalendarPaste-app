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

#define LABEL_TEXT_WIDTH 256.0f
#define LABEL_DETAIL_WIDTH 60.0f

#define CELL_WIDTH 300.0f
#define CELL_HEIGHT 44.0f

#define ACTION_PANEL_CORNER_RADIUS 8.0f
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
- (UIImage *)actionPanelBackground;
- (UIView *)actionPanelForIndexPath:(NSIndexPath *)indexPath andTableView:(UITableView *)tableView;
- (void)animateActionPanelHeight:(NSInteger)height forIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView;
- (void)showActionPanelForIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView;
- (void)hideActionPanelForIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView;
- (void)makeDefault:(id)sender;
@end


#pragma mark - Custom Table Cell to prevent auto layout

@interface UITableViewCellFixed : UITableViewCell
@end

@implementation UITableViewCellFixed
- (void)layoutSubviews {
    static double kCellVisualHeight = CELL_HEIGHT - 1.0f;
    static double kCheckmarkSize    = 14.0f;
    static double kMargin           = 10.0f;
    
    [super layoutSubviews];
    
    // TODO replace with @"default" simulated width when drawn
    CGRect textFrame = CGRectMake(10.0f, 0.0f, LABEL_TEXT_WIDTH, kCellVisualHeight);
    
    if (self.detailTextLabel.text != @" ")
    {
        textFrame.size.width = textFrame.size.width - LABEL_DETAIL_WIDTH - kMargin;
    }
    
    self.textLabel.frame = textFrame;
    self.detailTextLabel.frame = CGRectMake(CELL_WIDTH - LABEL_DETAIL_WIDTH - 2 * kMargin - kCheckmarkSize, 0.0f, LABEL_DETAIL_WIDTH, kCellVisualHeight);
    
    self.accessoryView.frame = CGRectMake(self.accessoryView.frame.origin.x, 15.0f, kCheckmarkSize, kCheckmarkSize);
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

- (UIImage *)actionPanelBackground
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor grayColor] CGColor]);
    //  [[UIColor colorWithRed:222./255 green:227./255 blue: 229./255 alpha:1] CGColor]) ;
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

- (UIView *)actionPanelForIndexPath:(NSIndexPath *)indexPath andTableView:(UITableView *)tableView
{
    NSInteger row     = [indexPath row];
    BOOL hideToolView = ![self.selectedCellIndexPath isEqual:indexPath] || [self.defaultCellIndexPath isEqual:indexPath];

    CGRect actionButtonFrame   = CGRectMake(0.0f, 0.0f, CELL_WIDTH, ACTION_PANEL_HEIGHT);
    CGRect actionPanelFrame    = actionButtonFrame;
    actionPanelFrame.origin.y  = CELL_HEIGHT;  // Top margin = cell height
    
    UIView *view           = [[UIView alloc] initWithFrame:actionPanelFrame];
    UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeCustom];

    // Setup wrapping view
    view.tag                 = TAG_ACTIONPANEL;
    view.layer.masksToBounds = YES;
    
    // Setup Action Panel
    actionButton.frame               = actionButtonFrame;
    actionButton.tag                 = row;
    actionButton.autoresizingMask    = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    actionButton.layer.masksToBounds = YES;
    
    UIImage *background = [[self actionPanelBackground] retain];
    [actionButton setBackgroundImage:background forState:UIControlStateNormal];
    [actionButton setBackgroundImage:background forState:UIControlStateSelected];
    [actionButton setBackgroundImage:background forState:UIControlStateSelected | UIControlStateHighlighted];
    [background release];
    
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
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.layer.masksToBounds = YES;
        cell.detailTextLabel.textAlignment = UITextAlignmentRight;
    }
    
    EKCalendar *calendar = [self.eventStore.calendars objectAtIndex:row];
    cell.textLabel.text = calendar.title;
    
    cell.detailTextLabel.text = [self defaultTextForCellAt:indexPath];
        
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(15.0, 15.0, 14.0, 14.0);
    button.frame = frame;
    
    if ([indexPath isEqual:self.selectedCellIndexPath])
    {
        UIImage *imageNormal = [UIImage imageNamed:@"UIPreferencesBlueCheck.png"];
        UIImage *imageHighlight = [UIImage imageNamed:@"UIPreferencesWhiteCheck.png"];
        [button setBackgroundImage:imageNormal forState:UIControlStateNormal];
        [button setBackgroundImage:imageHighlight forState:UIControlStateHighlighted];
    }
    
    cell.accessoryView = button;
    
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
    UIImage *imageNormal = [UIImage imageNamed:@"UIPreferencesBlueCheck.png"];
    UIImage *imageHighlight = [UIImage imageNamed:@"UIPreferencesWhiteCheck.png"];
    UIButton *button = (UIButton *)[tableView cellForRowAtIndexPath:self.selectedCellIndexPath].accessoryView;//Type = UITableViewCellAccessoryNone;
    [button setBackgroundImage:nil forState:UIControlStateNormal];
    [button setBackgroundImage:nil forState:UIControlStateHighlighted];
    
    //[tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    button = (UIButton *)[tableView cellForRowAtIndexPath:indexPath].accessoryView;
    [button setBackgroundImage:imageNormal forState:UIControlStateNormal];
    [button setBackgroundImage:imageHighlight forState:UIControlStateHighlighted];
    
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
        
        [oldDefaultIndexPath release];
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
