//
//  ShiftOverviewController.m
//  ShiftCal
//
//  Created by Christian Tietze on 26.07.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "ShiftOverviewController.h"

#import "ShiftModificationViewController.h"
#import "ShiftModificationDelegate.h"
#import "ShiftOverviewCell.h"

#import "ShiftAssignmentViewController.h"

#import "ShiftTemplateCollection.h"
#import "ShiftTemplate.h"

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

- (void)shiftModificationViewController:(ShiftModificationViewController *)shiftAddViewController modifiedShiftAttributes:(NSDictionary *)shiftAttributes
{
    [self.target dismissViewControllerAnimated:YES completion:nil]; // TODO refactor high coupling
    
    if (shiftAttributes)
    {
        self.shiftAttributes = shiftAttributes;
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
    [self.target replaceShiftAtRow:self.row withShiftWithAttributes:self.shiftAttributes];
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

@interface ShiftOverviewController ()
{
    // private instance variables
    ModificationCommand *_modificationCommand;
    ShiftTemplateCollection *_shiftCollection;
    NSUInteger _longHoursCount;
}

// private properties
@property (nonatomic, retain) ModificationCommand *modificationCommand;
@property (nonatomic, retain) ShiftTemplateCollection *shiftCollection;
@property (nonatomic, assign) NSUInteger longHoursCount;

// private methods
- (void)calloutCell:(NSIndexPath *)indexPath;
- (void)addAction:(id)sender;
- (void)showHud;
@end

@implementation ShiftOverviewController
@synthesize modificationCommand = _modificationCommand;
@synthesize shiftCollection = _shiftCollection;
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
        self.shiftCollection = [[[ShiftTemplateCollection alloc] init] autorelease];
        
        // Count hour values with 2 digits
        self.longHoursCount = 0;
        
        [self.shiftCollection.shifts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ShiftTemplate *shift = obj;
            if ([shift.durHours integerValue] >= 10)
            {
                self.longHoursCount++;
            }
        }];
    }
    
    return self;
}

- (void)dealloc
{
    [_modificationCommand release];
    [_shiftCollection release];
    
    [super dealloc];
}

- (void)setLongHoursCount:(NSUInteger)countLongHours
{
    // Update the labels on edge cases
    if (_longHoursCount == 0 && countLongHours > 0)
    {
        [ShiftOverviewCell enableLayoutTwoDigits];
        [self changeCellLabels:NO];
    }
    else if (countLongHours == 0 && _longHoursCount > 0)
    {
        [ShiftOverviewCell disableLayoutTwoDigits];
        [self changeCellLabels:YES];
    }
    
    _longHoursCount = countLongHours;
}

- (void)changeCellLabels:(BOOL)compact
{
    for (ShiftOverviewCell* cell in [self.tableView visibleCells])
    {
        if (compact)
        {
            [cell compactLabels];
        }
        else {
            [cell expandLabels];
        }
    }
}

#pragma mark - View callbacks

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

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
    
    self.title = @"Shifts";
    
    self.tableView.allowsSelectionDuringEditing = YES;
}


#pragma mark - TableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section != 0)
    {
        StupidError(@"only one section allowed:  section=%d", section);
    }
    
    return [self.shiftCollection countOfShifts];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ShiftOverviewCell cellHeight];
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
        ShiftAssignmentViewController *assignController = [[ShiftAssignmentViewController alloc] initWithShift:shift];
        
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
    ShiftModificationViewController *modificationController = [[ShiftModificationViewController alloc] initWithShift:shift];//shiftAttributes];
        
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
    [hud hide:YES afterDelay:0.4];
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
    if ([[shiftAttributes objectForKey:@"durHours"] integerValue] >= 10)
    {
        self.longHoursCount++;
    }
    
    // TODO refactor into notification
    NSInteger row = [self.shiftCollection addShiftWithAttributes:shiftAttributes];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
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
}

- (void)replaceShiftAtRow:(NSInteger)row withShiftWithAttributes:(NSDictionary *)shiftAttributes
{
    if ([[shiftAttributes objectForKey:@"durHours"] integerValue] >= 10)
    {
        self.longHoursCount++;
    }
    if ([[self.shiftCollection shiftAtIndex:row].durHours integerValue] >= 10)
    {
        self.longHoursCount--;
    }
    
    [self.shiftCollection replaceShiftAtIndex:row withShiftWithAttributes:shiftAttributes];

    // TODO refactor into notifications
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self calloutCell:indexPath];
}

- (void)calloutCell:(NSIndexPath *)indexPath
{
    ShiftOverviewController *__unsafe_unretained weakSelf = self;
    [UIView animateWithDuration:0.0
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^void() {
                         [[weakSelf.tableView cellForRowAtIndexPath:indexPath] setHighlighted:YES animated:YES];
                     }
                     completion:^(BOOL finished) {
                         [[weakSelf.tableView cellForRowAtIndexPath:indexPath] setHighlighted:NO animated:YES];
                     }];
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
