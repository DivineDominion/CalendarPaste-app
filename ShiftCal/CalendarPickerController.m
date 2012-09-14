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

#define CELL_ID @"calendarcell"

#pragma mark - Custom Table Cell: prevents auto layout and uses custom checkmarks

@interface CTCalendarCell : UITableViewCell
{
    // private instance variables
    BOOL _checked;
}

// private properties
@property (nonatomic, assign, getter = isChecked) BOOL checked;
@end

@implementation CTCalendarCell

@synthesize checked = _checked;

- (id)init
{
    return [self initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CELL_ID];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [self init];
    self.frame = frame;
    
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.userInteractionEnabled = NO; // Prevents selection
    self.accessoryView = button;
    
    self.layer.masksToBounds = YES;
    self.detailTextLabel.textAlignment = UITextAlignmentRight;
    
    return self;
}

- (void)setChecked:(BOOL)checked
{
    if (checked != _checked)
    {
        _checked = checked;
        
        UIImage *imageNormal    = nil;
        UIImage *imageHighlight = nil;
        UIButton *button = (UIButton *)self.accessoryView;
        
        if (checked == YES)
        {
            imageNormal    = [UIImage imageNamed:@"UIPreferencesBlueCheck.png"];
            imageHighlight = [UIImage imageNamed:@"UIPreferencesWhiteCheck.png"];
        }
        
        [button setBackgroundImage:imageNormal forState:UIControlStateNormal];
        [button setBackgroundImage:imageHighlight forState:UIControlStateHighlighted];
    }
}

- (void)layoutSubviews {
    static double kCellVisualHeight = CELL_HEIGHT - 1.0f;
    static double kCheckmarkSize    = 14.0f;
    static double kCheckmarkX       = CELL_WIDTH - 14.0f; // - kCheckmarkSize
    static double kMargin           = 10.0f;
    
    [super layoutSubviews];
    
    // TODO replace with @"default" simulated width when drawn
    CGRect textFrame = CGRectMake(10.0f, 0.0f, LABEL_TEXT_WIDTH, kCellVisualHeight);
    
    if (![self.detailTextLabel.text isEqualToString:@" "])
    {
        textFrame.size.width = textFrame.size.width - LABEL_DETAIL_WIDTH - kMargin;
    }
    
    self.textLabel.frame = textFrame;
    self.detailTextLabel.frame = CGRectMake(kCheckmarkX - LABEL_DETAIL_WIDTH - 2 * kMargin, 0.0f, LABEL_DETAIL_WIDTH, kCellVisualHeight);
    
    self.accessoryView.frame = CGRectMake(kCheckmarkX, 15.0f, kCheckmarkSize, kCheckmarkSize);
}
@end

#pragma mark CalendarPickerController
@interface CalendarPickerController ()
{
    NSIndexPath *_defaultCellIndexPath;
    NSIndexPath *_selectedCellIndexPath;
    
    EKEventStore *_eventStore;
}

// private properties
@property (nonatomic, retain) NSIndexPath *defaultCellIndexPath;
@property (nonatomic, retain) NSIndexPath *selectedCellIndexPath;
@property (nonatomic, retain) EKEventStore *eventStore;

// private methods
- (UIImage *)actionPanelBackground;
- (UIView *)actionPanelForIndexPath:(NSIndexPath *)indexPath andTableView:(UITableView *)tableView;
- (EKCalendar *)calendarForIndexPath:(NSIndexPath *)indexPath;
- (NSString *)defaultTextForCellAt:(NSIndexPath *)indexPath;

