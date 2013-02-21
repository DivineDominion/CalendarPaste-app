//
//  ShiftOverviewController.m
//  ShiftCal
//
//  Created by Christian Tietze on 26.07.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ShiftOverviewController.h"

#import "EventStoreConstants.h"

#import "ShiftModificationViewController.h"
#import "ShiftModificationDelegate.h"
#import "ShiftOverviewCell.h"

#import "ShiftAssignmentViewController.h"

#import "ShiftTemplateCollection.h"
#import "ShiftTemplate.h"

#import "LayoutHelper.h"

@interface ModificationCommand : NSObject <ShiftModificationDelegate>
{
    ShiftOverviewController *_target;
    NSDictionary *_shiftAttributes;
}

@property (nonatomic, weak) ShiftOverviewController *target;
@property (nonatomic, retain) NSDictionary *shiftAttributes;

- (id)initWithTarget:(ShiftOverviewController *)target;
- (void)execute;
@end


@implementation ModificationCommand

@synthesize shiftAttributes = _shiftAttributes;
@synthesize target = _target;

- (id)initWithTarget:(ShiftOverviewController *)target;
{
    self = [super init];
    
    if (self)
    {
        self.target = target;
    }
    
    return self;
}

- (void)dealloc
{
    [_shiftAttributes release];
    
    [super dealloc];
}

- (void)shiftModificationViewController:(ShiftModificationViewController *)shiftAddViewController modifiedShiftAttributes:(NSDictionary *)shiftAttributes
{
    [self.target dismissViewControllerAnimated:YES completion:nil]; // TODO refactor high coupling
    
    if (shiftAttributes)
    {
        self.shiftAttributes = [[shiftAttributes copy] autorelease];
        [self execute];
    }
}

- (void)execute
{
    // Do nothing;  override in implementation
}
@end

@interface EditCommand : ModificationCommand
{
    NSUInteger _row;
}

@property (nonatomic, assign) NSUInteger row;

-(id)initWithTarget:(ShiftOverviewController *)target forRow:(NSUInteger)row;
@end

@implementation EditCommand
@synthesize row = _row;

- (id)initWithTarget:(ShiftOverviewController *)target forRow:(NSUInteger)row
{
    self = [super initWithTarget:target];
    
    if (self)
    {
        self.row = row;
    }
    
    return self;
}

- (void)execute
{
    [self.target updateShiftAtRow:self.row withAttributes:self.shiftAttributes];
    [self.target modificationCommandFinished:self];
}
@end

@interface AddCommand : ModificationCommand
@end

@implementation AddCommand
- (void)execute
{
    [self.target addShiftWithAttributes:self.shiftAttributes];
    [self.target modificationCommandFinished:self];
}
@end

#pragma mark - ShiftOverviewController

#define TAG_EMPTY_LIST_VIEW 101

@interface ShiftOverviewController ()
{
    // private instance variables
    ModificationCommand *_modificationCommand;
    ShiftTemplateCollection *_shiftCollection;
    ShiftTemplateController *_shiftTemplateController;
    NSUInteger _longHoursCount;
}

// private properties
@property (nonatomic, retain) ModificationCommand *modificationCommand;
@property (nonatomic, retain) ShiftTemplateCollection *shiftCollection;
@property (nonatomic, retain) ShiftTemplateController *shiftTemplateController;
@property (nonatomic, assign) NSUInteger longHoursCount;

// private methods
- (void)addAction:(id)sender;
- (void)showHud;
- (void)invalidateCalendars:(NSNotification *)notification;

- (void)hideEmptyListView;
- (UIView *)emptyListView;
- (void)coverTable;
- (void)fadeInCoverTable;
@end

@implementation ShiftOverviewController
@synthesize modificationCommand = _modificationCommand;
@synthesize shiftCollection = _shiftCollection;
@synthesize shiftTemplateController = _shiftTemplateController;
@synthesize longHoursCount = _longHoursCount;

- (id)init
{
    return [self initWithStyle:UITableViewStylePlain];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    
    if (self)
    {
        NSUserDefaults *prefs               = [NSUserDefaults standardUserDefaults];
        NSString *defaultCalendarIdentifier = [prefs objectForKey:PREFS_DEFAULT_CALENDAR_KEY];

        self.shiftTemplateController = [[[ShiftTemplateController alloc] init] autorelease];
        self.shiftCollection = [[[ShiftTemplateCollection alloc] initWithFallbackCalendarIdentifier:defaultCalendarIdentifier shiftTemplateController:self.shiftTemplateController] autorelease];
        
        // Count hour values with 2 digits
        self.longHoursCount = 0;
        
        [self.shiftCollection.shifts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ShiftTemplate *shift = obj;
            if ([shift.durHours integerValue] >= 10)
            {
                self.longHoursCount++;
            }
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(invalidateCalendars:)
                                                     name:SCStoreChangedNotification
                                                   object:[[UIApplication sharedApplication] delegate]];
    }
    
    return self;
}

