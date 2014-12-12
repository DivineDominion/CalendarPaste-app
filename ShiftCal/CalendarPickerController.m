//
//  CalendarPickerController.m
//  ShiftCal
//
//  Created by Christian Tietze on 04.09.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "CalendarPickerController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import "EventStoreConstants.h"

#define TAG_ACTIONPANEL 102

#define LABEL_TEXT_WIDTH 256.0f
#define LABEL_DETAIL_WIDTH 60.0f

#define CELL_WIDTH 320.0f
#define CELL_HEIGHT 44.0f

#define ACTION_PANEL_CORNER_RADIUS 8.0f
#define ACTION_PANEL_HEIGHT 43.0f


#pragma mark - Custom Table Cell: prevents auto layout and uses custom checkmarks

#define CELL_ID @"calendarcell"

@interface SCCalendarCell : UITableViewCell
@property (nonatomic, assign, getter = isChecked) BOOL checked;
@end

@implementation SCCalendarCell

- (instancetype)init
{
    return [self initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CELL_ID];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [self init];
    self.frame = frame;
    
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.userInteractionEnabled = NO; // Prevents selection
    [button setTintColor:[UIColor colorWithRed:0 green:0.5 blue:1.0 alpha:1.0]];
    self.accessoryView = button;
    
    self.layer.masksToBounds = YES;
    self.detailTextLabel.textAlignment = NSTextAlignmentRight;
    
    return self;
}