- (void)animateActionPanelHeight:(NSInteger)height forIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView;
- (void)showActionPanelForIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView;
- (void)hideActionPanelForIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView;
- (void)makeDefault:(id)sender;
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
        
        // Read user defaults
        NSUserDefaults *prefs       = [NSUserDefaults standardUserDefaults];
        NSString *defaultIdentifier = [prefs objectForKey:PREFS_DEFAULT_CALENDAR_KEY];
        EKCalendar *defaultCalendar = [self.eventStore calendarWithIdentifier:defaultIdentifier];
        NSInteger defaultIndex      = [self.eventStore.calendars indexOfObject:defaultCalendar];

        self.defaultCellIndexPath = [NSIndexPath indexPathForRow:defaultIndex inSection:0];

        // Fallback to first row
        NSIndexPath *selectionPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
        if (calendar)
        {
            NSInteger index = [self.eventStore.calendars indexOfObject:calendar];
            selectionPath = [NSIndexPath indexPathForRow:index inSection:0];
        }
                
        self.selectedCellIndexPath = selectionPath;
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
    
    self.title = @"Duration";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static double kDoubleHeight = 2 * CELL_HEIGHT;
    
    if ([indexPath isEqual:self.selectedCellIndexPath] && ![indexPath isEqual:self.defaultCellIndexPath])
    {
        return kDoubleHeight;
    }
    
    return CELL_HEIGHT;
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
    UIImage *backgroundImage = nil;
    
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor grayColor] CGColor]);
    CGContextFillRect(context, rect);
    
    backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return backgroundImage;
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

- (EKCalendar *)calendarForIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    EKCalendar *calendar = [self.eventStore.calendars objectAtIndex:row];
    
    return calendar;
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
    CTCalendarCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID];
    
    if (!cell)
    {
        cell = [[[CTCalendarCell alloc] init] autorelease];
    }
    
    EKCalendar *calendar = [self calendarForIndexPath:indexPath];
    cell.textLabel.text = calendar.title;
    cell.detailTextLabel.text = [self defaultTextForCellAt:indexPath];
    
    if ([indexPath isEqual:self.selectedCellIndexPath])
    {
        cell.checked = YES;
    }
    
    UIView *actionPanelView = [self actionPanelForIndexPath:indexPath andTableView:tableView];
    [cell.contentView addSubview:actionPanelView];
    
    return cell;
}

#pragma mark Table view & subview delegate

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
    CTCalendarCell *oldCell = (CTCalendarCell *)[tableView cellForRowAtIndexPath:self.selectedCellIndexPath];
    CTCalendarCell *newCell = (CTCalendarCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    [tableView beginUpdates];
    oldCell.checked = NO;
    newCell.checked = YES;
    
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
        NSIndexPath *oldIndexPath = [[self.defaultCellIndexPath copy] autorelease];
        
        // Hide "make default" panel for selected cell
        [self hideActionPanelForIndexPath:indexPath inTableView:self.tableView];
        
        
        // Update "default" labels
        UITableViewCell *newCell = [self.tableView cellForRowAtIndexPath:indexPath];
        UITableViewCell *oldCell = [self.tableView cellForRowAtIndexPath:oldIndexPath];
        
        [self.tableView beginUpdates];
        self.defaultCellIndexPath = indexPath;
        
        oldCell.detailTextLabel.text = [self defaultTextForCellAt:oldIndexPath];
        newCell.detailTextLabel.text = [self defaultTextForCellAt:indexPath];
        [self.tableView endUpdates];

        
        // Store in preferences
        NSUserDefaults *prefs        = [NSUserDefaults standardUserDefaults];
        EKCalendar *calendar         = [self calendarForIndexPath:self.defaultCellIndexPath];
        NSString *calendarIdentifier = calendar.calendarIdentifier;
        
        [prefs setObject:calendarIdentifier forKey:PREFS_DEFAULT_CALENDAR_KEY];
    }
}

#pragma mark - Save and Cancel

- (void)save:(id)sender
{
    EKCalendar *selectedCalendar = [self calendarForIndexPath:self.selectedCellIndexPath];
    
    [self.delegate calendarPicker:self didSelectCalendar:selectedCalendar];
}

- (void)cancel:(id)sender
{
    [self.delegate calendarPicker:self didSelectCalendar:nil];
}

@end