- (void)invalidateCalendars:(NSNotification *)notification
{
    NSString *defaultCalendarIdentifer = [notification.userInfo objectForKey:NOTIFICATION_DEFAULT_CALENDAR_KEY];
    
    [self.shiftCollection resetInvalidCalendarsTo:defaultCalendarIdentifer onChanges:^{
        [self.tableView reloadData];
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_modificationCommand release];
    [_shiftCollection release];
    [_shiftTemplateController release];
    
    [super dealloc];
}

- (void)setLongHoursCount:(NSUInteger)countLongHours
{
    // Update the labels on edge cases
    if (_longHoursCount == 0 && countLongHours > 0)
    {
        [ShiftOverviewCell enableLayoutTwoDigits];
        [self resizeCellLabels:SCCellLabelWidthWide];
    }
    else if (countLongHours == 0 && _longHoursCount > 0)
    {
        [ShiftOverviewCell disableLayoutTwoDigits];
        [self resizeCellLabels:SCCellLabelWidthSmall];
    }
    
    _longHoursCount = countLongHours;
}

- (void)resizeCellLabels:(SCCellLabelWidth)cellLabelWidth
{
    if (cellLabelWidth == SCCellLabelWidthSmall)
    {
        for (ShiftOverviewCell* cell in [self.tableView visibleCells])
        {
            [cell compactLabels];
        }
    }
    else if (cellLabelWidth == SCCellLabelWidthWide)
    {
        for (ShiftOverviewCell* cell in [self.tableView visibleCells])
        {
            [cell expandLabels];
        }
    }
}

- (UIView *)emptyListView
{
    UIView *view = [LayoutHelper emptyListViewWithTarget:self action:@selector(addAction:)];
    view.tag = TAG_EMPTY_LIST_VIEW;
    return view;
}

#pragma mark - View callbacks

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Navigation Bar:
    // ---------------------
    // [Edit]  TITLE     [+]
    // ---------------------
    
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                   target:self
                                                                                   action:@selector(addAction:)];
    self.navigationItem.leftBarButtonItem  = [self editButtonItem];
    self.navigationItem.rightBarButtonItem = addButtonItem;
    
    [addButtonItem release];
    
    self.title = @"Templates";
    
    self.tableView.allowsSelectionDuringEditing = YES;
    self.tableView.rowHeight = [ShiftOverviewCell cellHeight];
    
    if ([self.shiftCollection isEmpty])
    {
        [self coverTable];
    }
}

- (void)coverTable
{
    UIView *emptyListView = [self emptyListView];
    
    [self.view addSubview:emptyListView];
    emptyListView.layer.zPosition = 100;
    self.tableView.scrollEnabled = NO;
    
    // Disable "Edit" when devoid of items
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
    
    if ([self isEditing])
    {
        [self setEditing:NO];
    }
}

- (void)fadeInCoverTable
{
    [self coverTable];
    
    UIView *emptyListView = [self.view viewWithTag:TAG_EMPTY_LIST_VIEW];
    emptyListView.alpha = 0.0f;

    [UIView animateWithDuration:0.6f animations:^{
        emptyListView.alpha = 1.0f;
    } completion:nil];
}

#pragma mark - TableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.shiftCollection countOfShifts];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellIdentifier = @"shiftcell";
    
    ShiftOverviewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    NSInteger row = [indexPath row];
    
    if (!cell)
    {
        cell = [[[ShiftOverviewCell alloc] initAndReuseIdentifier:kCellIdentifier] autorelease];
    }
    
    ShiftTemplate *shift = [self.shiftCollection shiftAtIndex:row];
    cell.shift = shift;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSUInteger sourceRow      = [sourceIndexPath row];
    NSUInteger destinationRow = [destinationIndexPath row];
    
    [self.shiftCollection moveObjectFromIndex:sourceRow toIndex:destinationRow];
}

#pragma mark TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger row = [indexPath row];
    ShiftTemplate *shift = [self.shiftCollection shiftAtIndex:row];
    
    if (self.editing)
    {
        EditCommand *editCommand = [[EditCommand alloc] initWithTarget:self forRow:row];
        self.modificationCommand = editCommand;
        
        [self presentModificationViewControllerWithShift:shift];
        
        [editCommand release];
    }
    else
    {
        ShiftAssignmentViewController *assignController = [[ShiftAssignmentViewController alloc] initWithShift:shift shiftTemplateController:self.shiftTemplateController];
        
        assignController.delegate = self;
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:assignController];
        
        [self presentViewController:navigationController animated:YES completion:nil];
        
        [assignController release];
        [navigationController release];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];

    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self deleteShiftAtRow:row];
    }
}

#pragma mark - Presented Views