- (void)setChecked:(BOOL)checked
{
    if (checked != _checked)
    {
        _checked = checked;
        
        UIImage *imageNormal    = nil;
        UIButton *button = (UIButton *)self.accessoryView;
        
        if (checked == YES)
        {
            imageNormal = [[UIImage imageNamed:@"Checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        
        [button setBackgroundImage:imageNormal forState:UIControlStateNormal];
    }
}

- (void)layoutSubviews {
    static double kCellVisualHeight = CELL_HEIGHT - 1.0f;
    static double kCheckmarkSize    = 14.0f;
    static double kCheckmarkX       = CELL_WIDTH - 10.0f - 14.0f; // - kCheckmarkSize
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

@interface SCCellSelection : NSObject
@property (strong) NSIndexPath *indexPath;
@property (strong) NSString    *calendarIdentifier;
@end
@implementation SCCellSelection
@end

#pragma mark - CalendarPickerController
@interface CalendarPickerController ()
@property (nonatomic, strong) NSIndexPath *defaultCellIndexPath;
@property (nonatomic, strong) NSString *preselectedCalendarIdentifier;
@property (nonatomic, copy)   NSArray *calendars;

@property (nonatomic, strong, readonly) SCCellSelection *selectedCell;
@property (nonatomic, strong, readonly) NSIndexPath *selectedCellIndexPath;
@property (nonatomic, strong, readonly) NSString *selectedCellCalendarIdentifier;

// private methods
- (UIView *)actionPanelForIndexPath:(NSIndexPath *)indexPath andTableView:(UITableView *)tableView;
- (NSString *)defaultTextForCellAt:(NSIndexPath *)indexPath;

- (NSIndexPath *)indexPathForCalendarWithIdentifier:(NSString *)calendarIdentifier;
- (EKCalendar *)calendarForIndexPath:(NSIndexPath *)indexPath;

- (void)loadCalendars;
- (void)loadUserDefaultCellIndexPath;
- (void)invalidateCalendars:(NSNotification *)notification;
- (void)setSelectedCellForIndexPath:(NSIndexPath *)indexPath;

- (void)animateActionPanelHeight:(NSInteger)height forIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView;
- (void)showActionPanelForIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView;
- (void)hideActionPanelForIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView;
- (void)makeDefault:(id)sender;
@end

@implementation CalendarPickerController

- (instancetype)init
{
    return [self initWithStyle:UITableViewStyleGrouped];
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    return [self initWithSelectedCalendarIdentifier:nil withStyle:style];
}

- (instancetype)initWithSelectedCalendarIdentifier:(NSString *)calendarIdentifier
{
    return [self initWithSelectedCalendarIdentifier:calendarIdentifier withStyle:UITableViewStyleGrouped];
}

- (instancetype)initWithSelectedCalendarIdentifier:(NSString *)calendarIdentifier withStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    
    if (self)
    {
        [self loadCalendars];
        [self loadUserDefaultCellIndexPath];
        
        if (calendarIdentifier)
        {
            NSIndexPath *selectedIndexPath = [self indexPathForCalendarWithIdentifier:calendarIdentifier];
            [self setSelectedCellForIndexPath:selectedIndexPath];
            
            self.preselectedCalendarIdentifier = calendarIdentifier;
        }
        else
        {
            StupidError(@"calendarIdentifier required");
            self = nil;
            return nil;
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(invalidateCalendars:)
                                                     name:SCStoreChangedNotification
                                                   object:[[UIApplication sharedApplication] delegate]];
    }

    return self;
}

- (EKEventStore *)eventStore
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.eventStore;
}

- (NSString *)selectedCellCalendarIdentifier
{
    return self.selectedCell.calendarIdentifier;
}

- (NSIndexPath *)selectedCellIndexPath
{
    return self.selectedCell.indexPath;
}

- (void)setSelectedCellForIndexPath:(NSIndexPath *)indexPath
{
    if (_selectedCell.indexPath == indexPath)
    {
        return;
    }
    
#warning TODO use value object instead
    _selectedCell.indexPath = indexPath;
    _selectedCell.calendarIdentifier = nil;
    
    if (indexPath != nil)
    {
        _selectedCell.calendarIdentifier  = [[self calendarForIndexPath:indexPath] calendarIdentifier];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    
    self.title = @"Calendar";
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
    return self.calendars.count;
}

- (UIView *)actionPanelForIndexPath:(NSIndexPath *)indexPath andTableView:(UITableView *)tableView
{
    NSInteger row     = [indexPath row];
    BOOL hideToolView = ![self.selectedCellIndexPath isEqual:indexPath] || [self.defaultCellIndexPath isEqual:indexPath];

    CGRect actionPanelFrame    = CGRectMake(0, CELL_HEIGHT, CELL_WIDTH, ACTION_PANEL_HEIGHT);
    CGRect actionButtonFrame   = actionPanelFrame;
    actionButtonFrame.origin.y  = 0;  // Top margin = cell height
    actionButtonFrame = CGRectInset(actionButtonFrame, 4.0f, 4.0f);
    
    UIView *view           = [[UIView alloc] initWithFrame:actionPanelFrame];
    UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeSystem];

    // Setup wrapping view
    view.tag                 = TAG_ACTIONPANEL;
    view.layer.masksToBounds = YES;
    
    // Setup Action Panel
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    UIColor *appColor = [appDelegate appColor];
    
    actionButton.frame               = actionButtonFrame;
    actionButton.tag                 = row;
    actionButton.autoresizingMask    = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    actionButton.layer.masksToBounds = YES;
    [actionButton setTitleColor:appColor forState:UIControlStateNormal];
    //actionButton.backgroundColor = [UIColor yellowColor];
    
    [actionButton setTitle:@"make default" forState:UIControlStateNormal];
    
    [actionButton addTarget:self action:@selector(makeDefault:) forControlEvents:UIControlEventTouchDown];
    
    actionButton.layer.borderWidth = 2.0f;
    actionButton.layer.borderColor = appColor.CGColor;
    actionButton.layer.cornerRadius = 8;
    actionButton.layer.masksToBounds = YES;
    
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
    SCCalendarCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID];
    
    if (!cell)
    {
        cell = [[SCCalendarCell alloc] init];
    }
    
    EKCalendar *calendar = [self calendarForIndexPath:indexPath];
    cell.textLabel.text = calendar.title;
    cell.detailTextLabel.text = [self defaultTextForCellAt:indexPath];
    cell.checked = NO;
    
    if ([indexPath isEqual:self.selectedCellIndexPath])
    {
        cell.checked = YES;
    }
    
    UIView *actionPanelView = [self actionPanelForIndexPath:indexPath andTableView:tableView];
    [[cell.contentView viewWithTag:TAG_ACTIONPANEL] removeFromSuperview]; // Remove old one if there was any
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
    SCCalendarCell *oldCell = (SCCalendarCell *)[tableView cellForRowAtIndexPath:self.selectedCellIndexPath];
    SCCalendarCell *newCell = (SCCalendarCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    [tableView beginUpdates];
    oldCell.checked = NO;
    newCell.checked = YES;
    
    [self setSelectedCellForIndexPath:indexPath];
    [tableView endUpdates];
}

#pragma mark - (Default) calendar actions

- (void)makeDefault:(id)sender
{
    UIButton *actionButton = (UIButton *)sender;
    
    if (actionButton)
    {
        NSInteger row = actionButton.tag;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        NSIndexPath *oldIndexPath = [self.defaultCellIndexPath copy];
        
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
#ifdef DEVELOPMENT
        [prefs synchronize];
#endif
    }
}

- (void)invalidateCalendars:(NSNotification *)notification
{
    [self loadCalendars];
    [self loadUserDefaultCellIndexPath];
    
    // Update user selection
    NSString *oldId         = self.selectedCell.calendarIdentifier;
    EKCalendar *oldCalendar = [self.eventStore calendarWithIdentifier:oldId];
    
    NSIndexPath *newSelectedIndexPath = nil;
    BOOL didSelectNewPath = NO;
    
    if (oldCalendar != nil)
    {
        newSelectedIndexPath = [self indexPathForCalendarWithIdentifier:oldId];
    }
    else
    {
        EKCalendar *preselectedCalendar = [self.eventStore calendarWithIdentifier:self.preselectedCalendarIdentifier];
        didSelectNewPath = YES;
        
        // Fallback to preselection from `init`, if possible;  use default otherwise
        if (preselectedCalendar != nil)
        {
            newSelectedIndexPath = [self indexPathForCalendarWithIdentifier:self.preselectedCalendarIdentifier];
        }
        else
        {
            newSelectedIndexPath = self.defaultCellIndexPath;
        }
    }
    
    [self setSelectedCellForIndexPath:newSelectedIndexPath];
    [self.tableView reloadData];
    
    if (didSelectNewPath)
    {
        [self calloutCell:newSelectedIndexPath];
    }
}

- (void)loadCalendars
{
    NSMutableArray *mutableCalendars = nil;
    
    mutableCalendars = [[self.eventStore calendarsForEntityType:EKEntityTypeEvent] mutableCopy];
    
#ifndef DEVELOPMENT
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.allowsContentModifications == YES"];
    [mutableCalendars filterUsingPredicate:predicate];
#endif
    
    self.calendars = mutableCalendars;
}

- (void)loadUserDefaultCellIndexPath
{
    // Read user defaults
    NSUserDefaults *prefs       = [NSUserDefaults standardUserDefaults];
    NSString *defaultIdentifier = [prefs objectForKey:PREFS_DEFAULT_CALENDAR_KEY];
    EKCalendar *defaultCalendar = [self.eventStore calendarWithIdentifier:defaultIdentifier];
    NSInteger defaultIndex      = [self.calendars indexOfObject:defaultCalendar];
    
    self.defaultCellIndexPath = [NSIndexPath indexPathForRow:defaultIndex inSection:0];
}

- (EKCalendar *)calendarForIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    EKCalendar *calendar = self.calendars[row];
    
    return calendar;
}

- (NSIndexPath *)indexPathForCalendarWithIdentifier:(NSString *)calendarIdentifier
{
    NSIndexPath *selectionPath = nil;
    NSInteger index = [self.calendars indexOfObjectPassingTest:^BOOL(id obj, NSUInteger index, BOOL *stop) {
        EKCalendar *calendar = (EKCalendar *)obj;
        return [calendar.calendarIdentifier isEqualToString:calendarIdentifier];
    }];
    
    selectionPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    return selectionPath;
}

#pragma mark - Save and Cancel

- (void)save:(id)sender
{
    EKCalendar *selectedCalendar = [self calendarForIndexPath:self.selectedCellIndexPath];
    
    [self.delegate calendarPicker:self didSelectCalendarWithIdentifier:selectedCalendar.calendarIdentifier];
}

- (void)cancel:(id)sender
{
    [self.delegate calendarPicker:self didSelectCalendarWithIdentifier:nil];
}

@end