- (void)presentModificationViewController
{
    [self presentModificationViewControllerWithShift:nil];
}

- (void)presentModificationViewControllerWithShift:(ShiftTemplate *)shift
{
    ShiftModificationViewController *modificationController = [[ShiftModificationViewController alloc] initWithShift:shift];
        
    UINavigationController *modificationNavController = [[UINavigationController alloc] initWithRootViewController:modificationController];
    
    modificationController.modificationDelegate = self.modificationCommand;
    
    [[self navigationController] presentViewController:modificationNavController animated:YES completion:nil];
    
    [modificationController release];
    [modificationNavController release];
}

#pragma mark ShiftAssignmentViewController callbacks

- (void)shiftAssignmentViewController:(ShiftAssignmentViewController *)shiftAssignmentViewController didCompleteWithAction:(SCAssignmentViewAction)action
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (action == SCAssignmentViewActionSaved)
    {
        [self showHud];
    }
}

- (void)showHud
{
    // To center vertically, select navigationController.view instead of self.view
    UIView *parentView = self.navigationController.view;
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:parentView];
    [parentView addSubview:hud];
    
    hud.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hud-checkmark.png"]] autorelease];
    hud.mode       = MBProgressHUDModeCustomView;
    hud.delegate   = self;
    
    [hud show:YES];
    [hud hide:YES afterDelay:0.6];
}

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
    [hud release];
}

#pragma mark ShiftModificationController callbacks

- (void)modificationCommandFinished:(ModificationCommand *)modificationCommand
{
    if (modificationCommand == self.modificationCommand)
    {
        self.modificationCommand = nil;
    }
}

- (void)addShiftWithAttributes:(NSDictionary *)shiftAttributes
{
    // Hide "Empty List" view and enable previously disabled edit button
    [self hideEmptyListView];
    UIBarButtonItem *editButton = self.navigationItem.leftBarButtonItem;
    [editButton setEnabled:YES];
    
    // TODO refactor into notification
    NSInteger row = [self.shiftCollection addShiftWithAttributes:shiftAttributes];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    
    // Increment count afterwards to have the row added before, so
    // it's modified, too.
    if ([[shiftAttributes objectForKey:@"durHours"] integerValue] >= 10)
    {
        self.longHoursCount++;
    }
}

- (void)deleteShiftAtRow:(NSInteger)row
{
    if ([[self.shiftCollection shiftAtIndex:row].durHours integerValue] >= 10)
    {
        self.longHoursCount--;
    }
    
    [self.shiftCollection removeShiftAtIndex:row];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    
    if ([self.shiftCollection isEmpty])
    {
        [self fadeInCoverTable];
    }
}

- (void)hideEmptyListView
{
    UIView *emptyListView = [self.view viewWithTag:TAG_EMPTY_LIST_VIEW];
    [emptyListView removeFromSuperview];
    
    self.tableView.scrollEnabled = YES;
}

- (void)updateShiftAtRow:(NSInteger)row withAttributes:(NSDictionary *)shiftAttributes
{
    // Compute a `longHoursCount` difference before/after the update
    NSInteger longHoursCountDifference = 0;
    
    BOOL newCellHasTwoDigits = [[shiftAttributes objectForKey:@"durHours"] integerValue] >= 10;
    BOOL oldCellHasTwoDigits = [[self.shiftCollection shiftAtIndex:row].durHours integerValue] >= 10;
    BOOL bothCellsHaveSameDigitAmount = newCellHasTwoDigits == oldCellHasTwoDigits;
    
    if (!bothCellsHaveSameDigitAmount)
    {
        if (newCellHasTwoDigits)
        {
            longHoursCountDifference += 1;
        }
            
        if (oldCellHasTwoDigits)
        {
            longHoursCountDifference -= 1;
        }
    }
    
    // Update cell data
    [self.shiftCollection updateShiftAtIndex:row withAttributes:shiftAttributes];
    
    // Display new data
    NSIndexPath *indexPath  = [NSIndexPath indexPathForRow:row inSection:0];
    ShiftOverviewCell *cell = (ShiftOverviewCell *)[self.tableView cellForRowAtIndexPath:indexPath];

    cell.shift = [self.shiftCollection shiftAtIndex:row];
    
    [self calloutCell:indexPath];
    
    // Update Cell label's width
    self.longHoursCount += longHoursCountDifference;
}

#pragma mark - UI Actions

- (void)addAction:(id)sender
{
    AddCommand *addCommand = [[AddCommand alloc] initWithTarget:self];
    self.modificationCommand = addCommand;
    
    [self presentModificationViewController];
    
    [addCommand release];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    
    UIBarButtonItem *addButton = self.navigationItem.rightBarButtonItem;
    
    if (editing)
    {
        addButton.enabled = NO;
    }
    else
    {
        addButton.enabled = YES;
        
        [self.shiftCollection persistOrder];
    }
}

@end
